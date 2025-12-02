import 'dart:async';
import '../models/song.dart';

class QueueService {
  // Singleton instance
  static final QueueService _instance = QueueService._internal();
  factory QueueService() => _instance;
  QueueService._internal();

  // Queue state
  List<Song> _queue = [];
  int _currentIndex = 0;
  bool _shuffleEnabled = false;
  int _repeatMode = 0; // 0=off, 1=all, 2=one

  // State streams
  final _currentSongController = StreamController<Song?>.broadcast();
  final _queueController = StreamController<List<Song>>.broadcast();
  final _shuffleController = StreamController<bool>.broadcast();
  final _repeatController = StreamController<int>.broadcast();

  // Getters
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isEmpty ? null : _queue[_currentIndex];
  bool get shuffleEnabled => _shuffleEnabled;
  int get repeatMode => _repeatMode;

  // Streams
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<List<Song>> get queueStream => _queueController.stream;
  Stream<bool> get shuffleStream => _shuffleController.stream;
  Stream<int> get repeatStream => _repeatController.stream;

  /// Set the queue and optionally jump to a specific index
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    
    _queueController.add(_queue);
    _currentSongController.add(currentSong);
    
    print('🎵 Queue set: ${_queue.length} songs, starting at index $_currentIndex');
  }

  /// Play next song
  Song? next() {
    if (_queue.isEmpty) return null;

    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      _currentSongController.add(currentSong);
      print('⏭️ Next: $_currentIndex/${_queue.length}');
      return currentSong;
    } else if (_repeatMode == 1) {
      // Repeat all - go back to start
      _currentIndex = 0;
      _currentSongController.add(currentSong);
      print('🔁 Repeat all: back to start');
      return currentSong;
    }

    print('⏭️ No next song available');
    return null;
  }

  /// Play previous song
  Song? previous() {
    if (_queue.isEmpty) return null;

    if (_currentIndex > 0) {
      _currentIndex--;
      _currentSongController.add(currentSong);
      print('⏮️ Previous: $_currentIndex/${_queue.length}');
      return currentSong;
    }

    print('⏮️ No previous song available');
    return null;
  }

  /// Jump to specific index
  Song? jumpTo(int index) {
    if (_queue.isEmpty || index < 0 || index >= _queue.length) return null;

    _currentIndex = index;
    _currentSongController.add(currentSong);
    print('🎯 Jumped to index $index');
    return currentSong;
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    
    if (_shuffleEnabled && _queue.isNotEmpty) {
      // Shuffle while keeping current song at index 0
      final current = _queue[_currentIndex];
      final others = List<Song>.from(_queue);
      others.removeAt(_currentIndex);
      others.shuffle();
      _queue = [current, ...others];
      _currentIndex = 0;
      
      _queueController.add(_queue);
      print('🔀 Shuffle enabled');
    } else {
      print('🔀 Shuffle disabled');
    }
    
    _shuffleController.add(_shuffleEnabled);
  }

  /// Cycle repeat mode (off -> all -> one -> off)
  void cycleRepeat() {
    _repeatMode = (_repeatMode + 1) % 3;
    _repeatController.add(_repeatMode);
    
    final modes = ['Off', 'All', 'One'];
    print('🔁 Repeat mode: ${modes[_repeatMode]}');
  }

  /// Check if we should repeat the current song
  bool shouldRepeatOne() => _repeatMode == 2;

  void dispose() {
    _currentSongController.close();
    _queueController.close();
    _shuffleController.close();
    _repeatController.close();
  }
}
