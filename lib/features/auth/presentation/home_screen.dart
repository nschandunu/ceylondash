import 'package:flutter/material.dart';

import '../../../core/domain/auth_service.dart';
import 'role_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserRole role;
  final AuthService _authService = AuthService();

  HomeScreen({super.key, required this.role});

  String get _roleLabel {
    switch (role) {
      case UserRole.client:
        return 'Client';
      case UserRole.business:
        return 'Business';
      case UserRole.rider:
        return 'Rider';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_roleLabel Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, $_roleLabel!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
