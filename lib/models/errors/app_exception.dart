import 'dart:io';

/// Abstract base exception for all custom app-level errors.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return '$runtimeType [$statusCode]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// Thrown when there is no active internet connection.
class NoInternetException extends AppException {
  const NoInternetException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// Thrown when an HTTP network request times out.
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The request timed out. Please try again.',
  ]);
}

/// Thrown when backend returns an API error response.
class ApiException extends AppException {
  const ApiException(super.message, {super.statusCode});
}

/// Thrown when response body parsing or JSON mapping fails.
class DataParseException extends AppException {
  const DataParseException([
    super.message = 'Failed to parse server response.',
  ]);
}

class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.statusCode});
}

/// Thrown when an unauthorized or unauthenticated request occurs (HTTP 401/403).
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Access denied. Please authenticate.',
    statusCode = HttpStatus.unauthorized,
  ]);
}
