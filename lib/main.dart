import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkAudiobook Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E3192)),
        useMaterial3: true,
      ),
      home: const AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();

    // Listen for errors and show SnackBar
    if (audioManager.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(audioManager.errorMessage!), backgroundColor: Colors.red),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkAudiobook Clone', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Audio File',
            onPressed: () => audioManager.pickAndLoadAudio(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Waveform View (Top 30%)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.waves, size: 64, color: Colors.blue.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'Waveform Visualizer',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 2. Subtitle / Phrase Display (Middle 40%)
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Phrases & Subtitles', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.subtitles, size: 16),
                            label: const Text('Load .SRT'),
                            onPressed: () => audioManager.loadSubtitles(),
                          )
                        ],
                      ),
                      const Divider(),
                      if (audioManager.phrases.isEmpty && !audioManager.isProcessing)
                        const Expanded(
                          child: Center(child: Text('Load an audio file to auto-detect phrases.')),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: audioManager.phrases.length,
                            itemBuilder: (context, index) {
                              final phrase = audioManager.phrases[index];
                              final isCurrent = index == audioManager.currentIndex;
                              return Card(
                                elevation: isCurrent ? 2 : 0,
                                color: isCurrent ? Colors.blue.shade50 : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isCurrent ? Colors.blue.shade200 : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isCurrent ? Colors.blue : Colors.grey.shade200,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCurrent ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  title: phrase.text != null 
                                      ? Text(phrase.text!, style: TextStyle(fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal))
                                      : Text('Phrase ${index + 1}', style: const TextStyle(color: Colors.black54)),
                                  subtitle: Text(
                                    '${phrase.start.inMinutes}:${(phrase.start.inSeconds % 60).toString().padLeft(2, '0')} - '
                                    '${phrase.end.inMinutes}:${(phrase.end.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: isCurrent ? const Icon(Icons.volume_up, color: Colors.blue) : null,
                                  onTap: () => audioManager.playPhrase(index),
                                ),
                              );
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ),
              
              // 3. Controls (Bottom 30%)
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Playback speed and practice mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<double>(
                              value: audioManager.playbackSpeed,
                              underline: const SizedBox(),
                              items: [0.5, 0.8, 1.0, 1.2, 1.5, 2.0].map((double val) {
                                return DropdownMenuItem<double>(
                                  value: val,
                                  child: Text('${val}x'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) audioManager.setSpeed(val);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Icon(audioManager.isRepeatMode ? Icons.loop : Icons.redo, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(audioManager.isRepeatMode ? 'Repeat Phrase' : 'Practice Mode', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 4),
                              Switch(
                                value: audioManager.isRepeatMode,
                                onChanged: (val) => audioManager.toggleRepeatMode(),
                                activeColor: Colors.blue,
                              ),
                            ],
                          )
                        ],
                      ),
                      
                      // Main Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 36,
                            onPressed: audioManager.currentIndex > 0 
                                ? () => audioManager.playPhrase(audioManager.currentIndex - 1) 
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.replay_5),
                            iconSize: 32,
                            onPressed: () => audioManager.seekRelative(const Duration(seconds: -5)),
                          ),
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: FloatingActionButton(
                              onPressed: () => audioManager.togglePlayPause(),
                              backgroundColor: Colors.blue,
                              elevation: 4,
                              shape: const CircleBorder(),
                              child: Icon(
                                audioManager.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, 
                                color: Colors.white, 
                                size: 48
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.forward_5),
                            iconSize: 32,
                            onPressed: () => audioManager.seekRelative(const Duration(seconds: 5)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 36,
                            onPressed: audioManager.currentIndex < audioManager.phrases.length - 1 
                                ? () => audioManager.playPhrase(audioManager.currentIndex + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          
          // Loading Overlay
          if (audioManager.isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing Audio Silences...', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('This may take a moment for large files', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
