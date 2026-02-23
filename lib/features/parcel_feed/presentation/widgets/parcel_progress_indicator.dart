import 'package:flutter/material.dart';
import '../../../../core/enums/parcel_status.dart';
import '../../../../core/theme/theme.dart';
import '../extensions/parcel_status_ui_extension.dart';

class ParcelProgressIndicator extends StatelessWidget {
  final ParcelStatus status;
  const ParcelProgressIndicator({super.key, required this.status});
  static const List<_ProgressStepData> _steps = [
    _ProgressStepData(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Pickup',
    ),
    _ProgressStepData(
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      label: 'Transit',
    ),
    _ProgressStepData(
      icon: Icons.delivery_dining_outlined,
      activeIcon: Icons.delivery_dining,
      label: 'Delivery',
    ),
    _ProgressStepData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Done',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = status.progressStep;
    final isCancelledOrFailed = currentStep < 0;

    if (isCancelledOrFailed) {
      return _buildErrorState();
    }

    return Column(
      children: [
        _buildProgressBar(currentStep),
        const SizedBox(height: AppDimensions.spacing12),
        _buildStepIcons(currentStep),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: status.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.spacing12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status.statusIconFilled,
            size: AppDimensions.iconLarge,
            color: status.statusColor,
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Text(
            status.displayName,
            style: AppTextStyles.labelLarge.copyWith(color: status.statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final stepWidth = totalWidth / (_steps.length - 1);
        final progressWidth = currentStep * stepWidth;

        return SizedBox(
          height: AppDimensions.progressDotActiveSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: AppDimensions.progressBarHeight,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.progressBarRadius,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: progressWidth,
                  height: AppDimensions.progressBarHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan, AppColors.cyanLight],
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.progressBarRadius,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_steps.length, (index) {
                  final isActive = index <= currentStep;
                  final isCurrent = index == currentStep;

                  return _buildProgressDot(
                    isActive: isActive,
                    isCurrent: isCurrent,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressDot({required bool isActive, required bool isCurrent}) {
    final size = isCurrent
        ? AppDimensions.progressDotActiveSize
        : AppDimensions.progressDotSize;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? AppColors.cyan : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.cyan : AppColors.divider,
          width: 2,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.cyan.withAlpha(77),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: isActive
          ? Icon(Icons.check, size: isCurrent ? 12 : 10, color: AppColors.white)
          : null,
    );
  }

  Widget _buildStepIcons(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;

        return _buildStepIcon(
          step: step,
          isActive: isActive,
          isCurrent: isCurrent,
        );
      }),
    );
  }

  Widget _buildStepIcon({
    required _ProgressStepData step,
    required bool isActive,
    required bool isCurrent,
  }) {
    return Column(
      children: [
        Icon(
          isActive ? step.activeIcon : step.icon,
          size: AppDimensions.iconMedium,
          color: isActive
              ? (isCurrent ? AppColors.cyan : AppColors.cyanDark)
              : AppColors.textHint,
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          step.label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.textSecondary : AppColors.textHint,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ProgressStepData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _ProgressStepData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
