import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Library',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Library Sections
              _buildLibrarySection(
                icon: Icons.favorite,
                title: 'Liked Songs',
                subtitle: 'Your favorite tracks',
                gradient: [Colors.pink[400]!, Colors.pink[600]!],
              ),
              const SizedBox(height: 12),
              _buildLibrarySection(
                icon: Icons.history,
                title: 'Recently Played',
                subtitle: 'Your listening history',
                gradient: [AppTheme.primaryPurple, AppTheme.darkPurple],
              ),
              const SizedBox(height: 12),
              _buildLibrarySection(
                icon: Icons.download,
                title: 'Downloads',
                subtitle: 'Offline music',
                gradient: [Colors.green[400]!, Colors.green[600]!],
              ),
              const SizedBox(height: 32),
              
              // Playlists
              const Text(
                'Playlists',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.playlist_add, size: 64, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text(
                        'No playlists yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first playlist',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibrarySection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
