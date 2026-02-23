import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../exceptions/app_exceptions.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const UnauthorizedException(
            'No authenticated user found. Please sign in.',
          ),
          type: DioExceptionType.cancel,
        ),
        true,
      );
      return;
    }

    final token = await user.getIdToken();
    if (token == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const UnauthorizedException(
            'Failed to retrieve a valid authentication token.',
          ),
          type: DioExceptionType.cancel,
        ),
        true,
      );
      return;
    }

    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
