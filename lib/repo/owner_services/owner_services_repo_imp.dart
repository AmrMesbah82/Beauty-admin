/// ******************* FILE INFO *******************
/// File Name: owner_services_repo_imp.dart
/// Description: Firebase implementation of OwnerServicesRepo.
/// Created by: Amr Mesbah
/// Last Update: 18/04/2026
/// UPDATED: saveOwnerServicesPage() now versions ALL fields using
///          Versioned.append() — full audit trail in Firestore ✅

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
      print(
          '🟡 [OwnerServicesRepoImp] fetchOwnerServicesPage: no doc — creating default');
      final defaultModel =
      OwnerServicesPageModel(id: gender, gender: gender);
      await _docRef(gender).set(defaultModel.toMap());
      return defaultModel;
    } catch (e, st) {
      print(
          '🔴 [OwnerServicesRepoImp] fetchOwnerServicesPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save (ALL fields versioned) ────────────────────────────────────────────
  @override
  Future<void> saveOwnerServicesPage(OwnerServicesPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [OwnerServicesRepoImp] saveOwnerServicesPage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🟡 [OwnerServicesRepoImp] saveOwnerServicesPage → reading existing doc...');
      final existingSnap = await _docRef(docGender)
          .get(const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};
      print('   existing keys = ${existingData.keys.toList()}');

      // ── Step 2: plain map from model ────────────────────────────────────
      final updatedModel = model.copyWith(lastUpdated: DateTime.now());
      final newMap = updatedModel.toMap();

      // ── Step 3: build versioned map — ALL fields ────────────────────────
      final versionedMap = <String, dynamic>{
        'id': Versioned.append(
          existingData['id'],
          newMap['id'],
        ),
        'status': Versioned.append(
          existingData['status'],
          newMap['status'],
        ),
        'gender': Versioned.append(
          existingData['gender'],
          newMap['gender'],
        ),
        'header': Versioned.append(
          existingData['header'],
          newMap['header'],
        ),
        'download': Versioned.append(
          existingData['download'],
          newMap['download'],
        ),
        'mockups': Versioned.append(
          existingData['mockups'],
          newMap['mockups'],
        ),
        'publishSchedule': Versioned.append(
          existingData['publishSchedule'],
          newMap['publishSchedule'],
        ),
        'lastUpdated': Versioned.append(
          existingData['lastUpdated'],
          newMap['lastUpdated'],
        ),
      };

      // ── Step 4: write to Firestore ──────────────────────────────────────
      print('🟡 [OwnerServicesRepoImp] saveOwnerServicesPage → writing versioned map...');
      print('   id history length              = ${(versionedMap['id'] as List).length}');
      print('   status history length          = ${(versionedMap['status'] as List).length}');
      print('   gender history length          = ${(versionedMap['gender'] as List).length}');
      print('   header history length          = ${(versionedMap['header'] as List).length}');
      print('   download history length        = ${(versionedMap['download'] as List).length}');
      print('   mockups history length         = ${(versionedMap['mockups'] as List).length}');
      print('   publishSchedule history length = ${(versionedMap['publishSchedule'] as List).length}');
      print('   lastUpdated history length     = ${(versionedMap['lastUpdated'] as List).length}');

      await _docRef(docGender).set(versionedMap, SetOptions(merge: true));
      print('🟢 [OwnerServicesRepoImp] saveOwnerServicesPage: ✅ ALL fields versioned DONE');

    } catch (e, st) {
      print(
          '🔴 [OwnerServicesRepoImp] saveOwnerServicesPage: ERROR $e\n$st');
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
    print(
        '🟡 [OwnerServicesRepoImp] uploadImage: path=$path fileName=$fileName');
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