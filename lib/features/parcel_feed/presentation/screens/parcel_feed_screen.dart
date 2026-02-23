import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/domain/entities/parcel.dart';
import '../../data/mock_parcel_data.dart';
import '../widgets/parcel_card.dart';
import 'feed_header_delegate.dart';

class ParcelFeedScreen extends StatefulWidget {
  const ParcelFeedScreen({super.key});

  @override
  State<ParcelFeedScreen> createState() => _ParcelFeedScreenState();
}

class _ParcelFeedScreenState extends State<ParcelFeedScreen> {
  late List<Parcel> _parcels;
  late ParcelStats _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _parcels = MockParcelData.getMockParcels();
    _stats = MockParcelData.getParcelStats();
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: FeedHeaderDelegate(
              stats: _stats,
              expandedHeight: AppDimensions.headerExpandedHeight,
              collapsedHeight: AppDimensions.headerCollapsedHeight,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacing16),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final parcel = _parcels[index];
              return ParcelCard(
                parcel: parcel,
                onTap: () => _onParcelTap(parcel),
                onViewDetails: () => _onViewDetails(parcel),
              );
            }, childCount: _parcels.length),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacing32),
          ),
        ],
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
