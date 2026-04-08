/// ******************* FILE INFO *******************
/// File Name: overview_repo_imp.dart
/// Description: Firebase implementation of OverviewRepo.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

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

  DocumentReference _docRef(String gender) =>
      _firestore.collection(_collection).doc(gender);

  @override
  Future<OverviewPageModel> fetchOverviewPage(
      {required String gender}) async {
    print('🟡 [OverviewRepoImp] fetchOverviewPage: gender=$gender');
    try {
      final snap = await _docRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [OverviewRepoImp] fetchOverviewPage: doc found');
        return OverviewPageModel.fromMap(data, docId: snap.id);
      }
      print('🟡 [OverviewRepoImp] fetchOverviewPage: no doc — creating default');
      final defaultModel = OverviewPageModel(id: gender, gender: gender);
      await _docRef(gender).set(defaultModel.toMap());
      return defaultModel;
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] fetchOverviewPage: ERROR $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> saveOverviewPage(OverviewPageModel model) async {
    print('🟡 [OverviewRepoImp] saveOverviewPage: id=${model.id} status=${model.status}');
    try {
      final data = model.copyWith(lastUpdated: DateTime.now()).toMap();
      await _docRef(model.gender.isEmpty ? 'female' : model.gender)
          .set(data, SetOptions(merge: true));
      print('🟢 [OverviewRepoImp] saveOverviewPage: ✅ DONE');
    } catch (e, st) {
      print('🔴 [OverviewRepoImp] saveOverviewPage: ERROR $e\n$st');
      rethrow;
    }
  }

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