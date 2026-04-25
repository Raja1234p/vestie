abstract class AppException implements Exception {
  final String message;
  final String? title;
  AppException(this.message, [this.title]);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred', super.title]);
}

class CacheException extends AppException {
  CacheException([super.message = 'Local cache error occurred', super.title]);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Unauthorized', super.title]);
}
