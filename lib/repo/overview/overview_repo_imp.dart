/// ******************* FILE INFO *******************
/// File Name: overview_repo_imp.dart
/// Description: Firebase implementation of OverviewRepo.
/// Created by: Amr Mesbah
/// Last Update: 18/04/2026
/// UPDATED: saveOverviewPage() now versions ALL fields using
///          Versioned.append() — full audit trail in Firestore ✅

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

  // ── Fetch ──────────────────────────────────────────────────────────────────
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

  // ── Save (ALL fields versioned) ────────────────────────────────────────────
  @override
  Future<void> saveOverviewPage(OverviewPageModel model) async {
    final docGender = model.gender.isEmpty ? 'female' : model.gender;
    print('🟡 [OverviewRepoImp] saveOverviewPage: id=${model.id} '
        'status=${model.status} gender=$docGender');

    try {
      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🟡 [OverviewRepoImp] saveOverviewPage → reading existing doc...');
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
        'headings': Versioned.append(
          existingData['headings'],
          newMap['headings'],
        ),
        'services': Versioned.append(
          existingData['services'],
          newMap['services'],
        ),
        'gallery': Versioned.append(
          existingData['gallery'],
          newMap['gallery'],
        ),
        'clientComments': Versioned.append(
          existingData['clientComments'],
          newMap['clientComments'],
        ),
        'download': Versioned.append(
          existingData['download'],
          newMap['download'],
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
      print('🟡 [OverviewRepoImp] saveOverviewPage → writing versioned map...');
      print('   id history length              = ${(versionedMap['id'] as List).length}');
      print('   status history length          = ${(versionedMap['status'] as List).length}');
      print('   gender history length          = ${(versionedMap['gender'] as List).length}');
      print('   headings history length        = ${(versionedMap['headings'] as List).length}');
      print('   services history length        = ${(versionedMap['services'] as List).length}');
      print('   gallery history length         = ${(versionedMap['gallery'] as List).length}');
      print('   clientComments history length  = ${(versionedMap['clientComments'] as List).length}');
      print('   download history length        = ${(versionedMap['download'] as List).length}');
      print('   publishSchedule history length = ${(versionedMap['publishSchedule'] as List).length}');
      print('   lastUpdated history length     = ${(versionedMap['lastUpdated'] as List).length}');

      await _docRef(docGender).set(versionedMap, SetOptions(merge: true));
      print('🟢 [OverviewRepoImp] saveOverviewPage: ✅ ALL fields versioned DONE');

    } catch (e, st) {
      print('🔴 [OverviewRepoImp] saveOverviewPage: ERROR $e\n$st');
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

  // ── Delete image ───────────────────────────────────────────────────────────
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