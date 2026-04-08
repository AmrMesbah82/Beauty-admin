/// ******************* FILE INFO *******************
/// File Name: master_repo_imp.dart
/// Description: Firebase implementation of MasterRepo.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/master/master_model.dart';
import 'master_repo.dart';

class MasterRepoImp implements MasterRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MasterRepoImp({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ── Collection / doc references ────────────────────────────────────────────
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
        return MasterPageModel.fromMap(data, docId: snap.id);
      }

      // First time — create default doc
      print('🟡 [MasterRepoImp] fetchMasterPage: no doc — creating default');
      final defaultModel = MasterPageModel(
        id: gender,
        gender: gender,
        sections: MasterPageModel.defaultSections(),
      );
      await _docRef(gender).set(defaultModel.toMap());
      return defaultModel;
    } catch (e, st) {
      print('🔴 [MasterRepoImp] fetchMasterPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  @override
  Future<void> saveMasterPage(MasterPageModel model) async {
    print('🟡 [MasterRepoImp] saveMasterPage: id=${model.id} '
        'status=${model.status}');
    try {
      final data = model
          .copyWith(lastUpdated: DateTime.now())
          .toMap();
      await _docRef(model.gender.isEmpty ? 'female' : model.gender)
          .set(data, SetOptions(merge: true));
      print('🟢 [MasterRepoImp] saveMasterPage: ✅ DONE');
    } catch (e, st) {
      print('🔴 [MasterRepoImp] saveMasterPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Upload image ───────────────────────────────────────────────────────────
  @override
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  }) async {
    print('🟡 [MasterRepoImp] uploadImage: path=$path fileName=$fileName');
    try {
      final ref = _storage.ref().child(path).child(fileName);
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