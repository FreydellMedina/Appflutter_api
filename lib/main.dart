import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/lyrics_search/data/datasources/lyrics_remote_data_source.dart';
import 'features/lyrics_search/data/repositories/favorites_repository_impl.dart';
import 'features/lyrics_search/data/repositories/lyrics_repository_impl.dart';
import 'features/lyrics_search/domain/usecases/search_lyrics_usecase.dart';
import 'features/lyrics_search/presentation/controllers/favorites_controller.dart';
import 'features/lyrics_search/presentation/controllers/lyrics_search_controller.dart';
import 'features/lyrics_search/presentation/pages/lyrics_search_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyección de dependencias Clean Architecture
    final apiClient = ApiClient();
    final remoteDataSource = LyricsRemoteDataSourceImpl(apiClient: apiClient);
    final repository = LyricsRepositoryImpl(remoteDataSource: remoteDataSource);
    final searchLyricsUseCase = SearchLyricsUseCase(repository);
    final favoritesRepository = FavoritesRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LyricsSearchController(searchLyricsUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesController(favoritesRepository),
        ),
      ],
      child: MaterialApp(
        title: 'LRCLIB Lyrics Finder',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const LyricsSearchPage(),
      ),
    );
  }
}