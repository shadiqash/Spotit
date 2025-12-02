import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../models/song.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final YoutubeExplode yt;

  SearchBloc(this.yt) : super(SearchInitial()) {
    on<SearchSongs>(_onSearchSongs);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchSongs(
    SearchSongs event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final searchResults = await yt.search.search(event.query);
      
      List<Song> songs = [];
      for (var video in searchResults.take(20)) {
        if (video is Video) {
          songs.add(Song(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            thumbnailUrl: video.thumbnails.highResUrl,
            duration: video.duration?.inSeconds.toString() ?? '0',
          ));
        }
      }
      
      emit(SearchSuccess(songs));
    } catch (e) {
      emit(SearchError('Failed to search: $e'));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
