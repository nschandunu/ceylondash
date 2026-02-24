import 'package:dio/dio.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/parcel_model.dart';

class ParcelService {
  ParcelService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  static const String _parcelsPath = '/api/parcels';

  Future<List<ParcelModel>> fetchParcels() async {
    final response = await _execute(
      () => _dio.get<Map<String, dynamic>>(_parcelsPath),
    );

    final envelope = response.data;
    if (envelope == null) return const [];

    final list = envelope['data'];
    if (list == null || list is! List) return const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(ParcelModel.fromJson)
        .toList();
  }

  Future<ParcelModel> fetchParcelDetails(String id) async {
    final response = await _execute(
      () => _dio.get<Map<String, dynamic>>('$_parcelsPath/$id'),
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    return ParcelModel.fromJson(data ?? {});
  }

  Future<ParcelModel> createParcel({
    required String deliveryAddress,
    String? receiverId,
    double codAmount = 0,
  }) async {
    final response = await _execute(
      () => _dio.post<Map<String, dynamic>>(
        _parcelsPath,
        data: {
          'deliveryAddress': deliveryAddress,
          if (receiverId != null) 'receiverId': receiverId,
          'codAmount': codAmount,
        },
      ),
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    return ParcelModel.fromJson(data ?? {});
  }

  Future<void> assignRider(String parcelId) async {
    await _execute(
      () => _dio.patch<Map<String, dynamic>>(
        '$_parcelsPath/$parcelId/assign',
      ),
    );
  }

  Future<void> updateParcelStatus(String parcelId, String status) async {
    await _execute(
      () => _dio.patch<Map<String, dynamic>>(
        '$_parcelsPath/$parcelId/status',
        data: {'status': status},
      ),
    );
  }

  /// Calls POST /api/parcels/:id/generate-token.
  /// Returns { token, qrCode } from the response data envelope.
  Future<Map<String, dynamic>> generateHandoverToken(String parcelId) async {
    final response = await _execute(
      () => _dio.post<Map<String, dynamic>>(
        '$_parcelsPath/$parcelId/generate-token',
      ),
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    return data ?? {};
  }

  /// Calls POST /api/parcels/:id/validate-token.
  /// Returns the response data envelope on success.
  Future<Map<String, dynamic>> validateHandoverToken(
    String parcelId,
    String token,
  ) async {
    final response = await _execute(
      () => _dio.post<Map<String, dynamic>>(
        '$_parcelsPath/$parcelId/validate-token',
        data: {'token': token},
      ),
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    return data ?? {};
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
    if (data is! Map<String, dynamic>) return null;

    // Backend shape: { "error": { "code": "...", "message": "..." } }
    final errorObj = data['error'];
    if (errorObj is Map<String, dynamic>) {
      final msg = errorObj['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }

    // Fallback for flat { "message": "..." } shapes
    final msg = data['message'];
    if (msg is String && msg.isNotEmpty) return msg;

    return null;
  }
}
