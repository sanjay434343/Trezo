/// Base Exception class for all custom app exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Thrown when a database operation fails.
class DatabaseException extends AppException {
  DatabaseException([String message = 'A database error occurred.']) : super(message, code: 'DB_ERROR');
}

/// Thrown when a server operation fails.
class ServerException extends AppException {
  ServerException([String message = 'A server error occurred.']) : super(message, code: 'SERVER_ERROR');
}

/// Thrown when a cache operation fails.
class CacheException extends AppException {
  CacheException([String message = 'A cache error occurred.']) : super(message, code: 'CACHE_ERROR');
}

/// Thrown when OCR or Entity Extraction fails.
class OCRException extends AppException {
  OCRException(super.message, {super.code = 'OCR_ERROR'});
}

/// Thrown when permission is denied.
class PermissionException extends AppException {
  PermissionException(super.message, {super.code = 'PERMISSION_DENIED'});
}

/// Thrown for native platform communication errors.
class NativePlatformException extends AppException {
  NativePlatformException(super.message, {super.code = 'PLATFORM_ERROR'});
}
