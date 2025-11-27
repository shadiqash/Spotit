import 'package:http/http.dart' as http;
import 'dart:convert';

class YtMp3Service {
  static const String _baseUrl = 'https://ytmp3.as';
  
  /// Get MP3 download URL from ytmp3.as
  Future<String> getAudioUrl(String youtubeUrl) async {
    try {
      print('Requesting conversion from ytmp3.as...');
      
      // ytmp3.as API endpoint (might need adjustment based on their API)
      final response = await http.post(
        Uri.parse('$_baseUrl/api/convert'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: json.encode({
          'url': youtubeUrl,
          'format': 'mp3',
          'quality': '128',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract download URL (adjust based on actual API response)
        final downloadUrl = data['download_url'] ?? data['url'] ?? data['link'];
        
        if (downloadUrl != null) {
          print('ytmp3.as conversion successful: $downloadUrl');
          return downloadUrl;
        }
      }
      
      throw Exception('ytmp3.as conversion failed: ${response.statusCode}');
    } catch (e) {
      print('ytmp3.as error: $e');
      rethrow;
    }
  }
}
