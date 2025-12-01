import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/webview_backend.dart';
import '../services/audio_player_service.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final WebViewBackend webViewBackend;
  final AudioPlayerService audioPlayerService;

  PlayerBloc(this.webViewBackend, this.audioPlayerService)
      : super(PlayerInitial()) {
    on<PlaySong>(_onPlaySong);
    on<PausePlayer>(_onPausePlayer);
    on<ResumePlayer>(_onResumePlayer);
    on<StopPlayer>(_onStopPlayer);
    on<SeekTo>(_onSeekTo);
  }

  Future<void> _onPlaySong(
    PlaySong event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoadingStream(event.song));
    try {
      // Get the stream URL from YouTube Music
      final streamUrl = await webViewBackend.getStreamUrl(event.song.id);
      
      if (streamUrl == null) {
        emit(PlayerError('Failed to get stream URL'));
        return;
      }

      // Play the audio
      await audioPlayerService.play(streamUrl);
      emit(PlayerPlaying(event.song));
    } catch (e) {
      emit(PlayerError('Failed to play: $e'));
    }
  }

  Future<void> _onPausePlayer(
    PausePlayer event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPlaying) {
      final currentSong = (state as PlayerPlaying).song;
      await audioPlayerService.pause();
      emit(PlayerPaused(currentSong));
    }
  }

  Future<void> _onResumePlayer(
    ResumePlayer event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPaused) {
      final currentSong = (state as PlayerPaused).song;
      await audioPlayerService.resume();
      emit(PlayerPlaying(currentSong));
    }
  }

  Future<void> _onStopPlayer(
    StopPlayer event,
    Emitter<PlayerState> emit,
  ) async {
    await audioPlayerService.stop();
    emit(PlayerStopped());
  }

  Future<void> _onSeekTo(
    SeekTo event,
    Emitter<PlayerState> emit,
  ) async {
    await audioPlayerService.seek(event.position);
  }
}
