/**
 * Audio Player Service
 * 
 * Wrapper around just_audio package for audio playback.
 * Handles streaming from URLs and playing local files.
 */

import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  // Singleton instance
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  // Audio player instance
  final AudioPlayer _player = AudioPlayer();

  /// Get the audio player instance
  AudioPlayer get player => _player;

  /// Play audio from a URL (stream or local file)
  /// 
  /// [url] - URL to the audio source
  /// 
  /// Returns true if successful
  Future<bool> play(String url) async {
    try {
      // Set the audio source
      await _player.setUrl(url);
      
      // Start playback
      await _player.play();
      
      return true;
    } catch (e) {
      print('Error playing audio: $e');
      return false;
    }
  }

  /// Play audio from a file path
  /// 
  /// [filePath] - Local file path
  /// 
  /// Returns true if successful
  Future<bool> playFromFile(String filePath) async {
    try {
      // Set the audio source from file
      await _player.setFilePath(filePath);
      
      // Start playback
      await _player.play();
      
      return true;
    } catch (e) {
      print('Error playing from file: $e');
      return false;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.play();
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to a specific position
  /// 
  /// [position] - Target position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set playback volume
  /// 
  /// [volume] - Volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Get current playback position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Get current duration stream
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Get player state stream
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Get current position
  Duration get position => _player.position;

  /// Get current duration
  Duration? get duration => _player.duration;

  /// Check if currently playing
  bool get isPlaying => _player.playing;

  /// Dispose the player
  void dispose() {
    _player.dispose();
  }
}
