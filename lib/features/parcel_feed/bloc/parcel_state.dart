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
