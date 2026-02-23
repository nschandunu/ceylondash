import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/domain/entities/parcel.dart';
import '../extensions/parcel_status_ui_extension.dart';
import 'parcel_progress_indicator.dart';
import 'status_badge.dart';

class ParcelCard extends StatelessWidget {
  final Parcel parcel;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const ParcelCard({
    super.key,
    required this.parcel,
    this.onTap,
    this.onViewDetails,
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
