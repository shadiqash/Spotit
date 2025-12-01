class Song {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.duration,
  });

  @override
  String toString() => 'Song(title: $title, artist: $artist)';
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'thumbnailUrl': thumbnailUrl,
    'duration': duration,
  };
  
  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Unknown',
    artist: json['artist'] ?? 'Unknown',
    thumbnailUrl: json['thumbnailUrl'] ?? '',
    duration: json['duration'] ?? '0:00',
  );
}
