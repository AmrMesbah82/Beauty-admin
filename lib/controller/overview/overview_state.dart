/// ******************* FILE INFO *******************
/// File Name: overview_state.dart
/// Description: States for OverviewCmsCubit.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import '../../model/overview/overview_model.dart';

abstract class OverviewCmsState {}

class OverviewCmsInitial extends OverviewCmsState {}

class OverviewCmsLoading extends OverviewCmsState {}

class OverviewCmsLoaded extends OverviewCmsState {
  final OverviewPageModel data;
  OverviewCmsLoaded(this.data);
}

class OverviewCmsSaved extends OverviewCmsState {
  final OverviewPageModel data;
  OverviewCmsSaved(this.data);
}

class OverviewCmsError extends OverviewCmsState {
  final String message;
  OverviewCmsError(this.message);
}