/**
 * Player Provider
 * 
 * Manages the state of the audio player using Provider pattern.
 * Handles playback control, playlist management, and streaming.
 */

import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/player_state.dart' as models;
import '../services/audio_player_service.dart';
import '../services/api_service.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final ApiService _apiService = ApiService();

  models.PlayerState _state = models.PlayerState();

  models.PlayerState get state => _state;
  Song? get currentSong => _state.currentSong;
  bool get isPlaying => _state.isPlaying;
  Duration get position => _state.position;
  Duration get duration => _state.duration;
  List<Song> get playlist => _state.playlist;

  PlayerProvider() {
    _initializeListeners();
  }

  /// Initialize audio player listeners
  void _initializeListeners() {
    // Listen to position changes
    _audioService.positionStream.listen((position) {
      _state = _state.copyWith(position: position);
      notifyListeners();
    });

    // Listen to duration changes
    _audioService.durationStream.listen((duration) {
      if (duration != null) {
        _state = _state.copyWith(duration: duration);
        notifyListeners();
      }
    });

    // Listen to player state changes
    _audioService.playerStateStream.listen((playerState) {
      _state = _state.copyWith(
        isPlaying: playerState.playing,
      );
      notifyListeners();
    });
  }

  /// Play a song (stream from YouTube)
  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    try {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();

      // Get stream URL from backend
      final streamData = await _apiService.getStreamUrl(song.videoId);
      final streamUrl = streamData['streamUrl'];

      // Update state with new song and playlist
      _state = _state.copyWith(
        currentSong: song,
        playlist: playlist ?? [song],
        currentIndex: index ?? 0,
        isLoading: false,
      );
      notifyListeners();

      // Play the stream
      await _audioService.play(streamUrl);
    } catch (e) {
      print('Error playing song: $e');
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  /// Play a downloaded song from local storage
  Future<void> playLocalSong(Song song, {List<Song>? playlist, int? index}) async {
    try {
      if (song.localPath == null) {
        print('No local path for song');
        return;
      }

      _state = _state.copyWith(
        currentSong: song,
        playlist: playlist ?? [song],
        currentIndex: index ?? 0,
        isLoading: false,
      );
      notifyListeners();

      // Play from local file
      await _audioService.playFromFile(song.localPath!);
    } catch (e) {
      print('Error playing local song: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.resume();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioService.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioService.resume();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioService.stop();
    _state = _state.copyWith(
      isPlaying: false,
      position: Duration.zero,
    );
    notifyListeners();
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  /// Play next song in playlist
  Future<void> playNext() async {
    if (_state.hasNext) {
      final nextIndex = _state.currentIndex + 1;
      final nextSong = _state.playlist[nextIndex];
      
      if (nextSong.isDownloaded && nextSong.localPath != null) {
        await playLocalSong(
          nextSong,
          playlist: _state.playlist,
          index: nextIndex,
        );
      } else {
        await playSong(
          nextSong,
          playlist: _state.playlist,
          index: nextIndex,
        );
      }
    }
  }

  /// Play previous song in playlist
  Future<void> playPrevious() async {
    if (_state.hasPrevious) {
      final prevIndex = _state.currentIndex - 1;
      final prevSong = _state.playlist[prevIndex];
      
      if (prevSong.isDownloaded && prevSong.localPath != null) {
        await playLocalSong(
          prevSong,
          playlist: _state.playlist,
          index: prevIndex,
        );
      } else {
        await playSong(
          prevSong,
          playlist: _state.playlist,
          index: prevIndex,
        );
      }
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
