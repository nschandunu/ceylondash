import 'package:equatable/equatable.dart';
import '../../../core/enums/parcel_status.dart';

abstract class ParcelEvent extends Equatable {
  const ParcelEvent();

  @override
  List<Object?> get props => [];
}

class LoadParcels extends ParcelEvent {}

class CreateParcel extends ParcelEvent {
  const CreateParcel({
    required this.deliveryAddress,
    this.receiverId,
    this.codAmount = 0,
  });

  final String deliveryAddress;
  final String? receiverId;
  final double codAmount;

  @override
  List<Object?> get props => [deliveryAddress, receiverId, codAmount];
}

class ClaimParcel extends ParcelEvent {
  const ClaimParcel(this.parcelId);

  final String parcelId;

  @override
  List<Object?> get props => [parcelId];
}

class UpdateParcelStatus extends ParcelEvent {
  const UpdateParcelStatus({
    required this.parcelId,
    required this.status,
  });

  final String parcelId;
  final ParcelStatus status;

  @override
  List<Object?> get props => [parcelId, status];
}
