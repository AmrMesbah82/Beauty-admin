// ******************* FILE INFO *******************
// File Name: request_state.dart
// Description: Request Cubit states
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › presentation › controller

/// File Name: request_state.dart
import 'package:beauty_admin/features/request/data/models/request_model.dart';


abstract class RequestDemoCmsState {}
class RequestDemoCmsInitial extends RequestDemoCmsState {}
class RequestDemoCmsLoading extends RequestDemoCmsState {}
class RequestDemoCmsLoaded extends RequestDemoCmsState {
  final RequestDemoPageModel data;
  RequestDemoCmsLoaded(this.data);
}
class RequestDemoCmsSaved extends RequestDemoCmsState {
  final RequestDemoPageModel data;
  RequestDemoCmsSaved(this.data);
}
class RequestDemoCmsError extends RequestDemoCmsState {
  final String message;
  RequestDemoCmsError(this.message);
}