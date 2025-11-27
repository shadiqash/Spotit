import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/download_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      Provider.of<SearchProvider>(context, listen: false).searchSongs(query);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _performSearch(),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'What do you want to listen to?',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.black87),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${provider.error}'),
                        ],
                      ),
                    );
                  }

                  if (provider.searchResults.isEmpty && _controller.text.isEmpty) {
                    // Browse Categories (Mock)
                    return _buildBrowseCategories();
                  }

                  if (provider.searchResults.isEmpty) {
                    return const Center(child: Text('No results found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final song = provider.searchResults[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          Provider.of<PlayerProvider>(context, listen: false).playSong(song);
                        },
                        trailing: DownloadButton(song: song),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseCategories() {
    final categories = [
      {'title': 'Pop', 'color': Colors.purple},
      {'title': 'Rock', 'color': Colors.red},
      {'title': 'Hip Hop', 'color': Colors.orange},
      {'title': 'Electronic', 'color': Colors.teal},
      {'title': 'Indie', 'color': Colors.blue},
      {'title': 'R&B', 'color': Colors.pink},
      {'title': 'Workout', 'color': Colors.green},
      {'title': 'Chill', 'color': Colors.indigo},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse all',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: cat['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Text(
                      cat['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -5,
                      child: Transform.rotate(
                        angle: 0.4,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
