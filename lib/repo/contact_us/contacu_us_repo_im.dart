// ******************* FILE INFO *******************
// File Name: contact_us_cms_repo_impl.dart
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: All field names use Capital_Underscore naming convention ✅
// UPDATED: All nested maps flattened — no nested maps in Firestore ✅
// UPDATED: save() versions each flattened field individually ✅
// FIX: Social_Icons versioned via _versionListField() Map format ✅

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
      return ContactUsCmsModel.fromJson(doc.data()!);
    } catch (e) {
      print('❌ ContactUsCmsRepo.load error: $e');
      rethrow;
    }
  }

  // ── Save (ALL fields versioned individually) ───────────────────────────────
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
      final ex = (existingSnap.exists ? existingSnap.data() : null) ?? {};

      // ── Step 2: plain map from model ────────────────────────────────────
      final newMap = updatedModel.toJson();

      // ── Step 3: build versioned map ─────────────────────────────────────
      final versionedMap = <String, dynamic>{
        // ── plain list fields (not versioned) ──────────────────────────
        'Client_Description_Reasons': newMap['Client_Description_Reasons'],
        'Owner_Description_Reasons':  newMap['Owner_Description_Reasons'],
        'Last_Updated_At':            FieldValue.serverTimestamp(),

        // ── versioned scalar fields ────────────────────────────────────
        'Publish_Status': Versioned.append(
          ex['Publish_Status'], newMap['Publish_Status'],
        ),

        // ── Headings (flattened, versioned) ────────────────────────────
        'Headings_Svg_Url': Versioned.append(
          ex['Headings_Svg_Url'], newMap['Headings_Svg_Url'],
        ),
        'Headings_Title_En': Versioned.append(
          ex['Headings_Title_En'], newMap['Headings_Title_En'],
        ),
        'Headings_Title_Ar': Versioned.append(
          ex['Headings_Title_Ar'], newMap['Headings_Title_Ar'],
        ),
        'Headings_Short_Description_En': Versioned.append(
          ex['Headings_Short_Description_En'], newMap['Headings_Short_Description_En'],
        ),
        'Headings_Short_Description_Ar': Versioned.append(
          ex['Headings_Short_Description_Ar'], newMap['Headings_Short_Description_Ar'],
        ),

        // ── Client Description (flattened, versioned) ──────────────────
        'Client_Description_En': Versioned.append(
          ex['Client_Description_En'], newMap['Client_Description_En'],
        ),
        'Client_Description_Ar': Versioned.append(
          ex['Client_Description_Ar'], newMap['Client_Description_Ar'],
        ),

        // ── Owner Description (flattened, versioned) ───────────────────
        'Owner_Description_En': Versioned.append(
          ex['Owner_Description_En'], newMap['Owner_Description_En'],
        ),
        'Owner_Description_Ar': Versioned.append(
          ex['Owner_Description_Ar'], newMap['Owner_Description_Ar'],
        ),

        // ── Social Icons (versioned via Map) ───────────────────────────
        'Social_Icons': _versionListField(
          ex['Social_Icons'],
          newMap['Social_Icons'] as List<dynamic>,
        ),
      };

      // ── Step 4: write to Firestore ──────────────────────────────────────
      print('🟡 [ContactCmsRepo] save → writing versioned map...');
      await _docRef.set(versionedMap, SetOptions(merge: true));
      print('✅ ContactUsCmsRepo.save: ALL fields versioned DONE');
    } catch (e) {
      print('❌ ContactUsCmsRepo.save error: $e');
      rethrow;
    }
  }

  // ── Version a List-typed field as a Map ───────────────────────────────────
  Map<String, dynamic> _versionListField(
      dynamic existing,
      List<dynamic> newValue,
      ) {
    final history = <String, dynamic>{};

    if (existing is Map) {
      existing.forEach((k, v) => history[k.toString()] = v);
    } else if (existing is List) {
      history['v0'] = existing;
    }

    if (history.isNotEmpty) {
      final lastKey = 'v${history.length - 1}';
      if (jsonEncode(history[lastKey]) == jsonEncode(newValue)) {
        print('   Social_Icons unchanged — skipping version bump');
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