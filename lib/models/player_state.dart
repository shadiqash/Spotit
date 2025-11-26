/**
 * Player State Model
 * 
 * Represents the current state of the audio player.
 */

import 'song.dart';

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<Song> playlist;
  final int currentIndex;
  final bool isLoading;

  PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playlist = const [],
    this.currentIndex = 0,
    this.isLoading = false,
  });

  /// Create a copy with updated fields
  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Song>? playlist,
    int? currentIndex,
    bool? isLoading,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if there's a next song in the playlist
  bool get hasNext => currentIndex < playlist.length - 1;

  /// Check if there's a previous song in the playlist
  bool get hasPrevious => currentIndex > 0;

  /// Get progress as a percentage (0.0 to 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() {
    return 'PlayerState(currentSong: ${currentSong?.title}, isPlaying: $isPlaying, position: $position, duration: $duration)';
  }
}
