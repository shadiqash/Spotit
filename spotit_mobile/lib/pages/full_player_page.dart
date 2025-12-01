import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class FullPlayerPage extends StatefulWidget {
  final String songTitle;
  final String artist;
  final String? thumbnailUrl;
  final AudioPlayer audioPlayer;
  final VoidCallback onClose;

  const FullPlayerPage({
    Key? key,
    required this.songTitle,
    required this.artist,
    this.thumbnailUrl,
    required this.audioPlayer,
    required this.onClose,
  }) : super(key: key);

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation for disc
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Pulse animation for controls
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Listen to player state
    widget.audioPlayer.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
      if (state.playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.darkPurple.withOpacity(0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                      color: Colors.white,
                      onPressed: widget.onClose,
                    ),
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Rotating disc visualization
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: child,
                  );
                },
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.darkPurple,
                        AppTheme.background,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceVariant,
                        image: widget.thumbnailUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.thumbnailUrl == null
                          ? const Icon(Icons.music_note, size: 80, color: Colors.white54)
                          : null,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Song info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      widget.songTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.artist,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<Duration>(
                  stream: widget.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = widget.audioPlayer.duration ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                    
                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: AppTheme.primaryPurple,
                            inactiveTrackColor: AppTheme.surfaceVariant,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: progress.clamp(0.0, 1.0),
                            onChanged: (value) {
                              if (duration.inMilliseconds > 0) {
                                widget.audioPlayer.seek(
                                  Duration(milliseconds: (value * duration.inMilliseconds).toInt()),
                                );
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle, size: 28),
                    color: Colors.grey[400],
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 36),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isPlaying ? 1.0 + (_pulseController.value * 0.1) : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryPurple, AppTheme.darkPurple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 36,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          if (_isPlaying) {
                            widget.audioPlayer.pause();
                          } else {
                            widget.audioPlayer.play();
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 36),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat, size: 28),
                    color: Colors.grey[400],
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
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
