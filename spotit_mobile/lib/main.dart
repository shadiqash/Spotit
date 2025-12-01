import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:just_audio/just_audio.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/library_page.dart';
import 'pages/full_player_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpotitApp());
}

class SpotitApp extends StatelessWidget {
  const SpotitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotit',
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _yt = YoutubeExplode();
  final _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  InAppWebViewController? _webController;
  
  String? _currentSong;
  String? _currentArtist;
  String? _currentThumbnail;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _audioPlayer.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  Future<void> _play(Video video) async {
    setState(() {
      _isLoading = true;
      _currentSong = video.title;
      _currentArtist = video.author;
      _currentThumbnail = video.thumbnails.mediumResUrl;
    });

    try {
      final videoId = video.id.value;
      final url = 'https://music.youtube.com/watch?v=$videoId';
      
      print('Loading YouTube Music: $url');
      await _webController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    } catch (e) {
      print('Play error: $e');
      setState(() => _isLoading = false);
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

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      SearchPage(onPlay: _play, yt: _yt),
      const LibraryPage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Pages
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          
          // Hidden InAppWebView for stream interception
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
                
                if (url.contains('googlevideo.com') && 
                    url.contains('videoplayback') &&
                    (url.contains('mime=audio') || url.contains('itag'))) {
                  print('🎵 Intercepted audio stream!');
                  _handleStreamUrl(url);
                  return null;
                }
                
                return null;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player
          if (_currentSong != null)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullPlayerPage(
                      songTitle: _currentSong!,
                      artist: _currentArtist ?? 'Unknown',
                      thumbnailUrl: _currentThumbnail,
                      audioPlayer: _audioPlayer,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.darkPurple.withOpacity(0.3), AppTheme.primaryPurple.withOpacity(0.3)],
                  ),
                  border: Border(
                    top: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.3)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                children: [
                  // Album art placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.darkPurple],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentSong!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_currentArtist != null)
                          Text(
                            _currentArtist!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (_isLoading)
                          Text(
                            'Loading stream...',
                            style: TextStyle(
                              color: AppTheme.primaryPurple,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryPurple,
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryPurple, AppTheme.darkPurple],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Bottom Navigation
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(color: AppTheme.surfaceVariant),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryPurple,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined),
                  activeIcon: Icon(Icons.library_music),
                  label: 'Library',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _yt.close();
    _audioPlayer.dispose();
    super.dispose();
  }
}
