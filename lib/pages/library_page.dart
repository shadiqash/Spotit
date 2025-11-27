import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<LibraryProvider>(context, listen: false).loadLibrary()
    );
  }

  String _selectedFilter = 'Downloaded';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Your Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChip('All'),
                  const SizedBox(width: 8),
                  _buildChip('Downloaded'),
                  const SizedBox(width: 8),
                  _buildChip('Playlists'),
                  const SizedBox(width: 8),
                  _buildChip('Artists'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: Consumer<LibraryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter logic
                  var songs = provider.songs;
                  if (_selectedFilter == 'Downloaded') {
                    songs = songs.where((s) => s.isDownloaded).toList();
                  }
                  // Other filters are mock for now

                  if (songs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.music_note, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'Downloaded' 
                                ? 'No downloaded songs' 
                                : 'Your library is empty',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Download songs to listen offline',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          Provider.of<PlayerProvider>(context, listen: false).playSong(song);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () {
                            provider.deleteSong(song.videoId);
                          },
                        ),
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

  Widget _buildChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.green : Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
