import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lrc_finder/core/constants/api_endpoints.dart';
import 'package:lrc_finder/core/network/api_client.dart';
import 'package:lrc_finder/core/network/api_exceptions.dart';

void main() {
  group('ApiClient Tests - Respuestas de la API', () {
    test('Debe retornar un List decodificado cuando la API responde 200 con JSON array', () async {
      final mockData = [
        {
          'id': 1,
          'name': 'Yellow',
          'trackName': 'Yellow',
          'artistName': 'Coldplay',
          'albumName': 'Parachutes',
          'duration': 269.0,
          'instrumental': false,
          'plainLyrics': 'Look at the stars...',
          'syncedLyrics': '[00:15.00] Look at the stars',
        }
      ];

      final mockClient = MockClient((request) async {
        expect(request.headers['User-Agent'], ApiEndpoints.defaultHeaders['User-Agent']);
        expect(request.headers['Accept'], 'application/json');
        return http.Response(jsonEncode(mockData), 200, headers: {'content-type': 'application/json; charset=utf-8'});
      });

      final apiClient = ApiClient(client: mockClient);
      final result = await apiClient.get(ApiEndpoints.search, queryParameters: {'q': 'Yellow'});

      expect(result, isA<List>());
      expect((result as List).length, 1);
      expect(result.first['trackName'], 'Yellow');
      expect(result.first['artistName'], 'Coldplay');
    });

    test('Debe retornar un Map decodificado cuando la API responde 200 con un objeto JSON', () async {
      final mockSong = {
        'id': 42,
        'name': 'Bohemian Rhapsody',
        'trackName': 'Bohemian Rhapsody',
        'artistName': 'Queen',
        'albumName': 'A Night at the Opera',
        'duration': 354.0,
        'instrumental': false,
        'plainLyrics': 'Is this the real life?',
        'syncedLyrics': '[00:01.00] Is this the real life?',
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockSong), 200, headers: {'content-type': 'application/json; charset=utf-8'});
      });

      final apiClient = ApiClient(client: mockClient);
      final result = await apiClient.get(ApiEndpoints.getById(42));

      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 42);
      expect(result['trackName'], 'Bohemian Rhapsody');
    });

    test('Debe retornar null cuando el cuerpo de respuesta 200 está vacío', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final result = await apiClient.get('https://lrclib.net/api/empty');

      expect(result, isNull);
    });

    test('Debe lanzar NotFoundException cuando la API responde 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Not found'}), 404);
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get(ApiEndpoints.getById(999999)),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Debe lanzar ServerException cuando la API responde 500 (Error de servidor)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get(ApiEndpoints.search, queryParameters: {'q': 'test'}),
        throwsA(isA<ServerException>()),
      );
    });

    test('Debe lanzar ApiException genérica para otros códigos de error (ej: 400 Bad Request)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Bad Request: Invalid params', 400);
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get(ApiEndpoints.search),
        throwsA(isA<ApiException>()),
      );
    });

    test('Debe lanzar NetworkException cuando ocurre un error de cliente HTTP', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Fallo en la conexión');
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get(ApiEndpoints.search, queryParameters: {'q': 'test'}),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}

