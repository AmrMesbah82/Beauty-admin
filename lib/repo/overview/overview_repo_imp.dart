/// ******************* FILE INFO *******************
/// File Name: overview_repo_imp.dart
/// Description: Firebase implementation of OverviewRepo.
///              Dual-document architecture:
///              - Published → `overviewPages/{gender}`
///              - Draft     → `overviewPages/{gender}_draft`
///
///              "Save For Later" writes to the _draft doc only.
///              "Publish" writes to the published doc and deletes the draft.
///              "Schedule" writes to the _draft doc with Status = 'scheduled'.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: Dual-document draft system ✅
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: EVERY single key goes through Versioned.append() ✅

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/overview/overview_model.dart';
import 'overview_repo.dart';

class OverviewRepoImp implements OverviewRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  OverviewRepoImp({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  static const String _collection = 'overviewPages';

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
      OverviewPageModel model,
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

  @override
  Future<OverviewPageModel> fetchOverviewPage(
      {required String gender}) async {
    print('🟡 [OverviewRepoImp] fetchOverviewPage: gender=$gender');
    try {
      final snap = await _publishedRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [OverviewRepoImp] fetchOverviewPage: doc found');
        return OverviewPageModel.fromMap(data, docId: snap.id);
      }
      print('🟡 [OverviewRepoImp] fetchOverviewPage: no doc — creating default');
      final defaultModel = OverviewPageModel(id: gender, gender: gender);
      final versionedDefault = _buildVersionedMap(defaultModel, {});
      await _publishedRef(gender).set(versionedDefault);
      return defaultModel;
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] fetchOverviewPage: ERROR $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> saveOverviewPage(OverviewPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [OverviewRepoImp] saveOverviewPage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      print('🟡 [OverviewRepoImp] saveOverviewPage → reading existing doc...');
      final existingSnap = await _publishedRef(docGender)
          .get(const GetOptions(source: Source.server));
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};
      print('   existing keys = ${ex.keys.toList()}');

      final versionedMap = _buildVersionedMap(model, ex);

      await _publishedRef(docGender).set(versionedMap, SetOptions(merge: false));
      print('🟢 [OverviewRepoImp] saveOverviewPage: ✅ ALL keys versioned DONE');
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] saveOverviewPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  DRAFT DOCUMENT
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<OverviewPageModel?> fetchDraft({required String gender}) async {
    print('🟡 [OverviewRepoImp] fetchDraft: gender=$gender');
    try {
      final snap = await _draftRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [OverviewRepoImp] fetchDraft: draft found');
        return OverviewPageModel.fromMap(data, docId: gender);
      }
      print('🟡 [OverviewRepoImp] fetchDraft: no draft exists');
      return null;
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] fetchDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> saveDraft(OverviewPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [OverviewRepoImp] saveDraft: gender=$docGender '
        'status=${model.status}');

    try {
      final existingSnap = await _draftRef(docGender).get();
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};

      final versionedMap = _buildVersionedMap(model, ex);

      await _draftRef(docGender).set(versionedMap, SetOptions(merge: false));
      print('🟢 [OverviewRepoImp] saveDraft: ✅ ALL keys versioned DONE');
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] saveDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteDraft({required String gender}) async {
    print('🟡 [OverviewRepoImp] deleteDraft: gender=$gender');
    try {
      final ref = _draftRef(gender);
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
        print('🟢 [OverviewRepoImp] deleteDraft: ✅ deleted');
      } else {
        print('🟡 [OverviewRepoImp] deleteDraft: no draft to delete');
      }
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] deleteDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> promoteDraft({required String gender}) async {
    print('🟡 [OverviewRepoImp] promoteDraft: gender=$gender');
    try {
      final draft = await fetchDraft(gender: gender);
      if (draft == null) {
        print('🟡 [OverviewRepoImp] promoteDraft: no draft to promote');
        return;
      }
      final publishedModel = draft.copyWith(status: 'published');
      await saveOverviewPage(publishedModel);
      await deleteDraft(gender: gender);
      print('🟢 [OverviewRepoImp] promoteDraft: ✅ DONE');
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] promoteDraft: ERROR $e\n$st');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ASSETS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  }) async {
    print('🟡 [OverviewRepoImp] uploadImage: path=$path fileName=$fileName');
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final ext = fileName.toLowerCase();
      final contentType = ext.endsWith('.svg')
          ? 'image/svg+xml'
          : ext.endsWith('.png')
          ? 'image/png'
          : ext.endsWith('.jpg') || ext.endsWith('.jpeg')
          ? 'image/jpeg'
          : 'application/octet-stream';
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );
      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();
      print('🟢 [OverviewRepoImp] uploadImage: ✅ url=$url');
      return url;
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] uploadImage: ERROR $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String url) async {
    if (url.isEmpty) return;
    print('🟡 [OverviewRepoImp] deleteImage: $url');
    try {
      await _storage.refFromURL(url).delete();
      print('🟢 [OverviewRepoImp] deleteImage: ✅ DONE');
    } catch (e) {
      print('🔴 [OverviewRepoImp] deleteImage: $e (ignoring)');
    }
  }
}