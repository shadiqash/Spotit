import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DesktopStorageService {
  /// Initialize storage - create Spotit directory if it doesn't exist
  Future<void> init() async {
    final dir = await getDownloadDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Get the directory where songs are saved
  /// On Linux: ~/Music/Spotit
  Future<Directory> getDownloadDirectory() async {
    // For Linux/Desktop, we prefer the user's Music directory
    try {
      // Try to get the standard downloads directory first
      final downloadsDir = await getDownloadsDirectory();
      
      if (downloadsDir != null) {
        // Create a 'Spotit' folder inside Downloads or Music
        // Note: path_provider on Linux usually returns ~/Downloads
        // We might want to construct ~/Music manually if possible, 
        // but sticking to standard paths is safer.
        
        // Let's try to find the Music directory by going up from Downloads if needed
        // Or just use Downloads/Spotit which is standard for many apps
        
        return Directory('${downloadsDir.path}/Spotit');
      }
    } catch (e) {
      print('Error getting downloads directory: $e');
    }
    
    // Fallback to application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/Spotit');
  }

  /// Get path for a song file
  Future<String> getSongPath(String songId) async {
    final dir = await getDownloadDirectory();
    return '${dir.path}/$songId.mp3';
  }

  /// Check if a song is downloaded
  Future<bool> isSongDownloaded(String songId) async {
    final path = await getSongPath(songId);
    return File(path).exists();
  }

  /// Delete a downloaded song
  Future<void> deleteSong(String songId) async {
    final path = await getSongPath(songId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  /// Get all downloaded song files
  Future<List<FileSystemEntity>> getDownloadedFiles() async {
    final dir = await getDownloadDirectory();
    if (await dir.exists()) {
      return dir.listSync().where((e) => e.path.endsWith('.mp3')).toList();
    }
    return [];
  }
}
