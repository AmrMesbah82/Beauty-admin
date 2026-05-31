// ******************* FILE INFO *******************
// File Name: about_page_model.dart
// Description: Shared helpers (Versioned, AboutBilingualText,
//   AboutNavigationLabel, AboutSection, AboutValueItem) + AboutPageModel + DocUpload
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: about_us › data › models

import 'dart:typed_data';
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

class AboutBilingualText {
  final String en;
  final String ar;

  const AboutBilingualText({this.en = '', this.ar = ''});

  AboutBilingualText copyWith({String? en, String? ar}) =>
      AboutBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Navigation Label — flattened into parent ──────────────────────────────────

class AboutNavigationLabel {
  final String iconUrl;
  final AboutBilingualText title;

  const AboutNavigationLabel({
    this.iconUrl = '',
    this.title = const AboutBilingualText(),
  });

  factory AboutNavigationLabel.empty() => const AboutNavigationLabel();

  AboutNavigationLabel copyWith({
    String? iconUrl,
    AboutBilingualText? title,
  }) =>
      AboutNavigationLabel(
        iconUrl: iconUrl ?? this.iconUrl,
        title: title ?? this.title,
      );
}

// ── Values item (inside list — has its own toMap/fromMap) ─────────────────────

class AboutValueItem {
  final String id;
  final String iconUrl;
  final AboutBilingualText title;
  final AboutBilingualText shortDescription;
  final AboutBilingualText description;

  const AboutValueItem({
    required this.id,
    this.iconUrl = '',
    this.title = const AboutBilingualText(),
    this.shortDescription = const AboutBilingualText(),
    this.description = const AboutBilingualText(),
  });

  factory AboutValueItem.empty(String id) => AboutValueItem(id: id);

  factory AboutValueItem.fromMap(Map<String, dynamic> map) => AboutValueItem(
    id:               map['Id'] ?? '',
    iconUrl:          map['Icon_Url'] ?? '',
    title:            AboutBilingualText(
      en: map['Title_En'] ?? '',
      ar: map['Title_Ar'] ?? '',
    ),
    shortDescription: AboutBilingualText(
      en: map['Short_Description_En'] ?? '',
      ar: map['Short_Description_Ar'] ?? '',
    ),
    description:      AboutBilingualText(
      en: map['Description_En'] ?? '',
      ar: map['Description_Ar'] ?? '',
    ),
  );

  Map<String, dynamic> toMap() => {
    'Id':                   id,
    'Icon_Url':             iconUrl,
    'Title_En':             title.en,
    'Title_Ar':             title.ar,
    'Short_Description_En': shortDescription.en,
    'Short_Description_Ar': shortDescription.ar,
    'Description_En':       description.en,
    'Description_Ar':       description.ar,
  };

  AboutValueItem copyWith({
    String? id,
    String? iconUrl,
    AboutBilingualText? title,
    AboutBilingualText? shortDescription,
    AboutBilingualText? description,
  }) =>
      AboutValueItem(
        id: id ?? this.id,
        iconUrl: iconUrl ?? this.iconUrl,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        description: description ?? this.description,
      );
}

// ── Section (Vision / Mission) — flattened into parent ────────────────────────

class AboutSection {
  final String iconUrl;
  final String svgUrl;
  final AboutBilingualText subDescription;
  final AboutBilingualText description;

  const AboutSection({
    this.iconUrl = '',
    this.svgUrl = '',
    this.subDescription = const AboutBilingualText(),
    this.description = const AboutBilingualText(),
  });

  factory AboutSection.empty() => const AboutSection();

