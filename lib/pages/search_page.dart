/**
 * Search Page
 * 
 * Main search interface for finding songs on YouTube.
 * Displays search bar and results list.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchProvider>().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.green,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for songs...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().clearResults();
                        },
                      )
                    : null,
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide clear button
              },
            ),
          ),
          
          // Results
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (searchProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchProvider.error!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _performSearch(_searchController.text),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!searchProvider.hasResults) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchProvider.query.isEmpty
                              ? 'Search for your favorite songs'
                              : 'No results found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: searchProvider.results.length,
                  itemBuilder: (context, index) {
                    final song = searchProvider.results[index];
                    
                    return Consumer<LibraryProvider>(
                      builder: (context, libraryProvider, child) {
                        final downloadProgress = libraryProvider.getDownloadProgress(song.videoId);
                        final isDownloaded = libraryProvider.isDownloaded(song.videoId);
                        
                        return SongTile(
                          song: song.copyWith(isDownloaded: isDownloaded),
                          onTap: () {
                            // Play the song
                            context.read<PlayerProvider>().playSong(
                              song,
                              playlist: searchProvider.results,
                              index: index,
                            );
                          },
                          onDownload: () {
                            // Download the song
                            libraryProvider.downloadSong(song);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Downloading ${song.title}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          downloadProgress: downloadProgress,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
