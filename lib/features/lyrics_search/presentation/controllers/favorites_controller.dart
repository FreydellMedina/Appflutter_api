import 'package:flutter/foundation.dart';
import '../../domain/entities/lyric.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesRepository _favoritesRepository;

  FavoritesController(this._favoritesRepository) {
    loadFavorites();
  }

  List<Lyric> _favorites = [];
  List<Lyric> get favorites => List.unmodifiable(_favorites);

  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isFavorite(int lyricId) => _favoriteIds.contains(lyricId);

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _favorites = await _favoritesRepository.getFavorites();
      _favoriteIds = _favorites.map((e) => e.id).toSet();
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Lyric lyric) async {
    final alreadyFavorite = _favoriteIds.contains(lyric.id);
    if (alreadyFavorite) {
      await removeFavorite(lyric.id);
    } else {
      await saveFavorite(lyric);
    }
  }

  Future<void> saveFavorite(Lyric lyric) async {
    try {
      await _favoritesRepository.saveFavorite(lyric);
      _favoriteIds.add(lyric.id);
      _favorites.insert(0, lyric);
      notifyListeners();
    } catch (e) {
      debugPrint('Error guardando favorito: $e');
    }
  }

  Future<void> removeFavorite(int lyricId) async {
    try {
      await _favoritesRepository.removeFavorite(lyricId);
      _favoriteIds.remove(lyricId);
      _favorites.removeWhere((item) => item.id == lyricId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error eliminando favorito: $e');
    }
  }
}

