import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../pages/player_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;
        if (song == null) return const SizedBox();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const PlayerPage(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 60), // Floating above bottom nav
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF282828), // Spotify dark grey surface
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                        child: Image.network(
                          song.thumbnail,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Title & Artist
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
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          player.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (player.isPlaying) {
                            player.pause();
                          } else {
                            player.resume();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                
                // Progress Bar Overlay
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = player.duration;
                    double value = 0.0;
                    if (duration.inMilliseconds > 0) {
                      value = position.inMilliseconds / duration.inMilliseconds;
                      value = value.clamp(0.0, 1.0);
                    }
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white, // White progress bar like Spotify mini player
                        ),
                        minHeight: 2,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
