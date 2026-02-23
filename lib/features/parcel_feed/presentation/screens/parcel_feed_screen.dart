import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/enums/parcel_status.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/data/models/parcel_model.dart';
import '../../../../features/data/services/parcel_service.dart';
import '../../../../features/domain/entities/parcel.dart';
import '../../data/mock_parcel_data.dart'; // ParcelStats
import '../widgets/parcel_card.dart';
import 'feed_header_delegate.dart';

class ParcelFeedScreen extends StatefulWidget {
  const ParcelFeedScreen({super.key});

  @override
  State<ParcelFeedScreen> createState() => _ParcelFeedScreenState();
}

class _ParcelFeedScreenState extends State<ParcelFeedScreen> {
  final _service = ParcelService();
  late Future<List<ParcelModel>> _parcelFuture;

  @override
  void initState() {
    super.initState();
    _parcelFuture = _service.fetchParcels();
  }

  void _retry() {
    setState(() {
      _parcelFuture = _service.fetchParcels();
    });
  }

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<ParcelModel>>(
        future: _parcelFuture,
        builder: (context, snapshot) {
          final parcels = snapshot.data ?? const [];
          final stats = _computeStats(parcels);

          return CustomScrollView(
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

              if (snapshot.connectionState == ConnectionState.waiting)
                _buildLoadingSliver()
              else if (snapshot.hasError)
                _buildErrorSliver(snapshot.error!)
              else if (parcels.isEmpty)
                _buildEmptySliver()
              else
                _buildParcelList(parcels),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.spacing32),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

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

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildErrorSliver(Object error) {
    final isUnauthorized = error is UnauthorizedException;
    final message = error is AppException
        ? error.message
        : 'An unexpected error occurred.';

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
              Icon(
                isUnauthorized
                    ? Icons.lock_outline_rounded
                    : Icons.error_outline_rounded,
                size: AppDimensions.iconXLarge,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                isUnauthorized ? 'Session Expired' : 'Something Went Wrong',
                style: AppTextStyles.heading3,
              ),
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
                  onPressed: _retry,
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

  // ── Empty ──────────────────────────────────────────────────────────────────

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

  // ── Data list ──────────────────────────────────────────────────────────────

  SliverList _buildParcelList(List<Parcel> parcels) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final parcel = parcels[index];
          return ParcelCard(
            parcel: parcel,
            onTap: () => _onParcelTap(parcel),
            onViewDetails: () => _onViewDetails(parcel),
          );
        },
        childCount: parcels.length,
      ),
    );
  }

  void _onParcelTap(Parcel parcel) {
    debugPrint('Tapped parcel: ${parcel.trackingCode}');
  }

  void _onViewDetails(Parcel parcel) {
    debugPrint('View details for: ${parcel.trackingCode}');
  }
}
