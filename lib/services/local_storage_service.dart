/**
 * Local Storage Service
 * 
 * Manages local MP3 files and provides utilities for file operations.
 */

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class LocalStorageService {
  /// Get the app's documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// List all downloaded MP3 files
  /// 
  /// Returns list of Song objects for local files
  Future<List<Song>> getDownloadedSongs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      
      final mp3Files = files
          .where((file) => file.path.endsWith('.mp3'))
          .toList();
      
      final songs = <Song>[];
      
      for (var file in mp3Files) {
        final filename = file.path.split('/').last;
        
        // Parse filename: {videoId}_{title}.mp3
        final match = RegExp(r'^([^_]+)_(.+)\.mp3$').firstMatch(filename);
        
        if (match != null) {
          final videoId = match.group(1) ?? '';
          final title = match.group(2)?.replaceAll('_', ' ') ?? 'Unknown';
          
          songs.add(Song(
            videoId: videoId,
            title: title,
            artist: 'Unknown Artist',
            thumbnail: '',
            duration: 0,
            url: '',
            isDownloaded: true,
            localPath: file.path,
            filename: filename,
          ));
        }
      }
      
      return songs;
    } catch (e) {
      print('Error getting downloaded songs: $e');
      return [];
    }
  }

  /// Check if a file exists
  /// 
  /// [filename] - Name of the file
  /// 
  /// Returns true if file exists
  Future<bool> fileExists(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size in bytes
  /// 
  /// [filename] - Name of the file
  /// 
  /// Returns file size or 0 if file doesn't exist
  Future<int> getFileSize(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      
      if (await file.exists()) {
        return await file.length();
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Delete a file
  /// 
  /// [filename] - Name of the file to delete
  /// 
  /// Returns true if successful
  Future<bool> deleteFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get total storage used by downloaded songs
  /// 
  /// Returns total size in bytes
  Future<int> getTotalStorageUsed() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      
      int totalSize = 0;
      
      for (var file in files) {
        if (file.path.endsWith('.mp3') && file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human-readable string
  /// 
  /// [bytes] - Size in bytes
  /// 
  /// Returns formatted string (e.g., "1.5 MB")
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
