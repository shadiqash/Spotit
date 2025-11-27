import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Search for songs on YouTube (Direct via YoutubeExplode - bypasses Piped)
  Future<List<Song>> search(String query, {int limit = 20}) async {
    try {
      print('Searching via YoutubeExplode: $query');
      final searchList = await _yt.search.getVideos(query);
      
      return searchList.take(limit).map((video) {
        return Song(
          videoId: video.id.value,
          title: video.title,
          artist: video.author,
          thumbnail: video.thumbnails.highResUrl,
          duration: video.duration?.inSeconds ?? 0,
          url: video.url,
          isDownloaded: false,
        );
      }).toList();
    } catch (e) {
      print('Search error: $e');
      throw Exception('Search error: $e');
    }
  }

  /// Get audio stream URL for a video with improved fallback
  Future<String> getAudioUrl(String videoId) async {
    try {
      print('Fetching manifest for video: $videoId');
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioOnly = manifest.audioOnly;
      
      if (audioOnly.isEmpty) {
        throw Exception('No audio streams available');
      }
      
      print('Found ${audioOnly.length} audio streams');
      
      // Try multiple stream formats in order of compatibility
      StreamInfo? selectedStream;
      
      // 1. Try MP4 AAC (best compatibility with just_audio)
      try {
        selectedStream = audioOnly.firstWhere(
          (s) => s.container == StreamContainer.mp4,
        );
        print('Using MP4 stream');
      } catch (_) {
        print('No MP4 stream found');
      }
      
      // 2. Fallback to highest bitrate audio
      selectedStream ??= audioOnly.withHighestBitrate();
      
      print('Selected: ${selectedStream!.container.name} | ${selectedStream.bitrate.bitsPerSecond ~/ 1000}kbps | ${selectedStream.size.totalMegaBytes.toStringAsFixed(1)}MB');
      print('Stream URL: ${selectedStream.url}');
      
      return selectedStream.url.toString();
    } catch (e) {
      print('Stream fetch error for $videoId: $e');
      throw Exception('Failed to get audio stream: $e');
    }
  }

  /// Get video details
  Future<Song> getVideoDetails(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      return Song(
        videoId: video.id.value,
        title: video.title,
        artist: video.author,
        thumbnail: video.thumbnails.highResUrl,
        duration: video.duration?.inSeconds ?? 0,
        url: video.url,
        isDownloaded: false,
      );
    } catch (e) {
      throw Exception('Details error: $e');
    }
  }

  void dispose() {
    _yt.close();
  }
}
