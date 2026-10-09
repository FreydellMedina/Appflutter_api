import '../../domain/entities/lyric.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../models/lyric_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _localDataSource;

  FavoritesRepositoryImpl({FavoritesLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? FavoritesLocalDataSourceImpl();

  @override
  Future<List<Lyric>> getFavorites() => _localDataSource.getFavorites();

  @override
  Future<void> saveFavorite(Lyric lyric) {
    final model = LyricModel.fromEntity(lyric);
    return _localDataSource.saveFavorite(model);
  }

  @override
  Future<void> removeFavorite(int lyricId) => _localDataSource.removeFavorite(lyricId);

  @override
  Future<bool> isFavorite(int lyricId) => _localDataSource.isFavorite(lyricId);
}

