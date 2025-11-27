/**
 * Song Model
 * 
 * Represents a song/video from YouTube with all necessary metadata.
 */

class Song {
  final String videoId;
  final String title;
  final String artist;
  final String thumbnail;
  final int duration; // in seconds
  final String url; // YouTube URL
  
  // Local storage info
  bool isDownloaded;
  String? localPath;
  String? filename;
  
  // Source info
  bool isSoundCloud;

  Song({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.duration,
    required this.url,
    this.isDownloaded = false,
    this.localPath,
    this.filename,
    this.isSoundCloud = false,
  });

  /// Create Song from JSON (from API response)
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? 0,
      url: json['url'] ?? '',
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
      filename: json['filename'],
      isSoundCloud: json['isSoundCloud'] ?? false,
    );
  }

  /// Convert Song to JSON
  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'thumbnail': thumbnail,
      'duration': duration,
      'url': url,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'filename': filename,
      'isSoundCloud': isSoundCloud,
    };
  }

  /// Create a copy of the song with updated fields
  Song copyWith({
    String? videoId,
    String? title,
    String? artist,
    String? thumbnail,
    int? duration,
    String? url,
    bool? isDownloaded,
    String? localPath,
    String? filename,
  }) {
    return Song(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      url: url ?? this.url,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      filename: filename ?? this.filename,
    );
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Song(videoId: $videoId, title: $title, artist: $artist, isDownloaded: $isDownloaded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.videoId == videoId;
  }

  @override
  int get hashCode => videoId.hashCode;
}
