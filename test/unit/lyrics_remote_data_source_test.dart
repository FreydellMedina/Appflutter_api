import 'package:flutter_test/flutter_test.dart';
import 'package:lrc_finder/core/constants/api_endpoints.dart';
import 'package:lrc_finder/core/network/api_client.dart';
import 'package:lrc_finder/core/network/api_exceptions.dart';
import 'package:lrc_finder/features/lyrics_search/data/datasources/lyrics_remote_data_source.dart';

class FakeApiClient extends ApiClient {
  dynamic responseToReturn;
  Exception? exceptionToThrow;
  String? lastUrl;
  Map<String, String>? lastParams;

  @override
  Future<dynamic> get(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    lastUrl = url;
    lastParams = queryParameters;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return responseToReturn;
  }
}

void main() {
  late FakeApiClient fakeApiClient;
  late LyricsRemoteDataSourceImpl dataSource;

  setUp(() {
    fakeApiClient = FakeApiClient();
    dataSource = LyricsRemoteDataSourceImpl(apiClient: fakeApiClient);
  });

  group('LyricsRemoteDataSource Tests', () {
    test('search debe enviar el parámetro q y mapear la lista de modelos', () async {
      fakeApiClient.responseToReturn = [
        {
          'id': 1,
          'trackName': 'Song A',
          'artistName': 'Artist A',
          'albumName': 'Album A',
          'duration': 180.0,
          'instrumental': false,
        },
        {
          'id': 2,
          'trackName': 'Song B',
          'artistName': 'Artist B',
          'albumName': 'Album B',
          'duration': 210.0,
          'instrumental': false,
        }
      ];

      final results = await dataSource.search('Rock');

      expect(fakeApiClient.lastUrl, ApiEndpoints.search);
      expect(fakeApiClient.lastParams, {'q': 'Rock'});
      expect(results.length, 2);
      expect(results[0].trackName, 'Song A');
      expect(results[1].trackName, 'Song B');
    });

    test('searchDetailed debe enviar track_name, artist_name y album_name cuando se proporcionan', () async {
      fakeApiClient.responseToReturn = [
        {
          'id': 10,
          'trackName': 'Yellow',
          'artistName': 'Coldplay',
          'albumName': 'Parachutes',
          'duration': 269.0,
          'instrumental': false,
        }
      ];

      final results = await dataSource.searchDetailed(
        trackName: 'Yellow',
        artistName: 'Coldplay',
        albumName: 'Parachutes',
      );

      expect(fakeApiClient.lastUrl, ApiEndpoints.search);
      expect(fakeApiClient.lastParams, {
        'track_name': 'Yellow',
        'artist_name': 'Coldplay',
        'album_name': 'Parachutes',
      });
      expect(results.length, 1);
      expect(results.first.trackName, 'Yellow');
    });

    test('getExact debe retornar null si la canción no existe (NotFoundException)', () async {
      fakeApiClient.exceptionToThrow = NotFoundException();

      final result = await dataSource.getExact(trackName: 'NonExistent', artistName: 'Unknown');

      expect(result, isNull);
    });

    test('getById debe retornar el modelo o lanzar NotFoundException si no es un Map', () async {
      fakeApiClient.responseToReturn = {
        'id': 99,
        'trackName': 'Fix You',
        'artistName': 'Coldplay',
        'albumName': 'X&Y',
        'duration': 295.0,
        'instrumental': false,
      };

      final result = await dataSource.getById(99);

      expect(fakeApiClient.lastUrl, ApiEndpoints.getById(99));
      expect(result.id, 99);
      expect(result.trackName, 'Fix You');
    });
  });
}

