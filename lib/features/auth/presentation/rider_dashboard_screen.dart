import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Temporary Dashboard shell for Riders.
class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Rider Dashboard', style: AppTextStyles.heading2),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacing8),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to sign out?'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.read<AuthBloc>().add(AuthLoggedOut());
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.cancelled),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.two_wheeler, size: 64, color: AppColors.cyan),
            const SizedBox(height: 16),
            const Text('Welcome, Rider!', style: AppTextStyles.heading2),
          ],
        ),
      ),
    );
  }
}
