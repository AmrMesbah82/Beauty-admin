/// ******************* FILE INFO *******************
/// File Name: client_services_repo_imp.dart
/// Description: Firebase implementation of ClientServicesRepo.
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

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

  @override
  Future<void> savePage(ClientServicesPageModel model) async {
    print('🟡 [ClientServicesRepoImp] savePage: id=${model.id}');
    try {
      final data = model.copyWith(lastUpdated: DateTime.now()).toMap();
      await _docRef(model.gender.isEmpty ? 'female' : model.gender)
          .set(data, SetOptions(merge: true));
      print('🟢 [ClientServicesRepoImp] savePage: ✅ DONE');
    } catch (e, st) {
      print('🔴 [ClientServicesRepoImp] savePage: ERROR $e\n$st');
      rethrow;
    }
  }

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