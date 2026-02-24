import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
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

  @override
  void dispose() {
    _addressController.dispose();
    _codController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final address = _addressController.text.trim();
    final cod = double.tryParse(_codController.text.trim()) ?? 0;

    context.read<ParcelBloc>().add(CreateParcel(
          deliveryAddress: address,
          codAmount: cod,
        ));
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
                // ── Delivery Address ──
                Text('Delivery Address', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppDimensions.spacing8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'e.g. 45 Galle Road, Colombo 03',
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardBorderRadius),
                      borderSide:
                          const BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardBorderRadius),
                      borderSide:
                          const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardBorderRadius),
                      borderSide:
                          const BorderSide(color: AppColors.cyan, width: 2),
                    ),
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
                Text('Cash on Delivery (LKR)', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppDimensions.spacing8),
                TextFormField(
                  controller: _codController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: 'Rs. ',
                    prefixStyle: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardBorderRadius),
                      borderSide:
                          const BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardBorderRadius),
                      borderSide:
                          const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardBorderRadius),
                      borderSide:
                          const BorderSide(color: AppColors.cyan, width: 2),
                    ),
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
}
