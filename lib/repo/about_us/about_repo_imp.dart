// ******************* FILE INFO *******************
// File Name: about_repo_impl.dart
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: All field names use Capital_Underscore naming convention ✅
// UPDATED: All nested maps flattened — no nested maps in Firestore ✅
// UPDATED: All save methods version each flattened field individually ✅

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/about_us/about_us.dart';
import 'about_repo.dart';

class AboutRepoImpl implements AboutRepo {
  static const String _aboutDoc    = 'aboutPage';
  static const String _strategyDoc = 'ourStrategy';
  static const String _termsDoc    = 'termsOfService';

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
      return AboutPageModel.fromMap(snap.data()!);
    } catch (e) {
      _log('🔴 [AboutRepo] fetchAboutPage ERROR: $e');
      rethrow;
    }
  }

  // ── Save About Page (ALL fields versioned individually) ────────────────────
  @override
  Future<void> saveAboutPage(AboutPageModel model) async {
    try {
      print('🟡 [AboutRepo] saveAboutPage → reading existing doc...');
      final existingSnap = await _docRef(_aboutDoc)
          .get(const GetOptions(source: Source.server));
      final ex = (existingSnap.exists ? existingSnap.data() : null) ?? {};

      final newMap = model.toMap();

      final versionedMap = <String, dynamic>{
        // ── plain fields (not versioned) ───────────────────────────────
        'Values':         newMap['Values'],
        'Last_Updated_At': FieldValue.serverTimestamp(),

        // ── versioned scalar fields ────────────────────────────────────
        'Publish_Status': Versioned.append(
          ex['Publish_Status'], newMap['Publish_Status'],
        ),
        'Svg_Url': Versioned.append(
          ex['Svg_Url'], newMap['Svg_Url'],
        ),

        // ── Title (flattened, versioned) ───────────────────────────────
        'Title_En': Versioned.append(ex['Title_En'], newMap['Title_En']),
        'Title_Ar': Versioned.append(ex['Title_Ar'], newMap['Title_Ar']),

        // ── Navigation Label (flattened, versioned) ────────────────────
        'Navigation_Label_Icon_Url': Versioned.append(
          ex['Navigation_Label_Icon_Url'], newMap['Navigation_Label_Icon_Url'],
        ),
        'Navigation_Label_Title_En': Versioned.append(
          ex['Navigation_Label_Title_En'], newMap['Navigation_Label_Title_En'],
        ),
        'Navigation_Label_Title_Ar': Versioned.append(
          ex['Navigation_Label_Title_Ar'], newMap['Navigation_Label_Title_Ar'],
        ),

        // ── Vision (flattened, versioned) ──────────────────────────────
        'Vision_Icon_Url': Versioned.append(
          ex['Vision_Icon_Url'], newMap['Vision_Icon_Url'],
        ),
        'Vision_Svg_Url': Versioned.append(
          ex['Vision_Svg_Url'], newMap['Vision_Svg_Url'],
        ),
        'Vision_Sub_Description_En': Versioned.append(
          ex['Vision_Sub_Description_En'], newMap['Vision_Sub_Description_En'],
        ),
        'Vision_Sub_Description_Ar': Versioned.append(
          ex['Vision_Sub_Description_Ar'], newMap['Vision_Sub_Description_Ar'],
        ),
        'Vision_Description_En': Versioned.append(
          ex['Vision_Description_En'], newMap['Vision_Description_En'],
        ),
        'Vision_Description_Ar': Versioned.append(
          ex['Vision_Description_Ar'], newMap['Vision_Description_Ar'],
        ),

        // ── Mission (flattened, versioned) ─────────────────────────────
        'Mission_Icon_Url': Versioned.append(
          ex['Mission_Icon_Url'], newMap['Mission_Icon_Url'],
        ),
        'Mission_Svg_Url': Versioned.append(
          ex['Mission_Svg_Url'], newMap['Mission_Svg_Url'],
        ),
        'Mission_Sub_Description_En': Versioned.append(
          ex['Mission_Sub_Description_En'], newMap['Mission_Sub_Description_En'],
        ),
        'Mission_Sub_Description_Ar': Versioned.append(
          ex['Mission_Sub_Description_Ar'], newMap['Mission_Sub_Description_Ar'],
        ),
        'Mission_Description_En': Versioned.append(
          ex['Mission_Description_En'], newMap['Mission_Description_En'],
        ),
        'Mission_Description_Ar': Versioned.append(
          ex['Mission_Description_Ar'], newMap['Mission_Description_Ar'],
        ),
      };

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
      return OurStrategyModel.fromMap(snap.data()!);
    } catch (e) {
      _log('🔴 [AboutRepo] fetchStrategy ERROR: $e');
      rethrow;
    }
  }

  // ── Save Strategy (ALL fields versioned individually) ──────────────────────
  @override
  Future<void> saveStrategy(OurStrategyModel model) async {
    try {
      print('🟡 [AboutRepo] saveStrategy → reading existing doc...');
      final existingSnap = await _docRef(_strategyDoc)
          .get(const GetOptions(source: Source.server));
      final ex = (existingSnap.exists ? existingSnap.data() : null) ?? {};

      final newMap = model.toMap();

      final versionedMap = <String, dynamic>{
        // ── Last Updated (not versioned) ──────────────────────────────
        'Last_Updated_At': FieldValue.serverTimestamp(),

        // ── versioned scalar fields ────────────────────────────────────
        'Publish_Status': Versioned.append(
          ex['Publish_Status'], newMap['Publish_Status'],
        ),
        'Strategic_House_En_Url': Versioned.append(
          ex['Strategic_House_En_Url'], newMap['Strategic_House_En_Url'],
        ),
        'Strategic_House_Ar_Url': Versioned.append(
          ex['Strategic_House_Ar_Url'], newMap['Strategic_House_Ar_Url'],
        ),

        // ── Navigation Label (flattened, versioned) ────────────────────
        'Navigation_Label_Icon_Url': Versioned.append(
          ex['Navigation_Label_Icon_Url'], newMap['Navigation_Label_Icon_Url'],
        ),
        'Navigation_Label_Title_En': Versioned.append(
          ex['Navigation_Label_Title_En'], newMap['Navigation_Label_Title_En'],
        ),
        'Navigation_Label_Title_Ar': Versioned.append(
          ex['Navigation_Label_Title_Ar'], newMap['Navigation_Label_Title_Ar'],
        ),

        // ── Vision (flattened, versioned) ──────────────────────────────
        'Vision_Svg_Url': Versioned.append(
          ex['Vision_Svg_Url'], newMap['Vision_Svg_Url'],
        ),
        'Vision_Description_En': Versioned.append(
          ex['Vision_Description_En'], newMap['Vision_Description_En'],
        ),
        'Vision_Description_Ar': Versioned.append(
          ex['Vision_Description_Ar'], newMap['Vision_Description_Ar'],
        ),
      };

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
      return TermsOfServiceModel.fromMap(snap.data()!);
    } catch (e) {
      _log('🔴 [AboutRepo] fetchTerms ERROR: $e');
      rethrow;
    }
  }

  // ── Save Terms (ALL fields versioned individually) ─────────────────────────
  @override
  Future<void> saveTerms(TermsOfServiceModel model) async {
    try {
      print('🟡 [AboutRepo] saveTerms → reading existing doc...');
      final existingSnap = await _docRef(_termsDoc)
          .get(const GetOptions(source: Source.server));
      final ex = (existingSnap.exists ? existingSnap.data() : null) ?? {};

      final newMap = model.toMap();

      final versionedMap = <String, dynamic>{
        // ── Last Updated (not versioned) ──────────────────────────────
        'Last_Updated_At': FieldValue.serverTimestamp(),

        // ── versioned scalar fields ────────────────────────────────────
        'Publish_Status': Versioned.append(
          ex['Publish_Status'], newMap['Publish_Status'],
        ),

        // ── Navigation Label (flattened, versioned) ────────────────────
        'Navigation_Label_Icon_Url': Versioned.append(
          ex['Navigation_Label_Icon_Url'], newMap['Navigation_Label_Icon_Url'],
        ),
        'Navigation_Label_Title_En': Versioned.append(
          ex['Navigation_Label_Title_En'], newMap['Navigation_Label_Title_En'],
        ),
        'Navigation_Label_Title_Ar': Versioned.append(
          ex['Navigation_Label_Title_Ar'], newMap['Navigation_Label_Title_Ar'],
        ),

        // ── Terms And Conditions (flattened, versioned) ────────────────
        'Terms_And_Conditions_Svg_Url': Versioned.append(
          ex['Terms_And_Conditions_Svg_Url'], newMap['Terms_And_Conditions_Svg_Url'],
        ),
        'Terms_And_Conditions_Description_En': Versioned.append(
          ex['Terms_And_Conditions_Description_En'], newMap['Terms_And_Conditions_Description_En'],
        ),
        'Terms_And_Conditions_Description_Ar': Versioned.append(
          ex['Terms_And_Conditions_Description_Ar'], newMap['Terms_And_Conditions_Description_Ar'],
        ),
        'Terms_And_Conditions_Attach_En_Url': Versioned.append(
          ex['Terms_And_Conditions_Attach_En_Url'], newMap['Terms_And_Conditions_Attach_En_Url'],
        ),
        'Terms_And_Conditions_Attach_Ar_Url': Versioned.append(
          ex['Terms_And_Conditions_Attach_Ar_Url'], newMap['Terms_And_Conditions_Attach_Ar_Url'],
        ),
        if (newMap.containsKey('Terms_And_Conditions_Last_Update'))
          'Terms_And_Conditions_Last_Update': Versioned.append(
            ex['Terms_And_Conditions_Last_Update'], newMap['Terms_And_Conditions_Last_Update'],
          ),

        // ── Privacy Policy (flattened, versioned) ──────────────────────
        'Privacy_Policy_Svg_Url': Versioned.append(
          ex['Privacy_Policy_Svg_Url'], newMap['Privacy_Policy_Svg_Url'],
        ),
        'Privacy_Policy_Description_En': Versioned.append(
          ex['Privacy_Policy_Description_En'], newMap['Privacy_Policy_Description_En'],
        ),
        'Privacy_Policy_Description_Ar': Versioned.append(
          ex['Privacy_Policy_Description_Ar'], newMap['Privacy_Policy_Description_Ar'],
        ),
        'Privacy_Policy_Attach_En_Url': Versioned.append(
          ex['Privacy_Policy_Attach_En_Url'], newMap['Privacy_Policy_Attach_En_Url'],
        ),
        'Privacy_Policy_Attach_Ar_Url': Versioned.append(
          ex['Privacy_Policy_Attach_Ar_Url'], newMap['Privacy_Policy_Attach_Ar_Url'],
        ),
        if (newMap.containsKey('Privacy_Policy_Last_Update'))
          'Privacy_Policy_Last_Update': Versioned.append(
            ex['Privacy_Policy_Last_Update'], newMap['Privacy_Policy_Last_Update'],
          ),
      };

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