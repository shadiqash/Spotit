/**
 * Player Page
 * 
 * Full-screen music player with album art, controls, and seek bar.
 * Shows current song info and allows downloading.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/player_controls.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!,
              Colors.green[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              final song = playerProvider.currentSong;
              
              if (song == null) {
                return const Center(
                  child: Text(
                    'No song playing',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              return Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'Now Playing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Album art
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: song.thumbnail.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: song.thumbnail,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Song info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          song.artist,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Seek bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: playerProvider.position.inMilliseconds.toDouble(),
                            max: playerProvider.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                            onChanged: (value) {
                              playerProvider.seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(playerProvider.position),
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              Text(
                                _formatDuration(playerProvider.duration),
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Player controls
                  PlayerControls(
                    isPlaying: playerProvider.isPlaying,
                    isLoading: playerProvider.state.isLoading,
                    onPlayPause: () => playerProvider.togglePlayPause(),
                    onPrevious: playerProvider.state.hasPrevious
                        ? () => playerProvider.playPrevious()
                        : null,
                    onNext: playerProvider.state.hasNext
                        ? () => playerProvider.playNext()
                        : null,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Download button
                  Consumer<LibraryProvider>(
                    builder: (context, libraryProvider, child) {
                      final isDownloaded = libraryProvider.isDownloaded(song.videoId);
                      final downloadProgress = libraryProvider.getDownloadProgress(song.videoId);
                      
                      if (downloadProgress != null) {
                        return Column(
                          children: [
                            CircularProgressIndicator(
                              value: downloadProgress,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Downloading... ${(downloadProgress * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }
                      
                      if (isDownloaded) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_done, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'Downloaded',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }
                      
                      return ElevatedButton.icon(
                        onPressed: () {
                          libraryProvider.downloadSong(song);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${song.title}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
