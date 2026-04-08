/// File Name: request_demo_repo_imp.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/request/request_demo_model.dart';
import 'request_demo_repo.dart';

class RequestDemoRepoImp implements RequestDemoRepo {
  final FirebaseFirestore _fs;
  final FirebaseStorage _st;
  RequestDemoRepoImp({FirebaseFirestore? fs, FirebaseStorage? st})
      : _fs = fs ?? FirebaseFirestore.instance,
        _st = st ?? FirebaseStorage.instance;

  static const _col = 'requestDemoPages';
  DocumentReference _doc(String g) => _fs.collection(_col).doc(g);

  @override
  Future<RequestDemoPageModel> fetchPage({required String gender}) async {
    print('🟡 [RequestDemoRepoImp] fetchPage: $gender');
    final snap = await _doc(gender).get();
    if (snap.exists && snap.data() != null) {
      return RequestDemoPageModel.fromMap(
          snap.data() as Map<String, dynamic>, docId: snap.id);
    }
    final def = RequestDemoPageModel(id: gender, gender: gender);
    await _doc(gender).set(def.toMap());
    return def;
  }

  @override
  Future<void> savePage(RequestDemoPageModel model) async {
    print('🟡 [RequestDemoRepoImp] savePage');
    await _doc(model.gender.isEmpty ? 'female' : model.gender)
        .set(model.copyWith(lastUpdated: DateTime.now()).toMap(),
        SetOptions(merge: true));
    print('🟢 [RequestDemoRepoImp] savePage ✅');
  }

  @override
  Future<String> uploadImage(
      {required String path,
        required Uint8List bytes,
        required String fileName}) async {
    final ref = _st.ref().child(path).child(fileName);
    final ct = fileName.endsWith('.svg') ? 'image/svg+xml' : 'image/png';
    await ref.putData(bytes, SettableMetadata(contentType: ct));
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteImage(String url) async {
    if (url.isEmpty) return;
    try { await _st.refFromURL(url).delete(); } catch (_) {}
  }
}