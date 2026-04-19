// ******************* FILE INFO *******************
// File Name: contact_us_cms_repo_impl.dart
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: save() now versions ALL fields using Versioned.append()
//          — full audit trail in Firestore ✅
// FIX: socialIcons versioned via _versionListField() which stores history as
//      a Map { "v0": [...], "v1": [...] } instead of a nested List,
//      avoiding Firestore's "nested arrays not supported" error.
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/contact_us/contact_model_location.dart';
import 'contact_us_location.dart';

class ContactUsCmsRepoImpl implements ContactUsCmsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage   _storage   = FirebaseStorage.instance;

  static const String _collectionName = 'contactUs';
  static const String _docId          = 'main';

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(_collectionName).doc(_docId);

  // ── Load ───────────────────────────────────────────────────────────────────
  @override
  Future<ContactUsCmsModel> load() async {
    try {
      final doc = await _docRef.get();

      if (!doc.exists || doc.data() == null) {
        return _defaultModel();
      }

      final model = ContactUsCmsModel.fromJson(doc.data()!);
      return model;
    } catch (e) {
      print('❌ ContactUsCmsRepo.load error: $e');
      rethrow;
    }
  }

  // ── Save (ALL fields versioned) ────────────────────────────────────────────
  @override
  Future<void> save({
    required ContactUsCmsModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    try {
      Map<String, String> uploadedUrls = {};
      if (imageUploads != null && imageUploads.isNotEmpty) {
        uploadedUrls = await _uploadImages(imageUploads);
      }

      final updatedModel = _updateModelWithUrls(model, uploadedUrls);

      // ── Step 1: read existing raw Firestore data ────────────────────────
      print('🟡 [ContactCmsRepo] save → reading existing doc...');
      final existingSnap = await _docRef
          .get(const GetOptions(source: Source.server));
      final existingData =
          (existingSnap.exists ? existingSnap.data() : null) ?? {};
      print('   existing keys = ${existingData.keys.toList()}');

      // ── Step 2: plain map from model ────────────────────────────────────
      final newMap = updatedModel.toJson();

      // ── Step 3: build versioned map — ALL fields ────────────────────────
      //
      // NOTE: socialIcons cannot use Versioned.append() because socialIcons
      // is itself a List, and appending it into another List creates a nested
      // array which Firestore does not support.
      // Instead, _versionListField() stores history as a Map:
      //   { "v0": [...icons...], "v1": [...icons...], ... }
      // Firestore allows Maps that contain Arrays, just not Arrays of Arrays.
      final versionedMap = <String, dynamic>{
        'publishStatus': Versioned.append(
          existingData['publishStatus'],
          newMap['publishStatus'],
        ),
        'headings': Versioned.append(
          existingData['headings'],
          newMap['headings'],
        ),
        'clientDescription': Versioned.append(
          existingData['clientDescription'],
          newMap['clientDescription'],
        ),
        'ownerDescription': Versioned.append(
          existingData['ownerDescription'],
          newMap['ownerDescription'],
        ),

        // ✅ FIX: socialIcons versioned as Map to avoid nested array error
        'socialIcons': _versionListField(
          existingData['socialIcons'],
          newMap['socialIcons'] as List<dynamic>,
        ),

        'lastUpdatedAt': Versioned.append(
          existingData['lastUpdatedAt'],
          DateTime.now().toUtc().toIso8601String(), // ✅ plain string, safe in arrays
        ),
      };

      // ── Step 4: write to Firestore ──────────────────────────────────────
      print('🟡 [ContactCmsRepo] save → writing versioned map...');
      print('   publishStatus history length     = ${(versionedMap['publishStatus'] as List).length}');
      print('   headings history length          = ${(versionedMap['headings'] as List).length}');
      print('   clientDescription history length = ${(versionedMap['clientDescription'] as List).length}');
      print('   ownerDescription history length  = ${(versionedMap['ownerDescription'] as List).length}');
      print('   socialIcons version count        = ${(versionedMap['socialIcons'] as Map).length}');

      await _docRef.set(versionedMap, SetOptions(merge: true));
      print('✅ ContactUsCmsRepo.save: ALL fields versioned DONE');
    } catch (e) {
      print('❌ ContactUsCmsRepo.save error: $e');
      rethrow;
    }
  }

  // ── Version a List-typed field as a Map ───────────────────────────────────
  //
  // Stores history as { "v0": [...], "v1": [...], ... }
  // Firestore supports Maps containing Arrays, but not Arrays containing Arrays.
  //
  // Handles existing data in three formats:
  //   • Map  { "v0": [...] }   — already versioned-map (normal path post-fix)
  //   • List [ {...}, {...} ]  — legacy plain list (pre-versioning)
  //   • null / missing         — first save
  Map<String, dynamic> _versionListField(
      dynamic existing,
      List<dynamic> newValue,
      ) {
    final history = <String, dynamic>{};

    if (existing is Map) {
      // Already versioned-map — copy all existing versions
      existing.forEach((k, v) => history[k.toString()] = v);
    } else if (existing is List) {
      // Legacy plain list — treat the whole list as v0
      history['v0'] = existing;
    }
    // null / missing → history stays empty, first entry will be v0

    // Skip write if the value is unchanged from the last version
    if (history.isNotEmpty) {
      final lastKey = 'v${history.length - 1}';
      if (jsonEncode(history[lastKey]) == jsonEncode(newValue)) {
        print('   socialIcons unchanged — skipping version bump');
        return history;
      }
    }

    final nextKey = 'v${history.length}';
    history[nextKey] = newValue;
    return history;
  }

  // ── Upload images ─────────────────────────────────────────────────────────

  Future<Map<String, String>> _uploadImages(Map<String, Uint8List> uploads) async {
    final Map<String, String> urls = {};

    for (final entry in uploads.entries) {
      final path  = entry.key;
      final bytes = entry.value;

      try {
        final contentType = _detectContentType(bytes);
        final ref      = _storage.ref().child(path);
        final metadata = SettableMetadata(contentType: contentType);

        await ref.putData(bytes, metadata);
        final downloadUrl = await ref.getDownloadURL();

        urls[path] = downloadUrl;
        print('✅ Uploaded: $path → $downloadUrl');
      } catch (e) {
        print('❌ Failed to upload $path: $e');
      }
    }

    return urls;
  }

  // ── Update model with uploaded URLs ───────────────────────────────────────

  ContactUsCmsModel _updateModelWithUrls(
      ContactUsCmsModel model,
      Map<String, String> uploadedUrls,
      ) {
    String headingSvgUrl = model.headings.svgUrl;
    const headingSvgPath = 'contact_cms/headings/svg';
    if (uploadedUrls.containsKey(headingSvgPath)) {
      headingSvgUrl = uploadedUrls[headingSvgPath]!;
    }

    final updatedSocialIcons = model.socialIcons.map((icon) {
      final iconPath = 'contact_cms/social_icons/${icon.id}/icon';
      if (uploadedUrls.containsKey(iconPath)) {
        return icon.copyWith(iconUrl: uploadedUrls[iconPath]!);
      }
      return icon;
    }).toList();

    return model.copyWith(
      headings:    model.headings.copyWith(svgUrl: headingSvgUrl),
      socialIcons: updatedSocialIcons,
    );
  }

  // ── Detect content type ───────────────────────────────────────────────────

  String _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) return 'application/octet-stream';

    if (bytes[0] == 0x89 && bytes[1] == 0x50 &&
        bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    final header = String.fromCharCodes(
        bytes.sublist(0, bytes.length > 100 ? 100 : bytes.length));
    if (header.trim().startsWith('<svg') || header.trim().startsWith('<?xml')) {
      return 'image/svg+xml';
    }

    return 'application/octet-stream';
  }

  // ── Default model ─────────────────────────────────────────────────────────

  ContactUsCmsModel _defaultModel() {
    return ContactUsCmsModel(
      publishStatus: 'draft',
      headings: ContactHeadings(
        svgUrl: '',
        title: ContactBilingualText(en: '', ar: ''),
        shortDescription: ContactBilingualText(en: '', ar: ''),
      ),
      clientDescription: ContactDescriptionSection(
        description: ContactBilingualText(en: '', ar: ''),
        reasons: [
          ContactReasonItem(
            id:         'reason_client_1',
            label:      ContactBilingualText(en: '', ar: ''),
            isRequired: true,
          ),
        ],
      ),
      ownerDescription: ContactDescriptionSection(
        description: ContactBilingualText(en: '', ar: ''),
        reasons: [
          ContactReasonItem(
            id:         'reason_owner_1',
            label:      ContactBilingualText(en: '', ar: ''),
            isRequired: false,
          ),
        ],
      ),
      socialIcons: [
        ContactSocialIcon(id: 'social_1', iconUrl: '', link: ''),
        ContactSocialIcon(id: 'social_2', iconUrl: '', link: ''),
        ContactSocialIcon(id: 'social_3', iconUrl: '', link: ''),
        ContactSocialIcon(id: 'social_4', iconUrl: '', link: ''),
      ],
    );
  }
}