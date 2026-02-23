import 'package:equatable/equatable.dart';

import '../../../core/enums/parcel_status.dart';

class StatusHistory extends Equatable {
    
    final ParcelStatus status;
    final DateTime updatedAt;

    const StatusHistory({
        required this.status,
        required this.updatedAt,
    });

  @override
  List<Object?> get props => [status, updatedAt];

  @override
  String toString() {
    return 'StatusHistory(status: $status, updatedAt: $updatedAt)';
  }
}
