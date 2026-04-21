// ******************* FILE INFO *******************
// File Name: contact_model_location.dart
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: All field names use Capital_Underscore naming convention ✅
// UPDATED: All nested maps (ContactBilingualText, ContactHeadings,
//          ContactDescriptionSection) flattened ✅
// UPDATED: ALL fields versioned — fromJson() uses Versioned.read() ✅
// FIX: socialIcons versioned via Map { v0: [...], v1: [...] } to avoid
//      Firestore nested array error ✅

import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Versioned Field Helper
// ─────────────────────────────────────────────────────────────────────────────

class Versioned {
  static T read<T>(dynamic raw, T Function(dynamic) parser) {
    if (raw is List && raw.isNotEmpty) return parser(raw.last);
    if (raw != null) return parser(raw);
    return parser(null);
  }

  static List<dynamic> append(dynamic existing, dynamic newValue) {
    final history = <dynamic>[];
    if (existing is List) {
      history.addAll(existing);
    } else if (existing != null) {
      history.add(existing);
    }
    if (history.isNotEmpty) {
      final lastEncoded = _encode(history.last);
      final newEncoded  = _encode(newValue);
      if (lastEncoded == newEncoded) return history;
    }
    history.add(newValue);
    return history;
  }

  static String _encode(dynamic value) {
    if (value == null) return 'null';
    if (value is Map) {
      final sorted = Map.fromEntries(
        (value.entries.toList()
          ..sort((a, b) => a.key.toString().compareTo(b.key.toString())))
            .map((e) => MapEntry(e.key.toString(), _encode(e.value))),
      );
      return sorted.toString();
    }
    if (value is List) return value.map(_encode).toList().toString();
    return value.toString();
  }
}

// ── Bilingual text — no toMap/fromMap, parent flattens ────────────────────────

class ContactBilingualText {
  final String en;
  final String ar;

  const ContactBilingualText({this.en = '', this.ar = ''});

  ContactBilingualText copyWith({String? en, String? ar}) =>
      ContactBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Headings — flattened into root ────────────────────────────────────────────

class ContactHeadings {
  final String svgUrl;
  final ContactBilingualText title;
  final ContactBilingualText shortDescription;

  const ContactHeadings({
    this.svgUrl = '',
    this.title = const ContactBilingualText(),
    this.shortDescription = const ContactBilingualText(),
  });

  ContactHeadings copyWith({
    String? svgUrl,
    ContactBilingualText? title,
    ContactBilingualText? shortDescription,
  }) =>
      ContactHeadings(
        svgUrl: svgUrl ?? this.svgUrl,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
      );
}

// ── Reason Item (inside list — has its own toMap/fromMap) ─────────────────────

class ContactReasonItem {
  final String id;
  final ContactBilingualText label;
  final bool isRequired;

  const ContactReasonItem({
    this.id = '',
    this.label = const ContactBilingualText(),
    this.isRequired = false,
  });

  factory ContactReasonItem.fromMap(Map<String, dynamic> map) =>
      ContactReasonItem(
        id:         map['Id'] ?? '',
        label:      ContactBilingualText(
          en: map['Label_En'] ?? '',
          ar: map['Label_Ar'] ?? '',
        ),
        isRequired: map['Is_Required'] ?? false,
      );

  Map<String, dynamic> toMap() => {
    'Id':          id,
    'Label_En':    label.en,
    'Label_Ar':    label.ar,
    'Is_Required': isRequired,
  };

  ContactReasonItem copyWith({
    String? id,
    ContactBilingualText? label,
    bool? isRequired,
  }) =>
      ContactReasonItem(
        id: id ?? this.id,
        label: label ?? this.label,
        isRequired: isRequired ?? this.isRequired,
      );
}

// ── Description Section — flattened into root ────────────────────────────────

class ContactDescriptionSection {
  final ContactBilingualText description;
  final List<ContactReasonItem> reasons;

  const ContactDescriptionSection({
    this.description = const ContactBilingualText(),
    this.reasons = const [],
  });

  ContactDescriptionSection copyWith({
    ContactBilingualText? description,
    List<ContactReasonItem>? reasons,
  }) =>
      ContactDescriptionSection(
        description: description ?? this.description,
        reasons: reasons ?? this.reasons,
      );
}

// ── Social Icon (inside list — has its own toMap/fromMap) ─────────────────────

class ContactSocialIcon {
  final String id;
  final String iconUrl;
  final String link;

  const ContactSocialIcon({
    this.id = '',
    this.iconUrl = '',
    this.link = '',
  });

