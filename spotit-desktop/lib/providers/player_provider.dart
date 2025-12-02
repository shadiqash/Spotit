import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/player_state.dart' as ps;
import '../services/youtube_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YouTubeService _youtubeService = YouTubeService();
  
  ps.PlayerState _state = ps.PlayerState();
  
  ps.PlayerState get state => _state;
  
  PlayerProvider() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      
      _state = _state.copyWith(
        isPlaying: isPlaying,
        isLoading: processingState == ProcessingState.loading || 
                   processingState == ProcessingState.buffering,
      );
      notifyListeners();
      
      // Auto-advance to next song
      if (processingState == ProcessingState.completed) {
        playNext();
      }
    });
    
    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _state = _state.copyWith(position: position);
      notifyListeners();
    });
    
    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _state = _state.copyWith(duration: duration);
        notifyListeners();
      }
    });
  }
  
  /// Play a specific song
  Future<void> playSong(Song song) async {
    try {
      _state = _state.copyWith(
        currentSong: song,
        isLoading: true,
      );
      notifyListeners();
      
      String? audioUrl;
      Map<String, String>? headers;
      
      // If downloaded, play local file
      if (song.isDownloaded && song.localPath != null) {
        audioUrl = song.localPath;
      } else {
        // Otherwise stream from YouTube
        final result = await _youtubeService.getAudioUrl(song.videoId);
        if (result != null) {
          audioUrl = result['url'];
          headers = result['headers'] as Map<String, String>?;
        }
      }
      
      if (audioUrl != null) {
        print('Attempting to play URL: $audioUrl');
        if (song.isDownloaded) {
          print('Playing local file');
          await _audioPlayer.setFilePath(audioUrl);
        } else {
          print('Playing stream URL with headers: $headers');
          await _audioPlayer.setUrl(audioUrl, headers: headers);
        }
        print('Calling play()...');
        await _audioPlayer.play();
        print('Play called successfully');
      } else {
        print('Could not get audio URL for ${song.title}');
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
      }
    } catch (e, stack) {
      print('Error playing song: $e');
      print('Stack trace: $stack');
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  /// Play a test song directly (bypass YouTube lookup)
  Future<void> playTestSong(Song song) async {
    try {
      _state = _state.copyWith(currentSong: song, isLoading: true);
      notifyListeners();
      
      print('Playing TEST song: ${song.url}');
      await _audioPlayer.setUrl(song.url);
      await _audioPlayer.play();
      print('Test song playing...');
    } catch (e) {
      print('Error playing test song: $e');
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }
  
  /// Toggle play/pause
  Future<void> togglePlay() async {
    if (_state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  /// Play next song
  Future<void> playNext() async {
    if (_state.hasNext) {
      final nextIndex = _state.currentIndex + 1;
      _state = _state.copyWith(currentIndex: nextIndex);
      await playSong(_state.playlist[nextIndex]);
    }
  }
  
  /// Play previous song
  Future<void> playPrevious() async {
    if (_state.hasPrevious) {
      final prevIndex = _state.currentIndex - 1;
      _state = _state.copyWith(currentIndex: prevIndex);
      await playSong(_state.playlist[prevIndex]);
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }
  
  /// Set playlist
  void setPlaylist(List<Song> songs, {int initialIndex = 0}) {
    _state = _state.copyWith(
      playlist: songs,
      currentIndex: initialIndex,
    );
    if (songs.isNotEmpty) {
      playSong(songs[initialIndex]);
    }
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    _youtubeService.dispose();
    super.dispose();
  }
}
