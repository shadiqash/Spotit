import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';

class WebViewBackend {
  late WebViewController _controller;
  final YoutubeExplode _yt = YoutubeExplode();
  bool _isInitialized = false;

  WebViewController get controller => _controller;

  /// Initialize the WebView
  Future<void> init() async {
    print('Initializing WebView backend...');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('WebView loaded: $url');
          },
        ),
      );

    // Enable hybrid composition for Android
    if (WebViewPlatform.instance is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _isInitialized = true;
    print('WebView initialized.');
  }

  /// Get the WebView widget (must be visible for playback to work)
  Widget getWebViewWidget() {
    return WebViewWidget(controller: _controller);
  }

  /// Search YouTube using youtube_explode_dart
  Future<List<Song>> search(String query) async {
    print('Searching YouTube for: $query');
    
    try {
      final searchResults = await _yt.search.search(query);
      
      List<Song> songs = [];
      
      for (var video in searchResults.take(20)) {
        if (video is Video) {
          songs.add(Song(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            thumbnailUrl: video.thumbnails.highResUrl,
            duration: video.duration?.inSeconds.toString() ?? '0',
          ));
        }
      }
      
      print('Found ${songs.length} songs');
      return songs;
    } catch (e) {
      print('Error searching: $e');
      return [];
    }
  }

  /// Play video in WebView (let YouTube Music handle playback)
  Future<String?> getStreamUrl(String videoId) async {
    if (!_isInitialized) await init();
    
    print('Loading YouTube Music player for: $videoId');
    
    try {
      // Load YouTube Music page in WebView
      final url = 'https://music.youtube.com/watch?v=$videoId&autoplay=1';
      await _controller.loadRequest(Uri.parse(url));
      
      // Wait for player to initialize
      await Future.delayed(const Duration(seconds: 3));
      
      // Return the URL (WebView is now playing)
      return url;
    } catch (e) {
      print('Error loading player: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    _yt.close();
  }
}
