import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/mock_parcel_data.dart';

class FeedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ParcelStats stats;
  final double expandedHeight;
  final double collapsedHeight;

  FeedHeaderDelegate({
    required this.stats,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant FeedHeaderDelegate oldDelegate) {
    return stats != oldDelegate.stats ||
        expandedHeight != oldDelegate.expandedHeight ||
        collapsedHeight != oldDelegate.collapsedHeight;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = math.min(1.0, shrinkOffset / (maxExtent - minExtent));
    final expandedProgress = 1.0 - progress;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow.withAlpha((progress * 40).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackgroundDecoration(expandedProgress),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.spacing16),
                  _buildTitleRow(progress),
                  if (expandedProgress > 0) ...[
                    SizedBox(
                      height: AppDimensions.spacing16 * expandedProgress,
                    ),
                    Opacity(
                      opacity: expandedProgress,
                      child: _buildSummarySection(isWideScreen),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration(double expandedProgress) {
    return Positioned(
      top: -50 + (expandedProgress * 50),
      right: -100 + (expandedProgress * 50),
      child: Opacity(
        opacity: expandedProgress * 0.1,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.cyan, AppColors.cyan.withAlpha(0)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                progress > 0.5 ? 'Parcels' : 'Good Day!',
                style: progress > 0.5
                    ? AppTextStyles.heading2
                    : AppTextStyles.heading1,
              ),
              if (progress < 0.8)
                Opacity(
                  opacity: 1.0 - (progress * 1.25),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacing4),
                    child: Text(
                      'Track your deliveries',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _buildHeaderAction(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.spacing12),
        child: Container(
          width: AppDimensions.touchTargetMin,
          height: AppDimensions.touchTargetMin,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.spacing12),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconMedium,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(bool isWideScreen) {
    return Row(
      children: [
        _buildStatCard(
          value: stats.active.toString(),
          label: 'Active',
          icon: Icons.local_shipping_outlined,
          color: AppColors.cyan,
          isHighlighted: true,
        ),
        const SizedBox(width: AppDimensions.spacing12),
        _buildStatCard(
          value: stats.pending.toString(),
          label: 'Pending',
          icon: Icons.inventory_2_outlined,
          color: AppColors.pending,
        ),
        const SizedBox(width: AppDimensions.spacing12),
        _buildStatCard(
          value: stats.delivered.toString(),
          label: 'Delivered',
          icon: Icons.check_circle_outline,
          color: AppColors.delivered,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: isHighlighted ? color.withAlpha(26) : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.spacing16),
          border: isHighlighted
              ? Border.all(color: color.withAlpha(51), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppDimensions.iconMedium, color: color),
                const Spacer(),
                Text(
                  value,
                  style: AppTextStyles.summaryNumber.copyWith(
                    color: isHighlighted ? color : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Text(label, style: AppTextStyles.summaryLabel),
          ],
        ),
      ),
    );
  }
}