  factory ContactSocialIcon.fromMap(Map<String, dynamic> map) =>
      ContactSocialIcon(
        id:      map['Id'] ?? '',
        iconUrl: map['Icon_Url'] ?? '',
        link:    map['Link'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'Id':       id,
    'Icon_Url': iconUrl,
    'Link':     link,
  };

  ContactSocialIcon copyWith({
    String? id,
    String? iconUrl,
    String? link,
  }) =>
      ContactSocialIcon(
        id: id ?? this.id,
        iconUrl: iconUrl ?? this.iconUrl,
        link: link ?? this.link,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// socialIcons versioned-list reader
//
// Supports three storage formats:
//   1. Versioned-map  { "v0": [...], "v1": [...] }  ← new format
//   2. Plain list     [ {...}, {...} ]               ← legacy
//   3. Versioned list [ [...], [...] ]               ← legacy bug
// ─────────────────────────────────────────────────────────────────────────────

List<ContactSocialIcon> _readVersionedListField(dynamic raw) {
  List<dynamic> lastValue = [];

  if (raw is Map) {
    if (raw.isNotEmpty) {
      final sortedKeys = raw.keys.toList()
        ..sort((a, b) {
          final ai = int.tryParse(a.toString().replaceFirst('v', '')) ?? 0;
          final bi = int.tryParse(b.toString().replaceFirst('v', '')) ?? 0;
          return ai.compareTo(bi);
        });
      final last = raw[sortedKeys.last];
      if (last is List) lastValue = last;
    }
  } else if (raw is List && raw.isNotEmpty) {
    final first = raw.first;
    if (first is List) {
      lastValue = raw.last as List;
    } else {
      lastValue = raw;
    }
  }

  return lastValue
      .map((e) => ContactSocialIcon.fromMap(
    e is Map ? Map<String, dynamic>.from(e) : {},
  ))
      .toList();
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════

class ContactUsCmsModel {
  final String publishStatus;
  final ContactHeadings headings;
  final ContactDescriptionSection clientDescription;
  final ContactDescriptionSection ownerDescription;
  final List<ContactSocialIcon> socialIcons;
  final DateTime? lastUpdatedAt;

  const ContactUsCmsModel({
    this.publishStatus = 'draft',
    this.headings = const ContactHeadings(),
    this.clientDescription = const ContactDescriptionSection(),
    this.ownerDescription = const ContactDescriptionSection(),
    this.socialIcons = const [],
    this.lastUpdatedAt,
  });

  // ── fromJson — ALL fields flattened, Capital_Underscore keys ─────────────
  factory ContactUsCmsModel.fromJson(Map<String, dynamic> map) {

    // ── Client Reasons (plain list) ─────────────────────────────────────
    final rawClientReasons = map['Client_Description_Reasons'] as List<dynamic>? ?? [];
    final clientReasons = rawClientReasons
        .map((e) => ContactReasonItem.fromMap(e as Map<String, dynamic>))
        .toList();

    // ── Owner Reasons (plain list) ──────────────────────────────────────
    final rawOwnerReasons = map['Owner_Description_Reasons'] as List<dynamic>? ?? [];
    final ownerReasons = rawOwnerReasons
        .map((e) => ContactReasonItem.fromMap(e as Map<String, dynamic>))
        .toList();

    // ── Last Updated (not versioned) ────────────────────────────────────
    DateTime? lastUpdatedAt;
    if (map['Last_Updated_At'] != null) {
      if (map['Last_Updated_At'] is Timestamp) {
        lastUpdatedAt = (map['Last_Updated_At'] as Timestamp).toDate();
      } else if (map['Last_Updated_At'] is String) {
        lastUpdatedAt = DateTime.tryParse(map['Last_Updated_At']);
      }
    }

    return ContactUsCmsModel(
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),

      // ── Headings (flattened, versioned) ───────────────────────────────
      headings: ContactHeadings(
        svgUrl: Versioned.read<String>(
          map['Headings_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        title: ContactBilingualText(
          en: Versioned.read<String>(
            map['Headings_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Headings_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        shortDescription: ContactBilingualText(
          en: Versioned.read<String>(
            map['Headings_Short_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Headings_Short_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      // ── Client Description (flattened, versioned) ─────────────────────
      clientDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: Versioned.read<String>(
            map['Client_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Client_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        reasons: clientReasons,
      ),

      // ── Owner Description (flattened, versioned) ──────────────────────
      ownerDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: Versioned.read<String>(
            map['Owner_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Owner_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        reasons: ownerReasons,
      ),

      // ── Social Icons (versioned via Map) ──────────────────────────────
      socialIcons: _readVersionedListField(map['Social_Icons']),

      lastUpdatedAt: lastUpdatedAt,
    );
  }

  // ── toJson — ALL fields flattened, Capital_Underscore naming ─────────────
  Map<String, dynamic> toJson() => {
    'Publish_Status': publishStatus,

    // ── Headings (flattened) ─────────────────────────────────────────
    'Headings_Svg_Url':              headings.svgUrl,
    'Headings_Title_En':             headings.title.en,
    'Headings_Title_Ar':             headings.title.ar,
    'Headings_Short_Description_En': headings.shortDescription.en,
    'Headings_Short_Description_Ar': headings.shortDescription.ar,

    // ── Client Description (flattened) ───────────────────────────────
    'Client_Description_En':      clientDescription.description.en,
    'Client_Description_Ar':      clientDescription.description.ar,
    'Client_Description_Reasons': clientDescription.reasons.map((r) => r.toMap()).toList(),

    // ── Owner Description (flattened) ────────────────────────────────
    'Owner_Description_En':      ownerDescription.description.en,
    'Owner_Description_Ar':      ownerDescription.description.ar,
    'Owner_Description_Reasons': ownerDescription.reasons.map((r) => r.toMap()).toList(),

    // ── Social Icons (list) ──────────────────────────────────────────
    'Social_Icons': socialIcons.map((s) => s.toMap()).toList(),
  };

  ContactUsCmsModel copyWith({
    String? publishStatus,
    ContactHeadings? headings,
    ContactDescriptionSection? clientDescription,
    ContactDescriptionSection? ownerDescription,
    List<ContactSocialIcon>? socialIcons,
    DateTime? lastUpdatedAt,
  }) =>
      ContactUsCmsModel(
        publishStatus: publishStatus ?? this.publishStatus,
        headings: headings ?? this.headings,
        clientDescription: clientDescription ?? this.clientDescription,
        ownerDescription: ownerDescription ?? this.ownerDescription,
        socialIcons: socialIcons ?? this.socialIcons,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
}