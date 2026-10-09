import '../entities/lyric.dart';

abstract class LyricsRepository {
  Future<List<Lyric>> searchLyrics(String query);
  Future<List<Lyric>> searchLyricsDetailed({String? trackName, String? artistName, String? albumName});
  Future<Lyric?> getExactLyric({required String trackName, required String artistName, String? albumName, double? duration});
  Future<Lyric> getLyricById(int id);
}