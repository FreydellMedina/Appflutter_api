class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: ${statusCode ?? "N/A"})';
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Sin conexión a internet. Revisa tu red.'])
      : super(message);
}

class ServerException extends ApiException {
  ServerException([String message = 'Error en el servidor de LRCLIB.', int? code])
      : super(message, code);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'No se encontraron letras para esta búsqueda.'])
      : super(message, 404);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'Tiempo de espera expirado.'])
      : super(message, 408);
}