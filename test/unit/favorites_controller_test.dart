import 'package:flutter_test/flutter_test.dart';
import 'package:lrc_finder/features/lyrics_search/domain/entities/lyric.dart';
import 'package:lrc_finder/features/lyrics_search/domain/repositories/favorites_repository.dart';
import 'package:lrc_finder/features/lyrics_search/presentation/controllers/favorites_controller.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  final List<Lyric> _storage = [];

  @override
  Future<List<Lyric>> getFavorites() async => List.from(_storage);

  @override
  Future<void> saveFavorite(Lyric lyric) async {
    if (!_storage.any((item) => item.id == lyric.id)) {
      _storage.insert(0, lyric);
    }
  }

  @override
  Future<void> removeFavorite(int lyricId) async {
    _storage.removeWhere((item) => item.id == lyricId);
  }

  @override
  Future<bool> isFavorite(int lyricId) async {
    return _storage.any((item) => item.id == lyricId);
  }
}

void main() {
  late FakeFavoritesRepository repository;
  late FavoritesController controller;

  const sampleLyric = Lyric(
    id: 1,
    name: 'Bohemian Rhapsody',
    trackName: 'Bohemian Rhapsody',
    artistName: 'Queen',
    albumName: 'A Night at the Opera',
    duration: 354,
    instrumental: false,
  );

  setUp(() {
    repository = FakeFavoritesRepository();
    controller = FavoritesController(repository);
  });

  group('FavoritesController Tests', () {
    test('Estado inicial debe estar vacío', () async {
      await controller.loadFavorites();
      expect(controller.favorites, isEmpty);
      expect(controller.isFavorite(1), isFalse);
    });

    test('Guardar favorito debe agregarlo a la lista y actualizar isFavorite', () async {
      await controller.saveFavorite(sampleLyric);

      expect(controller.favorites.length, 1);
      expect(controller.isFavorite(1), isTrue);
      expect(controller.favorites.first.trackName, 'Bohemian Rhapsody');
    });

    test('toggleFavorite debe alternar entre guardado y removido', () async {
      // Agregar
      await controller.toggleFavorite(sampleLyric);
      expect(controller.isFavorite(1), isTrue);
      expect(controller.favorites.length, 1);

      // Quitar
      await controller.toggleFavorite(sampleLyric);
      expect(controller.isFavorite(1), isFalse);
      expect(controller.favorites, isEmpty);
    });

    test('removeFavorite debe eliminar por id', () async {
      await controller.saveFavorite(sampleLyric);
      expect(controller.favorites.length, 1);

      await controller.removeFavorite(1);
      expect(controller.favorites, isEmpty);
      expect(controller.isFavorite(1), isFalse);
    });
  });
}

