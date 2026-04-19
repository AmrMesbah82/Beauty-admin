// ******************* FILE INFO *******************
// File Name: contact_model_location.dart
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: ALL fields are now versioned — every field in Firestore is stored
//          as a list for full history tracking. fromJson() uses Versioned.read()
//          for every field. toJson() writes plain values (repo handles versioning).
// FIX: socialIcons now read via _readVersionedListField() to support both
//      legacy plain-list format and new versioned-map format { v0: [...], v1: [...] }
//      This avoids the Firestore "nested arrays not supported" error.

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

  static List<T> readList<T>(dynamic raw, T Function(dynamic) parser) {
    if (raw is List && raw.isNotEmpty) {
      final last = raw.last;
      if (last is List) return last.map((e) => parser(e)).toList();
      return raw.map((e) => parser(e)).toList();
    }
    return [];
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

// ── Bilingual text ────────────────────────────────────────────────────────────

class ContactBilingualText {
  final String en;
  final String ar;

  const ContactBilingualText({this.en = '', this.ar = ''});

  factory ContactBilingualText.fromMap(Map<String, dynamic>? map) =>
      ContactBilingualText(
        en: (map?['en'] as String?) ?? '',
        ar: (map?['ar'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  ContactBilingualText copyWith({String? en, String? ar}) =>
      ContactBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Headings ──────────────────────────────────────────────────────────────────

class ContactHeadings {
  final String svgUrl;
  final ContactBilingualText title;
  final ContactBilingualText shortDescription;

  const ContactHeadings({
    this.svgUrl = '',
    this.title = const ContactBilingualText(),
    this.shortDescription = const ContactBilingualText(),
  });

  factory ContactHeadings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ContactHeadings();
    return ContactHeadings(
      svgUrl: (map['svgUrl'] as String?) ?? '',
      title: ContactBilingualText.fromMap(map['title'] as Map<String, dynamic>?),
      shortDescription: ContactBilingualText.fromMap(
          map['shortDescription'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'title': title.toMap(),
    'shortDescription': shortDescription.toMap(),
  };

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

// ── Reason Item ───────────────────────────────────────────────────────────────

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
        id: (map['id'] as String?) ?? '',
        label: ContactBilingualText.fromMap(map['label'] as Map<String, dynamic>?),
        isRequired: (map['isRequired'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label.toMap(),
    'isRequired': isRequired,
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

// ── Description Section (Client / Owner) ─────────────────────────────────────

class ContactDescriptionSection {
  final ContactBilingualText description;
  final List<ContactReasonItem> reasons;

  const ContactDescriptionSection({
    this.description = const ContactBilingualText(),
    this.reasons = const [],
  });

  factory ContactDescriptionSection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ContactDescriptionSection();
    final rawReasons = map['reasons'] as List<dynamic>? ?? [];
    return ContactDescriptionSection(
      description: ContactBilingualText.fromMap(
          map['description'] as Map<String, dynamic>?),
      reasons: rawReasons
          .map((e) => ContactReasonItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'description': description.toMap(),
    'reasons': reasons.map((r) => r.toMap()).toList(),
  };

  ContactDescriptionSection copyWith({
    ContactBilingualText? description,
    List<ContactReasonItem>? reasons,
  }) =>
      ContactDescriptionSection(
        description: description ?? this.description,
        reasons: reasons ?? this.reasons,
      );
}

// ── Social Icon ───────────────────────────────────────────────────────────────

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
        id: (map['id'] as String?) ?? '',
        iconUrl: (map['iconUrl'] as String?) ?? '',
        link: (map['link'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'iconUrl': iconUrl,
    'link': link,
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
//   1. Versioned-map  { "v0": [...], "v1": [...] }  ← new format (post-fix)
//   2. Plain list     [ {...}, {...} ]               ← legacy (pre-versioning)
//   3. Versioned list [ [...], [...] ]               ← legacy (old append bug)
// ─────────────────────────────────────────────────────────────────────────────

List<ContactSocialIcon> _readVersionedListField(dynamic raw) {
  List<dynamic> lastValue = [];

  if (raw is Map) {
    // ── Format 1: versioned-map { v0: [...], v1: [...] } ──────────────────
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
      // ── Format 3: versioned list [ [...], [...] ] — last entry is latest ─
      lastValue = raw.last as List;
    } else {
      // ── Format 2: plain list [ {id:...}, {id:...} ] ───────────────────────
      lastValue = raw;
    }
  }

  return lastValue
      .map((e) => ContactSocialIcon.fromMap(
    e is Map ? Map<String, dynamic>.from(e) : {},
  ))
      .toList();
}

// ── ROOT MODEL — ALL fields versioned ────────────────────────────────────────

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

  // ── fromJson — ALL fields use Versioned.read() ───────────────────────────
  factory ContactUsCmsModel.fromJson(Map<String, dynamic> map) {
    return ContactUsCmsModel(
      publishStatus: Versioned.read<String>(
        map['publishStatus'],
            (v) => v?.toString() ?? 'draft',
      ),

      headings: Versioned.read<ContactHeadings>(
        map['headings'],
            (v) => ContactHeadings.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      clientDescription: Versioned.read<ContactDescriptionSection>(
        map['clientDescription'],
            (v) => ContactDescriptionSection.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      ownerDescription: Versioned.read<ContactDescriptionSection>(
        map['ownerDescription'],
            (v) => ContactDescriptionSection.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      // ✅ FIX: use dedicated reader that handles versioned-map format
      //         to avoid Firestore "nested arrays not supported" error
      socialIcons: _readVersionedListField(map['socialIcons']),

      lastUpdatedAt: Versioned.read<DateTime?>(
        map['lastUpdatedAt'],
            (v) {
          if (v == null) return null;
          if (v is Timestamp) return v.toDate();
          if (v is String) return DateTime.tryParse(v);
          return null;
        },
      ),
    );
  }

  // ── toJson — plain values (versioning handled in repo layer) ─────────────
  Map<String, dynamic> toJson() => {
    'publishStatus': publishStatus,
    'headings': headings.toMap(),
    'clientDescription': clientDescription.toMap(),
    'ownerDescription': ownerDescription.toMap(),
    'socialIcons': socialIcons.map((s) => s.toMap()).toList(),
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