/// Base class for all data-layer exceptions
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred']);
}

class CacheException extends AppException {
  CacheException([super.message = 'Local cache error occurred']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Unauthorized']);
}
