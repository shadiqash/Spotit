import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'providers/search_provider.dart';
import 'providers/player_provider.dart';
import 'widgets/desktop_sidebar.dart';
import 'widgets/desktop_player.dart';
import 'pages/desktop_home_page.dart';
import 'pages/desktop_search_page.dart';

void main() {
  // Initialize just_audio_media_kit for Linux
  JustAudioMediaKit.ensureInitialized();
  
  runApp(const SpotitDesktopApp());
}

class SpotitDesktopApp extends StatelessWidget {
  const SpotitDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Spotit Desktop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFF1DB954), // Spotify Green
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1DB954),
            surface: Color(0xFF121212),
            background: Color(0xFF121212),
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const DesktopMainScreen(),
      ),
    );
  }
}

class DesktopMainScreen extends StatefulWidget {
  const DesktopMainScreen({super.key});

  @override
  State<DesktopMainScreen> createState() => _DesktopMainScreenState();
}

class _DesktopMainScreenState extends State<DesktopMainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const DesktopHomePage(),
    const DesktopSearchPage(),
    const Center(child: Text('Library (Coming Soon)')),
    const Center(child: Text('Install App')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar
                DesktopSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
                
                // Main Content
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
          
          // Bottom Player Bar
          const DesktopPlayer(),
        ],
      ),
    );
  }
}
