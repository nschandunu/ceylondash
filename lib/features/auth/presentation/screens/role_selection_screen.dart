import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'registration_screen.dart';

enum UserRole {
  rider('Rider', Icons.delivery_dining_rounded, 'Deliver parcels across Sri Lanka'),
  client('Client', Icons.person_rounded, 'Send and receive parcels with ease'),
  business('Business', Icons.store_rounded, 'Manage bulk shipments for your business');

  const UserRole(this.label, this.icon, this.description);

  final String label;
  final IconData icon;
  final String description;

  String get apiValue => name; // rider, client, business
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _onRoleSelected(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RegistrationScreen(role: role),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
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
              const SizedBox(height: AppDimensions.spacing8),
              Text('Choose Your Role', style: AppTextStyles.heading1),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Select how you want to use CeylonDash',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacing40),

              ...UserRole.values.map((role) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.spacing16),
                    child: _RoleCard(
                      role: role,
                      onTap: () => _onRoleSelected(context, role),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.onTap});

  final UserRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppDimensions.cardBorderRadius),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.cyan, AppColors.cyanDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(role.icon, color: AppColors.white, size: 28),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role.label, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(role.description, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textHint,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
