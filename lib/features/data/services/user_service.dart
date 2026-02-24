import 'package:dio/dio.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';

class UserService {
  UserService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  static const String _usersPath = '/api/users';

  /// Searches users by name or phone. Returns a list of user maps.
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_usersPath/search',
        queryParameters: {'query': query},
      );

      final list = response.data?['data'];
      if (list == null || list is! List) return const [];

      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      final msg = _extractServerMessage(e.response?.data);
      return switch (statusCode) {
        400 => BadRequestException(msg ?? 'Invalid search query.'),
        401 => UnauthorizedException(msg ?? 'Unauthorised.'),
        _ => ServerException(
            message: msg ?? 'A server error occurred.',
            statusCode: statusCode,
          ),
      };
    }
    return const UnknownException();
  }

  String? _extractServerMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final errorObj = data['error'];
    if (errorObj is Map<String, dynamic>) {
      final msg = errorObj['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final msg = data['message'];
    if (msg is String && msg.isNotEmpty) return msg;
    return null;
  }
}
