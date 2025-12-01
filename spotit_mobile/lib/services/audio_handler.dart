import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer;
  
  AudioPlayerHandler(this._audioPlayer) {
    // Listen to player state and update MediaItem/PlaybackState
    _audioPlayer.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[state.processingState]!,
      ));
    });
    
    // Listen to position for notification progress
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> stop() => _audioPlayer.stop();
  
  Future<void> updateNowPlaying({
    required String title,
    required String artist,
    String? artUri,
  }) async {
    mediaItem.add(MediaItem(
      id: title,
      title: title,
      artist: artist,
      artUri: artUri != null ? Uri.parse(artUri) : null,
    ));
  }
}
