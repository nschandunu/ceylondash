import 'package:flutter/material.dart';
import '../../../../core/enums/parcel_status.dart';
import '../../../../core/theme/theme.dart';
import '../extensions/parcel_status_ui_extension.dart';

class StatusBadge extends StatelessWidget {
  final ParcelStatus status;
  final bool showLabel;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? AppDimensions.spacing32 : AppDimensions.badgeHeight,
      padding: EdgeInsets.symmetric(
        horizontal: compact
            ? AppDimensions.spacing8
            : AppDimensions.badgePaddingHorizontal,
      ),
      decoration: BoxDecoration(
        color: status.statusColor,
        borderRadius: BorderRadius.circular(AppDimensions.badgeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: status.statusColor.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.statusIcon,
            size: compact ? AppDimensions.iconSmall : AppDimensions.iconMedium,
            color: AppColors.white,
          ),
          if (showLabel) ...[
            const SizedBox(width: AppDimensions.spacing8),
            Text(
              _getShortLabel(),
              style: compact
                  ? AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    )
                  : AppTextStyles.labelMedium,
            ),
          ],
        ],
      ),
    );
  }

  String _getShortLabel() {
    switch (status) {
      case ParcelStatus.pending:
        return 'Pending';
      case ParcelStatus.inTransit:
        return 'Moving';
      case ParcelStatus.outForDelivery:
        return 'Near';
      case ParcelStatus.delivered:
        return 'Done';
      case ParcelStatus.cancelled:
        return 'Stopped';
      case ParcelStatus.failed:
        return 'Issue';
    }
  }
}

class StatusIconLarge extends StatelessWidget {
  final ParcelStatus status;
  final double size;

  const StatusIconLarge({
    super.key,
    required this.status,
    this.size = AppDimensions.iconXLarge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + AppDimensions.spacing16,
      height: size + AppDimensions.spacing16,
      decoration: BoxDecoration(
        color: status.badgeBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: status.statusColor.withAlpha(77), width: 2),
      ),
      child: Icon(
        status.statusIconFilled,
        size: size,
        color: status.statusColor,
      ),
    );
  }
}
