import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MinimalMusicApp());
}

class MinimalMusicApp extends StatelessWidget {
  const MinimalMusicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MusicPlayer(),
    );
  }
}

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final _searchController = TextEditingController();
  final _yt = YoutubeExplode();
  final _audioPlayer = AudioPlayer();
  
  InAppWebViewController? _webController;
  
  List<Video> _results = [];
  bool _isSearching = false;
  String? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _results = [];
    });

    try {
      final results = await _yt.search.search(query);
      setState(() {
        _results = results.whereType<Video>().take(20).toList();
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _play(Video video) async {
    setState(() {
      _isLoading = true;
      _currentSong = video.title;
    });

    try {
      // Load YouTube Music page and intercept stream URL
      final videoId = video.id.value;
      final url = 'https://music.youtube.com/watch?v=$videoId';
      
      print('Loading YouTube Music: $url');
      await _webController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      
      // The stream URL will be intercepted by shouldInterceptRequest
      // and played automatically
    } catch (e) {
      print('Play error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _handleStreamUrl(String streamUrl) async {
    print('Playing stream: $streamUrl');
    
    try {
      await _audioPlayer.setUrl(streamUrl);
      await _audioPlayer.play();
      
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    } catch (e) {
      print('Audio player error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search YouTube Music...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _search,
              ),
            ),
            
            // Results
            Expanded(
              child: Stack(
                children: [
                  // Hidden InAppWebView (for intercepting network requests)
                  Positioned(
                    left: -1000,
                    top: -1000,
                    width: 100,
                    height: 100,
                    child: InAppWebView(
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                      ),
                      onWebViewCreated: (controller) {
                        _webController = controller;
                        print('WebView created');
                      },
                      onLoadStop: (controller, url) {
                        print('Page loaded: $url');
                      },
                      shouldInterceptRequest: (controller, request) async {
                        final url = request.url.toString();
                        
                        // Intercept YouTube audio streams
                        if (url.contains('googlevideo.com') && 
                            url.contains('videoplayback') &&
                            (url.contains('mime=audio') || url.contains('itag'))) {
                          print('🎵 Intercepted audio stream!');
                          print('URL: $url');
                          
                          // Play this stream
                          _handleStreamUrl(url);
                          
                          // Allow the request to continue
                          return null;
                        }
                        
                        return null;
                      },
                    ),
                  ),
                  
                  // Content layer
                  Container(
                    color: Colors.black,
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, i) {
                              final video = _results[i];
                              return ListTile(
                                title: Text(
                                  video.title,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  video.author,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                                  onPressed: () => _play(video),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            
            // Player controls
            if (_currentSong != null)
              Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentSong!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_isLoading)
                            const Text(
                              'Loading stream...',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _yt.close();
    _audioPlayer.dispose();
    super.dispose();
  }
}
