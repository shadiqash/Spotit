import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';

class DesktopPlayer extends StatelessWidget {
  const DesktopPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final song = player.state.currentSong;
        
        if (song == null) return const SizedBox.shrink();
        
        return Container(
          height: 90,
          color: const Color(0xFF181818),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Left: Song Info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    if (song.thumbnail.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          song.thumbnail,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.grey[400],
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              // Center: Player Controls
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle),
                          color: Colors.grey[400],
                          iconSize: 20,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          color: Colors.grey[400],
                          onPressed: player.playPrevious,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              player.state.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                            ),
                            onPressed: player.togglePlay,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          color: Colors.grey[400],
                          onPressed: player.playNext,
                        ),
                        IconButton(
                          icon: const Icon(Icons.repeat),
                          color: Colors.grey[400],
                          iconSize: 20,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _formatDuration(player.state.position),
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.grey[800],
                              thumbColor: Colors.white,
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            ),
                            child: Slider(
                              value: player.state.position.inSeconds.toDouble(),
                              max: player.state.duration.inSeconds.toDouble() > 0 
                                  ? player.state.duration.inSeconds.toDouble() 
                                  : 1.0,
                              onChanged: (value) {
                                player.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(player.state.duration),
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Right: Volume & Extras
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lyrics_outlined),
                      color: Colors.grey[400],
                      iconSize: 20,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music),
                      color: Colors.grey[400],
                      iconSize: 20,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      color: Colors.grey[400],
                      iconSize: 20,
                      onPressed: () {},
                    ),
                    SizedBox(
                      width: 100,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.grey[800],
                          thumbColor: Colors.white,
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: 0.8,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
