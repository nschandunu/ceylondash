import 'package:dio/dio.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/parcel_model.dart';

class ParcelService {
  ParcelService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  static const String _parcelsPath = '/api/parcels';

  Future<List<ParcelModel>> fetchParcels() async {
    final response = await _execute(() => _dio.get<List<dynamic>>(_parcelsPath));

    final data = response.data;
    if (data == null) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ParcelModel.fromJson)
        .toList();
  }

  Future<ParcelModel> fetchParcelDetails(String id) async {
    final response = await _execute(
      () => _dio.get<Map<String, dynamic>>('$_parcelsPath/$id'),
    );

    return ParcelModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> requestPickupToken(String id) async {
    final response = await _execute(
      () => _dio.post<Map<String, dynamic>>(
        '$_parcelsPath/$id/generate-token',
      ),
    );

    return response.data ?? {};
  }

  Future<Response<T>> _execute<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
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

    if (e.type == DioExceptionType.cancel) {
      final inner = e.error;
      if (inner is AppException) return inner;
      return const UnauthorizedException();
    }

    final statusCode = e.response?.statusCode;

    if (statusCode != null) {
      final serverMessage = _extractServerMessage(e.response?.data);

      return switch (statusCode) {
        400 => BadRequestException(
            serverMessage ?? 'The request contained invalid data.',
          ),
        401 => UnauthorizedException(
            serverMessage ?? 'Unauthorised. Please sign in and try again.',
          ),
        403 => ForbiddenException(
            serverMessage ??
                'You do not have permission to perform this action.',
          ),
        404 => NotFoundException(
            serverMessage ?? 'The requested resource was not found.',
          ),
        422 => BadRequestException(
            serverMessage ?? 'Validation failed.',
          ),
        _ => ServerException(
            message: serverMessage ?? 'A server error occurred.',
            statusCode: statusCode,
          ),
      };
    }

    return const UnknownException();
  }
  
  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return null;
  }
}
