import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

class DurationRange {
  final Duration start;
  final Duration end;
  final String? text; // For subtitles
  DurationRange(this.start, this.end, {this.text});
}

class AudioManager extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<DurationRange> phrases = [];
  int currentIndex = -1;
  bool isRepeatMode = true;
  bool isPlaying = false;
  bool isProcessing = false;
  double playbackSpeed = 1.0;
  String? errorMessage;
  
  StreamSubscription? _positionSub;

  AudioManager() {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        isPlaying = false;
      }
      notifyListeners();
    });

    _player.speedStream.listen((speed) {
      playbackSpeed = speed;
      notifyListeners();
    });
  }

  Future<void> pickAndLoadAudio() async {
    try {
      errorMessage = null;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await loadAudio(result.files.single.path!);
      }
    } catch (e) {
      _handleError("Failed to pick file: $e");
    }
  }

  Future<void> loadAudio(String path) async {
    isProcessing = true;
    phrases = [];
    currentIndex = -1;
    notifyListeners();

    try {
      // 1. Load into player
      await _player.setFilePath(path);

      // 2. Run Real Silence Detection via FFmpeg
      // We look for silences of at least 0.5s with -30dB threshold
      final session = await FFmpegKit.execute(
        "-i \"$path\" -af silencedetect=noise=-30dB:d=0.5 -f null -"
      );

      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        final logs = await session.getLogs();
        final fullLog = logs.map((l) => l.getMessage()).join("\n");
        _parseSilenceLogs(fullLog);
      } else {
        throw Exception("FFmpeg failed to analyze audio");
      }

      if (phrases.isEmpty) {
        // Fallback: entire file as one phrase
        final duration = _player.duration ?? Duration.zero;
        phrases.add(DurationRange(Duration.zero, duration));
      }

      currentIndex = 0;
      isProcessing = false;
      notifyListeners();
      playPhrase(0);

    } catch (e) {
      isProcessing = false;
      _handleError("Error loading audio: $e");
    }
  }

  void _parseSilenceLogs(String logs) {
    // FFmpeg output format: [silencedetect @ ...] silence_start: 1.23
    // [silencedetect @ ...] silence_end: 4.56 | silence_duration: 3.33
    final List<DurationRange> detected = [];
    double lastEnd = 0.0;

    final startMatches = RegExp(r"silence_start: ([\d.]+)").allMatches(logs);
    final endMatches = RegExp(r"silence_end: ([\d.]+)").allMatches(logs);

    final List<double> starts = startMatches.map((m) => double.parse(m.group(1)!)).toList();
    final List<double> ends = endMatches.map((m) => double.parse(m.group(1)!)).toList();

    for (int i = 0; i < starts.length; i++) {
        // A phrase is between the end of the previous silence and the start of the current silence
        if (starts[i] > lastEnd + 0.1) {
            detected.add(DurationRange(
                Duration(milliseconds: (lastEnd * 1000).toInt()),
                Duration(milliseconds: (starts[i] * 1000).toInt())
            ));
        }
        lastEnd = ends[i];
    }

    // Add the final segment
    final totalDuration = _player.duration?.inSeconds.toDouble() ?? lastEnd + 10;
    if (totalDuration > lastEnd + 0.1) {
        detected.add(DurationRange(
            Duration(milliseconds: (lastEnd * 1000).toInt()),
            Duration(milliseconds: (totalDuration * 1000).toInt())
        ));
    }

    phrases = detected;
  }

  Future<void> loadSubtitles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        _parseSRT(content);
      }
    } catch (e) {
      _handleError("Failed to load subtitles: $e");
    }
  }

  void _parseSRT(String content) {
    // Simple SRT parser
    final segments = content.split(RegExp(r'\n\s*\n'));
    final List<DurationRange> subs = [];

    for (var segment in segments) {
      final lines = segment.trim().split('\n');
      if (lines.length >= 3) {
        final timeLine = lines[1];
        final textLines = lines.sublist(2).join(" ");
        
        // Format: 00:00:01,600 --> 00:00:04,200
        final times = timeLine.split(" --> ");
        if (times.length == 2) {
            subs.add(DurationRange(
                _parseSrtTime(times[0]),
                _parseSrtTime(times[1]),
                text: textLines
            ));
        }
      }
    }
    
    if (subs.isNotEmpty) {
      phrases = subs;
      currentIndex = 0;
      notifyListeners();
    }
  }

  Duration _parseSrtTime(String timeStr) {
    // 00:00:01,600
    final parts = timeStr.trim().split(':');
    final secondsParts = parts[2].split(',');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1])
    );
  }

  void playPhrase(int index) {
    if (phrases.isEmpty || index < 0 || index >= phrases.length) return;
    
    currentIndex = index;
    _player.seek(phrases[index].start);
    _player.play();
    
    _positionSub?.cancel();
    _positionSub = _player.positionStream.listen((pos) async {
      if (pos >= phrases[currentIndex].end) {
        if (isRepeatMode) {
          _player.seek(phrases[currentIndex].start);
        } else {
          await _player.pause();
          // Auto-advance with pause logic
          int phraseDuration = phrases[currentIndex].end.inMilliseconds - phrases[currentIndex].start.inMilliseconds;
          await Future.delayed(Duration(milliseconds: phraseDuration));
          
          if (currentIndex + 1 < phrases.length) {
            playPhrase(currentIndex + 1);
          }
        }
      }
    });
    notifyListeners();
  }

  void setSpeed(double speed) {
    _player.setSpeed(speed);
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void seekRelative(Duration offset) {
    final currentPos = _player.position;
    _player.seek(currentPos + offset);
  }

  void toggleRepeatMode() {
    isRepeatMode = !isRepeatMode;
    notifyListeners();
  }

  void _handleError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
