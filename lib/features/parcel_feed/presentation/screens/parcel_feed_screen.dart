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

class ParcelFeedScreen extends StatelessWidget {
  const ParcelFeedScreen({super.key});

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
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ParcelBloc, ParcelState>(
        builder: (context, state) {
          final parcels = _parcelsFromState(state);
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
                'Your active and recent parcels will appear here.',
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
          );
        },
        childCount: parcels.length + (isActionInProgress ? 1 : 0),
      ),
    );
  }
}
