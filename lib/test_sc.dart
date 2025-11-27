import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

void main() async {
  final client = SoundcloudClient();
  print('Starting SoundCloud test...');
  
  // Test 1: Search
  print('\n--- Testing Search ---');
  try {
    int count = 0;
    await for (var batch in client.search('Shape of You')) {
      for (var result in batch) {
        print('Found result type: ${result.runtimeType}');
        if (result.toString().contains('Track') || result.runtimeType.toString().contains('Track')) {
          final dynamic track = result;
          print('Track found: ${track.title} (ID: ${track.id})');
          
          // Test 2: Stream extraction
          print('\n--- Testing Stream Extraction for ${track.id} ---');
          try {
            final streams = await client.tracks.getStreams(track.id!);
            print('Streams found: ${streams.length}');
            for (var stream in streams) {
              print('Stream Object: $stream');
              // Use dynamic to check properties at runtime
              final dynamic s = stream;
              try { print('s.url: ${s.url}'); } catch(e) { print('No url prop'); }
              try { print('s.streamUrl: ${s.streamUrl}'); } catch(e) { print('No streamUrl prop'); }
              try { print('s.httpMp3128Url: ${s.httpMp3128Url}'); } catch(e) { print('No httpMp3128Url prop'); }
            }
          } catch (e) {
            print('Stream extraction error: $e');
          }
          return; // Exit after first track
        }
      }
      // Keep searching batches until we find a track
      if (count++ > 10) break; // Safety break after 10 batches
    }
    print('No tracks found after searching batches.');
  } catch (e) {
    print('Search error: $e');
  }
}
