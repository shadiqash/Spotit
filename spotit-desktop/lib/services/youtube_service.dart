import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Search YouTube for songs
  Future<List<Song>> search(String query) async {
    try {
      final searchResults = await _yt.search.search(query);
      
      List<Song> songs = [];
      
      for (var video in searchResults.take(20)) {
        if (video is Video) {
          songs.add(Song(
            videoId: video.id.value,
            title: video.title,
            artist: video.author,
            thumbnail: video.thumbnails.highResUrl,
            duration: video.duration?.inSeconds ?? 0,
            url: 'https://youtube.com/watch?v=${video.id.value}',
          ));
        }
      }
      
      return songs;
    } catch (e) {
      print('YouTube search error: $e');
      return [];
    }
  }

  /// Get audio stream URL from YouTube video with headers
  Future<Map<String, dynamic>?> getAudioUrl(String videoId) async {
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      
      // Get the best audio-only stream
      var audioStream = manifest.audioOnly.withHighestBitrate();
      
      print('Found audio stream: ${audioStream.url}');
      
      // Return both URL and headers
      return {
        'url': audioStream.url.toString(),
        'headers': {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        }
      };
    } catch (e) {
      print('CRITICAL ERROR getting audio URL: $e');
      return null;
    }
  }

  /// Get video details
  Future<Video?> getVideoDetails(String videoId) async {
    try {
      return await _yt.videos.get(videoId);
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }

  /// Download audio stream
  Stream<List<int>> getAudioStream(String videoId) async* {
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      
      yield* _yt.videos.streamsClient.get(audioStream);
    } catch (e) {
      print('Error getting audio stream: $e');
    }
  }

  void dispose() {
    _yt.close();
  }
}
