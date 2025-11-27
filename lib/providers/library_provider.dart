import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';
import '../services/download_service.dart';
import '../services/youtube_service.dart';

class LibraryProvider with ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  final YouTubeService _ytService = YouTubeService();
  
  List<Song> _songs = [];
  bool _isLoading = false;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;

  LibraryProvider() {
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final songDir = Directory('${dir.path}/songs');
      
      if (!await songDir.exists()) {
        _songs = [];
        return;
      }

      final List<FileSystemEntity> files = songDir.listSync();
      
      _songs = [];
      
      for (var file in files) {
        if (file.path.endsWith('.mp3')) {
          final videoId = file.path.split('/').last.replaceAll('.mp3', '');
          
          try {
            // Fetch metadata from YouTube (or cache it locally in a real app)
            // For now, we'll fetch fresh metadata to keep it simple
            final song = await _ytService.getVideoDetails(videoId);
            _songs.add(song.copyWith(isDownloaded: true));
          } catch (e) {
            // If offline, we might need a local database for metadata
            // Fallback for now
            _songs.add(Song(
              videoId: videoId,
              title: 'Downloaded Song',
              artist: 'Unknown',
              thumbnail: '',
              duration: 0,
              url: '',
              isDownloaded: true,
            ));
          }
        }
      }
    } catch (e) {
      print('Library load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSong(String videoId) async {
    await _downloadService.deleteSong(videoId);
    await loadLibrary();
  }
}
