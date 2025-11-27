import 'dart:convert';
import 'package:http/http.dart' as http;

class CobaltService {
  // List of Cobalt instances to try
  final List<String> _instances = [
    'https://api.cobalt.tools',
    'https://co.wuk.sh',
    'https://cobalt.stealth.si',
  ];

  /// Get audio URL using Cobalt API (acting as a converter)
  Future<String> getAudioUrl(String videoUrl) async {
    for (final instance in _instances) {
      try {
        final url = await _tryInstance(instance, videoUrl);
        if (url != null) {
          print('Successfully converted via $instance');
          return url;
        }
      } catch (e) {
        print('Failed with instance $instance: $e');
      }
    }
    throw Exception('All converter instances failed');
  }

  Future<String?> _tryInstance(String baseUrl, String videoUrl) async {
    final uri = Uri.parse('$baseUrl/api/json');
    
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'url': videoUrl,
        'isAudioOnly': true,
        'aFormat': 'mp3', // Request MP3 conversion
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Check for success
      if (data['status'] == 'stream' || data['status'] == 'redirect') {
        return data['url'] as String;
      }
      
      if (data['status'] == 'picker') {
        // If it returns multiple, pick the first audio one
        final picker = data['picker'] as List;
        for (var item in picker) {
          if (item['type'] == 'audio') {
            return item['url'] as String;
          }
        }
      }
    }
    
    return null;
  }
}
