import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/song.dart';
import '../services/youtube_service.dart';
import '../services/download_service.dart';
import '../services/sponsor_block_service.dart';
import '../services/cobalt_service.dart';
import '../services/webview_player_service.dart';
import '../services/piped_service.dart';

import '../services/soundcloud_service.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YouTubeService _ytService = YouTubeService();
  final DownloadService _downloadService = DownloadService();
  final SponsorBlockService _sponsorBlockService = SponsorBlockService();
  final CobaltService _cobaltService = CobaltService();
  final WebViewPlayerService _webViewPlayer = WebViewPlayerService();
  final PipedService _pipedService = PipedService();
  final SoundCloudService _scService = SoundCloudService();

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isWebPlayback = false; // Flag to track active player
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<SkipSegment> _skipSegments = [];
  
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
      if (!_isWebPlayback) {
        _isPlaying = state.playing;
        _playerStateController.add(state);
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (!_isWebPlayback) {
        _position = pos;
        _positionController.add(pos);
        _checkSkipSegments(pos);
        notifyListeners();
      }
    });

    _audioPlayer.durationStream.listen((dur) {
      if (!_isWebPlayback) {
        _duration = dur ?? Duration.zero;
        _durationController.add(_duration);
        notifyListeners();
      }
    });

    // Web View Player Listeners
    _webViewPlayer.playerStateStream.listen((state) {
      if (_isWebPlayback) {
        _isPlaying = state.playing;
        _playerStateController.add(state);
        notifyListeners();
      }
    });

    _webViewPlayer.positionStream.listen((pos) {
      if (_isWebPlayback) {
        _position = pos;
        _positionController.add(pos);
        _checkSkipSegments(pos);
        notifyListeners();
      }
    });

    _webViewPlayer.durationStream.listen((dur) {
      if (_isWebPlayback) {
        _duration = dur;
        _durationController.add(dur);
        notifyListeners();
      }
    });
  }

  void _checkSkipSegments(Duration currentPos) {
    if (_skipSegments.isEmpty) return;

    final currentSeconds = currentPos.inMilliseconds / 1000.0;
    
    for (final segment in _skipSegments) {
      if (currentSeconds >= segment.start && currentSeconds < segment.end) {
        // We are inside a skip segment, seek to the end
        print('Skipping segment: ${segment.category} (${segment.start} - ${segment.end})');
        seek(Duration(milliseconds: (segment.end * 1000).toInt()));
        break; // Only skip one at a time
      }
    }
  }

  String _error = '';
  String get error => _error;

  Future<void> playSong(Song song) async {
    _currentSong = song;
    _isLoading = true;
    _error = '';
    _skipSegments = []; // Reset skip segments
    notifyListeners();

    try {
      // Stop players first
      await _audioPlayer.stop();
      if (_isWebPlayback) {
        await _webViewPlayer.pause(); // Ensure webview stops
      }
      
      String? audioUrl;
      
      // Check if downloaded first
      if (await _downloadService.isSongDownloaded(song.videoId)) {
        print('Playing from local storage: ${song.title}');
        _isWebPlayback = false;
        audioUrl = await _downloadService.getSongPath(song.videoId);
      } 
      // Handle SoundCloud tracks
      else if (song.isSoundCloud) {
        print('Playing SoundCloud track: ${song.title}');
        _isWebPlayback = false;
        audioUrl = await _scService.getStreamUrl(song.videoId);
        if (audioUrl == null) throw Exception('Could not get SoundCloud stream URL');
      }
      // Handle YouTube tracks (Legacy/Library)
      else {
        // Fetch skip segments only for YouTube
        _fetchSkipSegments(song.videoId);
        
        // Try Piped API first
        print('Attempting Piped API streaming: ${song.title}');
        _isWebPlayback = false;
        
        try {
          audioUrl = await _pipedService.getAudioUrl(song.videoId);
          print('Piped URL fetched successfully');
        } catch (pipedError) {
          print('Piped API failed: $pipedError');
          print('Falling back to direct YouTube streaming...');
          
          // Fallback to YoutubeExplode direct streaming
          audioUrl = await _ytService.getAudioUrl(song.videoId);
          print('Direct YouTube URL fetched: $audioUrl');
        }
      }

      // Try playing with native player
      if (audioUrl != null) {
        try {
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
        } catch (sourceError) {
          // If native player fails (Source error), try WebView ONLY for YouTube
          if (!song.isSoundCloud) {
            print('Native player failed: $sourceError');
            print('Falling back to WebView player...');
            _isWebPlayback = true;
            
            try {
              await _webViewPlayer.loadVideo(song.videoId);
              print('WebView player loaded successfully');
            } catch (webViewError) {
              print('WebView also failed: $webViewError');
              throw Exception('All playback methods failed.');
            }
          } else {
            throw sourceError; // Re-throw for SoundCloud
          }
        }
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

  Future<void> _fetchSkipSegments(String videoId) async {
    try {
      final segments = await _sponsorBlockService.getSkipSegments(videoId);
      _skipSegments = segments;
      print('Loaded ${_skipSegments.length} skip segments for $videoId');
    } catch (e) {
      print('Failed to load skip segments: $e');
    }
  }

  Future<void> pause() async {
    if (_isWebPlayback) {
      await _webViewPlayer.pause();
    } else {
      await _audioPlayer.pause();
    }
  }

  Future<void> resume() async {
    if (_isWebPlayback) {
      await _webViewPlayer.play();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    if (_isWebPlayback) {
      await _webViewPlayer.seek(position);
    } else {
      await _audioPlayer.seek(position);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _ytService.dispose();
    _webViewPlayer.dispose();
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
    super.dispose();
  }
}
