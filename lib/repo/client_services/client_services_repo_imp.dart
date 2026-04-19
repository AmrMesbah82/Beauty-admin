/// ******************* FILE INFO *******************
/// File Name: client_services_repo_imp.dart
/// Description: Firebase implementation of ClientServicesRepo.
/// Created by: Amr Mesbah
/// Last Update: 18/04/2026
/// UPDATED: savePage() now versions ALL fields using Versioned.append()
///          — full audit trail in Firestore ✅

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/client_services/client_services_model.dart';
import 'client_services_repo.dart';

class ClientServicesRepoImp implements ClientServicesRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ClientServicesRepoImp({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  static const String _collection = 'clientServicesPages';

  DocumentReference _docRef(String gender) =>
      _firestore.collection(_collection).doc(gender);

  // ── Fetch ──────────────────────────────────────────────────────────────────
  @override
  Future<ClientServicesPageModel> fetchPage({required String gender}) async {
    print('🟡 [ClientServicesRepoImp] fetchPage: gender=$gender');
    try {
      final snap = await _docRef(gender).get();
      if (snap.exists && snap.data() != null) {
        print('🟢 [ClientServicesRepoImp] fetchPage: doc found');
        return ClientServicesPageModel.fromMap(
            snap.data() as Map<String, dynamic>,
            docId: snap.id);
      }
      print('🟡 [ClientServicesRepoImp] fetchPage: no doc — creating default');
      final def = ClientServicesPageModel(id: gender, gender: gender);
      await _docRef(gender).set(def.toMap());
      return def;
    } catch (e, st) {
      print('🔴 [ClientServicesRepoImp] fetchPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save (ALL fields versioned) ────────────────────────────────────────────
  @override
  Future<void> savePage(ClientServicesPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [ClientServicesRepoImp] savePage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🟡 [ClientServicesRepoImp] savePage → reading existing doc...');
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
        'lastUpdated': Versioned.append(
          existingData['lastUpdated'],
          newMap['lastUpdated'],
        ),
      };

      // ── Step 4: write to Firestore ──────────────────────────────────────
      print('🟡 [ClientServicesRepoImp] savePage → writing versioned map...');
      print('   id history length          = ${(versionedMap['id'] as List).length}');
      print('   status history length      = ${(versionedMap['status'] as List).length}');
      print('   gender history length      = ${(versionedMap['gender'] as List).length}');
      print('   header history length      = ${(versionedMap['header'] as List).length}');
      print('   download history length    = ${(versionedMap['download'] as List).length}');
      print('   mockups history length     = ${(versionedMap['mockups'] as List).length}');
      print('   lastUpdated history length = ${(versionedMap['lastUpdated'] as List).length}');

      await _docRef(docGender).set(versionedMap, SetOptions(merge: true));
      print('🟢 [ClientServicesRepoImp] savePage: ✅ ALL fields versioned DONE');

    } catch (e, st) {
      print('🔴 [ClientServicesRepoImp] savePage: ERROR $e\n$st');
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
    print('🟡 [ClientServicesRepoImp] uploadImage: $path/$fileName');
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final ext = fileName.toLowerCase();
      final ct = ext.endsWith('.svg')
          ? 'image/svg+xml'
          : ext.endsWith('.png')
          ? 'image/png'
          : 'application/octet-stream';
      await ref.putData(bytes, SettableMetadata(contentType: ct));
      final url = await ref.getDownloadURL();
      print('🟢 [ClientServicesRepoImp] uploadImage: ✅ $url');
      return url;
    } catch (e, st) {
      print('🔴 [ClientServicesRepoImp] uploadImage: ERROR $e\n$st');
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
      print('🔴 [ClientServicesRepoImp] deleteImage: $e (ignoring)');
    }
  }
}