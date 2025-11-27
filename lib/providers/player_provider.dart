import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/song.dart';
import '../services/download_service.dart';
import '../services/soundcloud_service.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DownloadService _downloadService = DownloadService();
  final SoundCloudService _scService = SoundCloudService();

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  // Unified Stream Controllers
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  // Getters
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  
  // Stream getters
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  PlayerProvider() {
    _initPlayer();
  }

  void _initPlayer() {
    // Native Audio Player Listeners
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _playerStateController.add(state);
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      _positionController.add(pos);
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      _durationController.add(_duration);
      notifyListeners();
    });
  }



  String _error = '';
  String get error => _error;

  Future<void> playSong(Song song) async {
    _currentSong = song;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Stop player first
      await _audioPlayer.stop();
      
      String? audioUrl;
      
      // Check if downloaded first
      if (await _downloadService.isSongDownloaded(song.videoId)) {
        print('Playing from local storage: ${song.title}');
        audioUrl = await _downloadService.getSongPath(song.videoId);
      } 
      // Handle SoundCloud tracks (all new searches)
      else if (song.isSoundCloud) {
        print('Playing SoundCloud track: ${song.title}');
        audioUrl = await _scService.getStreamUrl(song.videoId);
        if (audioUrl == null) throw Exception('Could not get SoundCloud stream URL');
      }
      // Legacy YouTube tracks from library - just throw error
      else {
        throw Exception('YouTube playback not supported. Please search for this song again.');
      }

      // Play with native player
      if (audioUrl != null) {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(audioUrl),
            tag: song,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            },
          ),
        );
        await _audioPlayer.play();
      }

    } catch (e) {
      print('Play error: $e');
      _error = 'Playback failed: ${e.toString()}';
      _isPlaying = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
    super.dispose();
  }
}
