import '../entities/lyric.dart';

abstract class FavoritesRepository {
  Future<List<Lyric>> getFavorites();
  Future<void> saveFavorite(Lyric lyric);
  Future<void> removeFavorite(int lyricId);
  Future<bool> isFavorite(int lyricId);
}

