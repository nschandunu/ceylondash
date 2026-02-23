import '../../../core/enums/parcel_status.dart';
import '../../domain/entities/status_history.dart';

class StatusHistoryModel extends StatusHistory {
  const StatusHistoryModel({
    required super.status,
    required super.updatedAt,
  });

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryModel(
      status: ParcelStatusParser.fromString(json['status'] as String?),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  factory StatusHistoryModel.fromEntity(StatusHistory entity) {
    return StatusHistoryModel(
      status: entity.status,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toApiString(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
