import '../entities/lyric.dart';
import '../repositories/lyrics_repository.dart';

class SearchLyricsUseCase {
  final LyricsRepository _repository;

  SearchLyricsUseCase(this._repository);

  Future<List<Lyric>> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    return await _repository.searchLyrics(trimmed);
  }

  Future<List<Lyric>> searchDetailed({String? trackName, String? artistName, String? albumName}) async {
    return await _repository.searchLyricsDetailed(
      trackName: trackName,
      artistName: artistName,
      albumName: albumName,
    );
  }
}