import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/package:just_audio.dart';
import 'package:file_picker/package:file_picker.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';

class DurationRange {
  final Duration start;
  final Duration end;
  DurationRange(this.start, this.end);
}

class AudioManager extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<DurationRange> phrases = [];
  int currentIndex = 0;
  bool isRepeatMode = true;
  bool isPlaying = false;
  StreamSubscription? _positionSub;

  AudioManager() {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> pickAndLoadAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      await loadAudio(path);
    }
  }

  Future<void> loadAudio(String path) async {
    await _player.setFilePath(path);
    
    // In a real app, run FFmpeg to detect true silences:
    // await FFmpegKit.execute("-i $path -af silencedetect=noise=-30dB:d=0.5 -f null -");
    // Parse output into list...

    // Mocking silence detection to simulate the "WorkAudiobook" phrases behavior:
    phrases = [
      DurationRange(const Duration(seconds: 0), const Duration(seconds: 4)),
      DurationRange(const Duration(seconds: 5), const Duration(seconds: 10)),
      DurationRange(const Duration(seconds: 11), const Duration(seconds: 18)),
      DurationRange(const Duration(seconds: 19), const Duration(seconds: 25)),
    ];
    
    currentIndex = 0;
    notifyListeners();
    playPhrase(currentIndex);
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
          // Loop phrase
          _player.seek(phrases[currentIndex].start);
        } else {
          // The "Practice Pause" logic from WorkAudiobook
          await _player.pause();
          int phraseDuration = phrases[currentIndex].end.inMilliseconds - phrases[currentIndex].start.inMilliseconds;
          
          // Wait duration of the phrase before moving to next phrase automatically
          await Future.delayed(Duration(milliseconds: phraseDuration));
          
          if (currentIndex + 1 < phrases.length) {
            currentIndex++;
            notifyListeners();
            playPhrase(currentIndex);
          }
        }
      }
    });
    notifyListeners();
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

  @override
  void dispose() {
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
