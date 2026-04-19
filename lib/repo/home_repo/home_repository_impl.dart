// ******************* FILE INFO *******************
// File Name: home_repository_impl.dart
// Description: Firebase implementation of HomeRepository.
//   • Firestore  → document: home_page (direct root-level document)
//   • Storage    → bucket path: home_cms/...
// Created by: Amr Mesbah
// UPDATED: Fixed document path issue - using collection().doc() pattern
// UPDATED: saveHomePage() now appends versioned history for scalar/object
//          fields using Versioned.append() — full audit trail in Firestore ✅

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
      print('   raw title = ${data['title']}');
      print('   raw sections length = ${(data['sections'] as List?)?.length ?? 0}');
      if ((data['sections'] as List?)?.isNotEmpty == true) {
        final s0 = (data['sections'] as List)[0] as Map<String, dynamic>;
        print('   raw sections[0].imageUrl = ${s0['imageUrl']}');
        print('   raw sections[0].iconUrl  = ${s0['iconUrl']}');
      }
      final model = HomePageModel.fromMap(data);
      print('🟢 [Repo] fetchHomePage() → parsed OK');
      print('   model.title.en             = ${model.title.en}');
      print('   model.sections[0].imageUrl = ${model.sections.isNotEmpty ? model.sections[0].imageUrl : "NO SECTIONS"}');
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
      print('   raw title = ${data['title']}');
      print('   raw sections length = ${(data['sections'] as List?)?.length ?? 0}');
      if ((data['sections'] as List?)?.isNotEmpty == true) {
        final s0 = (data['sections'] as List)[0] as Map<String, dynamic>;
        print('   raw sections[0].imageUrl = ${s0['imageUrl']}');
        print('   raw sections[0].iconUrl  = ${s0['iconUrl']}');
      }
      print('   raw branding = ${data['branding']}');
      final model = HomePageModel.fromMap(data);
      print('🟢 [Repo] fetchHomePageFresh() → parsed OK');
      print('   model.title.en               = ${model.title.en}');
      print('   model.sections length        = ${model.sections.length}');
      print('   model.sections[0].imageUrl   = ${model.sections.isNotEmpty ? model.sections[0].imageUrl : "NO SECTIONS"}');
      print('   model.sections[0].iconUrl    = ${model.sections.isNotEmpty ? model.sections[0].iconUrl  : "NO SECTIONS"}');
      print('   model.branding.logoUrl       = ${model.branding.logoUrl}');
      print('   model.publishStatus          = ${model.publishStatus}');
      print('   model.appDownloadLinks.iosUrl         = ${model.appDownloadLinks.iosUrl}');
      print('   model.appDownloadLinks.androidUrl     = ${model.appDownloadLinks.androidUrl}');
      print('   model.appDownloadLinks.labelEn        = ${model.appDownloadLinks.labelEn}');
      print('   model.appDownloadLinks.labelAr        = ${model.appDownloadLinks.labelAr}');
      print('   model.appDownloadLinks.iosIconUrl     = ${model.appDownloadLinks.iosIconUrl}');
      print('   model.appDownloadLinks.androidIconUrl = ${model.appDownloadLinks.androidIconUrl}');
      print('   model.appDownloadLinks.visibility     = ${model.appDownloadLinks.visibility}');
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
    copy.remove('lastUpdatedAt');
    print('   [Repo] _sanitize() → removed lastUpdatedAt, '
        'remaining keys = ${copy.keys.toList()}');
    return copy;
  }

  // ── Save (versioned) ─────────────────────────────────────────────────────
  //
  // Strategy:
  //   1. Read current raw Firestore data (server, bypassing cache).
  //   2. Build new plain map from model via toMap().
  //   3. For every versioned field, call Versioned.append(existing, new)
  //      so Firestore stores the full history list.
  //   4. Non-versioned list fields (navButtons, sections, etc.) are written
  //      as plain lists — they are already ordered collections.
  //
  // Fields versioned (stored as list of snapshots):
  //   title | shortDescription | branding | appDownloadLinks |
  //   publishStatus | gender | scheduledPublishDate
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveHomePage(HomePageModel model) async {
    print('🔵 [Repo] saveHomePage() called');
    print('   model.title.en               = ${model.title.en}');
    print('   model.sections length        = ${model.sections.length}');
    if (model.sections.isNotEmpty) {
      print('   model.sections[0].imageUrl = ${model.sections[0].imageUrl}');
      print('   model.sections[0].iconUrl  = ${model.sections[0].iconUrl}');
    }
    print('   model.branding.logoUrl       = ${model.branding.logoUrl}');
    print('   model.publishStatus          = ${model.publishStatus}');
    print('   model.appDownloadLinks.iosUrl         = ${model.appDownloadLinks.iosUrl}');
    print('   model.appDownloadLinks.androidUrl     = ${model.appDownloadLinks.androidUrl}');
    print('   model.appDownloadLinks.labelEn        = ${model.appDownloadLinks.labelEn}');
    print('   model.appDownloadLinks.labelAr        = ${model.appDownloadLinks.labelAr}');
    print('   model.appDownloadLinks.iosIconUrl     = ${model.appDownloadLinks.iosIconUrl}');
    print('   model.appDownloadLinks.androidIconUrl = ${model.appDownloadLinks.androidIconUrl}');
    print('   model.appDownloadLinks.visibility     = ${model.appDownloadLinks.visibility}');

    try {
      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🔵 [Repo] saveHomePage() → reading existing Firestore doc...');
      final existingSnap = await _docRef.get(
          const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null) ?? {};
      print('   existing keys = ${existingData.keys.toList()}');

      // ── Step 2: plain map from model ────────────────────────────────────
      final newMap = model.toMap();

      // ── Step 3: build versioned map ─────────────────────────────────────
      //   • Versioned fields → Versioned.append(existing, new)
      //   • Plain list fields → taken directly from newMap (no wrapping)
      //   • lastUpdatedAt → always server timestamp
      final versionedMap = <String, dynamic>{
        // ── plain list fields (already list-of-items) ──────────────────
        'navButtons':    newMap['navButtons'],
        'footerColumns': newMap['footerColumns'],
        'socialLinks':   newMap['socialLinks'],

        'branding': Versioned.append(
          existingData['branding'],
          newMap['branding'],
        ),
        'appDownloadLinks': Versioned.append(
          existingData['appDownloadLinks'],
          newMap['appDownloadLinks'],
        ),
        'publishStatus': Versioned.append(
          existingData['publishStatus'],
          newMap['publishStatus'],
        ),
        'gender': Versioned.append(
          existingData['gender'],
          newMap['gender'],
        ),
        'scheduledPublishDate': Versioned.append(
          existingData['scheduledPublishDate'],
          newMap['scheduledPublishDate'],
        ),

        // ── server timestamp (never versioned) ─────────────────────────
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };

      // ── Step 4: write to Firestore ──────────────────────────────────────
      print('   branding history length         = ${(versionedMap['branding'] as List?)?.length ?? 0}');
      print('   appDownloadLinks history length = ${(versionedMap['appDownloadLinks'] as List?)?.length ?? 0}');
      print('   publishStatus history length    = ${(versionedMap['publishStatus'] as List?)?.length ?? 0}');
      print('   gender history length           = ${(versionedMap['gender'] as List?)?.length ?? 0}');

      await _docRef.set(versionedMap, SetOptions(merge: true));
      print('🟢 [Repo] saveHomePage() → versioned Firestore .set() completed ✅');

    } catch (e, st) {
      print('🔴 [Repo] saveHomePage() ERROR: $e');
      print('   StackTrace: $st');
      rethrow;
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