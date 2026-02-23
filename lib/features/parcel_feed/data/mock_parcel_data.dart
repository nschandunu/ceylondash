import '../../../core/enums/parcel_status.dart';
import '../../../features/domain/entities/parcel.dart';
import '../../../features/domain/entities/status_history.dart';

class MockParcelData {
  MockParcelData._();
  static List<Parcel> getMockParcels() {
    return [
      Parcel(
        id: '1',
        trackingCode: 'CLN-2026-001',
        senderId: 'sender_001',
        senderName: 'Colombo Electronics',
        receiverId: 'receiver_001',
        assignedRiderId: 'rider_001',
        status: ParcelStatus.inTransit,
        deliveryAddress: '45 Galle Road, Dehiwala',
        statusHistory: [
          StatusHistory(
            status: ParcelStatus.pending,
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          StatusHistory(
            status: ParcelStatus.inTransit,
            updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
        codAmount: 15000.00,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),

      Parcel(
        id: '2',
        trackingCode: 'CLN-2026-002',
        senderId: 'sender_002',
        senderName: 'Fashion Hub Kandy',
        receiverId: 'receiver_002',
        assignedRiderId: 'rider_002',
        status: ParcelStatus.outForDelivery,
        deliveryAddress: '78 Temple Street, Kandy',
        statusHistory: [
          StatusHistory(
            status: ParcelStatus.pending,
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          StatusHistory(
            status: ParcelStatus.inTransit,
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          StatusHistory(
            status: ParcelStatus.outForDelivery,
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        codAmount: 0.00,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),

      Parcel(
        id: '3',
        trackingCode: 'CLN-2026-003',
        senderId: 'sender_003',
        senderName: 'Tech World Negombo',
        receiverId: 'receiver_003',
        assignedRiderId: null,
        status: ParcelStatus.pending,
        deliveryAddress: '12 Beach Road, Negombo',
        statusHistory: [
          StatusHistory(
            status: ParcelStatus.pending,
            updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        ],
        codAmount: 8500.00,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),

      Parcel(
        id: '4',
        trackingCode: 'CLN-2026-004',
        senderId: 'sender_004',
        senderName: 'Book Emporium',
        receiverId: 'receiver_004',
        assignedRiderId: 'rider_003',
        status: ParcelStatus.delivered,
        deliveryAddress: '99 Main Street, Galle',
        statusHistory: [
          StatusHistory(
            status: ParcelStatus.pending,
            updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          StatusHistory(
            status: ParcelStatus.inTransit,
            updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          StatusHistory(
            status: ParcelStatus.outForDelivery,
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          StatusHistory(
            status: ParcelStatus.delivered,
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        codAmount: 2500.00,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      Parcel(
        id: '5',
        trackingCode: 'CLN-2026-005',
        senderId: 'sender_005',
        senderName: 'Spice Garden Matara',
        receiverId: 'receiver_005',
        assignedRiderId: 'rider_004',
        status: ParcelStatus.inTransit,
        deliveryAddress: '33 Hill Street, Matara',
        statusHistory: [
          StatusHistory(
            status: ParcelStatus.pending,
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          StatusHistory(
            status: ParcelStatus.inTransit,
            updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
        codAmount: 3200.00,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      
      Parcel(
        id: '6',
        trackingCode: 'CLN-2026-006',
        senderId: 'sender_006',
        senderName: 'Mobile Shop Jaffna',
        receiverId: 'receiver_006',
        assignedRiderId: 'rider_005',
        status: ParcelStatus.failed,
        deliveryAddress: '56 Hospital Road, Jaffna',
        statusHistory: [
          StatusHistory(
            status: ParcelStatus.pending,
            updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          StatusHistory(
            status: ParcelStatus.inTransit,
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          StatusHistory(
            status: ParcelStatus.outForDelivery,
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          StatusHistory(
            status: ParcelStatus.failed,
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        codAmount: 45000.00,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<Parcel> getActiveParcels() {
    return getMockParcels().where((p) => p.isInProgress).toList();
  }

  static int getActiveParcelCount() {
    return getMockParcels().where((p) => p.isInProgress).length;
  }

  static ParcelStats getParcelStats() {
    final parcels = getMockParcels();
    return ParcelStats(
      total: parcels.length,
      active: parcels.where((p) => p.isInProgress).length,
      pending: parcels.where((p) => p.status == ParcelStatus.pending).length,
      delivered: parcels
          .where((p) => p.status == ParcelStatus.delivered)
          .length,
    );
  }
}

class ParcelStats {
  final int total;
  final int active;
  final int pending;
  final int delivered;

  const ParcelStats({
    required this.total,
    required this.active,
    required this.pending,
    required this.delivered,
  });
}
