import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/search_bloc.dart';
import '../blocs/search_event.dart';
import '../blocs/search_state.dart';
import '../blocs/player_bloc.dart';
import '../blocs/player_event.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Music'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for songs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchBloc>().add(ClearSearch());
                  },
                ),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<SearchBloc>().add(SearchSongs(query));
                }
              },
            ),
          ),
          // Search results
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'Search for music',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                      ],
                    ),
                  );
                } else if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                } else if (state is SearchSuccess) {
                  if (state.songs.isEmpty) {
                    return Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.songs.length,
                    itemBuilder: (context, index) {
                      final song = state.songs[index];
                      return ListTile(
                        leading: song.thumbnailUrl.isNotEmpty
                            ? Image.network(song.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.music_note, color: Colors.white),
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: TextStyle(color: Colors.grey[400]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.green),
                          onPressed: () {
                            context.read<PlayerBloc>().add(PlaySong(song));
                          },
                        ),
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
