// ******************* FILE INFO *******************
// File Name: about_repo_impl.dart
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: All save methods now version ALL fields using Versioned.append()
//          — full audit trail in Firestore for AboutPage, OurStrategy, Terms ✅

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/about_us/about_us.dart';
import 'about_repo.dart';

class AboutRepoImpl implements AboutRepo {
  static const String _aboutDoc    = 'about_page';
  static const String _strategyDoc = 'our_strategy';
  static const String _termsDoc    = 'terms_of_service';

  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _docRef(String docId) =>
      _db.collection(docId).doc('data');

  // ── Fetch About Page ───────────────────────────────────────────────────────
  @override
  Future<AboutPageModel> fetchAboutPage() async {
    try {
      final snap = await _docRef(_aboutDoc)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists || snap.data() == null) {
        return AboutPageModel.empty();
      }
      final raw = snap.data()!;
      final model = AboutPageModel.fromMap(raw);
      return model;
    } catch (e) {
      _log('🔴 [AboutRepo] fetchAboutPage ERROR: $e');
      rethrow;
    }
  }

  // ── Save About Page (ALL fields versioned) ─────────────────────────────────
  @override
  Future<void> saveAboutPage(AboutPageModel model) async {
    try {
      print('🟡 [AboutRepo] saveAboutPage → reading existing doc...');
      final existingSnap = await _docRef(_aboutDoc)
          .get(const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null) ?? {};
      print('   existing keys = ${existingData.keys.toList()}');

      final newMap = model.toMap();

      final versionedMap = <String, dynamic>{
        'publishStatus': Versioned.append(
          existingData['publishStatus'],
          newMap['publishStatus'],
        ),
        'title': Versioned.append(
          existingData['title'],
          newMap['title'],
        ),
        'svgUrl': Versioned.append(
          existingData['svgUrl'],
          newMap['svgUrl'],
        ),
        'navigationLabel': Versioned.append(
          existingData['navigationLabel'],
          newMap['navigationLabel'],
        ),
        'vision': Versioned.append(
          existingData['vision'],
          newMap['vision'],
        ),
        'mission': Versioned.append(
          existingData['mission'],
          newMap['mission'],
        ),
        'values': Versioned.append(
          existingData['values'],
          newMap['values'],
        ),
        'lastUpdatedAt': Versioned.append(
          existingData['lastUpdatedAt'],
          newMap['lastUpdatedAt'],
        ),
      };

      print('🟡 [AboutRepo] saveAboutPage → writing versioned map...');
      print('   publishStatus history length = ${(versionedMap['publishStatus'] as List).length}');
      print('   title history length         = ${(versionedMap['title'] as List).length}');
      print('   svgUrl history length        = ${(versionedMap['svgUrl'] as List).length}');
      print('   navigationLabel history len  = ${(versionedMap['navigationLabel'] as List).length}');
      print('   vision history length        = ${(versionedMap['vision'] as List).length}');
      print('   mission history length       = ${(versionedMap['mission'] as List).length}');
      print('   values history length        = ${(versionedMap['values'] as List).length}');
      print('   lastUpdatedAt history length = ${(versionedMap['lastUpdatedAt'] as List).length}');

      await _docRef(_aboutDoc).set(versionedMap, SetOptions(merge: true));
      _log('🟢 [AboutRepo] saveAboutPage: ✅ ALL fields versioned DONE');
    } catch (e) {
      _log('🔴 [AboutRepo] saveAboutPage ERROR: $e');
      rethrow;
    }
  }

  // ── Fetch Strategy ─────────────────────────────────────────────────────────
  @override
  Future<OurStrategyModel> fetchStrategy() async {
    try {
      final snap = await _docRef(_strategyDoc)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists || snap.data() == null) {
        return OurStrategyModel.empty();
      }
      final raw = snap.data()!;
      final model = OurStrategyModel.fromMap(raw);
      return model;
    } catch (e) {
      _log('🔴 [AboutRepo] fetchStrategy ERROR: $e');
      rethrow;
    }
  }

  // ── Save Strategy (ALL fields versioned) ───────────────────────────────────
  @override
  Future<void> saveStrategy(OurStrategyModel model) async {
    try {
      print('🟡 [AboutRepo] saveStrategy → reading existing doc...');
      final existingSnap = await _docRef(_strategyDoc)
          .get(const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null) ?? {};
      print('   existing keys = ${existingData.keys.toList()}');

      final newMap = model.toMap();

      final versionedMap = <String, dynamic>{
        'publishStatus': Versioned.append(
          existingData['publishStatus'],
          newMap['publishStatus'],
        ),
        'navigationLabel': Versioned.append(
          existingData['navigationLabel'],
          newMap['navigationLabel'],
        ),
        'vision': Versioned.append(
          existingData['vision'],
          newMap['vision'],
        ),
        'strategicHouseEnUrl': Versioned.append(
          existingData['strategicHouseEnUrl'],
          newMap['strategicHouseEnUrl'],
        ),
        'strategicHouseArUrl': Versioned.append(
          existingData['strategicHouseArUrl'],
          newMap['strategicHouseArUrl'],
        ),
        'lastUpdatedAt': Versioned.append(
          existingData['lastUpdatedAt'],
          FieldValue.serverTimestamp(),
        ),
      };

      print('🟡 [AboutRepo] saveStrategy → writing versioned map...');
      print('   publishStatus history length     = ${(versionedMap['publishStatus'] as List).length}');
      print('   navigationLabel history length   = ${(versionedMap['navigationLabel'] as List).length}');
      print('   vision history length            = ${(versionedMap['vision'] as List).length}');
      print('   strategicHouseEnUrl history len  = ${(versionedMap['strategicHouseEnUrl'] as List).length}');
      print('   strategicHouseArUrl history len  = ${(versionedMap['strategicHouseArUrl'] as List).length}');

      await _docRef(_strategyDoc).set(versionedMap, SetOptions(merge: true));
      _log('🟢 [AboutRepo] saveStrategy: ✅ ALL fields versioned DONE');
    } catch (e) {
      _log('🔴 [AboutRepo] saveStrategy ERROR: $e');
      rethrow;
    }
  }

  // ── Fetch Terms ────────────────────────────────────────────────────────────
  @override
  Future<TermsOfServiceModel> fetchTerms() async {
    try {
      final snap = await _docRef(_termsDoc)
          .get(const GetOptions(source: Source.server));
      if (!snap.exists || snap.data() == null) {
        return TermsOfServiceModel.empty();
      }
      final raw = snap.data()!;
      final model = TermsOfServiceModel.fromMap(raw);
      return model;
    } catch (e) {
      _log('🔴 [AboutRepo] fetchTerms ERROR: $e');
      rethrow;
    }
  }

  // ── Save Terms (ALL fields versioned) ──────────────────────────────────────
  @override
  Future<void> saveTerms(TermsOfServiceModel model) async {
    try {
      print('🟡 [AboutRepo] saveTerms → reading existing doc...');
      final existingSnap = await _docRef(_termsDoc)
          .get(const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null) ?? {};
      print('   existing keys = ${existingData.keys.toList()}');

      final newMap = model.toMap();

      final versionedMap = <String, dynamic>{
        'publishStatus': Versioned.append(
          existingData['publishStatus'],
          newMap['publishStatus'],
        ),
        'navigationLabel': Versioned.append(
          existingData['navigationLabel'],
          newMap['navigationLabel'],
        ),
        'termsAndConditions': Versioned.append(
          existingData['termsAndConditions'],
          newMap['termsAndConditions'],
        ),
        'privacyPolicy': Versioned.append(
          existingData['privacyPolicy'],
          newMap['privacyPolicy'],
        ),
        'lastUpdatedAt': Versioned.append(
          existingData['lastUpdatedAt'],
          FieldValue.serverTimestamp(),
        ),
      };

      print('🟡 [AboutRepo] saveTerms → writing versioned map...');
      print('   publishStatus history length      = ${(versionedMap['publishStatus'] as List).length}');
      print('   navigationLabel history length    = ${(versionedMap['navigationLabel'] as List).length}');
      print('   termsAndConditions history length = ${(versionedMap['termsAndConditions'] as List).length}');
      print('   privacyPolicy history length      = ${(versionedMap['privacyPolicy'] as List).length}');

      await _docRef(_termsDoc).set(versionedMap, SetOptions(merge: true));
      _log('🟢 [AboutRepo] saveTerms: ✅ ALL fields versioned DONE');
    } catch (e) {
      _log('🔴 [AboutRepo] saveTerms ERROR: $e');
      rethrow;
    }
  }

  // ── Upload image ───────────────────────────────────────────────────────────
  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String storagePath,
  }) async {
    try {
      _log('🔵 [AboutRepo] uploadImage → $storagePath');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _detectExtension(bytes);
      final uniquePath = storagePath.contains('.')
          ? storagePath.replaceFirst('.', '_$timestamp.')
          : '$storagePath$timestamp.$extension';

      final mime = _detectMime(bytes);
      final ref = _storage.ref(uniquePath);
      await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      _log('🟢 [AboutRepo] uploadImage → $url');
      return url;
    } catch (e) {
      _log('🔴 [AboutRepo] uploadImage ERROR: $e');
      rethrow;
    }
  }

  // ── Upload document ────────────────────────────────────────────────────────
  @override
  Future<String> uploadDocument({
    required Uint8List bytes,
    required String storagePath,
    required String fileName,
  }) async {
    try {
      _log('🔵 [AboutRepo] uploadDocument → $storagePath/$fileName');
      final mime = fileName.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'application/octet-stream';
      final ref = _storage.ref('$storagePath/$fileName');
      await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url = await ref.getDownloadURL();
      _log('🟢 [AboutRepo] uploadDocument → $url');
      return url;
    } catch (e) {
      _log('🔴 [AboutRepo] uploadDocument ERROR: $e');
      rethrow;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _detectMime(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
      if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
      if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'image/webp';
    }
    if (bytes.length > 4) {
      final header = String.fromCharCodes(bytes.take(5));
      if (header.contains('<svg') || header.contains('<?xml'))
        return 'image/svg+xml';
    }
    return 'image/png';
  }

  String _detectExtension(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'png';
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'jpg';
      if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'gif';
      if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'webp';
    }
    if (bytes.length > 4) {
      final header = String.fromCharCodes(bytes.take(5));
      if (header.contains('<svg') || header.contains('<?xml'))
        return 'svg';
    }
    return 'png';
  }

  void _log(String msg) => print(msg);
}