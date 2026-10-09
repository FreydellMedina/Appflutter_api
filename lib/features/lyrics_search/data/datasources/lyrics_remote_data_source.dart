import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/lyric_model.dart';

abstract class LyricsRemoteDataSource {
  Future<List<LyricModel>> search(String query);
  Future<List<LyricModel>> searchDetailed({String? trackName, String? artistName, String? albumName});
  Future<LyricModel?> getExact({required String trackName, required String artistName, String? albumName, double? duration});
  Future<LyricModel> getById(int id);
}

class LyricsRemoteDataSourceImpl implements LyricsRemoteDataSource {
  final ApiClient _apiClient;

  LyricsRemoteDataSourceImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<LyricModel>> search(String query) async {
    final response = await _apiClient.get(ApiEndpoints.search, queryParameters: {'q': query});
    if (response is List) {
      return response.map((item) => LyricModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<LyricModel>> searchDetailed({String? trackName, String? artistName, String? albumName}) async {
    final Map<String, String> params = {};
    if (trackName != null && trackName.isNotEmpty) params['track_name'] = trackName;
    if (artistName != null && artistName.isNotEmpty) params['artist_name'] = artistName;
    if (albumName != null && albumName.isNotEmpty) params['album_name'] = albumName;

    final response = await _apiClient.get(ApiEndpoints.search, queryParameters: params);
    if (response is List) {
      return response.map((item) => LyricModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<LyricModel?> getExact({required String trackName, required String artistName, String? albumName, double? duration}) async {
    try {
      final Map<String, String> params = {'track_name': trackName, 'artist_name': artistName};
      if (albumName != null && albumName.isNotEmpty) params['album_name'] = albumName;
      if (duration != null && duration > 0) params['duration'] = duration.toString();

      final response = await _apiClient.get(ApiEndpoints.getLyrics, queryParameters: params);
      if (response is Map<String, dynamic>) return LyricModel.fromJson(response);
      return null;
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<LyricModel> getById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.getById(id));
    if (response is Map<String, dynamic>) return LyricModel.fromJson(response);
    throw NotFoundException('Letra no encontrada');
  }
}