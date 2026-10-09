import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lrc_finder/core/theme/app_theme.dart';
import 'package:lrc_finder/features/lyrics_search/domain/entities/lyric.dart';
import 'package:lrc_finder/features/lyrics_search/domain/repositories/favorites_repository.dart';
import 'package:lrc_finder/features/lyrics_search/domain/repositories/lyrics_repository.dart';
import 'package:lrc_finder/features/lyrics_search/domain/usecases/search_lyrics_usecase.dart';
import 'package:lrc_finder/features/lyrics_search/presentation/controllers/favorites_controller.dart';
import 'package:lrc_finder/features/lyrics_search/presentation/controllers/lyrics_search_controller.dart';
import 'package:lrc_finder/features/lyrics_search/presentation/pages/lyrics_search_page.dart';
import 'package:provider/provider.dart';

class MockLyricsRepository implements LyricsRepository {
  List<Lyric> results = [];

  @override
  Future<List<Lyric>> searchLyrics(String query) async => results;

  @override
  Future<List<Lyric>> searchLyricsDetailed({String? trackName, String? artistName, String? albumName}) async => results;

  @override
  Future<Lyric?> getExactLyric({required String trackName, required String artistName, String? albumName, double? duration}) async => null;

  @override
  Future<Lyric> getLyricById(int id) async => results.first;
}

class MockFavoritesRepository implements FavoritesRepository {
  final List<Lyric> _favs = [];

  @override
  Future<List<Lyric>> getFavorites() async => _favs;

  @override
  Future<void> saveFavorite(Lyric lyric) async => _favs.add(lyric);

  @override
  Future<void> removeFavorite(int lyricId) async => _favs.removeWhere((item) => item.id == lyricId);

  @override
  Future<bool> isFavorite(int lyricId) async => _favs.any((item) => item.id == lyricId);
}

void main() {
  Widget createWidgetUnderTest({
    required LyricsSearchController searchCtrl,
    required FavoritesController favsCtrl,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LyricsSearchController>.value(value: searchCtrl),
        ChangeNotifierProvider<FavoritesController>.value(value: favsCtrl),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LyricsSearchPage(),
      ),
    );
  }

  testWidgets('Renderiza la interfaz inicial con título, buscador y sugerencias', (WidgetTester tester) async {
    final repo = MockLyricsRepository();
    final searchCtrl = LyricsSearchController(SearchLyricsUseCase(repo));
    final favsCtrl = FavoritesController(MockFavoritesRepository());

    await tester.pumpWidget(createWidgetUnderTest(searchCtrl: searchCtrl, favsCtrl: favsCtrl));
    await tester.pumpAndSettle();

    expect(find.text('LRCLIB Finder'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Encuentra letras sincronizadas'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });

  testWidgets('Abre la hoja de Información de la API al presionar el botón de info', (WidgetTester tester) async {
    final repo = MockLyricsRepository();
    final searchCtrl = LyricsSearchController(SearchLyricsUseCase(repo));
    final favsCtrl = FavoritesController(MockFavoritesRepository());

    await tester.pumpWidget(createWidgetUnderTest(searchCtrl: searchCtrl, favsCtrl: favsCtrl));
    await tester.pumpAndSettle();

    // Tocar el botón de información en la AppBar
    final infoButton = find.byIcon(Icons.info_outline_rounded);
    expect(infoButton, findsOneWidget);
    await tester.tap(infoButton);
    await tester.pumpAndSettle();

    // Debe mostrar la hoja de Información de la API
    expect(find.text('Información de la API'), findsOneWidget);
    expect(find.text('LRCLIB - Open Lyrics Database'), findsOneWidget);
    expect(find.text('Endpoints Consumidos'), findsOneWidget);
  });

  testWidgets('Abre la hoja de Búsqueda Filtrada al presionar el botón de filtro', (WidgetTester tester) async {
    final repo = MockLyricsRepository();
    final searchCtrl = LyricsSearchController(SearchLyricsUseCase(repo));
    final favsCtrl = FavoritesController(MockFavoritesRepository());

    await tester.pumpWidget(createWidgetUnderTest(searchCtrl: searchCtrl, favsCtrl: favsCtrl));
    await tester.pumpAndSettle();

    // Tocar el icono de filtros en la barra de búsqueda
    final filterButton = find.byIcon(Icons.tune_rounded);
    expect(filterButton, findsOneWidget);
    await tester.tap(filterButton);
    await tester.pumpAndSettle();

    // Debe mostrar el modal de búsqueda filtrada
    expect(find.text('Búsqueda Filtrada'), findsOneWidget);
    expect(find.text('Título de la Canción'), findsOneWidget);
    expect(find.text('Nombre del Artista'), findsOneWidget);
    expect(find.text('Solo letras sincronizadas (LRC)'), findsOneWidget);
  });

  testWidgets('Muestra la lista de resultados y permite guardarlo en favoritos', (WidgetTester tester) async {
    final repo = MockLyricsRepository();
    repo.results = [
      const Lyric(
        id: 77,
        name: 'Adventure of a Lifetime',
        trackName: 'Adventure of a Lifetime',
        artistName: 'Coldplay',
        albumName: 'A Head Full of Dreams',
        duration: 263.0,
        instrumental: false,
        syncedLyrics: '[00:10.00] Turn your magic on',
      ),
    ];
    final searchCtrl = LyricsSearchController(SearchLyricsUseCase(repo));
    final favsCtrl = FavoritesController(MockFavoritesRepository());

    await tester.pumpWidget(createWidgetUnderTest(searchCtrl: searchCtrl, favsCtrl: favsCtrl));
    await tester.pumpAndSettle();

    // Ejecutar búsqueda
    await searchCtrl.search('Coldplay');
    await tester.pumpAndSettle();

    // Verificar que se renderiza el LyricCard
    expect(find.text('Adventure of a Lifetime'), findsOneWidget);
    expect(find.text('Coldplay'), findsOneWidget);
    expect(find.text('SYNC'), findsOneWidget);

    // Tocar el botón de favorito en la tarjeta
    final favButton = find.byTooltip('Agregar a favoritos');
    expect(favButton, findsOneWidget);
    await tester.tap(favButton);
    await tester.pumpAndSettle();

    // Verificar que ahora tiene el icono de favorito lleno y está en favsCtrl
    expect(favsCtrl.isFavorite(77), isTrue);
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
  });
}
