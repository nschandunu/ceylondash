import 'package:flutter/material.dart';

import 'login_screen.dart';

enum UserRole { client, business, rider }

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to CeylonDash',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your role to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              _RoleCard(
                icon: Icons.person,
                label: 'Client',
                color: Colors.blue,
                onTap: () => _navigateToLogin(context, UserRole.client),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.store,
                label: 'Business',
                color: Colors.orange,
                onTap: () => _navigateToLogin(context, UserRole.business),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.delivery_dining,
                label: 'Rider',
                color: Colors.green,
                onTap: () => _navigateToLogin(context, UserRole.rider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
