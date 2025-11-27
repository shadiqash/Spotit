import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import '../providers/player_provider.dart';
import '../services/download_service.dart';
import '../models/song.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  List<Color> _bgColors = [Colors.black, Colors.black];
  final DownloadService _downloadService = DownloadService();
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _updatePalette();
    _checkDownloadStatus();
  }

  @override
  void didUpdateWidget(PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePalette();
    _checkDownloadStatus();
  }

  Future<void> _updatePalette() async {
    final song = Provider.of<PlayerProvider>(context, listen: false).currentSong;
    if (song == null || song.thumbnail.isEmpty) return;

    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(song.thumbnail),
        maximumColorCount: 20,
      ).timeout(const Duration(seconds: 2)); // Timeout to prevent hanging
      
      if (mounted) {
        setState(() {
          _bgColors = [
            paletteGenerator.dominantColor?.color.withOpacity(0.6) ?? const Color(0xFF9C27B0).withOpacity(0.6),
            Colors.black,
          ];
        });
      }
    } catch (e) {
      print('Palette error: $e');
      // Fallback to default purple gradient
      if (mounted) {
        setState(() {
          _bgColors = [
            const Color(0xFF9C27B0).withOpacity(0.6),
            Colors.black,
          ];
        });
      }
    }
  }

  Future<void> _checkDownloadStatus() async {
    final song = Provider.of<PlayerProvider>(context, listen: false).currentSong;
    if (song == null) return;

    final downloaded = await _downloadService.isSongDownloaded(song.videoId);
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
      });
    }
  }

  Future<void> _downloadSong() async {
    final song = Provider.of<PlayerProvider>(context, listen: false).currentSong;
    if (song == null) return;

    setState(() => _isDownloading = true);
    
    await _downloadService.downloadSong(song);
    
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded to library')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inMinutes}:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;
        
        // Show error if present
        if (player.error.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${player.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

        if (song == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text('No song playing', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _bgColors,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          children: [
                            Text(
                              'PLAYING FROM SEARCH',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'YouTube Music',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),

                  // Artwork
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4), // Spotify uses sharper corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(song.thumbnail),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Title & Artist & Like Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.2),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: player.position.inSeconds.toDouble().clamp(0.0, player.duration.inSeconds.toDouble()),
                            max: player.duration.inSeconds.toDouble() > 0 ? player.duration.inSeconds.toDouble() : 1.0,
                            onChanged: (value) {
                              player.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(player.position),
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                              ),
                              Text(
                                _formatDuration(player.duration),
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                        onPressed: () {},
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            player.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 32,
                          ),
                          onPressed: () {
                            if (player.isPlaying) {
                              player.pause();
                            } else {
                              player.resume();
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bottom Actions (Lyrics / Download)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.devices, color: Colors.white70, size: 20),
                        
                        // Download Button (Subtle)
                        IconButton(
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Icon(
                                  _isDownloaded ? Icons.check_circle : Icons.download_for_offline_outlined,
                                  color: _isDownloaded ? const Color(0xFF1DB954) : Colors.white70,
                                  size: 24,
                                ),
                          onPressed: _isDownloaded ? null : _downloadSong,
                        ),
                        
                        const Icon(Icons.list, color: Colors.white70, size: 24),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
