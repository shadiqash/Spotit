/**
 * Download Service
 * 
 * Handles downloading MP3 files from the backend and saving them locally.
 * Provides progress tracking for downloads.
 */

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';
import 'api_service.dart';

class DownloadService {
  final Dio _dio = Dio();

  /// Download a song MP3 file
  /// 
  /// [song] - Song to download
  /// [onProgress] - Callback for download progress (0.0 to 1.0)
  /// 
  /// Returns the local file path
  Future<String> downloadSong(
    Song song, {
    Function(double)? onProgress,
  }) async {
    try {
      // First, trigger backend download
      final apiService = ApiService();
      final downloadResult = await apiService.downloadSong(song);
      
      final filename = downloadResult['filename'];
      final songUrl = ApiService.getSongUrl(filename);
      
      // Get local storage directory
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/$filename';
      
      // Check if file already exists
      final file = File(localPath);
      if (await file.exists()) {
        print('File already exists locally: $localPath');
        return localPath;
      }
      
      // Download the file from backend to local storage
      await _dio.download(
        songUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );
      
      print('Download complete: $localPath');
      return localPath;
    } catch (e) {
      print('Download error: $e');
      throw Exception('Failed to download song: $e');
    }
  }

  /// Check if a song is downloaded locally
  /// 
  /// [filename] - Name of the file
  /// 
  /// Returns true if file exists
  Future<bool> isDownloaded(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get local file path for a song
  /// 
  /// [filename] - Name of the file
  /// 
  /// Returns the full local path
  Future<String> getLocalPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  /// Delete a downloaded song from local storage
  /// 
  /// [filename] - Name of the file to delete
  /// 
  /// Returns true if successful
  Future<bool> deleteLocalFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      
      if (await file.exists()) {
        await file.delete();
        print('Deleted local file: $filename');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
