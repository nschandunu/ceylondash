import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/parcel_status.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/domain/entities/parcel.dart';
import '../../bloc/parcel_bloc.dart';
import '../../bloc/parcel_event.dart';
import '../../bloc/parcel_state.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../data/mock_parcel_data.dart'; // ParcelStats
import '../widgets/parcel_card.dart';
import 'feed_header_delegate.dart';
import 'qr_scanner_screen.dart';

/// Controls which subset of parcels the feed displays.
enum FeedMode { all, sent, received }

class ParcelFeedScreen extends StatelessWidget {
  const ParcelFeedScreen({super.key, this.feedMode = FeedMode.all});

  final FeedMode feedMode;

  ParcelStats _computeStats(List<Parcel> parcels) {
    return ParcelStats(
      total: parcels.length,
      active: parcels.where((p) => p.isInProgress).length,
      pending:
          parcels.where((p) => p.status == ParcelStatus.pending).length,
      delivered:
          parcels.where((p) => p.status == ParcelStatus.delivered).length,
    );
  }

  String? _currentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.mongoUser['_id'] as String?;
    }
    return null;
  }

  List<Parcel> _filterParcels(List<Parcel> parcels, String? userId) {
    if (userId == null || feedMode == FeedMode.all) return parcels;
    return switch (feedMode) {
      FeedMode.sent => parcels.where((p) => p.senderId == userId).toList(),
      FeedMode.received =>
        parcels.where((p) => p.receiverId == userId).toList(),
      FeedMode.all => parcels,
    };
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocListener<ParcelBloc, ParcelState>(
      listener: (context, state) {
        if (state is ParcelActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.failed,
            ),
          );
        } else if (state is HandoverTokenGenerated &&
            feedMode != FeedMode.sent) {
          _showHandoverQRDialog(context, state);
        } else if (state is HandoverVerified && feedMode != FeedMode.sent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery Successful!'),
              backgroundColor: AppColors.delivered,
            ),
          );
          context.read<ParcelBloc>().add(LoadParcels());
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ParcelBloc, ParcelState>(
        builder: (context, state) {
          final allParcels = _parcelsFromState(state);
          final userId = _currentUserId(context);
          final parcels = _filterParcels(allParcels, userId);
          final stats = _computeStats(parcels);
          final isActionInProgress = state is ParcelActionInProgress;

          return RefreshIndicator(
            color: AppColors.cyan,
            onRefresh: () async {
              context.read<ParcelBloc>().add(LoadParcels());
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: FeedHeaderDelegate(
                    stats: stats,
                    expandedHeight: AppDimensions.headerExpandedHeight,
                    collapsedHeight: AppDimensions.headerCollapsedHeight,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.spacing16),
                ),

                if (state is ParcelLoading)
                  _buildLoadingSliver()
                else if (state is ParcelError)
                  _buildErrorSliver(context, state.message)
                else if (parcels.isEmpty)
                  _buildEmptySliver()
                else
                  _buildParcelList(parcels, isActionInProgress),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.spacing32),
                ),
              ],
            ),
          );
        },
      ),
    ),
    );
  }

  List<Parcel> _parcelsFromState(ParcelState state) {
    if (state is ParcelLoaded) return state.parcels;
    if (state is ParcelActionInProgress) return state.parcels;
    if (state is ParcelActionError) return state.parcels;
    if (state is HandoverTokenGenerated) return state.parcels;
    if (state is HandoverVerified) return state.parcels;
    return const [];
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoadingSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.cyan,
              strokeWidth: 3,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Fetching your parcels\u2026',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildErrorSliver(BuildContext context, String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: AppDimensions.iconXLarge,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text('Something Went Wrong', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<ParcelBloc>().add(LoadParcels()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.buttonRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty ────────────────────────────────────────────────────────────────

  Widget _buildEmptySliver() {
    final emptyMessage = switch (feedMode) {
      FeedMode.sent => 'Parcels you send will appear here.',
      FeedMode.received => 'Parcels sent to you will appear here.',
      FeedMode.all => 'Your active and recent parcels will appear here.',
    };

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text('No Parcels Yet', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                emptyMessage,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Handover QR Dialog ──────────────────────────────────────────────────

  void _showHandoverQRDialog(
    BuildContext context,
    HandoverTokenGenerated state,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Handover QR Code', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'Show this to your rider to confirm delivery.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing24),
                if (state.qrCode != null) ...[
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.spacing12),
                    child: Image.memory(
                      base64Decode(
                        state.qrCode!.replaceFirst(
                          RegExp(r'data:image/png;base64,'),
                          '',
                        ),
                      ),
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ] else ...[
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.spacing12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      state.token,
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacing20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppDimensions.spacing12),
                Text(
                  'Manual PIN',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacing12,
                    horizontal: AppDimensions.spacing16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.spacing12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    state.token,
                    style: AppTextStyles.heading3.copyWith(
                      letterSpacing: 6,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  'Share this PIN if the rider cannot scan.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textHint, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── PIN Entry Dialog (Rider fallback) ───────────────────────────────────

  void _showPINEntryDialog(BuildContext context, String parcelId) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          ),
          title: Text('Enter Handover PIN', style: AppTextStyles.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ask the receiver for their manual PIN code.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              TextField(
                controller: pinController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3.copyWith(letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: 'e.g. A1B2C3D4',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.spacing12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.spacing12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.spacing12),
                    borderSide:
                        const BorderSide(color: AppColors.cyan, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final token = pinController.text.trim();
                if (token.isEmpty) return;
                Navigator.of(dialogContext).pop();
                context.read<ParcelBloc>().add(VerifyHandover(
                      parcelId: parcelId,
                      token: token,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.delivered,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.buttonRadius),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // ── Data list ────────────────────────────────────────────────────────────

  Widget _buildParcelList(List<Parcel> parcels, bool isActionInProgress) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (isActionInProgress && index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.spacing8),
              child: LinearProgressIndicator(
                color: AppColors.cyan,
                backgroundColor: AppColors.background,
              ),
            );
          }

          final parcelIndex = isActionInProgress ? index - 1 : index;
          if (parcelIndex < 0) return const SizedBox.shrink();
          final parcel = parcels[parcelIndex];

          final authState = context.read<AuthBloc>().state;
          String? userRole;
          String? currentUserId;
          if (authState is Authenticated) {
            userRole = authState.mongoUser['role'] as String?;
            currentUserId = authState.mongoUser['_id'] as String?;
          }

          return ParcelCard(
            parcel: parcel,
            userRole: userRole,
            currentUserId: currentUserId,
            isLoading: isActionInProgress,
            onTap: () => debugPrint('Tapped parcel: ${parcel.trackingCode}'),
            onViewDetails: () =>
                debugPrint('View details for: ${parcel.trackingCode}'),
            onClaimDelivery: () =>
                context.read<ParcelBloc>().add(ClaimParcel(parcel.id)),
            onUpdateStatus: (status) => context.read<ParcelBloc>().add(
                  UpdateParcelStatus(
                    parcelId: parcel.id,
                    status: ParcelStatusParser.fromString(status),
                  ),
                ),
            onShowHandoverQR: () => context
                .read<ParcelBloc>()
                .add(GenerateHandoverToken(parcel.id)),
            onScanHandoverQR: () => Navigator.of(context).push(
                  MaterialPageRoute<String>(
                    builder: (_) => const QRScannerScreen(),
                  ),
                ),
            onEnterPINManually: () =>
                _showPINEntryDialog(context, parcel.id),
          );
        },
        childCount: parcels.length + (isActionInProgress ? 1 : 0),
      ),
    );
  }
}
