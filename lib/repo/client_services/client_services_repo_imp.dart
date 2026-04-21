/// ******************* FILE INFO *******************
/// File Name: client_services_repo_imp.dart
/// Description: Firebase implementation of ClientServicesRepo.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: EVERY single key goes through Versioned.append() ✅

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

  // ═════════════════════════════════════════════════════════════════════════
  //  GENERIC VERSIONED SAVE
  // ═════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> _buildVersionedMap(
      ClientServicesPageModel model,
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
      final versionedDefault = _buildVersionedMap(def, {});
      await _docRef(gender).set(versionedDefault);
      return def;
    } catch (e, st) {
      print('🔴 [ClientServicesRepoImp] fetchPage: ERROR $e\n$st');
      rethrow;
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  @override
  Future<void> savePage(ClientServicesPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [ClientServicesRepoImp] savePage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      print('🟡 [ClientServicesRepoImp] savePage → reading existing doc...');
      final existingSnap = await _docRef(docGender)
          .get(const GetOptions(source: Source.server));
      final ex =
          (existingSnap.exists ? existingSnap.data() : null)
          as Map<String, dynamic>? ??
              {};
      print('   existing keys = ${ex.keys.toList()}');

      final versionedMap = _buildVersionedMap(model, ex);

      await _docRef(docGender).set(versionedMap, SetOptions(merge: false));
      print('🟢 [ClientServicesRepoImp] savePage: ✅ ALL keys versioned DONE');
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