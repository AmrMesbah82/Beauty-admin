// ******************* FILE INFO *******************
// File Name: about_us.dart  (model)
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: ALL fields are now versioned — every field in Firestore is stored
//          as a list for full history tracking. fromMap() uses Versioned.read()
//          for every field. toMap() writes plain values (repo handles versioning).

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

class AboutBilingualText {
  final String en;
  final String ar;

  const AboutBilingualText({this.en = '', this.ar = ''});

  factory AboutBilingualText.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AboutBilingualText();
    return AboutBilingualText(
      en: (map['en'] as String?) ?? '',
      ar: (map['ar'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  AboutBilingualText copyWith({String? en, String? ar}) =>
      AboutBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ── Navigation Label ──────────────────────────────────────────────────────────

class AboutNavigationLabel {
  final String iconUrl;
  final AboutBilingualText title;

  const AboutNavigationLabel({
    this.iconUrl = '',
    this.title = const AboutBilingualText(),
  });

  factory AboutNavigationLabel.empty() => const AboutNavigationLabel();

  factory AboutNavigationLabel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AboutNavigationLabel();
    return AboutNavigationLabel(
      iconUrl: (map['iconUrl'] as String?) ?? '',
      title: AboutBilingualText.fromMap(map['title'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'iconUrl': iconUrl,
    'title': title.toMap(),
  };

  AboutNavigationLabel copyWith({
    String? iconUrl,
    AboutBilingualText? title,
  }) =>
      AboutNavigationLabel(
        iconUrl: iconUrl ?? this.iconUrl,
        title: title ?? this.title,
      );
}

// ── Values item ───────────────────────────────────────────────────────────────

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
    id: (map['id'] as String?) ?? '',
    iconUrl: (map['iconUrl'] as String?) ?? '',
    title:
    AboutBilingualText.fromMap(map['title'] as Map<String, dynamic>?),
    shortDescription: AboutBilingualText.fromMap(
        map['shortDescription'] as Map<String, dynamic>?),
    description: AboutBilingualText.fromMap(
        map['description'] as Map<String, dynamic>?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'iconUrl': iconUrl,
    'title': title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'description': description.toMap(),
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

// ── Section (Vision / Mission) ────────────────────────────────────────────────

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

  factory AboutSection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AboutSection();
    return AboutSection(
      iconUrl: (map['iconUrl'] as String?) ?? '',
      svgUrl: (map['svgUrl'] as String?) ?? '',
      subDescription: AboutBilingualText.fromMap(
          map['subDescription'] as Map<String, dynamic>?),
      description: AboutBilingualText.fromMap(
          map['description'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'iconUrl': iconUrl,
    'svgUrl': svgUrl,
    'subDescription': subDescription.toMap(),
    'description': description.toMap(),
  };

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

// ── About Us Main model — ALL fields versioned ───────────────────────────────

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

  // ── fromMap — ALL fields use Versioned.read() ────────────────────────────
  factory AboutPageModel.fromMap(Map<String, dynamic> map) {
    return AboutPageModel(
      publishStatus: Versioned.read<String>(
        map['publishStatus'],
            (v) => v?.toString() ?? 'draft',
      ),

      title: Versioned.read<AboutBilingualText>(
        map['title'],
            (v) => AboutBilingualText.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      svgUrl: Versioned.read<String>(
        map['svgUrl'],
            (v) => v?.toString() ?? '',
      ),

      navigationLabel: Versioned.read<AboutNavigationLabel>(
        map['navigationLabel'],
            (v) => AboutNavigationLabel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      vision: Versioned.read<AboutSection>(
        map['vision'],
            (v) => AboutSection.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      mission: Versioned.read<AboutSection>(
        map['mission'],
            (v) => AboutSection.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      values: Versioned.readList<AboutValueItem>(
        map['values'],
            (e) => AboutValueItem.fromMap(
            e is Map ? Map<String, dynamic>.from(e) : {}),
      ),

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

  // ── toMap — plain values (versioning handled in repo layer) ──────────────
  Map<String, dynamic> toMap() => {
    'publishStatus': publishStatus,
    'title': title.toMap(),
    'svgUrl': svgUrl,
    'navigationLabel': navigationLabel.toMap(),
    'vision': vision.toMap(),
    'mission': mission.toMap(),
    'values': values.map((v) => v.toMap()).toList(),
    'lastUpdatedAt': DateTime.now().toIso8601String(),
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

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY MODEL — ALL fields versioned
// ═══════════════════════════════════════════════════════════════════════════════

class StrategySection {
  final String svgUrl;
  final AboutBilingualText description;

  const StrategySection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
  });

  factory StrategySection.empty() => const StrategySection();

  factory StrategySection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StrategySection();
    return StrategySection(
      svgUrl: (map['svgUrl'] as String?) ?? '',
      description: AboutBilingualText.fromMap(
          map['description'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'description': description.toMap(),
  };

  StrategySection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
  }) =>
      StrategySection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
      );
}

class OurStrategyModel {
  final String publishStatus;
  final AboutNavigationLabel navigationLabel;
  final StrategySection vision;
  final String strategicHouseEnUrl;
  final String strategicHouseArUrl;
  final DateTime? lastUpdatedAt;

  const OurStrategyModel({
    this.publishStatus = 'draft',
    this.navigationLabel = const AboutNavigationLabel(),
    this.vision = const StrategySection(),
    this.strategicHouseEnUrl = '',
    this.strategicHouseArUrl = '',
    this.lastUpdatedAt,
  });

  factory OurStrategyModel.empty() => const OurStrategyModel();

  // ── fromMap — ALL fields use Versioned.read() ────────────────────────────
  factory OurStrategyModel.fromMap(Map<String, dynamic> map) =>
      OurStrategyModel(
        publishStatus: Versioned.read<String>(
          map['publishStatus'],
              (v) => v?.toString() ?? 'draft',
        ),

        navigationLabel: Versioned.read<AboutNavigationLabel>(
          map['navigationLabel'],
              (v) => AboutNavigationLabel.fromMap(
              v is Map ? Map<String, dynamic>.from(v) : null),
        ),

        vision: Versioned.read<StrategySection>(
          map['vision'],
              (v) => StrategySection.fromMap(
              v is Map ? Map<String, dynamic>.from(v) : null),
        ),

        strategicHouseEnUrl: Versioned.read<String>(
          map['strategicHouseEnUrl'],
              (v) => v?.toString() ?? '',
        ),

        strategicHouseArUrl: Versioned.read<String>(
          map['strategicHouseArUrl'],
              (v) => v?.toString() ?? '',
        ),

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

  // ── toMap — plain values (versioning handled in repo layer) ──────────────
  Map<String, dynamic> toMap() => {
    'publishStatus': publishStatus,
    'navigationLabel': navigationLabel.toMap(),
    'vision': vision.toMap(),
    'strategicHouseEnUrl': strategicHouseEnUrl,
    'strategicHouseArUrl': strategicHouseArUrl,
  };

  OurStrategyModel copyWith({
    String? publishStatus,
    AboutNavigationLabel? navigationLabel,
    StrategySection? vision,
    String? strategicHouseEnUrl,
    String? strategicHouseArUrl,
    DateTime? lastUpdatedAt,
  }) =>
      OurStrategyModel(
        publishStatus: publishStatus ?? this.publishStatus,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        vision: vision ?? this.vision,
        strategicHouseEnUrl: strategicHouseEnUrl ?? this.strategicHouseEnUrl,
        strategicHouseArUrl: strategicHouseArUrl ?? this.strategicHouseArUrl,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS OF SERVICE MODEL — ALL fields versioned
// ═══════════════════════════════════════════════════════════════════════════════

class TermsSection {
  final String svgUrl;
  final AboutBilingualText description;
  final String attachEnUrl;
  final String attachArUrl;
  final String? lastUpdate;

  const TermsSection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
    this.attachEnUrl = '',
    this.attachArUrl = '',
    this.lastUpdate,
  });

  factory TermsSection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TermsSection();
    return TermsSection(
      svgUrl: (map['svgUrl'] as String?) ?? '',
      description: AboutBilingualText.fromMap(map['description'] as Map<String, dynamic>?),
      attachEnUrl: (map['attachEnUrl'] as String?) ?? '',
      attachArUrl: (map['attachArUrl'] as String?) ?? '',
      lastUpdate: map['lastUpdate'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'description': description.toMap(),
    'attachEnUrl': attachEnUrl,
    'attachArUrl': attachArUrl,
    if (lastUpdate != null) 'lastUpdate': lastUpdate,
  };

  TermsSection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
    String? attachEnUrl,
    String? attachArUrl,
    String? lastUpdate,
  }) =>
      TermsSection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
        attachEnUrl: attachEnUrl ?? this.attachEnUrl,
        attachArUrl: attachArUrl ?? this.attachArUrl,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}

class TermsOfServiceModel {
  final String publishStatus;
  final AboutNavigationLabel navigationLabel;
  final TermsSection termsAndConditions;
  final TermsSection privacyPolicy;
  final DateTime? lastUpdatedAt;

  const TermsOfServiceModel({
    this.publishStatus = 'draft',
    this.navigationLabel = const AboutNavigationLabel(),
    this.termsAndConditions = const TermsSection(),
    this.privacyPolicy = const TermsSection(),
    this.lastUpdatedAt,
  });

  factory TermsOfServiceModel.empty() => const TermsOfServiceModel();

  // ── fromMap — ALL fields use Versioned.read() ────────────────────────────
  factory TermsOfServiceModel.fromMap(Map<String, dynamic> map) =>
      TermsOfServiceModel(
        publishStatus: Versioned.read<String>(
          map['publishStatus'],
              (v) => v?.toString() ?? 'draft',
        ),

        navigationLabel: Versioned.read<AboutNavigationLabel>(
          map['navigationLabel'],
              (v) => AboutNavigationLabel.fromMap(
              v is Map ? Map<String, dynamic>.from(v) : null),
        ),

        termsAndConditions: Versioned.read<TermsSection>(
          map['termsAndConditions'],
              (v) => TermsSection.fromMap(
              v is Map ? Map<String, dynamic>.from(v) : null),
        ),

        privacyPolicy: Versioned.read<TermsSection>(
          map['privacyPolicy'],
              (v) => TermsSection.fromMap(
              v is Map ? Map<String, dynamic>.from(v) : null),
        ),

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

  // ── toMap — plain values (versioning handled in repo layer) ──────────────
  Map<String, dynamic> toMap() => {
    'publishStatus': publishStatus,
    'navigationLabel': navigationLabel.toMap(),
    'termsAndConditions': termsAndConditions.toMap(),
    'privacyPolicy': privacyPolicy.toMap(),
  };

  TermsOfServiceModel copyWith({
    String? publishStatus,
    AboutNavigationLabel? navigationLabel,
    TermsSection? termsAndConditions,
    TermsSection? privacyPolicy,
    DateTime? lastUpdatedAt,
  }) =>
      TermsOfServiceModel(
        publishStatus: publishStatus ?? this.publishStatus,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        termsAndConditions: termsAndConditions ?? this.termsAndConditions,
        privacyPolicy: privacyPolicy ?? this.privacyPolicy,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
}

class DocUpload {
  final Uint8List bytes;
  final String fileName;
  const DocUpload({required this.bytes, required this.fileName});
}