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

  /// Parse m3u8 playlist and extract segment URLs
  Future<List<String>> _parseM3u8(String playlistUrl) async {
    final response = await _dio.get(playlistUrl);
    final content = response.data.toString();
    
    final segments = <String>[];
    final lines = content.split('\n');
    
    // Get base URL for resolving relative paths
    final baseUri = Uri.parse(playlistUrl);
    
    for (var line in lines) {
      line = line.trim();
      // Skip comments and empty lines
      if (line.startsWith('#') || line.isEmpty) continue;
      
      // If it's another m3u8 (master playlist), recursively parse it
      if (line.endsWith('.m3u8')) {
        final nestedUrl = baseUri.resolve(line).toString();
        return await _parseM3u8(nestedUrl); // Return nested playlist segments
      }
      
      // If it's a segment (.ts, .aac, etc.), add it
      if (line.contains('.')) {
        final segmentUrl = baseUri.resolve(line).toString();
        segments.add(segmentUrl);
      }
    }
    
    return segments;
  }

  /// Download HLS stream by downloading and merging segments
  Future<String?> _downloadHlsStream(
    String playlistUrl, String savePath, {Function(double)? onProgress}) async {
    
    print('Parsing m3u8 playlist...');
    final segments = await _parseM3u8(playlistUrl);
    
    if (segments.isEmpty) {
      throw Exception('No segments found in m3u8 playlist');
    }
    
    print('Found ${segments.length} segments to download');
    
    // Create temp directory for segments
    final tempDir = await getTemporaryDirectory();
    final segmentDir = Directory('${tempDir.path}/hls_download_${DateTime.now().millisecondsSinceEpoch}');
    await segmentDir.create(recursive: true);
    
    try {
      // Download all segments
      final segmentFiles = <File>[];
      for (var i = 0; i < segments.length; i++) {
        final segmentUrl = segments[i];
        final segmentPath = '${segmentDir.path}/segment_$i';
        
        await _dio.download(
          segmentUrl,
          segmentPath,
          options: Options(
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': '*/*',
            },
          ),
        );
        
        segmentFiles.add(File(segmentPath));
        
        // Update progress
        if (onProgress != null) {
          onProgress((i + 1) / segments.length);
        }
        
        print('Downloaded segment ${i + 1}/${segments.length}');
      }
      
      // Merge all segments into one file
      print('Merging segments...');
      final outputFile = File(savePath);
      final sink = outputFile.openWrite();
      
      for (var segmentFile in segmentFiles) {
        final bytes = await segmentFile.readAsBytes();
        sink.add(bytes);
      }
      
      await sink.flush();
      await sink.close();
      
      print('Download complete: $savePath');
      
      // Cleanup temp directory
      await segmentDir.delete(recursive: true);
      
      return savePath;
    } catch (e) {
      // Cleanup on error
      if (await segmentDir.exists()) {
        await segmentDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  /// Download a song from SoundCloud stream
  Future<String?> downloadSong(Song song, {Function(double)? onProgress}) async {
    try {
      // Request storage permissions
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      // Get SoundCloud stream URL
      String? audioUrl;
      
      if (song.isSoundCloud) {
        print('Downloading from SoundCloud...');
        audioUrl = await _scService.getStreamUrl(song.videoId);
        if (audioUrl == null) throw Exception('Could not get SoundCloud stream URL');
      } else {
        throw Exception('YouTube downloads not supported. Please search for this song again.');
      }

      // Get storage path
      final dir = await _getDownloadDirectory();
      final filename = _sanitizeFilename('${song.title} - ${song.artist} [${song.videoId}].m4a');
      final savePath = '${dir.path}/$filename';
      
      // Check if already exists
      if (File(savePath).existsSync()) {
        print('File already exists: $savePath');
        return savePath;
      }

      // Download HLS stream or direct file
      if (audioUrl.contains('.m3u8')) {
        print('Detected HLS stream, downloading segments...');
        return await _downloadHlsStream(audioUrl, savePath, onProgress: onProgress);
      } else {
        // Direct stream download
        print('Direct stream download...');
        await _dio.download(
          audioUrl,
          savePath,
          options: Options(
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': '*/*',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total != -1 && onProgress != null) {
              onProgress(received / total);
            }
          },
        );
        return savePath;
      }
    } catch (e) {
      print('Download error: $e');
      rethrow;
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
