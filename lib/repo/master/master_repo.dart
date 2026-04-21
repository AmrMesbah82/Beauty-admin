/// ******************* FILE INFO *******************
/// File Name: master_repo.dart
/// Description: Abstract repository for the Master CMS module.
///              Supports dual-document architecture:
///              - Published doc  → `female` / `male`
///              - Draft doc      → `female_draft` / `male_draft`
/// Created by: Amr Mesbah
/// Last Update: 19/04/2026
/// UPDATED: Added draft lifecycle methods (fetch, save, delete, promote) ✅

import 'dart:typed_data';
import '../../model/master/master_model.dart';

abstract class MasterRepo {
  // ── Published document ───────────────────────────────────────────────────
  Future<MasterPageModel> fetchMasterPage({required String gender});
  Future<void> saveMasterPage(MasterPageModel model);

  // ── Draft document ───────────────────────────────────────────────────────
  /// Fetch the draft version. Returns null if no draft exists.
  Future<MasterPageModel?> fetchDraft({required String gender});

  /// Save form edits as a draft (does NOT touch the published doc).
  Future<void> saveDraft(MasterPageModel model);

  /// Delete the draft document (e.g. after publish or discard).
  Future<void> deleteDraft({required String gender});

  /// Promote draft → published: copies draft into the published doc,
  /// then deletes the draft.
  Future<void> promoteDraft({required String gender});

  // ── Assets ───────────────────────────────────────────────────────────────
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  });

  Future<void> deleteImage(String url);
}