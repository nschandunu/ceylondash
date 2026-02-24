import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../data/services/user_service.dart';
import '../../bloc/parcel_bloc.dart';
import '../../bloc/parcel_event.dart';
import '../../bloc/parcel_state.dart';

class CreateParcelScreen extends StatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _codController = TextEditingController(text: '0');
  final _receiverSearchController = TextEditingController();

  final UserService _userService = UserService();
  Timer? _debounce;

  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedReceiver;
  bool _isSearching = false;

  @override
  void dispose() {
    _addressController.dispose();
    _codController.dispose();
    _receiverSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onReceiverSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _userService.searchUsers(query.trim());
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectReceiver(Map<String, dynamic> user) {
    setState(() {
      _selectedReceiver = user;
      _receiverSearchController.text = user['name'] as String? ?? '';
      _searchResults = [];
    });
  }

  void _clearReceiver() {
    setState(() {
      _selectedReceiver = null;
      _receiverSearchController.clear();
      _searchResults = [];
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final address = _addressController.text.trim();
    final cod = double.tryParse(_codController.text.trim()) ?? 0;
    final receiverId = _selectedReceiver?['_id'] as String?;

    context.read<ParcelBloc>().add(CreateParcel(
          deliveryAddress: address,
          receiverId: receiverId,
          codAmount: cod,
        ));
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      prefixStyle:
          AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        borderSide: const BorderSide(color: AppColors.cyan, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParcelBloc, ParcelState>(
      listener: (context, state) {
        if (state is ParcelLoaded) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Parcel created successfully'),
              backgroundColor: AppColors.delivered,
            ),
          );
        } else if (state is ParcelError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.failed,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('New Parcel'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Receiver ──
                Text('Receiver', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppDimensions.spacing8),
                if (_selectedReceiver != null)
                  _buildSelectedReceiverChip()
                else ...[
                  TextField(
                    controller: _receiverSearchController,
                    decoration: _inputDecoration(
                      hintText: 'Search by name or phone',
                    ).copyWith(
                      prefixIcon: const Icon(Icons.person_search_outlined,
                          color: AppColors.textHint),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.cyan,
                                ),
                              ),
                            )
                          : null,
                    ),
                    onChanged: _onReceiverSearchChanged,
                  ),
                  if (_searchResults.isNotEmpty) _buildSearchResults(),
                ],
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  'Optional \u2014 leave empty if the receiver isn\'t on CeylonDash.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textHint, fontSize: 11),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // ── Delivery Address ──
                Text('Delivery Address', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppDimensions.spacing8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hintText: 'e.g. 45 Galle Road, Colombo 03',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Delivery address is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // ── COD Amount ──
                Text('Cash on Delivery (LKR)',
                    style: AppTextStyles.labelLarge),
                const SizedBox(height: AppDimensions.spacing8),
                TextFormField(
                  controller: _codController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: _inputDecoration(
                    hintText: '0',
                    prefixText: 'Rs. ',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed < 0) {
                        return 'Enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // ── Submit ──
                BlocBuilder<ParcelBloc, ParcelState>(
                  builder: (context, state) {
                    final isSubmitting = state is ParcelActionInProgress;

                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor:
                              AppColors.cyan.withAlpha(128),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text('Create Parcel',
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: AppColors.white)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedReceiverChip() {
    final name = _selectedReceiver!['name'] as String? ?? 'Unknown';
    final phone = _selectedReceiver!['phoneNumber'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cyan.withAlpha(20),
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        border: Border.all(color: AppColors.cyan.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.cyan, size: 20),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                if (phone.isNotEmpty)
                  Text(phone,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReceiver,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textHint,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final name = user['name'] as String? ?? 'Unknown';
          final phone = user['phoneNumber'] as String? ?? '';

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.cyan.withAlpha(30),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(name, style: AppTextStyles.bodyMedium),
            subtitle: phone.isNotEmpty
                ? Text(phone,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary))
                : null,
            onTap: () => _selectReceiver(user),
          );
        },
      ),
    );
  }
}
