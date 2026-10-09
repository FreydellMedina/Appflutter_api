import 'package:flutter_test/flutter_test.dart';
import 'package:lrc_finder/core/network/api_exceptions.dart';
import 'package:lrc_finder/features/lyrics_search/domain/entities/lyric.dart';
import 'package:lrc_finder/features/lyrics_search/domain/repositories/lyrics_repository.dart';
import 'package:lrc_finder/features/lyrics_search/domain/usecases/search_lyrics_usecase.dart';
import 'package:lrc_finder/features/lyrics_search/presentation/controllers/lyrics_search_controller.dart';

class FakeLyricsRepository implements LyricsRepository {
  List<Lyric> resultsToReturn = [];
  Exception? errorToThrow;

  @override
  Future<List<Lyric>> searchLyrics(String query) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resultsToReturn;
  }

  @override
  Future<List<Lyric>> searchLyricsDetailed({String? trackName, String? artistName, String? albumName}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resultsToReturn;
  }

  @override
  Future<Lyric?> getExactLyric({required String trackName, required String artistName, String? albumName, double? duration}) async {
    return null;
  }

  @override
  Future<Lyric> getLyricById(int id) async {
    return resultsToReturn.first;
  }
}

void main() {
  late FakeLyricsRepository repository;
  late SearchLyricsUseCase useCase;
  late LyricsSearchController controller;

  setUp(() {
    repository = FakeLyricsRepository();
    useCase = SearchLyricsUseCase(repository);
    controller = LyricsSearchController(useCase);
  });

  group('LyricsSearchController Tests', () {
    test('Estado inicial debe ser LyricsSearchStatus.initial y lista vacía', () {
      expect(controller.status, LyricsSearchStatus.initial);
      expect(controller.lyrics, isEmpty);
      expect(controller.hasActiveFilters, isFalse);
    });

    test('Búsqueda exitosa debe cambiar el estado a loaded con los resultados', () async {
      repository.resultsToReturn = [
        const Lyric(
          id: 1,
          name: 'Radioactive',
          trackName: 'Radioactive',
          artistName: 'Imagine Dragons',
          albumName: 'Night Visions',
          duration: 186.0,
          instrumental: false,
          syncedLyrics: '[00:10.00] I\'m waking up...',
        ),
      ];

      final future = controller.search('Imagine Dragons');
      expect(controller.status, LyricsSearchStatus.loading);
      await future;

      expect(controller.status, LyricsSearchStatus.loaded);
      expect(controller.lyrics.length, 1);
      expect(controller.lyrics.first.trackName, 'Radioactive');
    });

    test('Búsqueda con 0 resultados debe transicionar a empty', () async {
      repository.resultsToReturn = [];

      await controller.search('CanciónInexistente123');

      expect(controller.status, LyricsSearchStatus.empty);
      expect(controller.lyrics, isEmpty);
    });

    test('Búsqueda vacía debe restablecer el estado a initial', () async {
      repository.resultsToReturn = [
        const Lyric(
          id: 1,
          name: 'Song',
          trackName: 'Song',
          artistName: 'Artist',
          albumName: 'Album',
          duration: 120,
          instrumental: false,
        )
      ];

      await controller.search('Song');
      expect(controller.status, LyricsSearchStatus.loaded);

      await controller.search('');
      expect(controller.status, LyricsSearchStatus.initial);
      expect(controller.lyrics, isEmpty);
    });

    test('Error de red/servidor debe transicionar a error y almacenar mensaje legible', () async {
      repository.errorToThrow = NetworkException('Sin conexión a internet');

      await controller.search('Coldplay');

      expect(controller.status, LyricsSearchStatus.error);
      expect(controller.errorMessage, 'Sin conexión a internet');
    });

    test('Filtro de solo letras sincronizadas (toggleOnlySynced) debe filtrar resultados', () async {
      repository.resultsToReturn = [
        const Lyric(
          id: 1,
          name: 'Song With Sync',
          trackName: 'Song With Sync',
          artistName: 'Artist',
          albumName: 'Album',
          duration: 120,
          instrumental: false,
          syncedLyrics: '[00:01.00] Line',
        ),
        const Lyric(
          id: 2,
          name: 'Song Without Sync',
          trackName: 'Song Without Sync',
          artistName: 'Artist',
          albumName: 'Album',
          duration: 120,
          instrumental: false,
          syncedLyrics: null,
          plainLyrics: 'Line',
        ),
      ];

      await controller.search('Artist');
      expect(controller.lyrics.length, 2);

      // Activar filtro solo sincronizadas
      controller.toggleOnlySynced();
      expect(controller.onlySynced, isTrue);
      expect(controller.lyrics.length, 1);
      expect(controller.lyrics.first.id, 1);

      // Desactivar filtro
      controller.toggleOnlySynced();
      expect(controller.onlySynced, isFalse);
      expect(controller.lyrics.length, 2);
    });

    test('searchDetailed debe registrar los parámetros de filtro y activeFilterCount', () async {
      repository.resultsToReturn = [
        const Lyric(
          id: 10,
          name: 'Yellow',
          trackName: 'Yellow',
          artistName: 'Coldplay',
          albumName: 'Parachutes',
          duration: 269,
          instrumental: false,
        ),
      ];

      await controller.searchDetailed(
        trackName: 'Yellow',
        artistName: 'Coldplay',
        albumName: 'Parachutes',
        onlySynced: true,
      );

      expect(controller.filterTrackName, 'Yellow');
      expect(controller.filterArtistName, 'Coldplay');
      expect(controller.filterAlbumName, 'Parachutes');
      expect(controller.onlySynced, isTrue);
      expect(controller.hasActiveFilters, isTrue);
      expect(controller.activeFilterCount, 4);

      // Limpiar filtros
      controller.clearFilters();
      expect(controller.hasActiveFilters, isFalse);
      expect(controller.activeFilterCount, 0);
    });
  });
}

