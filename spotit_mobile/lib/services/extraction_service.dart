import 'dart:async';

class ExtractionService {
  // Singleton instance
  static final ExtractionService _instance = ExtractionService._internal();
  factory ExtractionService() => _instance;
  ExtractionService._internal();

  // Rule #2: Command API
  final _pendingExtractions = StreamController<String>.broadcast();
  Stream<String> get pendingExtractions => _pendingExtractions.stream;

  // Rule #4: Extraction Result Channel
  final _streamUrlController = StreamController<String>.broadcast();
  Stream<String> get streamUrlStream => _streamUrlController.stream;

  final _errorController = StreamController<void>.broadcast();
  Stream<void> get errorStream => _errorController.stream;

  // Rule #5: Extraction Locks
  bool _isExtracting = false;

  // Rule #6: Throttling
  DateTime _lastExtract = DateTime(0);
  static const int _throttleMs = 300;

  /// Request extraction of a video ID
  void extract(String videoId) {
    // Rule #6: Throttle
    if (DateTime.now().difference(_lastExtract).inMilliseconds < _throttleMs) {
      print('⚠️ Extraction throttled for $videoId');
      return;
    }
    
    // Rule #5: Lock
    if (_isExtracting) {
      print('⚠️ Extraction locked. Already extracting.');
      return;
    }

    _lastExtract = DateTime.now();
    _isExtracting = true;
    
    print('🚀 ExtractionService: Requesting extraction for $videoId');
    _pendingExtractions.add(videoId);
  }

  /// Called by StreamExtractor when URL is found
  void onStreamUrlReceived(String url) {
    print('✅ ExtractionService: URL received');
    _isExtracting = false;
    _streamUrlController.add(url);
  }

  /// Called by StreamExtractor when error occurs
  void onStreamError() {
    print('❌ ExtractionService: Error received');
    _isExtracting = false;
    _errorController.add(null);
  }

  void dispose() {
    _pendingExtractions.close();
    _streamUrlController.close();
    _errorController.close();
  }
}
