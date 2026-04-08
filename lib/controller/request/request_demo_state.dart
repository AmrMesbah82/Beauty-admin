/// File Name: request_demo_state.dart
import '../../model/request/request_demo_model.dart';

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