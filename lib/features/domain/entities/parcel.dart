import 'package:equatable/equatable.dart';

import '../../../core/enums/parcel_status.dart';
import 'status_history.dart';

class Parcel extends Equatable {
  final String id;
  final String trackingCode;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String? assignedRiderId;
  final ParcelStatus status;
  final String deliveryAddress;
  final List<StatusHistory> statusHistory;
  final double codAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Parcel({
    required this.id,
    required this.trackingCode,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    this.assignedRiderId,
    required this.status,
    required this.deliveryAddress,
    required this.statusHistory,
    required this.codAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasAssignedRider => assignedRiderId != null;

  bool get hasCodPayment => codAmount > 0;

  bool get isCompleted => status.isTerminal;

  bool get isInProgress => status.isActive;
  
  Parcel copyWith({
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
    return Parcel(
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

  @override
  List<Object?> get props => [
        id,
        trackingCode,
        senderId,
        senderName,
        receiverId,
        assignedRiderId,
        status,
        deliveryAddress,
        statusHistory,
        codAmount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Parcel('
        'id: $id, '
        'trackingCode: $trackingCode, '
        'status: $status, '
        'senderId: $senderId, '
        'receiverId: $receiverId'
        ')';
  }
}
