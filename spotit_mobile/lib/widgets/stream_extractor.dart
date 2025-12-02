import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/extraction_service.dart';

/// StreamExtractor - The "Sealed Black Box"
/// 
/// ⚠️ DANGER ZONE - DO NOT MODIFY ⚠️
/// 
/// This widget contains the fragile WebView extraction logic.
/// Follow RULE #1: Never touch this code unless absolutely necessary.
/// All communication happens via ExtractionService.
class StreamExtractor extends StatefulWidget {
  const StreamExtractor({Key? key}) : super(key: key);

  @override
  State<StreamExtractor> createState() => _StreamExtractorState();
}

class _StreamExtractorState extends State<StreamExtractor> {
  final ExtractionService _extractionService = ExtractionService();
  InAppWebViewController? _webController;
  StreamSubscription? _extractionSubscription;

  @override
  void initState() {
    super.initState();
    
    // Listen to extraction commands
    _extractionSubscription = _extractionService.pendingExtractions.listen((videoId) {
      _loadVideo(videoId);
    });
    
    print('🔒 StreamExtractor: Initialized');
  }

  /// Load video in WebView - EXTRACTION CODE STARTS HERE
  /// ⚠️ DO NOT MODIFY ⚠️
  Future<void> _loadVideo(String videoId) async {
    if (_webController == null) {
      print('❌ StreamExtractor: WebView not ready');
      _extractionService.onStreamError();
      return;
    }

    try {
      final url = 'https://music.youtube.com/watch?v=$videoId';
      print('🌐 StreamExtractor: Loading $url');
      await _webController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    } catch (e) {
      print('❌ StreamExtractor: Load error: $e');
      _extractionService.onStreamError();
    }
  }

  @override
  Widget build(BuildContext context) {
    // RULE #7: Keep WebView mounted forever, invisible
    return Positioned(
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
          print('🔒 StreamExtractor: WebView created');
        },
        onLoadStop: (controller, url) {
          print('🔒 StreamExtractor: Page loaded: $url');
        },
        // EXTRACTION LOGIC - DO NOT MODIFY
        shouldInterceptRequest: (controller, request) async {
          final url = request.url.toString();
          
          // Intercept audio streams from YouTube/Google Video
          if (url.contains('googlevideo.com') && 
              url.contains('videoplayback') &&
              (url.contains('mime=audio') || url.contains('itag'))) {
            print('🎵 StreamExtractor: Intercepted audio stream!');
            _extractionService.onStreamUrlReceived(url);
            return null;
          }
          
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _extractionSubscription?.cancel();
    super.dispose();
  }
}
