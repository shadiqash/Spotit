import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'extraction_service.dart';
import 'queue_service.dart';
import 'audio_player_service.dart';
import '../models/song.dart';

class PlaybackService {
  // Singleton instance
  static final PlaybackService _instance = PlaybackService._internal();
  factory PlaybackService() => _instance;
  PlaybackService._internal();

  final ExtractionService _extractionService = ExtractionService();
  final QueueService _queueService = QueueService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  StreamSubscription? _streamUrlSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _playerStateSubscription;

  bool _isInitialized = false;

  // State
  final _isLoadingController = StreamController<bool>.broadcast();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  bool _isLoading = false;

  /// Initialize the playback service
  void init() {
    if (_isInitialized) return;

    // Listen to extraction results
    _streamUrlSubscription = _extractionService.streamUrlStream.listen((url) {
      _handleStreamUrl(url);
    });

    _errorSubscription = _extractionService.errorStream.listen((_) {
      _handleStreamError();
    });

    // Listen to player state for auto-next
    _playerStateSubscription = _audioPlayerService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });

    _isInitialized = true;
    print('✅ PlaybackService initialized');
  }

  /// Play a specific song
  void play(Song song) {
    print('▶️ PlaybackService: Play requested for "${song.title}"');
    
    _setLoading(true);
    
    // Request extraction
    _extractionService.extract(song.id);
  }

  /// Play the current song in the queue
  void playCurrent() {
    final current = _queueService.currentSong;
    if (current != null) {
      play(current);
    }
  }

  /// Play next song
  void playNext() {
    final next = _queueService.next();
    if (next != null) {
      play(next);
    }
  }

  /// Play previous song
  void playPrevious() {
    final previous = _queueService.previous();
    if (previous != null) {
      play(previous);
    }
  }

  /// Jump to specific index in queue
  void jumpTo(int index) {
    final song = _queueService.jumpTo(index);
    if (song != null) {
      play(song);
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayerService.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayerService.resume();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayerService.seek(position);
  }

  /// Handle stream URL received
  Future<void> _handleStreamUrl(String url) async {
    print('🎵 PlaybackService: Stream URL received, playing...');
    
    try {
      await _audioPlayerService.play(url);
      _setLoading(false);
      print('✅ PlaybackService: Playback started');
    } catch (e) {
      print('❌ PlaybackService: Audio player error: $e');
      _setLoading(false);
    }
  }

  /// Handle stream extraction error
  void _handleStreamError() {
    print('❌ PlaybackService: Stream extraction failed');
    _setLoading(false);
    // Could implement retry logic here
  }

  /// Handle song completion
  void _handleSongCompletion() {
    print('🏁 PlaybackService: Song completed');
    
    if (_queueService.shouldRepeatOne()) {
      // Repeat one
      _audioPlayerService.seek(Duration.zero);
      _audioPlayerService.resume();
      print('🔁 Repeating current song');
    } else {
      // Auto-play next
      playNext();
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    _isLoadingController.add(loading);
  }

  // Expose audio player properties
  AudioPlayer get audioPlayer => _audioPlayerService.player;
  bool get isPlaying => _audioPlayerService.isPlaying;
  bool get isLoading => _isLoading;
  Stream<Duration> get positionStream => _audioPlayerService.positionStream;
  Stream<Duration?> get durationStream => _audioPlayerService.durationStream;

  void dispose() {
    _streamUrlSubscription?.cancel();
    _errorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _isLoadingController.close();
  }
}
