import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:just_audio/just_audio.dart'; // For PlayerState enum

class WebViewPlayerService {
  HeadlessInAppWebView? _headlessWebView;
  bool _isInitialized = false;
  
  // Streams
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri("about:blank")),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        iframeAllowFullscreen: true,
      ),
      onWebViewCreated: (controller) {
        // Setup JS handlers
        controller.addJavaScriptHandler(handlerName: 'onStateChange', callback: (args) {
          final state = args[0] as int;
          // Map YouTube states to JustAudio states
          // -1: unstarted, 0: ended, 1: playing, 2: paused, 3: buffering, 5: video cued
          if (state == 1) {
            _playerStateController.add(PlayerState(true, ProcessingState.ready));
          } else if (state == 2) {
            _playerStateController.add(PlayerState(false, ProcessingState.ready));
          } else if (state == 0) {
            _playerStateController.add(PlayerState(false, ProcessingState.completed));
          } else if (state == 3) {
            _playerStateController.add(PlayerState(true, ProcessingState.buffering));
          }
        });

        controller.addJavaScriptHandler(handlerName: 'onProgress', callback: (args) {
          final currentTime = (args[0] as num).toDouble();
          final duration = (args[1] as num).toDouble();
          _positionController.add(Duration(milliseconds: (currentTime * 1000).toInt()));
          _durationController.add(Duration(milliseconds: (duration * 1000).toInt()));
        });
      },
      onConsoleMessage: (controller, consoleMessage) {
        print("WebView Console: ${consoleMessage.message}");
      },
    );

    await _headlessWebView?.run();
    _isInitialized = true;
  }

  Future<void> loadVideo(String videoId) async {
    if (!_isInitialized) await init();

    final html = '''
      <!DOCTYPE html>
      <html>
      <body>
        <div id="player"></div>
        <script>
          var tag = document.createElement('script');
          tag.src = "https://www.youtube.com/iframe_api";
          var firstScriptTag = document.getElementsByTagName('script')[0];
          firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

          var player;
          function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
              height: '100%',
              width: '100%',
              videoId: '$videoId',
              playerVars: {
                'playsinline': 1,
                'autoplay': 1,
                'controls': 0
              },
              events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange
              }
            });
          }

          function onPlayerReady(event) {
            event.target.playVideo();
            startProgressLoop();
          }

          function onPlayerStateChange(event) {
            window.flutter_inappwebview.callHandler('onStateChange', event.data);
          }

          function startProgressLoop() {
            setInterval(function() {
              if (player && player.getCurrentTime) {
                window.flutter_inappwebview.callHandler('onProgress', player.getCurrentTime(), player.getDuration());
              }
            }, 500);
          }
        </script>
      </body>
      </html>
    ''';

    await _headlessWebView?.webViewController?.loadData(data: html);
  }

  Future<void> play() async {
    await _headlessWebView?.webViewController?.evaluateJavascript(source: "player.playVideo();");
  }

  Future<void> pause() async {
    await _headlessWebView?.webViewController?.evaluateJavascript(source: "player.pauseVideo();");
  }

  Future<void> seek(Duration position) async {
    final seconds = position.inSeconds;
    await _headlessWebView?.webViewController?.evaluateJavascript(source: "player.seekTo($seconds, true);");
  }

  void dispose() {
    _headlessWebView?.dispose();
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
  }
}
