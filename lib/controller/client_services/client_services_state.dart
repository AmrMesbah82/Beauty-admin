/// ******************* FILE INFO *******************
/// File Name: client_services_state.dart
/// Description: States for ClientServicesCmsCubit.
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import '../../model/client_services/client_services_model.dart';

abstract class ClientServicesCmsState {}

class ClientServicesCmsInitial extends ClientServicesCmsState {}

class ClientServicesCmsLoading extends ClientServicesCmsState {}

class ClientServicesCmsLoaded extends ClientServicesCmsState {
  final ClientServicesPageModel data;
  ClientServicesCmsLoaded(this.data);
}

class ClientServicesCmsSaved extends ClientServicesCmsState {
  final ClientServicesPageModel data;
  ClientServicesCmsSaved(this.data);
}

class ClientServicesCmsError extends ClientServicesCmsState {
  final String message;
  ClientServicesCmsError(this.message);
}