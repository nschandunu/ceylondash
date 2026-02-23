import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../presentation/screens/role_selection_screen.dart';

class AuthService {
  AuthService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.requestTimeout,
              receiveTimeout: AppConfig.requestTimeout,
            ));

  final Dio _dio;

  /// Creates a user profile in the backend after Firebase signup.
  /// The [idToken] is used to authenticate the request.
  Future<Map<String, dynamic>> createUserProfile({
    required String idToken,
    required String firebaseUid,
    required UserRole role,
    required Map<String, dynamic> formData,
  }) async {
    final response = await _dio.post(
      '/api/auth/register',
      data: {
        'firebaseUid': firebaseUid,
        'role': role.apiValue,
        ...formData,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }
}
