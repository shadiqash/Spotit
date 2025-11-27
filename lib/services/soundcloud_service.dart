import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';
import '../models/song.dart';

class SoundCloudService {
  final SoundcloudClient _client = SoundcloudClient();

  /// Search for tracks on SoundCloud
  Future<List<Song>> searchSongs(String query) async {
    try {
      final List<Song> songs = [];
      
      await for (var batch in _client.search(query)) {
        for (var result in batch) {
          if (songs.length >= 20) break;

          // Check if it looks like a track (has title and id)
          // The runtime type is internal, so we check properties dynamically or by string
          if (result.toString().contains('Track') || result.runtimeType.toString().contains('Track')) {
              final dynamic track = result;
              songs.add(Song(
                videoId: track.id.toString(),
                title: track.title,
                artist: track.user.username,
                thumbnail: track.artworkUrl?.toString() ?? track.user.avatarUrl?.toString() ?? '',
                duration: ((track.duration as num?)?.toInt() ?? 0) ~/ 1000,
                url: track.permalinkUrl?.toString() ?? '',
                isSoundCloud: true,
              ));
          }
        }
        if (songs.length >= 20) break;
      }
      return songs;
    } catch (e) {
      print('SoundCloud search error: $e');
      return [];
    }
  }

  /// Get direct audio stream URL
  Future<String?> getStreamUrl(String trackId) async {
    try {
      final id = int.parse(trackId);
      final streams = await _client.tracks.getStreams(id);
      
      // Try to find a valid stream
      for (var stream in streams) {
        // Use dynamic to access 'url' property as found in testing
        final dynamic s = stream;
        return s.url.toString();
      }
      
      return null;
    } catch (e) {
      print('SoundCloud stream error: $e');
      return null;
    }
  }
}
