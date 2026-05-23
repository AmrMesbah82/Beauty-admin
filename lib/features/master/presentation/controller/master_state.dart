/// ******************* FILE INFO *******************
/// File Name: master_state.dart
/// Description: States for MasterCmsCubit.
///              Supports dual-document architecture (published + draft).
/// Created by: Amr Mesbah
/// Last Update: 19/04/2026
/// UPDATED: Added hasDraft flag to MasterCmsLoaded ✅
/// UPDATED: Added MasterCmsDraftSaved state ✅
/// UPDATED: Added MasterCmsDraftDeleted state ✅

import '../../data/models/master_model.dart';

abstract class MasterCmsState {}

class MasterCmsInitial extends MasterCmsState {}

class MasterCmsLoading extends MasterCmsState {}

/// Loaded state — carries the data being edited AND whether it came from a draft.
class MasterCmsLoaded extends MasterCmsState {
  final MasterPageModel data;

  /// true  → the data was loaded from the `_draft` document
  /// false → the data was loaded from the published document
  final bool isFromDraft;

  MasterCmsLoaded(this.data, {this.isFromDraft = false});
}

/// Published successfully — draft was saved to the published doc
/// and the draft doc was deleted.
class MasterCmsSaved extends MasterCmsState {
  final MasterPageModel data;
  MasterCmsSaved(this.data);
}

/// Draft saved successfully — published doc was NOT touched.
class MasterCmsDraftSaved extends MasterCmsState {
  final MasterPageModel data;
  MasterCmsDraftSaved(this.data);
}

/// Draft deleted (e.g. user chose Discard while editing a draft).
class MasterCmsDraftDeleted extends MasterCmsState {}

class MasterCmsError extends MasterCmsState {
  final String message;
  MasterCmsError(this.message);
}