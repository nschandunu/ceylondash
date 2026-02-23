import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

/// Service that handles Firebase ↔ MongoDB user sync.
class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  /// Syncs the currently authenticated Firebase user with MongoDB.
  ///
  /// For returning users, no [registrationData] is needed.
  /// For new users, [registrationData] should contain:
  /// - role, name, phoneNumber, and role-specific fields.
  Future<Map<String, dynamic>> syncUser({
    Map<String, dynamic>? registrationData,
  }) async {
    final response = await _dio.post(
      '/api/auth/sync',
      data: registrationData ?? {},
    );

    return response.data as Map<String, dynamic>;
  }
}
