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

import '../../model/master/master_model.dart';
import 'master_repo.dart';

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
    print('🟡 [MasterRepoImp] fetchMasterPage: gender=$gender');
    try {
      final snap = await _publishedRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [MasterRepoImp] fetchMasterPage: doc found');
        final model = MasterPageModel.fromMap(data, docId: snap.id);
        print('   title active value     = ${model.title.en}');
        print('   status active value    = ${model.status}');
        print('   imageUrl active value  = ${model.imageUrl}');
        print('   sections length        = ${model.sections.length}');
        return model;
      }

      // First time — create default doc
      print('🟡 [MasterRepoImp] fetchMasterPage: no doc — creating default');
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
      print('🔴 [MasterRepoImp] fetchMasterPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save published (versioned) ─────────────────────────────────────────────
  @override
  Future<void> saveMasterPage(MasterPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [MasterRepoImp] saveMasterPage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      // ── Read existing ───────────────────────────────────────────────────
      print('🟡 [MasterRepoImp] saveMasterPage → reading existing doc...');
      final existingSnap = await _publishedRef(docGender)
          .get(const GetOptions(source: Source.server));
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};
      print('   existing keys = ${ex.keys.toList()}');

      // ── Build & write versioned map ─────────────────────────────────────
      final versionedMap = _buildVersionedMap(model, ex);

      await _publishedRef(docGender).set(versionedMap, SetOptions(merge: false));
      print('🟢 [MasterRepoImp] saveMasterPage: ✅ ALL keys versioned DONE');

    } catch (e, st) {
      print('🔴 [MasterRepoImp] saveMasterPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  DRAFT DOCUMENT
  // ═════════════════════════════════════════════════════════════════════════

  // ── Fetch draft ────────────────────────────────────────────────────────────
  @override
  Future<MasterPageModel?> fetchDraft({required String gender}) async {
    print('🟡 [MasterRepoImp] fetchDraft: gender=$gender');
    try {
      final snap = await _draftRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [MasterRepoImp] fetchDraft: draft found');
        return MasterPageModel.fromMap(data, docId: gender);
      }
      print('🟡 [MasterRepoImp] fetchDraft: no draft exists');
      return null;
    } catch (e, st) {
      print('🔴 [MasterRepoImp] fetchDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save draft (versioned, same logic as published but to _draft doc) ──────
  @override
  Future<void> saveDraft(MasterPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [MasterRepoImp] saveDraft: gender=$docGender '
        'status=${model.status}');

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
      print('🟢 [MasterRepoImp] saveDraft: ✅ ALL keys versioned DONE');
    } catch (e, st) {
      print('🔴 [MasterRepoImp] saveDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Delete draft ───────────────────────────────────────────────────────────
  @override
  Future<void> deleteDraft({required String gender}) async {
    print('🟡 [MasterRepoImp] deleteDraft: gender=$gender');
    try {
      final ref = _draftRef(gender);
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
        print('🟢 [MasterRepoImp] deleteDraft: ✅ deleted');
      } else {
        print('🟡 [MasterRepoImp] deleteDraft: no draft to delete');
      }
    } catch (e, st) {
      print('🔴 [MasterRepoImp] deleteDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Promote draft → published ──────────────────────────────────────────────
  @override
  Future<void> promoteDraft({required String gender}) async {
    print('🟡 [MasterRepoImp] promoteDraft: gender=$gender');
    try {
      final draft = await fetchDraft(gender: gender);
      if (draft == null) {
        print('🟡 [MasterRepoImp] promoteDraft: no draft to promote');
        return;
      }

      // Save draft content as published
      final publishedModel = draft.copyWith(status: 'published');
      await saveMasterPage(publishedModel);

      // Delete the draft
      await deleteDraft(gender: gender);
      print('🟢 [MasterRepoImp] promoteDraft: ✅ DONE');
    } catch (e, st) {
      print('🔴 [MasterRepoImp] promoteDraft: ERROR $e\n$st');
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
    print('🟡 [MasterRepoImp] uploadImage: path=$path fileName=$fileName');
    try {
      final ref      = _storage.ref().child(path).child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/svg+xml',
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );
      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();
      print('🟢 [MasterRepoImp] uploadImage: ✅ url=$url');
      return url;
    } catch (e, st) {
      print('🔴 [MasterRepoImp] uploadImage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Delete image ───────────────────────────────────────────────────────────
  @override
  Future<void> deleteImage(String url) async {
    if (url.isEmpty) return;
    print('🟡 [MasterRepoImp] deleteImage: $url');
    try {
      await _storage.refFromURL(url).delete();
      print('🟢 [MasterRepoImp] deleteImage: ✅ DONE');
    } catch (e) {
      print('🔴 [MasterRepoImp] deleteImage: $e (ignoring)');
    }
  }
}