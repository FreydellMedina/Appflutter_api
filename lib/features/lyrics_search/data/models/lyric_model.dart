import '../../domain/entities/lyric.dart';

class LyricModel extends Lyric {
  const LyricModel({
    required super.id,
    required super.name,
    required super.trackName,
    required super.artistName,
    required super.albumName,
    required super.duration,
    required super.instrumental,
    super.plainLyrics,
    super.syncedLyrics,
  });

  factory LyricModel.fromJson(Map<String, dynamic> json) {
    return LyricModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? json['trackName'] as String? ?? 'Desconocido',
      trackName: json['trackName'] as String? ?? json['name'] as String? ?? 'Desconocido',
      artistName: json['artistName'] as String? ?? 'Artista Desconocido',
      albumName: json['albumName'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      instrumental: json['instrumental'] as bool? ?? false,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }

  factory LyricModel.fromEntity(Lyric entity) {
    return LyricModel(
      id: entity.id,
      name: entity.name,
      trackName: entity.trackName,
      artistName: entity.artistName,
      albumName: entity.albumName,
      duration: entity.duration,
      instrumental: entity.instrumental,
      plainLyrics: entity.plainLyrics,
      syncedLyrics: entity.syncedLyrics,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trackName': trackName,
    'artistName': artistName,
    'albumName': albumName,
    'duration': duration,
    'instrumental': instrumental,
    'plainLyrics': plainLyrics,
    'syncedLyrics': syncedLyrics,
  };
}