  AboutSection copyWith({
    String? iconUrl,
    String? svgUrl,
    AboutBilingualText? subDescription,
    AboutBilingualText? description,
  }) =>
      AboutSection(
        iconUrl: iconUrl ?? this.iconUrl,
        svgUrl: svgUrl ?? this.svgUrl,
        subDescription: subDescription ?? this.subDescription,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ABOUT PAGE MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════

class AboutPageModel {
  final String publishStatus;
  final AboutBilingualText title;
  final String svgUrl;
  final AboutNavigationLabel navigationLabel;
  final AboutSection vision;
  final AboutSection mission;
  final List<AboutValueItem> values;
  final DateTime? lastUpdatedAt;

  const AboutPageModel({
    this.publishStatus = 'draft',
    this.title = const AboutBilingualText(),
    this.svgUrl = '',
    this.navigationLabel = const AboutNavigationLabel(),
    this.vision = const AboutSection(),
    this.mission = const AboutSection(),
    this.values = const [],
    this.lastUpdatedAt,
  });

  factory AboutPageModel.empty() => const AboutPageModel();

  factory AboutPageModel.fromMap(Map<String, dynamic> map) {
    final rawValues = map['Values'] as List<dynamic>? ?? [];
    final valueItems = rawValues
        .map((e) => AboutValueItem.fromMap(e as Map<String, dynamic>))
        .toList();

    DateTime? lastUpdatedAt;
    if (map['Last_Updated_At'] != null) {
      if (map['Last_Updated_At'] is Timestamp) {
        lastUpdatedAt = (map['Last_Updated_At'] as Timestamp).toDate();
      } else if (map['Last_Updated_At'] is String) {
        lastUpdatedAt = DateTime.tryParse(map['Last_Updated_At']);
      }
    }

    return AboutPageModel(
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),
      title: AboutBilingualText(
        en: Versioned.read<String>(map['Title_En'], (v) => v?.toString() ?? ''),
        ar: Versioned.read<String>(map['Title_Ar'], (v) => v?.toString() ?? ''),
      ),
      svgUrl: Versioned.read<String>(map['Svg_Url'], (v) => v?.toString() ?? ''),
      navigationLabel: AboutNavigationLabel(
        iconUrl: Versioned.read<String>(map['Navigation_Label_Icon_Url'], (v) => v?.toString() ?? ''),
        title: AboutBilingualText(
          en: Versioned.read<String>(map['Navigation_Label_Title_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Navigation_Label_Title_Ar'], (v) => v?.toString() ?? ''),
        ),
      ),
      vision: AboutSection(
        iconUrl: Versioned.read<String>(map['Vision_Icon_Url'], (v) => v?.toString() ?? ''),
        svgUrl: Versioned.read<String>(map['Vision_Svg_Url'], (v) => v?.toString() ?? ''),
        subDescription: AboutBilingualText(
          en: Versioned.read<String>(map['Vision_Sub_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Vision_Sub_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(map['Vision_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Vision_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
      ),
      mission: AboutSection(
        iconUrl: Versioned.read<String>(map['Mission_Icon_Url'], (v) => v?.toString() ?? ''),
        svgUrl: Versioned.read<String>(map['Mission_Svg_Url'], (v) => v?.toString() ?? ''),
        subDescription: AboutBilingualText(
          en: Versioned.read<String>(map['Mission_Sub_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Mission_Sub_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(map['Mission_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Mission_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
      ),
      values: valueItems,
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'Publish_Status': publishStatus,
    'Title_En': title.en,
    'Title_Ar': title.ar,
    'Svg_Url': svgUrl,
    'Navigation_Label_Icon_Url':  navigationLabel.iconUrl,
    'Navigation_Label_Title_En':  navigationLabel.title.en,
    'Navigation_Label_Title_Ar':  navigationLabel.title.ar,
    'Vision_Icon_Url':            vision.iconUrl,
    'Vision_Svg_Url':             vision.svgUrl,
    'Vision_Sub_Description_En':  vision.subDescription.en,
    'Vision_Sub_Description_Ar':  vision.subDescription.ar,
    'Vision_Description_En':      vision.description.en,
    'Vision_Description_Ar':      vision.description.ar,
    'Mission_Icon_Url':           mission.iconUrl,
    'Mission_Svg_Url':            mission.svgUrl,
    'Mission_Sub_Description_En': mission.subDescription.en,
    'Mission_Sub_Description_Ar': mission.subDescription.ar,
    'Mission_Description_En':     mission.description.en,
    'Mission_Description_Ar':     mission.description.ar,
    'Values': values.map((v) => v.toMap()).toList(),
    'Last_Updated_At': DateTime.now().toIso8601String(),
  };

  AboutPageModel copyWith({
    String? publishStatus,
    AboutBilingualText? title,
    String? svgUrl,
    AboutNavigationLabel? navigationLabel,
    AboutSection? vision,
    AboutSection? mission,
    List<AboutValueItem>? values,
    DateTime? lastUpdatedAt,
  }) =>
      AboutPageModel(
        publishStatus: publishStatus ?? this.publishStatus,
        title: title ?? this.title,
        svgUrl: svgUrl ?? this.svgUrl,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        vision: vision ?? this.vision,
        mission: mission ?? this.mission,
        values: values ?? this.values,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DocUpload
// ─────────────────────────────────────────────────────────────────────────────

class DocUpload {
  final Uint8List bytes;
  final String fileName;
  const DocUpload({required this.bytes, required this.fileName});
}
