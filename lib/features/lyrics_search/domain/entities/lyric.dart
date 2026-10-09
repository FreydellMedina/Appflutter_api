class Lyric {
  final int id;
  final String name;
  final String trackName;
  final String artistName;
  final String albumName;
  final double duration;
  final bool instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  const Lyric({
    required this.id,
    required this.name,
    required this.trackName,
    required this.artistName,
    required this.albumName,
    required this.duration,
    required this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });

  bool get hasSyncedLyrics => syncedLyrics != null && syncedLyrics!.trim().isNotEmpty;
  bool get hasLyrics => (plainLyrics != null && plainLyrics!.trim().isNotEmpty) || hasSyncedLyrics;
}