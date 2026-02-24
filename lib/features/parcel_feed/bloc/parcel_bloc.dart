import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/parcel_status.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../data/models/parcel_model.dart';
import '../../data/services/parcel_service.dart';
import 'parcel_event.dart';
import 'parcel_state.dart';

class ParcelBloc extends Bloc<ParcelEvent, ParcelState> {
  ParcelBloc({ParcelService? parcelService})
      : _parcelService = parcelService ?? ParcelService(),
        super(ParcelInitial()) {
    on<LoadParcels>(_onLoadParcels);
    on<CreateParcel>(_onCreateParcel);
    on<ClaimParcel>(_onClaimParcel);
    on<UpdateParcelStatus>(_onUpdateParcelStatus);
  }

  final ParcelService _parcelService;

  Future<void> _onLoadParcels(
    LoadParcels event,
    Emitter<ParcelState> emit,
  ) async {
    emit(ParcelLoading());
    try {
      final parcels = await _parcelService.fetchParcels();
      emit(ParcelLoaded(parcels));
    } on AppException catch (e) {
      emit(ParcelError(e.message));
    } catch (e) {
      emit(const ParcelError('Failed to load parcels.'));
    }
  }

  Future<void> _onCreateParcel(
    CreateParcel event,
    Emitter<ParcelState> emit,
  ) async {
    final current = _currentParcels;
    emit(ParcelActionInProgress(current));
    try {
      await _parcelService.createParcel(
        deliveryAddress: event.deliveryAddress,
        receiverId: event.receiverId,
        codAmount: event.codAmount,
      );
      final parcels = await _parcelService.fetchParcels();
      emit(ParcelLoaded(parcels));
    } on AppException catch (e) {
      emit(ParcelActionError(parcels: current, message: e.message));
    } catch (e) {
      emit(ParcelActionError(
          parcels: current, message: 'Failed to create parcel.'));
    }
  }

  Future<void> _onClaimParcel(
    ClaimParcel event,
    Emitter<ParcelState> emit,
  ) async {
    final current = _currentParcels;
    emit(ParcelActionInProgress(current));
    try {
      await _parcelService.assignRider(event.parcelId);
      final parcels = await _parcelService.fetchParcels();
      emit(ParcelLoaded(parcels));
    } on AppException catch (e) {
      emit(ParcelActionError(parcels: current, message: e.message));
    } catch (e) {
      emit(ParcelActionError(
          parcels: current, message: 'Failed to claim parcel.'));
    }
  }

  Future<void> _onUpdateParcelStatus(
    UpdateParcelStatus event,
    Emitter<ParcelState> emit,
  ) async {
    final current = _currentParcels;
    emit(ParcelActionInProgress(current));
    try {
      await _parcelService.updateParcelStatus(
        event.parcelId,
        event.status.toApiString(),
      );
      final parcels = await _parcelService.fetchParcels();
      emit(ParcelLoaded(parcels));
    } on AppException catch (e) {
      emit(ParcelActionError(parcels: current, message: e.message));
    } catch (e) {
      emit(ParcelActionError(
          parcels: current, message: 'Failed to update parcel status.'));
    }
  }

  List<ParcelModel> get _currentParcels {
    final s = state;
    if (s is ParcelLoaded) return s.parcels;
    if (s is ParcelActionInProgress) return s.parcels;
    if (s is ParcelActionError) return s.parcels;
    return const [];
  }
}
