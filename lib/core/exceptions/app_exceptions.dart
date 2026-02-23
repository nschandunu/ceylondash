abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Unauthorised. Please sign in and try again.',
  ]);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'You do not have permission to perform this action.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}

class BadRequestException extends AppException {
  const BadRequestException([
    super.message = 'The request contained invalid data.',
  ]);
}

class ServerException extends AppException {
  const ServerException({
    String message = 'A server error occurred. Please try again later.',
    this.statusCode,
  }) : super(message);

  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Unable to reach the server. Please check your connection.',
  ]);
}

class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The request timed out. Please try again.',
  ]);
}

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred.',
  ]);
}
