import 'package:puppeteer/puppeteer.dart';
import '../models/song.dart';

class BrowserBackend {
  Browser? _browser;
  Page? _page;

  /// Initialize the headless browser
  Future<void> init() async {
    print('Launching headless browser...');
    // Launch browser. 
    // Note: This expects Chrome/Chromium to be installed.
    // 'headless: true' makes it invisible.
    _browser = await puppeteer.launch(
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    );
    _page = await _browser!.newPage();
    
    // Set User-Agent to look like a real Linux desktop browser
    await _page!.setUserAgent(
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
        
    print('Browser launched.');
  }

  /// Search YouTube Music
  Future<List<Song>> search(String query) async {
    if (_page == null) await init();
    
    print('Searching for: $query');
    // Navigate to search page
    await _page!.goto('https://music.youtube.com/search?q=$query', wait: Until.networkIdle);

    // Extract songs from the DOM
    // We look for 'ytmusic-responsive-list-item-renderer' which are the list items
    final result = await _page!.evaluate('''() => {
      const songs = [];
      const items = document.querySelectorAll('ytmusic-responsive-list-item-renderer');
      
      items.forEach(item => {
        // We want to ensure it's a song (usually has a play button overlay or specific metadata)
        // For simplicity, we grab items that have a title and a video ID link
        
        const titleEl = item.querySelector('.title-column .text');
        const artistEl = item.querySelector('.secondary-flex-columns .text');
        const thumbEl = item.querySelector('img');
        const linkEl = item.querySelector('a'); // The main link usually contains the video ID
        
        if (titleEl && linkEl && linkEl.href.includes('watch?v=')) {
           const videoId = linkEl.href.split('v=')[1]?.split('&')[0];
           
           if (videoId) {
             songs.push({
               id: videoId,
               title: titleEl.innerText,
               artist: artistEl ? artistEl.innerText : 'Unknown',
               thumbnailUrl: thumbEl ? thumbEl.src : '',
               duration: '0:00' // Duration is often hard to scrape from list view without hovering
             });
           }
        }
      });
      return songs;
    }''');

    List<Song> songs = [];
    if (result is List) {
      for (var item in result) {
        if (item is Map) {
          songs.add(Song(
            id: item['id'] ?? '',
            title: item['title'] ?? 'Unknown',
            artist: item['artist'] ?? 'Unknown',
            thumbnailUrl: item['thumbnailUrl'] ?? '',
            duration: item['duration'] ?? '0:00',
          ));
        }
      }
    }
    
    // Deduplicate based on ID
    final uniqueSongs = <String, Song>{};
    for (var s in songs) {
      uniqueSongs[s.id] = s;
    }
    
    return uniqueSongs.values.toList();
  }

  /// Get the audio stream URL for a video ID
  Future<String?> getStreamUrl(String videoId) async {
    if (_page == null) await init();
    
    print('Getting stream for: $videoId');
    
    String? audioUrl;
    
    // Listen for network responses to find the audio stream
    // YouTube streams usually come from googlevideo.com and have mime=audio
    var responseListener = _page!.onResponse.listen((response) {
      if (response.url.contains('googlevideo.com') && 
          response.url.contains('videoplayback') && 
          response.url.contains('mime=audio')) {
        print('Found audio stream: ${response.url}');
        audioUrl = response.url;
      }
    });

    // Navigate to the video page
    await _page!.goto('https://music.youtube.com/watch?v=$videoId');
    
    // Wait for a few seconds to allow the player to start and requests to fire
    // We can't wait indefinitely, so we poll or wait for a fixed time
    int retries = 0;
    while (audioUrl == null && retries < 10) {
      await Future.delayed(Duration(milliseconds: 500));
      retries++;
    }
    
    await responseListener.cancel();
    
    return audioUrl;
  }

  /// Close the browser
  Future<void> close() async {
    await _browser?.close();
    _browser = null;
    _page = null;
  }
}
