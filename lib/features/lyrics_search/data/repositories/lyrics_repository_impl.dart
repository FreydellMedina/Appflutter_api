import '../../domain/entities/lyric.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../datasources/lyrics_remote_data_source.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsRemoteDataSource _remoteDataSource;

  LyricsRepositoryImpl({LyricsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? LyricsRemoteDataSourceImpl();

  @override
  Future<List<Lyric>> searchLyrics(String query) => _remoteDataSource.search(query);

  @override
  Future<List<Lyric>> searchLyricsDetailed({String? trackName, String? artistName, String? albumName}) =>
      _remoteDataSource.searchDetailed(trackName: trackName, artistName: artistName, albumName: albumName);

  @override
  Future<Lyric?> getExactLyric({required String trackName, required String artistName, String? albumName, double? duration}) =>
      _remoteDataSource.getExact(trackName: trackName, artistName: artistName, albumName: albumName, duration: duration);

  @override
  Future<Lyric> getLyricById(int id) => _remoteDataSource.getById(id);
}