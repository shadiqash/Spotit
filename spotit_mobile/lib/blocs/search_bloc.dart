import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/webview_backend.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final WebViewBackend webViewBackend;

  SearchBloc(this.webViewBackend) : super(SearchInitial()) {
    on<SearchSongs>(_onSearchSongs);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchSongs(
    SearchSongs event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final songs = await webViewBackend.search(event.query);
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
