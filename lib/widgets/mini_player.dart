/**
 * Mini Player Widget
 * 
 * Persistent bottom player that shows current song and basic controls.
 * Tapping it navigates to the full-screen player.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import '../pages/player_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final song = playerProvider.currentSong;
        
        // Don't show mini player if no song is playing
        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayerPage()),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                _buildThumbnail(song.thumbnail),
                
                const SizedBox(width: 12),
                
                // Song info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Play/Pause button
                IconButton(
                  icon: Icon(
                    playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () => playerProvider.togglePlayPause(),
                ),
                
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(String thumbnailUrl) {
    if (thumbnailUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        color: Colors.grey[800],
        child: const Icon(Icons.music_note, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.music_note, color: Colors.grey),
      ),
    );
  }
}
