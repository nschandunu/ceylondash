import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/enums/parcel_status.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/domain/entities/parcel.dart';
import '../extensions/parcel_status_ui_extension.dart';
import 'parcel_progress_indicator.dart';
import 'status_badge.dart';

class ParcelCard extends StatelessWidget {
  final Parcel parcel;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onClaimDelivery;
  final ValueChanged<String>? onUpdateStatus;
  final VoidCallback? onShowHandoverQR;
  final VoidCallback? onScanHandoverQR;
  final String? userRole;
  final String? currentUserId;
  final bool isLoading;

  const ParcelCard({
    super.key,
    required this.parcel,
    this.onTap,
    this.onViewDetails,
    this.onClaimDelivery,
    this.onUpdateStatus,
    this.onShowHandoverQR,
    this.onScanHandoverQR,
    this.userRole,
    this.currentUserId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingHorizontal,
          vertical: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.white.withAlpha(128),
              blurRadius: 0,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimensions.glassBlur,
              sigmaY: AppDimensions.glassBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: AppDimensions.glassBorderWidth,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardBorderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildProgressSection(),
                    if (_shouldShowRiderActions) ...[
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildRiderActions(),
                    ],
                    if (_shouldShowHandoverActions) ...[
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildHandoverActions(),
                    ],
                    const SizedBox(height: AppDimensions.spacing20),
                    _buildActionSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _shouldShowHandoverActions {
    if (parcel.status != ParcelStatus.outForDelivery) return false;
    // Receiver sees "Show Handover QR"
    if (userRole == 'user' &&
        currentUserId != null &&
        parcel.receiverId == currentUserId &&
        onShowHandoverQR != null) {
      return true;
    }
    // Rider sees "Scan Receiver QR"
    if (userRole == 'rider' &&
        currentUserId != null &&
        parcel.assignedRiderId == currentUserId &&
        onScanHandoverQR != null) {
      return true;
    }
    return false;
  }

  Widget _buildHandoverActions() {
    // Receiver → generate & show QR
    if (userRole == 'user' && onShowHandoverQR != null) {
      return SizedBox(
        width: double.infinity,
        height: AppDimensions.touchTargetMin,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onShowHandoverQR,
          icon: isLoading
              ? const SizedBox(
                  width: AppDimensions.iconMedium,
                  height: AppDimensions.iconMedium,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.qr_code, size: AppDimensions.iconMedium),
          label: Text(isLoading ? 'Generating\u2026' : 'Show Handover QR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.delivered,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.delivered.withAlpha(128),
            disabledForegroundColor: AppColors.white.withAlpha(180),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
        ),
      );
    }

    // Rider → scan QR
    if (userRole == 'rider' && onScanHandoverQR != null) {
      return SizedBox(
        width: double.infinity,
        height: AppDimensions.touchTargetMin,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onScanHandoverQR,
          icon: isLoading
              ? const SizedBox(
                  width: AppDimensions.iconMedium,
                  height: AppDimensions.iconMedium,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.qr_code_scanner, size: AppDimensions.iconMedium),
          label: Text(isLoading ? 'Verifying\u2026' : 'Scan Receiver QR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.delivered,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.delivered.withAlpha(128),
            disabledForegroundColor: AppColors.white.withAlpha(180),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  bool get _shouldShowRiderActions {
    if (userRole != 'rider') return false;
    if (parcel.status == ParcelStatus.pending && onClaimDelivery != null) {
      return true;
    }
    if (parcel.status == ParcelStatus.inTransit &&
        currentUserId != null &&
        parcel.assignedRiderId == currentUserId &&
        onUpdateStatus != null) {
      return true;
    }
    return false;
  }

  Widget _buildRiderActions() {
    // Pending parcel → "Claim Delivery" button
    if (parcel.status == ParcelStatus.pending && onClaimDelivery != null) {
      return SizedBox(
        width: double.infinity,
        height: AppDimensions.touchTargetMin,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onClaimDelivery,
          icon: isLoading
              ? const SizedBox(
                  width: AppDimensions.iconMedium,
                  height: AppDimensions.iconMedium,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.delivery_dining, size: AppDimensions.iconMedium),
          label: Text(isLoading ? 'Claiming\u2026' : 'Claim Delivery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyan,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.cyan.withAlpha(128),
            disabledForegroundColor: AppColors.white.withAlpha(180),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
        ),
      );
    }

    // In-transit parcel owned by this rider → "Out for Delivery" button
    if (parcel.status == ParcelStatus.inTransit && onUpdateStatus != null) {
      return SizedBox(
        width: double.infinity,
        height: AppDimensions.touchTargetMin,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : () => onUpdateStatus!('out_for_delivery'),
          icon: isLoading
              ? const SizedBox(
                  width: AppDimensions.iconMedium,
                  height: AppDimensions.iconMedium,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.local_shipping, size: AppDimensions.iconMedium),
          label: Text(isLoading ? 'Updating\u2026' : 'Mark Out for Delivery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.outForDelivery,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.outForDelivery.withAlpha(128),
            disabledForegroundColor: AppColors.white.withAlpha(180),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimensions.iconXLarge,
          height: AppDimensions.iconXLarge,
          decoration: BoxDecoration(
            color: parcel.status.badgeBackgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.spacing12),
          ),
          child: Icon(
            parcel.status.statusIconFilled,
            size: AppDimensions.iconLarge,
            color: parcel.status.statusColor,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        // Tracking info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parcel.trackingCode,
                style: AppTextStyles.trackingCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacing4),

              Text(
                parcel.senderName,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        // Status Badge
        StatusBadge(status: parcel.status),
      ],
    );
  }

  Widget _buildProgressSection() {
    return ParcelProgressIndicator(status: parcel.status);
  }

  Widget _buildActionSection() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: AppDimensions.iconMedium,
                color: AppColors.textHint,
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Expanded(
                child: Text(
                  parcel.deliveryAddress,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacing12),
        _buildViewDetailsButton(),
      ],
    );
  }
  
  Widget _buildViewDetailsButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewDetails ?? onTap,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          height: AppDimensions.touchTargetMin,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.cyan, AppColors.cyanLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withAlpha(77),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: AppDimensions.iconMedium,
                color: AppColors.white,
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Text('View', style: AppTextStyles.buttonMedium),
            ],
          ),
        ),
      ),
    );
  }
}
