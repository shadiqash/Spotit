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
}
