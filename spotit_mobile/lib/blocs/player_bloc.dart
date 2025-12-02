import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/playback_service.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlaybackService playbackService;

  PlayerBloc(this.playbackService) : super(PlayerInitial()) {
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
    // PlaybackService handles everything internally
    playbackService.play(event.song);
    // State updates will come from stream listeners
    emit(PlayerPlaying(event.song));
  }

  Future<void> _onPausePlayer(
    PausePlayer event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPlaying) {
      final currentSong = (state as PlayerPlaying).song;
      await playbackService.pause();
      emit(PlayerPaused(currentSong));
    }
  }

  Future<void> _onResumePlayer(
    ResumePlayer event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPaused) {
      final currentSong = (state as PlayerPaused).song;
      await playbackService.resume();
      emit(PlayerPlaying(currentSong));
    }
  }

  Future<void> _onStopPlayer(
    StopPlayer event,
    Emitter<PlayerState> emit,
  ) async {
    // Stop not currently supported in PlaybackService
    emit(PlayerStopped());
  }

  Future<void> _onSeekTo(
    SeekTo event,
    Emitter<PlayerState> emit,
  ) async {
    await playbackService.seek(event.position);
  }
}
