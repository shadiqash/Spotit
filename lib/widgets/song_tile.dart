import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.thumbnail.isNotEmpty
            ? Image.network(
                song.thumbnail,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
      trailing: trailing ?? IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {
          // Show options menu
        },
      ),
    );
  }
}
