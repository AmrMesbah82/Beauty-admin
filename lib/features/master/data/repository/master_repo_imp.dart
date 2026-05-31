/// ******************* FILE INFO *******************
/// File Name: master_repo_imp.dart
/// Description: Firebase implementation of MasterRepo.
///              Dual-document architecture:
///              - Published → `masterPages/{gender}`
///              - Draft     → `masterPages/{gender}_draft`
///
///              "Save For Later" writes to the _draft doc only.
///              "Publish" writes to the published doc and deletes the draft.
///              "Schedule" writes to the _draft doc with Status = 'scheduled'.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: Dual-document draft system ✅
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: Sections flattened into indexed root-level keys ✅
/// UPDATED: EVERY single key goes through Versioned.append() ✅

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../about_us/data/models/about_us_model.dart' hide Versioned;
import '../../domain/base_repository/master_repo.dart';
import '../models/master_model.dart';


class MasterRepoImp implements MasterRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage   _storage;

  MasterRepoImp({
    FirebaseFirestore? firestore,
    FirebaseStorage?   storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage   = storage   ?? FirebaseStorage.instance;

  // ── Collection / doc references ───────────────────────────────────────────
  static const String _collection = 'masterPages';

  DocumentReference _publishedRef(String gender) =>
      _firestore.collection(_collection).doc(gender);

  DocumentReference _draftRef(String gender) =>
      _firestore.collection(_collection).doc('${gender}_draft');

  // ═════════════════════════════════════════════════════════════════════════
  //  GENERIC VERSIONED SAVE
  // ═════════════════════════════════════════════════════════════════════════

  /// Builds a versioned map from [model] against [existing] Firestore data.
  /// EVERY key except Last_Updated goes through Versioned.append().
  /// Stale indexed keys (when lists shrink) are marked with FieldValue.delete().
  Map<String, dynamic> _buildVersionedMap(
      MasterPageModel model,
      Map<String, dynamic> existing,
      ) {
    final newMap       = model.copyWith(lastUpdated: DateTime.now()).toMap();
    final versionedMap = <String, dynamic>{};

    // ── Version every key ─────────────────────────────────────────────────
    for (final key in newMap.keys) {
      if (key == 'Last_Updated') continue;
      versionedMap[key] = Versioned.append(existing[key], newMap[key]);
    }

    // ── Clean stale indexed keys when lists shrink ────────────────────────
    for (final key in existing.keys) {
      if (key == 'Last_Updated') continue;
      if (!newMap.containsKey(key)) {
        versionedMap[key] = FieldValue.delete();
      }
    }

    // ── Server timestamp (never versioned) ────────────────────────────────
    versionedMap['Last_Updated'] = FieldValue.serverTimestamp();

    return versionedMap;
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PUBLISHED DOCUMENT
  // ═════════════════════════════════════════════════════════════════════════

  // ── Fetch published ────────────────────────────────────────────────────────
  @override
  Future<MasterPageModel> fetchMasterPage({required String gender}) async {
    try {
      final snap = await _publishedRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        final model = MasterPageModel.fromMap(data, docId: snap.id);
        return model;
      }

      // First time — create default doc
      final defaultModel = MasterPageModel(
        id:       gender,
        gender:   gender,
        sections: MasterPageModel.defaultSections(),
      );
      // Write default as versioned
      final versionedDefault = _buildVersionedMap(defaultModel, {});
      await _publishedRef(gender).set(versionedDefault);
      return defaultModel;
    } catch (e, st) {
      rethrow;
    }
  }

  // ── Save published (versioned) ─────────────────────────────────────────────
  @override
  Future<void> saveMasterPage(MasterPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;

    try {
      // ── Read existing ───────────────────────────────────────────────────
      final existingSnap = await _publishedRef(docGender)
          .get(const GetOptions(source: Source.server));
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};

      // ── Build & write versioned map ─────────────────────────────────────
      final versionedMap = _buildVersionedMap(model, ex);

      await _publishedRef(docGender).set(versionedMap, SetOptions(merge: false));

    } catch (e, st) {
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  DRAFT DOCUMENT
  // ═════════════════════════════════════════════════════════════════════════

  // ── Fetch draft ────────────────────────────────────────────────────────────
  @override
  Future<MasterPageModel?> fetchDraft({required String gender}) async {
    try {
      final snap = await _draftRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        return MasterPageModel.fromMap(data, docId: gender);
      }
      return null;
    } catch (e, st) {
      rethrow;
    }
  }

  // ── Save draft (versioned, same logic as published but to _draft doc) ──────
  @override
  Future<void> saveDraft(MasterPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;

    try {
      // ── Read existing draft data ────────────────────────────────────────
      final existingSnap = await _draftRef(docGender).get();
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};

      // ── Build & write versioned map ─────────────────────────────────────
      final versionedMap = _buildVersionedMap(model, ex);

      await _draftRef(docGender).set(versionedMap, SetOptions(merge: false));
    } catch (e, st) {
      rethrow;
    }
  }

  // ── Delete draft ───────────────────────────────────────────────────────────
  @override
  Future<void> deleteDraft({required String gender}) async {
    try {
      final ref = _draftRef(gender);
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
      } else {
      }
    } catch (e, st) {
      rethrow;
    }
  }

  // ── Promote draft → published ──────────────────────────────────────────────
  @override
  Future<void> promoteDraft({required String gender}) async {
    try {
      final draft = await fetchDraft(gender: gender);
      if (draft == null) {
        return;
      }

      // Save draft content as published
      final publishedModel = draft.copyWith(status: 'published');
      await saveMasterPage(publishedModel);

      // Delete the draft
      await deleteDraft(gender: gender);
    } catch (e, st) {
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ASSETS
  // ═════════════════════════════════════════════════════════════════════════

  // ── Upload image ───────────────────────────────────────────────────────────
  @override
  Future<String> uploadImage({
    required String    path,
    required Uint8List bytes,
    required String    fileName,
  }) async {
    try {
      final ref      = _storage.ref().child(path).child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/svg+xml',
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );
      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e, st) {
      rethrow;
    }
  }

  // ── Delete image ───────────────────────────────────────────────────────────
  @override
  Future<void> deleteImage(String url) async {
    if (url.isEmpty) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
    }
  }
}