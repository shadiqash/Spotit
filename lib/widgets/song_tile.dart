/**
 * Song Tile Widget
 * 
 * Reusable widget for displaying a song in a list.
 * Shows thumbnail, title, artist, duration, and download status.
 */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onDownload;
  final bool showDownloadButton;
  final double? downloadProgress;

  const SongTile({
    Key? key,
    required this.song,
    required this.onTap,
    this.onDownload,
    this.showDownloadButton = true,
    this.downloadProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildThumbnail(),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget _buildThumbnail() {
    if (song.thumbnail.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: song.thumbnail,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.music_note, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration
        Text(
          song.formattedDuration,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        
        // Download button/status
        if (showDownloadButton) _buildDownloadIndicator(),
      ],
    );
  }

  Widget _buildDownloadIndicator() {
    // Show progress if downloading
    if (downloadProgress != null) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: downloadProgress,
          strokeWidth: 2,
        ),
      );
    }

    // Show downloaded icon if downloaded
    if (song.isDownloaded) {
      return const Icon(
        Icons.download_done,
        color: Colors.green,
        size: 20,
      );
    }

    // Show download button
    if (onDownload != null) {
      return IconButton(
        icon: const Icon(Icons.download, size: 20),
        onPressed: onDownload,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return const SizedBox.shrink();
  }
}
