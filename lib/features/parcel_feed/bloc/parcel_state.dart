import 'package:equatable/equatable.dart';
import '../../data/models/parcel_model.dart';

abstract class ParcelState extends Equatable {
  const ParcelState();

  @override
  List<Object?> get props => [];
}

class ParcelInitial extends ParcelState {}

class ParcelLoading extends ParcelState {}

class ParcelLoaded extends ParcelState {
  const ParcelLoaded(this.parcels);

  final List<ParcelModel> parcels;

  @override
  List<Object?> get props => [parcels];
}

class ParcelActionInProgress extends ParcelState {
  const ParcelActionInProgress(this.parcels);

  final List<ParcelModel> parcels;

  @override
  List<Object?> get props => [parcels];
}

class ParcelError extends ParcelState {
  const ParcelError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ParcelActionError extends ParcelState {
  const ParcelActionError({required this.parcels, required this.message});

  final List<ParcelModel> parcels;
  final String message;

  @override
  List<Object?> get props => [parcels, message];
}

class HandoverTokenGenerated extends ParcelState {
  const HandoverTokenGenerated({
    required this.parcels,
    required this.qrCode,
    required this.token,
  });

  final List<ParcelModel> parcels;
  final String? qrCode;
  final String token;

  @override
  List<Object?> get props => [parcels, qrCode, token];
}

class HandoverVerified extends ParcelState {
  const HandoverVerified(this.parcels);

  final List<ParcelModel> parcels;

  @override
  List<Object?> get props => [parcels];
}
