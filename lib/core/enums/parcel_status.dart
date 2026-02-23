enum ParcelStatus {
  pending,
  inTransit,
  outForDelivery,
  delivered,
  cancelled,
  failed,
}

extension ParcelStatusExtension on ParcelStatus {
  String toApiString() {
    switch (this) {
      case ParcelStatus.pending:
        return 'pending';
      case ParcelStatus.inTransit:
        return 'in_transit';
      case ParcelStatus.outForDelivery:
        return 'out_for_delivery';
      case ParcelStatus.delivered:
        return 'delivered';
      case ParcelStatus.cancelled:
        return 'cancelled';
      case ParcelStatus.failed:
        return 'failed';
    }
  }

  String get displayName {
    switch (this) {
      case ParcelStatus.pending:
        return 'Pending';
      case ParcelStatus.inTransit:
        return 'In Transit';
      case ParcelStatus.outForDelivery:
        return 'Out for Delivery';
      case ParcelStatus.delivered:
        return 'Delivered';
      case ParcelStatus.cancelled:
        return 'Cancelled';
      case ParcelStatus.failed:
        return 'Failed';
    }
  }

  bool get isTerminal {
    return this == ParcelStatus.delivered ||
        this == ParcelStatus.cancelled ||
        this == ParcelStatus.failed;
  }

  bool get isActive {
    return this == ParcelStatus.inTransit ||
        this == ParcelStatus.outForDelivery;
  }
}

class ParcelStatusParser {
  ParcelStatusParser._();
  
  static ParcelStatus fromString(String? value) {
    if (value == null || value.isEmpty) {
      return ParcelStatus.pending;
    }

    switch (value.toLowerCase().trim()) {
      case 'pending':
        return ParcelStatus.pending;
      case 'in_transit':
        return ParcelStatus.inTransit;
      case 'out_for_delivery':
        return ParcelStatus.outForDelivery;
      case 'delivered':
        return ParcelStatus.delivered;
      case 'cancelled':
        return ParcelStatus.cancelled;
      case 'failed':
        return ParcelStatus.failed;
      default:
        return ParcelStatus.pending;
    }
  }
  
  static ParcelStatus? tryFromString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    switch (value.toLowerCase().trim()) {
      case 'pending':
        return ParcelStatus.pending;
      case 'in_transit':
        return ParcelStatus.inTransit;
      case 'out_for_delivery':
        return ParcelStatus.outForDelivery;
      case 'delivered':
        return ParcelStatus.delivered;
      case 'cancelled':
        return ParcelStatus.cancelled;
      case 'failed':
        return ParcelStatus.failed;
      default:
        return null;
    }
  }
}
