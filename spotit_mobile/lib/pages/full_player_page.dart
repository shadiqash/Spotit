import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_theme.dart';
import '../services/queue_service.dart';
import '../services/playback_service.dart';
import '../models/song.dart';
import 'dart:math' as math;

class FullPlayerPage extends StatefulWidget {
  final QueueService queueService;
  final PlaybackService playbackService;
  final VoidCallback onClose;

  const FullPlayerPage({
    Key? key,
    required this.queueService,
    required this.playbackService,
    required this.onClose,
  }) : super(key: key);

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  // Dynamic state from streams
  Song? _currentSong;
  bool _isPlaying = false;
  bool _shuffleEnabled = false;
  int _repeatMode = 0;
  Duration _currentPosition = Duration.zero;
  
  // Stream subscriptions for cleanup
  StreamSubscription? _songSubscription;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _shuffleSubscription;
  StreamSubscription? _repeatSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    
    // Initialize rotation animation for disc
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Initialize pulse animation for controls
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Set initial state from services
    _currentSong = widget.queueService.currentSong;
    _shuffleEnabled = widget.queueService.shuffleEnabled;
    _repeatMode = widget.queueService.repeatMode;
    
    _setupStreamListeners();
  }

  /// Set up all stream listeners with error handling
  void _setupStreamListeners() {
    // Listen to current song changes - updates metadata when next/prev pressed
    _songSubscription = widget.queueService.currentSongStream.listen(
      _updateCurrentSong,
      onError: (error) => print('Error in song stream: $error'),
    );
    
    // Listen to player state - updates play/pause button and disc animation
    _playerSubscription = widget.playbackService.audioPlayer.playerStateStream.listen(
      _updatePlayerState,
      onError: (error) => print('Error in player state stream: $error'),
    );
    
    // Listen to shuffle state - updates shuffle button color
    _shuffleSubscription = widget.queueService.shuffleStream.listen(
      _updateShuffleState,
      onError: (error) => print('Error in shuffle stream: $error'),
    );
    
    // Listen to repeat mode - updates repeat button icon
    _repeatSubscription = widget.queueService.repeatStream.listen(
      _updateRepeatMode,
      onError: (error) => print('Error in repeat stream: $error'),
    );

    // Listen to position stream - updates progress bar
    _positionSubscription = widget.playbackService.audioPlayer.positionStream.listen(
      (position) {
        if (mounted) setState(() => _currentPosition = position);
      },
      onError: (error) => print('Error in position stream: $error'),
    );
    
    // Set initial playing state
    _updatePlayerState(widget.playbackService.audioPlayer.playerState);
  }

  /// Update current song and reset disc animation for smooth transition
  void _updateCurrentSong(Song? song) {
    if (!mounted) return;
    
    setState(() {
      _currentSong = song;
      _currentPosition = Duration.zero; // Reset position on song change
    });
    
    // Reset disc rotation animation on track skip for smoother visual transition
    if (song != null) {
      _rotationController.reset();
      if (_isPlaying) {
        _rotationController.repeat();
      }
    }
  }

  /// Update player state and control disc animation
  void _updatePlayerState(PlayerState state) {
    if (!mounted) return;
    
    setState(() => _isPlaying = state.playing);
    
    if (state.playing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  /// Update shuffle state
  void _updateShuffleState(bool enabled) {
    if (!mounted) return;
    setState(() => _shuffleEnabled = enabled);
  }

  /// Update repeat mode
  void _updateRepeatMode(int mode) {
    if (!mounted) return;
    setState(() => _repeatMode = mode);
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions to prevent memory leaks
    _songSubscription?.cancel();
    _playerSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _repeatSubscription?.cancel();
    _positionSubscription?.cancel();
    
    // Dispose animation controllers
    _rotationController.dispose();
    _pulseController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if no song is loaded
    if (_currentSong == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                      color: Colors.white,
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'No song loaded',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final duration = widget.playbackService.audioPlayer.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / duration.inMilliseconds
        : 0.0;

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
                        image: _currentSong!.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_currentSong!.thumbnailUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _currentSong!.thumbnailUrl.isEmpty
                          ? const Icon(Icons.music_note, size: 80, color: Colors.white54)
                          : null,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Song info - updates dynamically from stream
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _currentSong!.title,
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
                      _currentSong!.artist,
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
              
              // Progress bar - real-time updates via positionStream
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
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
                          // Allow seeking by dragging
                          if (duration.inMilliseconds > 0) {
                            widget.playbackService.seek(
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
                            _formatDuration(_currentPosition),
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
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle button - purple when active
                  IconButton(
                    icon: const Icon(Icons.shuffle, size: 28),
                    color: _shuffleEnabled ? AppTheme.primaryPurple : Colors.grey[400],
                    onPressed: widget.queueService.toggleShuffle,
                  ),
                  // Previous button
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 36),
                    color: Colors.white,
                    onPressed: widget.playbackService.playPrevious,
                  ),
                  // Play/Pause button with pulse animation
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
                            widget.playbackService.pause();
                          } else {
                            widget.playbackService.resume();
                          }
                        },
                      ),
                    ),
                  ),
                  // Next button
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 36),
                    color: Colors.white,
                    onPressed: widget.playbackService.playNext,
                  ),
                  // Repeat button - shows different icons per mode
                  IconButton(
                    icon: Icon(
                      _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                      size: 28,
                    ),
                    color: _repeatMode > 0 ? AppTheme.primaryPurple : Colors.grey[400],
                    onPressed: widget.queueService.cycleRepeat,
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
