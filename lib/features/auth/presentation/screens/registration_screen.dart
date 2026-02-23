import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/services/auth_service.dart';
import 'role_selection_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Shared fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  // Rider-specific
  final _vehicleTypeController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  // Business-specific
  final _businessNameController = TextEditingController();
  final _businessRegController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _vehicleTypeController.dispose();
    _licenseNumberController.dispose();
    _businessNameController.dispose();
    _businessRegController.dispose();
    super.dispose();
  }

  List<_FieldConfig> get _fields {
    final shared = [
      if (widget.role == UserRole.business)
        _FieldConfig(
          controller: _businessNameController,
          label: 'Business Name',
          icon: Icons.business_rounded,
          validator: _requiredValidator('Business name'),
        ),
      _FieldConfig(
        controller: _nameController,
        label: widget.role == UserRole.business ? 'Contact Person' : 'Full Name',
        icon: Icons.person_outlined,
        validator: _requiredValidator('Name'),
      ),
      _FieldConfig(
        controller: _emailController,
        label: 'Email',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: _emailValidator,
      ),
      _FieldConfig(
        controller: _phoneController,
        label: 'Phone Number',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        hint: '07X XXX XXXX',
        validator: _phoneValidator,
      ),
      _FieldConfig(
        controller: _passwordController,
        label: 'Password',
        icon: Icons.lock_outline_rounded,
        isPassword: true,
        validator: _passwordValidator,
      ),
    ];

    final roleSpecific = switch (widget.role) {
      UserRole.rider => [
        _FieldConfig(
          controller: _vehicleTypeController,
          label: 'Vehicle Type',
          icon: Icons.two_wheeler_rounded,
          hint: 'e.g. Motorcycle, Three-wheeler',
          validator: _requiredValidator('Vehicle type'),
        ),
        _FieldConfig(
          controller: _licenseNumberController,
          label: 'License Number',
          icon: Icons.badge_outlined,
          validator: _requiredValidator('License number'),
        ),
      ],
      UserRole.client => [
        _FieldConfig(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          validator: _requiredValidator('Address'),
        ),
      ],
      UserRole.business => [
        _FieldConfig(
          controller: _businessRegController,
          label: 'Business Registration No.',
          icon: Icons.description_outlined,
          validator: _requiredValidator('Registration number'),
        ),
        _FieldConfig(
          controller: _addressController,
          label: 'Business Address',
          icon: Icons.location_on_outlined,
          validator: _requiredValidator('Address'),
        ),
      ],
    };

    return [...shared, ...roleSpecific];
  }

  Map<String, dynamic> get _formData {
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    if (widget.role == UserRole.rider) {
      data['vehicleType'] = _vehicleTypeController.text.trim();
      data['licenseNumber'] = _licenseNumberController.text.trim();
    } else if (widget.role == UserRole.business) {
      data['businessName'] = _businessNameController.text.trim();
      data['businessRegNumber'] = _businessRegController.text.trim();
    }

    return data;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Create Firebase account
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user!;
      final idToken = await user.getIdToken();

      // 2. Create backend profile
      await _authService.createUserProfile(
        idToken: idToken!,
        firebaseUid: user.uid,
        role: widget.role,
        formData: _formData,
      );

      // AuthBloc will pick up the auth state change automatically
      // and navigate to the dashboard. Pop back to root.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'email-already-in-use' => 'An account already exists with this email.',
          'weak-password' => 'Password is too weak. Use at least 6 characters.',
          'invalid-email' => 'Please enter a valid email address.',
          _ => 'Registration failed. Please try again.',
        };
      });
    } catch (e) {
      // If backend call fails after Firebase signup, delete the Firebase account
      // to avoid orphaned accounts.
      await FirebaseAuth.instance.currentUser?.delete();
      setState(() {
        _errorMessage = 'Failed to create your profile. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing8),

                // Header with role icon
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cyan, AppColors.cyanDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(widget.role.icon,
                          color: AppColors.white, size: 24),
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.role.label} Registration',
                            style: AppTextStyles.heading2),
                        Text('Fill in your details',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing32),

                // Error banner
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.spacing12),
                    decoration: BoxDecoration(
                      color: AppColors.cancelled.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.spacing12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: AppColors.cancelled, size: 20),
                        const SizedBox(width: AppDimensions.spacing8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.cancelled),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                ],

                // Dynamic fields
                ..._fields.map((field) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacing16),
                      child: TextFormField(
                        controller: field.controller,
                        keyboardType: field.keyboardType,
                        obscureText: field.isPassword && _obscurePassword,
                        validator: field.validator,
                        decoration: InputDecoration(
                          labelText: field.label,
                          hintText: field.hint,
                          labelStyle: AppTextStyles.bodyMedium,
                          hintStyle: AppTextStyles.bodySmall,
                          prefixIcon: Icon(field.icon,
                              color: AppColors.textHint, size: 20),
                          suffixIcon: field.isPassword
                              ? IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textHint,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing16,
                            vertical: AppDimensions.spacing16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.spacing12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.spacing12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.spacing12),
                            borderSide: const BorderSide(
                                color: AppColors.cyan, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.spacing12),
                            borderSide: BorderSide(color: AppColors.cancelled),
                          ),
                        ),
                      ),
                    )),

                const SizedBox(height: AppDimensions.spacing16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.buttonRadius),
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
                        : Text('Create Account',
                            style: AppTextStyles.buttonLarge),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Validators --

  String? Function(String?) _requiredValidator(String fieldName) {
    return (v) {
      if (v == null || v.trim().isEmpty) return '$fieldName is required';
      return null;
    };
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!v.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final cleaned = v.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(?:\+94|0)?7[0-9]{8}$').hasMatch(cleaned)) {
      return 'Enter a valid Sri Lankan phone number';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Must be at least 8 characters';
    return null;
  }
}

class _FieldConfig {
  const _FieldConfig({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.isPassword = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
}
