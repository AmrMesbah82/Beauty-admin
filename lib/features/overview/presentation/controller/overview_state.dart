/// ******************* FILE INFO *******************
/// File Name: overview_state.dart
/// Description: States for OverviewCmsCubit.
///              Supports dual-document architecture (published + draft).
/// Created by: Amr Mesbah
/// Last Update: 19/04/2026
/// UPDATED: Added isFromDraft flag to OverviewCmsLoaded ✅
/// UPDATED: Added OverviewCmsDraftSaved state ✅
/// UPDATED: Added OverviewCmsDraftDeleted state ✅

import '../../data/models/overview_model.dart';

abstract class OverviewCmsState {}

class OverviewCmsInitial extends OverviewCmsState {}

class OverviewCmsLoading extends OverviewCmsState {}

/// Loaded state — carries the data being edited AND whether it came from a draft.
class OverviewCmsLoaded extends OverviewCmsState {
  final OverviewPageModel data;

  /// true  → the data was loaded from the `_draft` document
  /// false → the data was loaded from the published document
  final bool isFromDraft;

  OverviewCmsLoaded(this.data, {this.isFromDraft = false});
}

/// Published successfully — draft was saved to the published doc
/// and the draft doc was deleted.
class OverviewCmsSaved extends OverviewCmsState {
  final OverviewPageModel data;
  OverviewCmsSaved(this.data);
}

/// Draft saved successfully — published doc was NOT touched.
class OverviewCmsDraftSaved extends OverviewCmsState {
  final OverviewPageModel data;
  OverviewCmsDraftSaved(this.data);
}

/// Draft deleted (e.g. user chose Discard while editing a draft).
class OverviewCmsDraftDeleted extends OverviewCmsState {}

class OverviewCmsError extends OverviewCmsState {
  final String message;
  OverviewCmsError(this.message);
}