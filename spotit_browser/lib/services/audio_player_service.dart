import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Play audio from a URL
  Future<void> play(String url) async {
    try {
      print('AudioPlayerService: Playing $url');
      // We might need to set headers if the URL is signed/restricted, 
      // but for now we assume the scraped URL is valid for a short time.
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      print('Error playing audio: $e');
      throw e;
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }
  
  Future<void> resume() async {
    await _player.play();
  }
  
  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  
  void dispose() {
    _player.dispose();
  }
}
