import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../../../parcel_feed/presentation/screens/parcel_feed_screen.dart';
import '../bloc/auth_bloc.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: switch (state.status) {
            AuthStatus.authenticated => const ParcelFeedScreen(
                key: ValueKey('dashboard'),
              ),
            AuthStatus.unauthenticated => const LoginScreen(
                key: ValueKey('login'),
              ),
            AuthStatus.unknown => Scaffold(
                key: const ValueKey('splash'),
                backgroundColor: AppColors.background,
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          },
        );
      },
    );
  }
}
