class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({this.message = 'Server Error occurred', this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache Error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No Internet connection detected'});

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Session expired or invalid credentials'});

  @override
  String toString() => 'UnauthorizedException: $message';
}
