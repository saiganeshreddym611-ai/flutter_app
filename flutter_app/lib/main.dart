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
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
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
                      'Waveform UI Placeholder\n(Will render flutter_audio_waveforms)',
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
                        onPressed: () {},
                      )
                    ],
                  ),
                  const Divider(),
                  if (audioManager.phrases.isEmpty)
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
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCurrent ? Colors.blue : Colors.grey.shade200,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: isCurrent ? Colors.white : Colors.black87),
                                ),
                              ),
                              title: Text('Phrase ${index + 1}'),
                              subtitle: Text('${phrase.start.inSeconds}s - ${phrase.end.inSeconds}s'),
                              trailing: isCurrent ? const Icon(Icons.volume_up, color: Colors.blue) : null,
                              onTap: () => audioManager.playPhrase(index),
                              onLongPress: () {
                                // Show dictionary mock
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => Container(
                                    padding: const EdgeInsets.all(24),
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Dictionary Lookup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 12),
                                        Text('Definition mock functionality here...'),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                      DropdownButton<double>(
                        value: 1.0,
                        items: const [
                          DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                          DropdownMenuItem(value: 0.8, child: Text('0.8x')),
                          DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                          DropdownMenuItem(value: 1.2, child: Text('1.2x')),
                        ],
                        onChanged: (val) {
                          // Change speed
                        },
                      ),
                      Row(
                        children: [
                          const Icon(Icons.loop, size: 18),
                          const SizedBox(width: 8),
                          const Text('Repeat:'),
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
                        onPressed: () {
                          if (audioManager.currentIndex > 0) {
                            audioManager.playPhrase(audioManager.currentIndex - 1);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        iconSize: 32,
                        onPressed: () => audioManager.seekRelative(const Duration(seconds: -10)),
                      ),
                      FloatingActionButton(
                        onPressed: () => audioManager.togglePlayPause(),
                        backgroundColor: Colors.blue,
                        child: Icon(audioManager.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        iconSize: 32,
                        onPressed: () => audioManager.seekRelative(const Duration(seconds: 10)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 36,
                        onPressed: () {
                          if (audioManager.currentIndex < audioManager.phrases.length - 1) {
                            audioManager.playPhrase(audioManager.currentIndex + 1);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
