import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final mergedHeaders = {
        ...ApiEndpoints.defaultHeaders,
        if (headers != null) ...headers,
      };

      final response = await _client.get(uri, headers: mergedHeaders).timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException catch (e) {
      throw NetworkException('Error de conexión HTTP: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = utf8.decode(response.bodyBytes);

    if (statusCode >= 200 && statusCode < 300) {
      if (bodyString.isEmpty) return null;
      return jsonDecode(bodyString);
    } else if (statusCode == 404) {
      throw NotFoundException();
    } else if (statusCode >= 500) {
      throw ServerException('Error interno del servidor LRCLIB', statusCode);
    } else {
      throw ApiException('Error en la petición: $bodyString', statusCode);
    }
  }

  void close() => _client.close();
}