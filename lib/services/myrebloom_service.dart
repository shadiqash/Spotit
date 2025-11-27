import 'package:http/http.dart' as http;
import 'dart:convert';

class MyRebloomService {
  static const String _baseUrl = 'https://www.myrebloom.fr';
  
  /// Get MP3 download URL from myrebloom.fr
  Future<String> getAudioUrl(String youtubeUrl) async {
    try {
      print('Requesting conversion from myrebloom.fr...');
      
      // myrebloom.fr API endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/api/json'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: json.encode({
          'url': youtubeUrl,
          'vQuality': 'max',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract download URL from response
        final downloadUrl = data['url'] ?? data['download'] ?? data['dlink'];
        
        if (downloadUrl != null) {
          print('myrebloom.fr conversion successful: $downloadUrl');
          return downloadUrl;
        }
      }
      
      throw Exception('myrebloom.fr conversion failed: ${response.statusCode}');
    } catch (e) {
      print('myrebloom.fr error: $e');
      rethrow;
    }
  }
}
