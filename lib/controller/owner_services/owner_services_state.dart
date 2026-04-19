/// ******************* FILE INFO *******************
/// File Name: owner_services_state.dart
/// Description: States for OwnerServicesCmsCubit.
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

import '../../model/owner_services/owner_services_model.dart';

abstract class OwnerServicesCmsState {}

class OwnerServicesCmsInitial extends OwnerServicesCmsState {}

class OwnerServicesCmsLoading extends OwnerServicesCmsState {}

class OwnerServicesCmsLoaded extends OwnerServicesCmsState {
  final OwnerServicesPageModel data;
  OwnerServicesCmsLoaded(this.data);
}

class OwnerServicesCmsSaved extends OwnerServicesCmsState {
  final OwnerServicesPageModel data;
  OwnerServicesCmsSaved(this.data);
}

class OwnerServicesCmsError extends OwnerServicesCmsState {
  final String message;
  OwnerServicesCmsError(this.message);
}