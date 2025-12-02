import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/player_bloc.dart';
import '../blocs/player_state.dart';
import '../blocs/player_event.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state is PlayerInitial || state is PlayerStopped) {
          return const SizedBox.shrink();
        }

        String title = '';
        String artist = '';
        bool isPlaying = false;
        bool isLoading = false;

        if (state is PlayerLoadingStream) {
          title = state.song.title;
          artist = state.song.artist;
          isLoading = true;
        } else if (state is PlayerPlaying) {
          title = state.song.title;
          artist = state.song.artist;
          isPlaying = true;
        } else if (state is PlayerPaused) {
          title = state.song.title;
          artist = state.song.artist;
        } else if (state is PlayerError) {
          title = 'Error';
          artist = state.message;
        }

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Controls
              if (isLoading)
                const CircularProgressIndicator(color: Colors.green, strokeWidth: 2)
              else
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          context.read<PlayerBloc>().add(PausePlayer());
                        } else {
                          context.read<PlayerBloc>().add(ResumePlayer());
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop, color: Colors.white),
                      onPressed: () {
                        context.read<PlayerBloc>().add(StopPlayer());
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
