import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../parcel_feed/presentation/screens/create_parcel_screen.dart';
import '../../parcel_feed/presentation/screens/parcel_feed_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Dashboard shell with logout and Sent/Received tabs for users.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final role = authState is Authenticated
        ? authState.mongoUser['role'] as String?
        : null;

    // Riders see the full unfiltered feed (they need to claim/manage deliveries).
    if (role == 'rider') {
      return _buildRiderDashboard(context);
    }

    // Regular users get Sent / Received tabs.
    return _buildUserDashboard(context);
  }

  // ── Rider dashboard (no tabs) ─────────────────────────────────────────

  Widget _buildRiderDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('CeylonDash', style: AppTextStyles.heading2),
        actions: [_buildLogoutButton(context)],
      ),
      body: const ParcelFeedScreen(),
    );
  }

  // ── User dashboard (tabs) ─────────────────────────────────────────────

  Widget _buildUserDashboard(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('CeylonDash', style: AppTextStyles.heading2),
          actions: [_buildLogoutButton(context)],
          bottom: const TabBar(
            indicatorColor: AppColors.cyan,
            indicatorWeight: 3,
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.labelLarge,
            tabs: [
              Tab(text: 'My Shipments'),
              Tab(text: 'Incoming Parcels'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ParcelFeedScreen(feedMode: FeedMode.sent),
            ParcelFeedScreen(feedMode: FeedMode.received),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CreateParcelScreen(),
              ),
            );
          },
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
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
    );
  }
}
