import 'package:flutter/material.dart';

import '../../../../core/enums/parcel_status.dart';
import '../../../../core/theme/app_colors.dart';

/// UI-specific extensions for ParcelStatus
/// Maps status to visual elements (colors, icons) for accessible presentation
extension ParcelStatusUIExtension on ParcelStatus {
  /// Returns the visual color for this status
  Color get statusColor {
    switch (this) {
      case ParcelStatus.pending:
        return AppColors.pending;
      case ParcelStatus.inTransit:
        return AppColors.inTransit;
      case ParcelStatus.outForDelivery:
        return AppColors.outForDelivery;
      case ParcelStatus.delivered:
        return AppColors.delivered;
      case ParcelStatus.cancelled:
        return AppColors.cancelled;
      case ParcelStatus.failed:
        return AppColors.failed;
    }
  }

  /// Returns a large, recognizable icon for this status
  /// Designed for illiterate-friendly UI
  IconData get statusIcon {
    switch (this) {
      case ParcelStatus.pending:
        return Icons.inventory_2_outlined; // Box icon for pending
      case ParcelStatus.inTransit:
        return Icons.local_shipping; // Moving truck for in-transit
      case ParcelStatus.outForDelivery:
        return Icons.delivery_dining; // Delivery vehicle
      case ParcelStatus.delivered:
        return Icons.home_outlined; // House with check for delivered
      case ParcelStatus.cancelled:
        return Icons.cancel_outlined; // Cancel icon
      case ParcelStatus.failed:
        return Icons.error_outline; // Error icon
    }
  }

  /// Returns a filled version of the status icon
  IconData get statusIconFilled {
    switch (this) {
      case ParcelStatus.pending:
        return Icons.inventory_2;
      case ParcelStatus.inTransit:
        return Icons.local_shipping;
      case ParcelStatus.outForDelivery:
        return Icons.delivery_dining;
      case ParcelStatus.delivered:
        return Icons.home;
      case ParcelStatus.cancelled:
        return Icons.cancel;
      case ParcelStatus.failed:
        return Icons.error;
    }
  }

  /// Background color for status badges (slightly transparent)
  Color get badgeBackgroundColor {
    return statusColor.withAlpha(26); // 10% opacity
  }

  /// Progress value from 0.0 to 1.0
  double get progressValue {
    switch (this) {
      case ParcelStatus.pending:
        return 0.0;
      case ParcelStatus.inTransit:
        return 0.33;
      case ParcelStatus.outForDelivery:
        return 0.66;
      case ParcelStatus.delivered:
        return 1.0;
      case ParcelStatus.cancelled:
        return 0.0;
      case ParcelStatus.failed:
        return 0.0;
    }
  }

  /// Returns the step index for progress visualization (0-3)
  int get progressStep {
    switch (this) {
      case ParcelStatus.pending:
        return 0;
      case ParcelStatus.inTransit:
        return 1;
      case ParcelStatus.outForDelivery:
        return 2;
      case ParcelStatus.delivered:
        return 3;
      case ParcelStatus.cancelled:
        return -1; // Special case
      case ParcelStatus.failed:
        return -1; // Special case
    }
  }
}
