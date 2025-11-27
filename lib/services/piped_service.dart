import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class PipedService {
  // List of Piped instances to try
  static const List<String> _instances = [
    'https://pipedapi.kavin.rocks',
    'https://pipedapi.syncpundit.com',
    'https://pipedapi.esmailelbob.xyz',
    'https://pipedapi.nosebs.ru',
    'https://api.piped.privacy.com.de',
  ];

  int _currentInstanceIndex = 0;

  // Helper to get current instance
  String get _baseUrl => _instances[_currentInstanceIndex];

  // Rotate to next instance
  void _rotateInstance() {
    _currentInstanceIndex = (_currentInstanceIndex + 1) % _instances.length;
    print('Switched to Piped instance: $_baseUrl');
  }

  // DNS over HTTPS (DoH) resolver
  Future<String?> _resolveHostname(String hostname) async {
    // Try Google DNS (8.8.8.8) directly via IP to avoid DNS lookup for the resolver
    try {
      print('Attempting DoH lookup for $hostname via 8.8.8.8...');
      final response = await http.get(
        Uri.parse('https://8.8.8.8/resolve?name=$hostname&type=A'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Answer'] != null && data['Answer'].isNotEmpty) {
          final ip = data['Answer'][0]['data'];
          print('DoH resolved $hostname -> $ip');
          return ip;
        }
      }
    } catch (e) {
      print('Google DoH failed: $e');
    }

    // Try Cloudflare DNS (1.1.1.1) as backup
    try {
      print('Attempting DoH lookup for $hostname via 1.1.1.1...');
      final response = await http.get(
        Uri.parse('https://1.1.1.1/dns-query?name=$hostname&type=A'),
        headers: {'Accept': 'application/dns-json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Answer'] != null && data['Answer'].isNotEmpty) {
          final ip = data['Answer'][0]['data'];
          print('DoH resolved $hostname -> $ip');
          return ip;
        }
      }
    } catch (e) {
      print('Cloudflare DoH failed: $e');
    }
    
    return null;
  }

  // Hardcoded IP map to bypass DNS
  static const Map<String, String> _hardcodedIps = {
    'pipedapi.kavin.rocks': '104.21.38.236', // Cloudflare
    'api.piped.privacy.com.de': '188.114.97.3', // Cloudflare
  };

  Future<List<Song>> search(String query) async {
    Exception? lastError;

    // Try each instance
    for (var i = 0; i < _instances.length; i++) {
      try {
        final baseUrl = _baseUrl;
        final hostname = Uri.parse(baseUrl).host;
        
        // Check for hardcoded IP
        if (_hardcodedIps.containsKey(hostname)) {
          final ip = _hardcodedIps[hostname]!;
          print('Using hardcoded IP $ip for $hostname');
          final ipUrl = baseUrl.replaceFirst(hostname, ip);
          return await _performSearch(ipUrl, query, hostHeader: hostname);
        }
        
        return await _performSearch(baseUrl, query);
      } catch (e) {
        print('Instance $_baseUrl failed: $e');
        lastError = e as Exception;
        
        // DoH fallback (keep as backup)
        if (e.toString().contains('Failed host lookup')) {
           // ... existing DoH logic ...
        }
        
        _rotateInstance();
      }
    }
    throw lastError ?? Exception('All Piped instances failed');
  }

  Future<List<Song>> _performSearch(String baseUrl, String query, {String? hostHeader}) async {
    final uri = Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}&filter=videos');
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-User': '?1',
      'Upgrade-Insecure-Requests': '1',
    };
    if (hostHeader != null) {
      headers['Host'] = hostHeader;
    }

    final response = await http.get(uri, headers: headers).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Connection timed out');
      },
    );
    // ... rest of method

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;

      return items.where((item) => item['type'] == 'stream').map((item) {
        final duration = item['duration'] ?? 0;
        return Song(
          videoId: item['url'].toString().replaceAll('/watch?v=', ''),
          title: item['title'],
          artist: item['uploaderName'],
          thumbnail: item['thumbnail'],
          duration: duration is int ? duration : (duration as double).toInt(),
          url: 'https://youtube.com${item['url']}',
          isDownloaded: false,
        );
      }).toList();
    } else {
      throw Exception('Search failed: ${response.statusCode}');
    }
  }

  Future<String> getAudioUrl(String videoId) async {
    Exception? lastError;

    for (var i = 0; i < _instances.length; i++) {
      try {
        final baseUrl = _baseUrl;
        final hostname = Uri.parse(baseUrl).host;
        
        // Check for hardcoded IP
        if (_hardcodedIps.containsKey(hostname)) {
          final ip = _hardcodedIps[hostname]!;
          print('Using hardcoded IP $ip for $hostname');
          final ipUrl = baseUrl.replaceFirst(hostname, ip);
          return await _performGetAudioUrl(ipUrl, videoId, hostHeader: hostname);
        }

        return await _performGetAudioUrl(baseUrl, videoId);
      } catch (e) {
        print('Instance $_baseUrl failed: $e');
        lastError = e as Exception;
        _rotateInstance();
      }
    }
    throw lastError ?? Exception('All Piped instances failed');
  }

  Future<String> _performGetAudioUrl(String baseUrl, String videoId, {String? hostHeader}) async {
    final uri = Uri.parse('$baseUrl/streams/$videoId');
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-User': '?1',
      'Upgrade-Insecure-Requests': '1',
    };
    if (hostHeader != null) {
      headers['Host'] = hostHeader;
    }

    final response = await http.get(uri, headers: headers).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Connection timed out');
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final audioStreams = data['audioStreams'] as List;
      
      if (audioStreams.isEmpty) {
        throw Exception('No audio streams found');
      }

      // Prefer m4a/mp4 and 128kbps (or highest)
      audioStreams.sort((a, b) {
        final bitrateA = a['bitrate'] ?? 0;
        final bitrateB = b['bitrate'] ?? 0;
        return bitrateB.compareTo(bitrateA);
      });

      return audioStreams.first['url'];
    } else {
      throw Exception('Failed to load stream: ${response.statusCode}');
    }
  }
}
