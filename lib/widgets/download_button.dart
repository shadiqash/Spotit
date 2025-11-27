import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/download_service.dart';

class DownloadButton extends StatefulWidget {
  final Song song;
  final double size;
  final Color? color;

  const DownloadButton({
    super.key,
    required this.song,
    this.size = 24.0,
    this.color,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final DownloadService _downloadService = DownloadService();
  bool _isDownloading = false;
  bool _isDownloaded = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final downloaded = await _downloadService.isSongDownloaded(widget.song.videoId);
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
      });
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    try {
      final path = await _downloadService.downloadSong(
        widget.song,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _progress = progress);
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = path != null;
        });
        
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded: ${widget.song.title}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloaded) {
      return Icon(
        Icons.check_circle,
        color: Theme.of(context).primaryColor,
        size: widget.size,
      );
    }

    if (_isDownloading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
          strokeWidth: 2,
        ),
      );
    }

    return IconButton(
      icon: Icon(Icons.download_rounded, size: widget.size),
      color: widget.color ?? Colors.grey,
      onPressed: _startDownload,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
