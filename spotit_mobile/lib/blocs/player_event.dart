import 'package:equatable/equatable.dart';
import '../models/song.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class PlaySong extends PlayerEvent {
  final Song song;

  const PlaySong(this.song);

  @override
  List<Object> get props => [song];
}

class PausePlayer extends PlayerEvent {}

class ResumePlayer extends PlayerEvent {}

class StopPlayer extends PlayerEvent {}

class SeekTo extends PlayerEvent {
  final Duration position;

  const SeekTo(this.position);

  @override
  List<Object> get props => [position];
}
