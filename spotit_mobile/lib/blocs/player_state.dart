import 'package:equatable/equatable.dart';
import '../models/song.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoadingStream extends PlayerState {
  final Song song;

  const PlayerLoadingStream(this.song);

  @override
  List<Object> get props => [song];
}

class PlayerPlaying extends PlayerState {
  final Song song;

  const PlayerPlaying(this.song);

  @override
  List<Object> get props => [song];
}

class PlayerPaused extends PlayerState {
  final Song song;

  const PlayerPaused(this.song);

  @override
  List<Object> get props => [song];
}

class PlayerStopped extends PlayerState {}

class PlayerError extends PlayerState {
  final String message;

  const PlayerError(this.message);

  @override
  List<Object> get props => [message];
}
