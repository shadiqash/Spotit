import 'dart:convert';
import 'package:http/http.dart' as http;

class SkipSegment {
  final double start;
  final double end;
  final String category;

  SkipSegment({
    required this.start,
    required this.end,
    required this.category,
  });

  factory SkipSegment.fromJson(Map<String, dynamic> json) {
    // API returns segment as [start, end]
    final segment = json['segment'];
    return SkipSegment(
      start: (segment[0] as num).toDouble(),
      end: (segment[1] as num).toDouble(),
      category: json['category'] as String,
    );
  }
}

class SponsorBlockService {
  static const String _baseUrl = 'https://sponsor.ajay.app/api/skipSegments';
  
  // Categories to skip
  static const List<String> _categoriesToSkip = [
    'sponsor',
    'intro',
    'outro',
    'selfpromo',
    'interaction',
    'music_offtopic'
  ];

  Future<List<SkipSegment>> getSkipSegments(String videoId) async {
    try {
      final uri = Uri.parse('$_baseUrl?videoID=$videoId&categories=${jsonEncode(_categoriesToSkip)}');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final segments = data.map((json) => SkipSegment.fromJson(json)).toList();
        
        // Sort segments by start time
        segments.sort((a, b) => a.start.compareTo(b.start));
        return segments;
      } else if (response.statusCode == 404) {
        // No segments found for this video
        return [];
      } else {
        print('SponsorBlock API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching skip segments: $e');
      return [];
    }
  }
}
