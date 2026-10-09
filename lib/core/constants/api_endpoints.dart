/// Constantes para endpoints de la API lrclib.net
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://lrclib.net/api';
  static const String search = '$baseUrl/search';
  static const String getLyrics = '$baseUrl/get';
  static String getById(int id) => '$baseUrl/get/$id';

  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'LRCFinderFlutterApp/1.0.0 (https://github.com/lrclib)',
    'Accept': 'application/json',
  };
}