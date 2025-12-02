import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/library_page.dart';
import 'pages/full_player_page.dart';
import 'services/playback_service.dart';
import 'services/queue_service.dart';
import 'widgets/stream_extractor.dart';
import 'models/song.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize PlaybackService
  PlaybackService().init();
  
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
  final _playbackService = PlaybackService();
  final _queueService = QueueService();
  
  int _currentIndex = 0;
  
  // UI state from streams
  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _shuffleEnabled = false;
  int _repeatMode = 0;

  @override
  void initState() {
    super.initState();
    
    // Listen to current song changes
    _queueService.currentSongStream.listen((song) {
      if (mounted) {
        setState(() => _currentSong = song);
      }
    });
    
    // Listen to playback state
    _playbackService.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
      }
    });
    
    // Listen to loading state
    _playbackService.isLoadingStream.listen((loading) {
      if (mounted) {
        setState(() => _isLoading = loading);
      }
    });
    
    // Listen to shuffle state
    _queueService.shuffleStream.listen((shuffled) {
      if (mounted) {
        setState(() => _shuffleEnabled = shuffled);
      }
    });
    
    // Listen to repeat mode
    _queueService.repeatStream.listen((mode) {
      if (mounted) {
        setState(() => _repeatMode = mode);
      }
    });
  }

  void _onPlay(Video video, List<Video> allResults) {
    // Convert Video to Song
    final songs = allResults.map((v) => Song(
      id: v.id.value,
      title: v.title,
      artist: v.author,
      thumbnailUrl: v.thumbnails.highResUrl,
      duration: v.duration?.inSeconds.toString() ?? '0',
    )).toList();
    
    final selectedSong = Song(
      id: video.id.value,
      title: video.title,
      artist: video.author,
      thumbnailUrl: video.thumbnails.highResUrl,
      duration: video.duration?.inSeconds.toString() ?? '0',
    );
    
    // Set the queue
    final index = songs.indexWhere((s) => s.id == selectedSong.id);
    _queueService.setQueue(songs, startIndex: index >= 0 ? index : 0);
    
    // Play the song
    _playbackService.play(selectedSong);
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _playbackService.pause();
    } else {
      await _playbackService.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      SearchPage(
        onPlay: _onPlay,
        yt: _yt,
      ),
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
          
          // RULE #7: StreamExtractor mounted forever, invisible
          const StreamExtractor(),
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
                      queueService: _queueService,
                      playbackService: _playbackService,
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
                          _currentSong!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _currentSong!.artist,
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
    super.dispose();
  }
}
