import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.role});

  final String role;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Role-specific controllers
  final _addressController = TextEditingController(); // user
  final _licensePlateController = TextEditingController(); // rider
  final _passcodeController = TextEditingController(); // admin

  String _vehicleType = 'bike'; // rider default
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _licensePlateController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  String get _roleLabel {
    return switch (widget.role) {
      'user' => 'User',
      'rider' => 'Rider',
      'admin' => 'Admin',
      _ => 'User',
    };
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Create Firebase user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Build the sync payload
      final payload = <String, dynamic>{
        'role': widget.role,
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      };

      // Add role-specific fields
      if (widget.role == 'user') {
        payload['defaultDeliveryAddress'] = _addressController.text.trim();
      } else if (widget.role == 'rider') {
        payload['vehicleType'] = _vehicleType;
        payload['licensePlateNumber'] = _licensePlateController.text.trim();
      } else if (widget.role == 'admin') {
        payload['adminAccessPasscode'] = _passcodeController.text.trim();
      }

      // 3. Sync to MongoDB
      final authService = AuthService();
      await authService.syncUser(registrationData: payload);

      // AuthBloc will automatically detect the new Firebase user and navigate.
      if (mounted) {
        // Pop all auth screens — AuthWrapper will handle routing
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'email-already-in-use' => 'An account with this email already exists.',
          'weak-password' => 'Password is too weak. Use at least 6 characters.',
          'invalid-email' => 'The email address is invalid.',
          _ => e.message ?? 'Registration failed. Please try again.',
        };
      });
    } catch (e) {
      debugPrint('❌ Registration sync error: $e');

      // If Firebase user was created but sync failed, delete the Firebase user
      // to avoid orphaned accounts.
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await currentUser.delete();
        } catch (_) {
          // Best effort cleanup
        }
      }

      // Extract a meaningful message from Dio errors
      String message = 'Registration failed. Please try again.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['error'] != null) {
          message = data['error']['message'] ?? message;
        }
      }

      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Register as $_roleLabel',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
            vertical: AppDimensions.spacing16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing12),
                    decoration: BoxDecoration(
                      color: AppColors.cancelled.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cancelled.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.cancelled,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacing8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.cancelled,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                ],

                // Section: Account Info
                _sectionLabel('Account Information'),
                const SizedBox(height: AppDimensions.spacing12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Minimum 6 characters',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Section: Personal Info
                _sectionLabel('Personal Information'),
                const SizedBox(height: AppDimensions.spacing12),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '07X XXX XXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^(?:\+94|0)?[7][0-9]{8}$')
                        .hasMatch(v.trim().replaceAll(' ', ''))) {
                      return 'Enter a valid Sri Lankan phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Section: Role-specific fields
                ..._buildRoleFields(),

                const SizedBox(height: AppDimensions.spacing32),

                // Register button
                SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: AppTextStyles.buttonLarge,
                          ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleFields() {
    return switch (widget.role) {
      'user' => [
          _sectionLabel('Delivery Details'),
          const SizedBox(height: AppDimensions.spacing12),
          _buildTextField(
            controller: _addressController,
            label: 'Default Delivery Address',
            hint: 'No. 123, Main Street, Colombo',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Delivery address is required';
              }
              return null;
            },
          ),
        ],
      'rider' => [
          _sectionLabel('Vehicle Details'),
          const SizedBox(height: AppDimensions.spacing12),
          // Vehicle type dropdown
          DropdownButtonFormField<String>(
            initialValue: _vehicleType,
            decoration: InputDecoration(
              labelText: 'Vehicle Type',
              labelStyle: AppTextStyles.bodyMedium,
              prefixIcon:
                  const Icon(Icons.directions_bike, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing16,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.buttonRadius),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.buttonRadius),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.buttonRadius),
                borderSide:
                    const BorderSide(color: AppColors.cyan, width: 1.5),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'bike', child: Text('Bike')),
              DropdownMenuItem(
                  value: 'three-wheeler', child: Text('Three-wheeler')),
              DropdownMenuItem(value: 'van', child: Text('Van')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _vehicleType = value);
            },
          ),
          const SizedBox(height: AppDimensions.spacing16),
          _buildTextField(
            controller: _licensePlateController,
            label: 'License Plate Number',
            hint: 'ABC-1234',
            icon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.characters,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'License plate number is required';
              }
              return null;
            },
          ),
        ],
      'admin' => [
          _sectionLabel('Admin Verification'),
          const SizedBox(height: AppDimensions.spacing12),
          _buildTextField(
            controller: _passcodeController,
            label: 'Admin Access Passcode',
            hint: 'Enter the admin passcode',
            icon: Icons.security,
            obscureText: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Admin access passcode is required';
              }
              return null;
            },
          ),
        ],
      _ => [],
    };
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.heading3.copyWith(fontSize: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: AppTextStyles.bodyLarge,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodySmall,
        prefixIcon: Icon(icon, color: AppColors.textHint),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.cancelled),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.cancelled, width: 1.5),
        ),
      ),
    );
  }
}
