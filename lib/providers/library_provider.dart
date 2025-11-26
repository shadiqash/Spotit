/**
 * Library Provider
 * 
 * Manages the state of downloaded songs library.
 * Handles loading, adding, and removing songs from local storage.
 */

import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/local_storage_service.dart';
import '../services/download_service.dart';
import '../services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  final DownloadService _downloadService = DownloadService();
  final ApiService _apiService = ApiService();

  List<Song> _songs = [];
  bool _isLoading = false;
  Map<String, double> _downloadProgress = {};

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  Map<String, double> get downloadProgress => _downloadProgress;

  /// Load downloaded songs from local storage
  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    try {
      _songs = await _storageService.getDownloadedSongs();
    } catch (e) {
      print('Error loading library: $e');
      _songs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Download a song
  Future<bool> downloadSong(Song song) async {
    try {
      // Initialize progress
      _downloadProgress[song.videoId] = 0.0;
      notifyListeners();

      // Download the song
      final localPath = await _downloadService.downloadSong(
        song,
        onProgress: (progress) {
          _downloadProgress[song.videoId] = progress;
          notifyListeners();
        },
      );

      // Create filename from videoId and title
      final filename = localPath.split('/').last;

      // Update song with download info
      final downloadedSong = song.copyWith(
        isDownloaded: true,
        localPath: localPath,
        filename: filename,
      );

      // Add to library if not already there
      final existingIndex = _songs.indexWhere((s) => s.videoId == song.videoId);
      if (existingIndex >= 0) {
        _songs[existingIndex] = downloadedSong;
      } else {
        _songs.add(downloadedSong);
      }

      // Remove from progress map
      _downloadProgress.remove(song.videoId);
      notifyListeners();

      return true;
    } catch (e) {
      print('Error downloading song: $e');
      _downloadProgress.remove(song.videoId);
      notifyListeners();
      return false;
    }
  }

  /// Check if a song is downloaded
  bool isDownloaded(String videoId) {
    return _songs.any((song) => song.videoId == videoId);
  }

  /// Get download progress for a song
  double? getDownloadProgress(String videoId) {
    return _downloadProgress[videoId];
  }

  /// Delete a song from library
  Future<bool> deleteSong(Song song) async {
    try {
      // Delete from local storage
      if (song.filename != null) {
        await _storageService.deleteFile(song.filename!);
        
        // Also delete from backend
        try {
          await _apiService.deleteSong(song.filename!);
        } catch (e) {
          print('Error deleting from backend: $e');
          // Continue even if backend delete fails
        }
      }

      // Remove from library
      _songs.removeWhere((s) => s.videoId == song.videoId);
      notifyListeners();

      return true;
    } catch (e) {
      print('Error deleting song: $e');
      return false;
    }
  }

  /// Get total storage used
  Future<String> getTotalStorageUsed() async {
    final bytes = await _storageService.getTotalStorageUsed();
    return _storageService.formatBytes(bytes);
  }

  /// Refresh library (reload from storage)
  Future<void> refresh() async {
    await loadLibrary();
  }
}
