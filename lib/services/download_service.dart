import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import 'soundcloud_service.dart';

class DownloadService {
  final Dio _dio = Dio();
  final SoundCloudService _scService = SoundCloudService();
  
  final Map<String, bool> _downloadedSongs = {};
  /// Get the public download directory
  Future<Directory> _getDownloadDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  /// Sanitize filename
  String _sanitizeFilename(String filename) {
    return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  }

  /// Download a song directly from YouTube stream
  Future<String?> downloadSong(Song song, {Function(double)? onProgress}) async {
    try {
      // Request storage permissions
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      // Try multiple conversion services to bypass network blocks
      String? audioUrl;
      
      if (song.isSoundCloud) {
        print('Downloading from SoundCloud...');
        audioUrl = await _scService.getStreamUrl(song.videoId);
        if (audioUrl == null) throw Exception('Could not get SoundCloud stream URL');
      } else {
        // Legacy YouTube tracks - not supported
        throw Exception('YouTube downloads not supported. Please search for this song again.');
      }
      
      if (audioUrl == null) throw Exception('No download URL found');

      // Get storage path
      final dir = await _getDownloadDirectory();
      
      // Create readable filename: "Title - Artist [videoId].mp3"
      final filename = _sanitizeFilename('${song.title} - ${song.artist} [${song.videoId}].mp3');
      final savePath = '${dir.path}/$filename';

      // Download file
      await _dio.download(
        audioUrl,
        savePath,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Origin': 'https://www.youtube.com',
            'Referer': 'https://www.youtube.com/',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return savePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  /// Check if song is already downloaded
  Future<bool> isSongDownloaded(String videoId) async {
    // This is tricky because we changed to readable filenames.
    // We'd need to check if ANY file matches the song info, or store a mapping.
    // For simplicity, we'll check if the file exists based on the title/artist we have NOW.
    // NOTE: This might be flaky if title/artist changes. Ideally we'd store metadata.
    // But for "public folder" requirement, this is the tradeoff.
    
    // Actually, to keep it robust for the app, we should probably ALSO save a map or 
    // just rely on the user seeing the file.
    // Let's try to reconstruct the path.
    // BUT we don't have the song object here, only videoId.
    // This breaks `isSongDownloaded(videoId)`.
    
    // FIX: We will scan the directory for a file that *contains* the videoId? 
    // No, we don't put videoId in the filename.
    
    // Alternative: We can't easily check by videoId anymore unless we store a database.
    // Let's assume for now we won't check by videoId for the UI "check" icon, 
    // OR we append the videoId to the filename: "Title - Artist [videoId].mp3"
    // This is common in youtube-dl.
    
    final dir = await _getDownloadDirectory();
    final files = dir.listSync();
    for (var file in files) {
      if (file.path.contains(videoId)) {
        return true;
      }
    }
    return false;
  }
  
  /// Helper to find file by videoId
  Future<File?> _findFileByVideoId(String videoId) async {
    final dir = await _getDownloadDirectory();
    if (!await dir.exists()) return null;
    
    try {
      final files = dir.listSync();
      for (var file in files) {
        if (file.path.contains(videoId)) {
          return File(file.path);
        }
      }
    } catch (e) {
      print('Error listing files: $e');
    }
    return null;
  }

  /// Get local file path for a song
  Future<String> getSongPath(String videoId) async {
    final file = await _findFileByVideoId(videoId);
    return file?.path ?? '';
  }
  
  /// Delete a downloaded song
  Future<void> deleteSong(String videoId) async {
    final file = await _findFileByVideoId(videoId);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }
}
