import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'screens/login_screen.dart';
import 'dashboard_screen.dart';
import 'rider_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

/// Routes based on AuthBloc state:
/// - Authenticated → DashboardScreen
/// - Unauthenticated → LoginScreen
/// - Loading / Initial → Splash indicator
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final role = state.mongoUser['role'] as String?;
          
          if (role == 'rider') {
            return const RiderDashboardScreen();
          } else if (role == 'admin') {
            return const AdminDashboardScreen();
          }
          
          // Default to user dashboard
          return const DashboardScreen();
        }

        if (state is Unauthenticated) {
          return const LoginScreen();
        }

        // AuthInitial or AuthLoading — show a branded splash
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          ),
        );
      },
    );
  }
}
