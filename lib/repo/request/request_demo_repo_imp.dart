/// ******************* FILE INFO *******************
/// File Name: request_demo_repo_imp.dart
/// Description: Repository implementation for Request Demo CMS module.
///              ALL fields flattened — NO nested maps in Firestore ✅
///              EVERY single field is versioned (array in Firestore,
///              .last = active value). Uses Versioned.append() on ALL. ✅
///              All Firestore keys follow Capital_Underscore naming convention.
/// Created by: Amr Mesbah
/// Last Update: 23/04/2026

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

  // ─────────────────────────────────────────────────────────────────────────
  // FETCH
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<RequestDemoPageModel> fetchPage({required String gender}) async {
    print('🟡 [RequestDemoRepoImp] fetchPage: $gender');
    final snap = await _doc(gender).get();
    if (snap.exists && snap.data() != null) {
      final raw = Map<String, dynamic>.from(snap.data()! as Map);
      return RequestDemoPageModel.fromMap(raw, docId: snap.id);
    }
    // No document yet → create a blank default and persist it
    final def = RequestDemoPageModel(id: gender, gender: gender);
    await savePage(def);
    return def;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<void> savePage(RequestDemoPageModel model) async {
    print('🟡 [RequestDemoRepoImp] savePage');
    final docRef = _doc(model.gender.isEmpty ? 'female' : model.gender);

    // 1. Read current Firestore state
    final snap = await docRef.get();
    final existing = snap.exists
        ? Map<String, dynamic>.from(snap.data()! as Map)
        : <String, dynamic>{};

    // 2. Get plain map from model
    final plain = model.copyWith(lastUpdated: DateTime.now()).toMap();

    // 3. Wrap EVERY key (except Last_Updated) in Versioned.append()
    final update = <String, dynamic>{};
    for (final entry in plain.entries) {
      if (entry.key == 'Last_Updated') {
        update[entry.key] = entry.value; // Timestamp — never versioned
      } else {
        update[entry.key] = Versioned.append(existing[entry.key], entry.value);
      }
    }

    // 4. Persist
    await docRef.set(update, SetOptions(merge: true));
    print('🟢 [RequestDemoRepoImp] savePage ✅');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STORAGE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ref = _st.ref().child(path).child(fileName);
    final ct = fileName.endsWith('.svg') ? 'image/svg+xml' : 'image/png';
    await ref.putData(bytes, SettableMetadata(contentType: ct));
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteImage(String url) async {
    if (url.isEmpty) return;
    try {
      await _st.refFromURL(url).delete();
    } catch (_) {}
  }
}