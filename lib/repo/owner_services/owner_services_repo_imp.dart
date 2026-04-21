/// ******************* FILE INFO *******************
/// File Name: owner_services_repo_imp.dart
/// Description: Firebase implementation of OwnerServicesRepo.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: EVERY single key goes through Versioned.append() ✅

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/owner_services/owner_services_model.dart';
import 'owner_services_repo.dart';

class OwnerServicesRepoImp implements OwnerServicesRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  OwnerServicesRepoImp({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  static const String _collection = 'ownerServicesPages';

  DocumentReference _docRef(String gender) =>
      _firestore.collection(_collection).doc(gender);

  // ═════════════════════════════════════════════════════════════════════════
  //  GENERIC VERSIONED SAVE
  // ═════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> _buildVersionedMap(
      OwnerServicesPageModel model,
      Map<String, dynamic> existing,
      ) {
    final newMap       = model.copyWith(lastUpdated: DateTime.now()).toMap();
    final versionedMap = <String, dynamic>{};

    for (final key in newMap.keys) {
      if (key == 'Last_Updated') continue;
      versionedMap[key] = Versioned.append(existing[key], newMap[key]);
    }

    for (final key in existing.keys) {
      if (key == 'Last_Updated') continue;
      if (!newMap.containsKey(key)) {
        versionedMap[key] = FieldValue.delete();
      }
    }

    versionedMap['Last_Updated'] = FieldValue.serverTimestamp();
    return versionedMap;
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────
  @override
  Future<OwnerServicesPageModel> fetchOwnerServicesPage(
      {required String gender}) async {
    print('🟡 [OwnerServicesRepoImp] fetchOwnerServicesPage: gender=$gender');
    try {
      final snap = await _docRef(gender).get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        print('🟢 [OwnerServicesRepoImp] fetchOwnerServicesPage: doc found');
        return OwnerServicesPageModel.fromMap(data, docId: snap.id);
      }
      print('🟡 [OwnerServicesRepoImp] fetchOwnerServicesPage: no doc — creating default');
      final defaultModel = OwnerServicesPageModel(id: gender, gender: gender);
      final versionedDefault = _buildVersionedMap(defaultModel, {});
      await _docRef(gender).set(versionedDefault);
      return defaultModel;
    } catch (e, st) {
      print('🔴 [OwnerServicesRepoImp] fetchOwnerServicesPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  @override
  Future<void> saveOwnerServicesPage(OwnerServicesPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [OwnerServicesRepoImp] saveOwnerServicesPage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      print('🟡 [OwnerServicesRepoImp] saveOwnerServicesPage → reading existing doc...');
      final existingSnap = await _docRef(docGender)
          .get(const GetOptions(source: Source.server));
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};
      print('   existing keys = ${ex.keys.toList()}');

      final versionedMap = _buildVersionedMap(model, ex);

      await _docRef(docGender).set(versionedMap, SetOptions(merge: false));
      print('🟢 [OwnerServicesRepoImp] saveOwnerServicesPage: ✅ ALL keys versioned DONE');
    } catch (e, st) {
      print('🔴 [OwnerServicesRepoImp] saveOwnerServicesPage: ERROR $e\n$st');
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
    print('🟡 [OwnerServicesRepoImp] uploadImage: path=$path fileName=$fileName');
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
      print('🟢 [OwnerServicesRepoImp] uploadImage: ✅ url=$url');
      return url;
    } catch (e, st) {
      print('🔴 [OwnerServicesRepoImp] uploadImage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Delete image ───────────────────────────────────────────────────────────
  @override
  Future<void> deleteImage(String url) async {
    if (url.isEmpty) return;
    print('🟡 [OwnerServicesRepoImp] deleteImage: $url');
    try {
      await _storage.refFromURL(url).delete();
      print('🟢 [OwnerServicesRepoImp] deleteImage: ✅ DONE');
    } catch (e) {
      print('🔴 [OwnerServicesRepoImp] deleteImage: $e (ignoring)');
    }
  }
}