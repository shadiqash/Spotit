/**
 * API Service
 * 
 * Handles all HTTP communication with the backend API.
 * Provides methods for searching, streaming, downloading, and library management.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class ApiService {
  // Backend API base URL
  // TODO: Update this to your backend URL
  // For Android emulator: http://10.0.2.2:3000
  // For iOS simulator: http://localhost:3000
  // For physical device: http://YOUR_COMPUTER_IP:3000
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Search for songs on YouTube
  /// 
  /// [query] - Search query string
  /// [limit] - Maximum number of results (default: 10)
  /// 
  /// Returns list of Song objects
  Future<List<Song>> search(String query, {int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {
        'q': query,
        'limit': limit.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  /// Get direct audio stream URL for a video
  /// 
  /// [videoId] - YouTube video ID
  /// 
  /// Returns stream URL and metadata
  Future<Map<String, dynamic>> getStreamUrl(String videoId) async {
    try {
      final uri = Uri.parse('$baseUrl/stream').replace(queryParameters: {
        'videoId': videoId,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to get stream URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }

  /// Download a song as MP3
  /// 
  /// [song] - Song to download
  /// 
  /// Returns download result with filename and URL
  Future<Map<String, dynamic>> downloadSong(Song song) async {
    try {
      final uri = Uri.parse('$baseUrl/download');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'videoId': song.videoId,
          'title': song.title,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }

  /// Get list of downloaded songs from the library
  /// 
  /// Returns list of Song objects with download info
  Future<List<Song>> getLibrary() async {
    try {
      final uri = Uri.parse('$baseUrl/library');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final songs = data['songs'] as List;
        
        return songs.map((json) {
          final song = Song(
            videoId: json['videoId'] ?? '',
            title: json['title'] ?? 'Unknown',
            artist: 'Unknown Artist',
            thumbnail: '',
            duration: 0,
            url: json['url'] ?? '',
            isDownloaded: true,
            filename: json['filename'],
          );
          return song;
        }).toList();
      } else {
        throw Exception('Failed to get library: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Library error: $e');
    }
  }

  /// Delete a downloaded song
  /// 
  /// [filename] - Name of the file to delete
  /// 
  /// Returns true if successful
  Future<bool> deleteSong(String filename) async {
    try {
      final uri = Uri.parse('$baseUrl/song/$filename');

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete error: $e');
    }
  }

  /// Get the full URL for a song file
  /// 
  /// [filename] - Name of the MP3 file
  /// 
  /// Returns full URL to stream/download the file
  static String getSongUrl(String filename) {
    return '$baseUrl/song/$filename';
  }
}
