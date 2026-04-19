/// ******************* FILE INFO *******************
/// File Name: master_repo_imp.dart
/// Description: Firebase implementation of MasterRepo.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026
/// UPDATED: saveMasterPage() now appends versioned history for scalar/object
///          fields using Versioned.append() — full audit trail in Firestore ✅

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

  DocumentReference _docRef(String gender) =>
      _firestore.collection(_collection).doc(gender);

  // ── Fetch ──────────────────────────────────────────────────────────────────
  @override
  Future<MasterPageModel> fetchMasterPage({required String gender}) async {
    print('🟡 [MasterRepoImp] fetchMasterPage: gender=$gender');
    try {
      final snap = await _docRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [MasterRepoImp] fetchMasterPage: doc found');
        print('   title active value     = ${MasterPageModel.fromMap(data, docId: snap.id).title.en}');
        print('   status active value    = ${MasterPageModel.fromMap(data, docId: snap.id).status}');
        print('   imageUrl active value  = ${MasterPageModel.fromMap(data, docId: snap.id).imageUrl}');
        return MasterPageModel.fromMap(data, docId: snap.id);
      }

      // First time — create default doc
      print('🟡 [MasterRepoImp] fetchMasterPage: no doc — creating default');
      final defaultModel = MasterPageModel(
        id:       gender,
        gender:   gender,
        sections: MasterPageModel.defaultSections(),
      );
      await _docRef(gender).set(defaultModel.toMap());
      return defaultModel;
    } catch (e, st) {
      print('🔴 [MasterRepoImp] fetchMasterPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save (versioned) ───────────────────────────────────────────────────────
  //
  // Strategy:
  //   1. Read current raw Firestore data (server, bypassing cache).
  //   2. Build new plain map from model via toMap().
  //   3. For every versioned field, call Versioned.append(existing, new)
  //      so Firestore stores the full history list.
  //   4. Non-versioned list fields (sections) are written as plain lists.
  //
  // Fields versioned (stored as list of snapshots):
  //   title | shortDescription | status | gender | appLinks |
  //   publishSchedule | imageUrl
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<void> saveMasterPage(MasterPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [MasterRepoImp] saveMasterPage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🟡 [MasterRepoImp] saveMasterPage → reading existing doc...');
      final existingSnap = await _docRef(docGender)
          .get(const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};
      print('   existing keys = ${existingData.keys.toList()}');

      // ── Step 2: plain map from model ────────────────────────────────────
      final updatedModel = model.copyWith(lastUpdated: DateTime.now());
      final newMap       = updatedModel.toMap();

      // ── Step 3: build versioned map ─────────────────────────────────────
      //   • Versioned fields  → Versioned.append(existing, new)
      //   • sections          → plain list (not versioned at root)
      //   • lastUpdated       → always latest DateTime (not versioned)
      final versionedMap = <String, dynamic>{
        // ── plain fields ───────────────────────────────────────────────
        'id':          newMap['id'],
        'sections':    newMap['sections'],
        'lastUpdated': newMap['lastUpdated'],

        // ── versioned scalar / object fields ───────────────────────────
        // 'title': Versioned.append(
        //   existingData['title'],
        //   newMap['title'],
        // ),
        // 'shortDescription': Versioned.append(
        //   existingData['shortDescription'],
        //   newMap['shortDescription'],
        // ),
        'status': Versioned.append(
          existingData['status'],
          newMap['status'],
        ),
        'gender': Versioned.append(
          existingData['gender'],
          newMap['gender'],
        ),
        'appLinks': Versioned.append(
          existingData['appLinks'],
          newMap['appLinks'],
        ),
        'publishSchedule': Versioned.append(
          existingData['publishSchedule'],
          newMap['publishSchedule'],
        ),
        'imageUrl': Versioned.append(
          existingData['imageUrl'],
          newMap['imageUrl'],
        ),
      };

      // ── Step 4: write to Firestore ──────────────────────────────────────
      print('🟡 [MasterRepoImp] saveMasterPage → writing versioned map...');
      // print('   title history length           = ${(versionedMap['title'] as List).length}');
      // print('   shortDescription history length= ${(versionedMap['shortDescription'] as List).length}');
      print('   status history length          = ${(versionedMap['status'] as List).length}');
      print('   gender history length          = ${(versionedMap['gender'] as List).length}');
      print('   appLinks history length        = ${(versionedMap['appLinks'] as List).length}');
      print('   publishSchedule history length = ${(versionedMap['publishSchedule'] as List).length}');
      print('   imageUrl history length        = ${(versionedMap['imageUrl'] as List).length}');

      await _docRef(docGender).set(versionedMap, SetOptions(merge: true));
      print('🟢 [MasterRepoImp] saveMasterPage: ✅ versioned DONE');

    } catch (e, st) {
      print('🔴 [MasterRepoImp] saveMasterPage: ERROR $e\n$st');
      rethrow;
    }
  }

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