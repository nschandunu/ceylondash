import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'registration_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacing16),
              const Text('Choose Your Role', style: AppTextStyles.heading1),
              const SizedBox(height: AppDimensions.spacing8),
              const Text(
                'Select how you want to use CeylonDash',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacing40),

              _RoleCard(
                icon: Icons.person_outline,
                title: 'User',
                description: 'Send and receive parcels with ease',
                gradient: const [Color(0xFF00BCD4), Color(0xFF00E5FF)],
                onTap: () => _navigateToRegistration(context, 'user'),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              _RoleCard(
                icon: Icons.two_wheeler,
                title: 'Rider',
                description: 'Deliver parcels and earn money',
                gradient: const [Color(0xFF4CAF50), Color(0xFF81C784)],
                onTap: () => _navigateToRegistration(context, 'rider'),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              _RoleCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin',
                description: 'Manage the system and operations',
                gradient: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                onTap: () => _navigateToRegistration(context, 'admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRegistration(BuildContext context, String role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegistrationScreen(role: role),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppDimensions.cardElevation,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.white, size: 28),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
