import '../../../core/enums/parcel_status.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/status_history.dart';
import 'status_history_model.dart';

class ParcelModel extends Parcel {
  const ParcelModel({
    required super.id,
    required super.trackingCode,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    super.assignedRiderId,
    required super.status,
    required super.deliveryAddress,
    required super.statusHistory,
    required super.codAmount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    return ParcelModel(
      id: _parseId(json),
      trackingCode: json['trackingCode'] as String? ?? '',
      senderId: _parseObjectId(json['senderId']),
      senderName: json['senderName'] as String? ?? '',
      receiverId: _parseObjectId(json['receiverId']),
      assignedRiderId: _parseNullableObjectId(json['assignedRiderId']),
      status: ParcelStatusParser.fromString(json['status'] as String?),
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      statusHistory: _parseStatusHistory(json['statusHistory']),
      codAmount: _parseDouble(json['codAmount']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  factory ParcelModel.fromEntity(Parcel entity) {
    return ParcelModel(
      id: entity.id,
      trackingCode: entity.trackingCode,
      senderId: entity.senderId,
      senderName: entity.senderName,
      receiverId: entity.receiverId,
      assignedRiderId: entity.assignedRiderId,
      status: entity.status,
      deliveryAddress: entity.deliveryAddress,
      statusHistory: entity.statusHistory,
      codAmount: entity.codAmount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingCode': trackingCode,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      if (assignedRiderId != null) 'assignedRiderId': assignedRiderId,
      'status': status.toApiString(),
      'deliveryAddress': deliveryAddress,
      'statusHistory': statusHistory
          .map((history) => StatusHistoryModel.fromEntity(history).toJson())
          .toList(),
      'codAmount': codAmount,
    };
  }

  Map<String, dynamic> toFullJson() {
    return {
      '_id': id,
      ...toJson(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  static String _parseId(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'];
    if (id == null) return '';
    if (id is Map && id.containsKey('\$oid')) {
      return id['\$oid'] as String;
    }
    return id.toString();
  }

  static String _parseObjectId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map && value.containsKey('\$oid')) {
      return value['\$oid'] as String;
    }
    return value.toString();
  }

  static String? _parseNullableObjectId(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    return _parseObjectId(value);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    if (value is Map && value.containsKey('\$date')) {
      final dateValue = value['\$date'];
      if (dateValue is String) {
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      }
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  static List<StatusHistory> _parseStatusHistory(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => StatusHistoryModel.fromJson(item))
        .toList();
  }

  @override
  ParcelModel copyWith({
    String? id,
    String? trackingCode,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? assignedRiderId,
    ParcelStatus? status,
    String? deliveryAddress,
    List<StatusHistory>? statusHistory,
    double? codAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParcelModel(
      id: id ?? this.id,
      trackingCode: trackingCode ?? this.trackingCode,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      assignedRiderId: assignedRiderId ?? this.assignedRiderId,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      statusHistory: statusHistory ?? this.statusHistory,
      codAmount: codAmount ?? this.codAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
