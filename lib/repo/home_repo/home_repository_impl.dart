// ******************* FILE INFO *******************
// File Name: home_repository_impl.dart
// Description: Firebase implementation of HomeRepository.
//   • Firestore  → document: home_page (direct root-level document)
//   • Storage    → bucket path: home_cms/...
// Created by: Amr Mesbah
// UPDATED: All field names use Capital_Underscore naming convention ✅
// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
// UPDATED: EVERY single key goes through Versioned.append() ✅
//          Nav_Buttons_0_Status: [true]  — versioned array, not plain bool ✅

import 'dart:typed_data';

import 'package:beauty_admin/model/home/home_model.dart';
import 'package:beauty_admin/repo/home_repo/repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage?   storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage   = storage   ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage   _storage;

  static const String _collection = 'homePage';
  static const String _document   = 'home_page';

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(_collection).doc(_document);

  // ── Fetch (cache-first) ──────────────────────────────────────────────────

  @override
  Future<HomePageModel> fetchHomePage() async {
    print('🔵 [Repo] fetchHomePage() called (cache-first)');
    try {
      final snapshot = await _docRef.get();
      print('   snapshot.exists               = ${snapshot.exists}');
      print('   snapshot.metadata.isFromCache = ${snapshot.metadata.isFromCache}');
      if (!snapshot.exists || snapshot.data() == null) {
        print('⚠️  [Repo] fetchHomePage() → no document, returning defaultModel');
        return HomePageModel.defaultModel;
      }
      final data = _sanitize(snapshot.data()!);
      print('   sanitized keys = ${data.keys.toList()}');
      final model = HomePageModel.fromMap(data);
      print('🟢 [Repo] fetchHomePage() → parsed OK');
      print('   model.title.en = ${model.title.en}');
      return model;
    } catch (e, st) {
      print('🔴 [Repo] fetchHomePage() ERROR: $e');
      print('   StackTrace: $st');
      return HomePageModel.defaultModel;
    }
  }

  // ── Fetch FRESH (server only, bypasses cache) ────────────────────────────

  @override
  Future<HomePageModel> fetchHomePageFresh() async {
    print('🔵 [Repo] fetchHomePageFresh() called (Source.server)');
    try {
      final snapshot = await _docRef.get(
          const GetOptions(source: Source.server));
      print('   snapshot.exists               = ${snapshot.exists}');
      print('   snapshot.metadata.isFromCache = ${snapshot.metadata.isFromCache}');
      if (!snapshot.exists || snapshot.data() == null) {
        print('⚠️  [Repo] fetchHomePageFresh() → no document, returning defaultModel');
        return HomePageModel.defaultModel;
      }
      final data = _sanitize(snapshot.data()!);
      print('   sanitized keys = ${data.keys.toList()}');
      final model = HomePageModel.fromMap(data);
      print('🟢 [Repo] fetchHomePageFresh() → parsed OK');
      print('   model.title.en                         = ${model.title.en}');
      print('   model.sections length                  = ${model.sections.length}');
      print('   model.branding.logoUrl                 = ${model.branding.logoUrl}');
      print('   model.publishStatus                    = ${model.publishStatus}');
      print('   model.headerItems length               = ${model.headerItems.length}');
      print('   model.footerColumns length             = ${model.footerColumns.length}');
      print('   model.navButtons length                = ${model.navButtons.length}');
      print('   model.socialLinks length               = ${model.socialLinks.length}');
      print('   model.appDownloadLinks.iosUrl           = ${model.appDownloadLinks.iosUrl}');
      print('   model.appDownloadLinks.androidUrl       = ${model.appDownloadLinks.androidUrl}');
      print('   model.appDownloadLinks.labelEn          = ${model.appDownloadLinks.labelEn}');
      print('   model.appDownloadLinks.labelAr          = ${model.appDownloadLinks.labelAr}');
      print('   model.appDownloadLinks.iosIconUrl       = ${model.appDownloadLinks.iosIconUrl}');
      print('   model.appDownloadLinks.androidIconUrl   = ${model.appDownloadLinks.androidIconUrl}');
      print('   model.appDownloadLinks.visibility       = ${model.appDownloadLinks.visibility}');
      return model;
    } catch (e, st) {
      print('🔴 [Repo] fetchHomePageFresh() ERROR: $e');
      print('   StackTrace: $st');
      return HomePageModel.defaultModel;
    }
  }

  // ── Sanitize raw Firestore map ────────────────────────────────────────────

  Map<String, dynamic> _sanitize(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    copy.remove('Last_Updated_At');
    print('   [Repo] _sanitize() → removed Last_Updated_At, '
        'remaining keys = ${copy.keys.toList()}');
    return copy;
  }

  // ── Save (versioned) ─────────────────────────────────────────────────────
  //
  // EVERY single key in the Firestore document goes through
  // Versioned.append(). No exceptions — list fields, counts, scalars,
  // branding, app download links — ALL versioned arrays.
  //
  // Example Firestore result:
  //   Nav_Buttons_0_Status:   [true]
  //   Nav_Buttons_0_Name_En:  ['Home']
  //   Nav_Buttons_Count:      [6]
  //   Title_En:               ['Bayanatz']
  //   Header_Items_2_Title_Ar: ['عنوان 3']
  //   Footer_Columns_0_Labels_1_Label_En: ['Owner Services']
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveHomePage(HomePageModel model) async {
    print('🔵 [Repo] saveHomePage() called');
    print('   model.title.en          = ${model.title.en}');
    print('   model.sections length   = ${model.sections.length}');
    print('   model.branding.logoUrl  = ${model.branding.logoUrl}');
    print('   model.publishStatus     = ${model.publishStatus}');

    try {
      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🔵 [Repo] saveHomePage() → reading existing Firestore doc...');
      final existingSnap = await _docRef.get(
          const GetOptions(source: Source.server));
      final ex =
          (existingSnap.exists ? existingSnap.data() : null) ?? {};
      print('   existing keys = ${ex.keys.toList()}');

      // ── Step 2: plain map from model (flat primitives) ──────────────────
      final newMap = model.toMap();

      // ── Step 3: version EVERY key ───────────────────────────────────────
      final versionedMap = <String, dynamic>{};

      for (final key in newMap.keys) {
        // Skip Last_Updated_At — handled separately as server timestamp
        if (key == 'Last_Updated_At') continue;

        versionedMap[key] = Versioned.append(ex[key], newMap[key]);
      }

      // ── Clean stale indexed keys when lists shrink ──────────────────────
      // e.g. had 6 nav buttons, now 4 → delete Nav_Buttons_4_*, Nav_Buttons_5_*
      _cleanStaleKeys(ex, versionedMap, newMap);

      // ── server timestamp (never versioned) ──────────────────────────────
      versionedMap['Last_Updated_At'] = FieldValue.serverTimestamp();

      // ── Step 4: write to Firestore ──────────────────────────────────────
      await _docRef.set(versionedMap, SetOptions(merge: false));
      print('🟢 [Repo] saveHomePage() → ALL keys versioned, '
          'Firestore .set() completed ✅');

    } catch (e, st) {
      print('🔴 [Repo] saveHomePage() ERROR: $e');
      print('   StackTrace: $st');
      rethrow;
    }
  }

  // ── Stale Key Cleanup ────────────────────────────────────────────────────
  //
  // Since we use merge:false, old keys not in versionedMap are auto-removed.
  // This method explicitly handles any edge cases by marking stale indexed
  // keys with FieldValue.delete() — safe even with merge:false.
  // ─────────────────────────────────────────────────────────────────────────

  void _cleanStaleKeys(
      Map<String, dynamic> existing,
      Map<String, dynamic> target,
      Map<String, dynamic> newMap,
      ) {
    for (final key in existing.keys) {
      if (key == 'Last_Updated_At') continue;
      if (!newMap.containsKey(key)) {
        target[key] = FieldValue.delete();
      }
    }
  }

  // ── Upload ───────────────────────────────────────────────────────────────

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String    storagePath,
  }) async {
    print('🔵 [Repo] uploadImage() storagePath=$storagePath bytes=${bytes.length}');
    try {
      final ref  = _storage.ref().child(storagePath);
      final mime = _detectMime(bytes);
      print('   detected MIME = $mime');
      final task = await ref.putData(
          bytes, SettableMetadata(contentType: mime));
      final url  = await task.ref.getDownloadURL();
      print('🟢 [Repo] uploadImage() → url=$url');
      return url;
    } catch (e, st) {
      print('🔴 [Repo] uploadImage() ERROR: $e');
      print('   StackTrace: $st');
      rethrow;
    }
  }

  // ── Watch ────────────────────────────────────────────────────────────────

  @override
  Stream<HomePageModel> watchHomePage() {
    print('🔵 [Repo] watchHomePage() stream created');
    return _docRef.snapshots().map((snap) {
      print('📡 [Repo] watchHomePage() snapshot received');
      print('   snap.exists               = ${snap.exists}');
      print('   snap.metadata.isFromCache = ${snap.metadata.isFromCache}');
      if (!snap.exists || snap.data() == null) {
        return HomePageModel.defaultModel;
      }
      try {
        return HomePageModel.fromMap(snap.data()!);
      } catch (e) {
        print('🔴 [Repo] watchHomePage() parse ERROR: $e');
        return HomePageModel.defaultModel;
      }
    });
  }

  // ── MIME sniff ────────────────────────────────────────────────────────────

  String _detectMime(Uint8List b) {
    if (b.length < 4) return 'application/octet-stream';
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'image/png';
    if (b[0] == 0xFF && b[1] == 0xD8)                                   return 'image/jpeg';
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return 'image/gif';
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b.length >= 12 &&
        b[8]  == 0x57 && b[9]  == 0x45 &&
        b[10] == 0x42 && b[11] == 0x50)                                  return 'image/webp';
    if (b[0] == 0x3C)                                                    return 'image/svg+xml';
    return 'image/jpeg';
  }
}