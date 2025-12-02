import 'package:flutter/material.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.music_note, color: Theme.of(context).primaryColor, size: 40),
                const SizedBox(width: 12),
                const Text(
                  'Spotit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation
          _buildNavItem(context, 0, Icons.home_filled, 'Home'),
          _buildNavItem(context, 1, Icons.search, 'Search'),
          _buildNavItem(context, 2, Icons.library_music, 'Your Library'),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.grey, thickness: 0.5, indent: 24, endIndent: 24),
          
          // Playlists section (placeholder)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'PLAYLISTS',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          _buildPlaylistItem('Liked Songs'),
          _buildPlaylistItem('Daily Mix 1'),
          _buildPlaylistItem('Discover Weekly'),
          
          const Spacer(),
          
          // Install App / User section
          _buildNavItem(context, 3, Icons.download, 'Install App'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: isSelected 
              ? Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaylistItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}
