/// File Name: demo_state.dart
import 'package:beauty_admin/features/request/data/model/request_model.dart';


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