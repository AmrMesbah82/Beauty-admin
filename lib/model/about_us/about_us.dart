// ******************* FILE INFO *******************
// File Name: about_us.dart  (model)
// Created by: Amr Mesbah
// Last Update: 18/04/2026
// UPDATED: All field names use Capital_Underscore naming convention ✅
// UPDATED: All nested maps (AboutBilingualText, AboutNavigationLabel,
//          AboutSection, StrategySection, TermsSection) flattened ✅
// UPDATED: ALL fields versioned — fromMap() uses Versioned.read() ✅

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

  // ── fromMap — ALL fields flattened, Capital_Underscore keys ───────────────
  factory AboutPageModel.fromMap(Map<String, dynamic> map) {

    // ── Values (plain list) ─────────────────────────────────────────────
    final rawValues = map['Values'] as List<dynamic>? ?? [];
    final valueItems = rawValues
        .map((e) => AboutValueItem.fromMap(e as Map<String, dynamic>))
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

    return AboutPageModel(
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),

      // ── Title (flattened) ─────────────────────────────────────────────
      title: AboutBilingualText(
        en: Versioned.read<String>(
          map['Title_En'], (v) => v?.toString() ?? '',
        ),
        ar: Versioned.read<String>(
          map['Title_Ar'], (v) => v?.toString() ?? '',
        ),
      ),

      svgUrl: Versioned.read<String>(
        map['Svg_Url'], (v) => v?.toString() ?? '',
      ),

      // ── Navigation Label (flattened) ──────────────────────────────────
      navigationLabel: AboutNavigationLabel(
        iconUrl: Versioned.read<String>(
          map['Navigation_Label_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        title: AboutBilingualText(
          en: Versioned.read<String>(
            map['Navigation_Label_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Navigation_Label_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      // ── Vision (flattened) ────────────────────────────────────────────
      vision: AboutSection(
        iconUrl: Versioned.read<String>(
          map['Vision_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        svgUrl: Versioned.read<String>(
          map['Vision_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        subDescription: AboutBilingualText(
          en: Versioned.read<String>(
            map['Vision_Sub_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Vision_Sub_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(
            map['Vision_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Vision_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      // ── Mission (flattened) ───────────────────────────────────────────
      mission: AboutSection(
        iconUrl: Versioned.read<String>(
          map['Mission_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        svgUrl: Versioned.read<String>(
          map['Mission_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        subDescription: AboutBilingualText(
          en: Versioned.read<String>(
            map['Mission_Sub_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Mission_Sub_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(
            map['Mission_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Mission_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      values: valueItems,
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  // ── toMap — ALL fields flattened, Capital_Underscore naming ───────────────
  Map<String, dynamic> toMap() => {
    'Publish_Status': publishStatus,

    // ── Title (flattened) ────────────────────────────────────────────
    'Title_En': title.en,
    'Title_Ar': title.ar,

    'Svg_Url': svgUrl,

    // ── Navigation Label (flattened) ─────────────────────────────────
    'Navigation_Label_Icon_Url':  navigationLabel.iconUrl,
    'Navigation_Label_Title_En':  navigationLabel.title.en,
    'Navigation_Label_Title_Ar':  navigationLabel.title.ar,

    // ── Vision (flattened) ───────────────────────────────────────────
    'Vision_Icon_Url':            vision.iconUrl,
    'Vision_Svg_Url':             vision.svgUrl,
    'Vision_Sub_Description_En':  vision.subDescription.en,
    'Vision_Sub_Description_Ar':  vision.subDescription.ar,
    'Vision_Description_En':      vision.description.en,
    'Vision_Description_Ar':      vision.description.ar,

    // ── Mission (flattened) ──────────────────────────────────────────
    'Mission_Icon_Url':           mission.iconUrl,
    'Mission_Svg_Url':            mission.svgUrl,
    'Mission_Sub_Description_En': mission.subDescription.en,
    'Mission_Sub_Description_Ar': mission.subDescription.ar,
    'Mission_Description_En':     mission.description.en,
    'Mission_Description_Ar':     mission.description.ar,

    // ── Values (list) ────────────────────────────────────────────────
    'Values': values.map((v) => v.toMap()).toList(),

    // ── Last Updated ─────────────────────────────────────────────────
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

// ═══════════════════════════════════════════════════════════════════════════════
// STRATEGY SECTION — flattened into OurStrategyModel (no standalone toMap)
// ═══════════════════════════════════════════════════════════════════════════════

class StrategySection {
  final String svgUrl;
  final AboutBilingualText description;

  const StrategySection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
  });

  factory StrategySection.empty() => const StrategySection();

  StrategySection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
  }) =>
      StrategySection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════

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

  // ── fromMap — ALL fields flattened, Capital_Underscore keys ───────────────
  factory OurStrategyModel.fromMap(Map<String, dynamic> map) {

    DateTime? lastUpdatedAt;
    if (map['Last_Updated_At'] != null) {
      if (map['Last_Updated_At'] is Timestamp) {
        lastUpdatedAt = (map['Last_Updated_At'] as Timestamp).toDate();
      } else if (map['Last_Updated_At'] is String) {
        lastUpdatedAt = DateTime.tryParse(map['Last_Updated_At']);
      }
    }

    return OurStrategyModel(
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),

      // ── Navigation Label (flattened) ──────────────────────────────────
      navigationLabel: AboutNavigationLabel(
        iconUrl: Versioned.read<String>(
          map['Navigation_Label_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        title: AboutBilingualText(
          en: Versioned.read<String>(
            map['Navigation_Label_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Navigation_Label_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      // ── Vision (flattened) ────────────────────────────────────────────
      vision: StrategySection(
        svgUrl: Versioned.read<String>(
          map['Vision_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(
            map['Vision_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Vision_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      strategicHouseEnUrl: Versioned.read<String>(
        map['Strategic_House_En_Url'], (v) => v?.toString() ?? '',
      ),
      strategicHouseArUrl: Versioned.read<String>(
        map['Strategic_House_Ar_Url'], (v) => v?.toString() ?? '',
      ),

      lastUpdatedAt: lastUpdatedAt,
    );
  }

  // ── toMap — ALL fields flattened, Capital_Underscore naming ───────────────
  Map<String, dynamic> toMap() => {
    'Publish_Status': publishStatus,

    // ── Navigation Label (flattened) ─────────────────────────────────
    'Navigation_Label_Icon_Url': navigationLabel.iconUrl,
    'Navigation_Label_Title_En': navigationLabel.title.en,
    'Navigation_Label_Title_Ar': navigationLabel.title.ar,

    // ── Vision (flattened) ───────────────────────────────────────────
    'Vision_Svg_Url':        vision.svgUrl,
    'Vision_Description_En': vision.description.en,
    'Vision_Description_Ar': vision.description.ar,

    'Strategic_House_En_Url': strategicHouseEnUrl,
    'Strategic_House_Ar_Url': strategicHouseArUrl,
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
// TERMS SECTION — flattened into TermsOfServiceModel (no standalone toMap)
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

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS OF SERVICE MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════

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

  // ── fromMap — ALL fields flattened, Capital_Underscore keys ───────────────
  factory TermsOfServiceModel.fromMap(Map<String, dynamic> map) {

    DateTime? lastUpdatedAt;
    if (map['Last_Updated_At'] != null) {
      if (map['Last_Updated_At'] is Timestamp) {
        lastUpdatedAt = (map['Last_Updated_At'] as Timestamp).toDate();
      } else if (map['Last_Updated_At'] is String) {
        lastUpdatedAt = DateTime.tryParse(map['Last_Updated_At']);
      }
    }

    return TermsOfServiceModel(
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),

      // ── Navigation Label (flattened) ──────────────────────────────────
      navigationLabel: AboutNavigationLabel(
        iconUrl: Versioned.read<String>(
          map['Navigation_Label_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        title: AboutBilingualText(
          en: Versioned.read<String>(
            map['Navigation_Label_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Navigation_Label_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      // ── Terms And Conditions (flattened) ──────────────────────────────
      termsAndConditions: TermsSection(
        svgUrl: Versioned.read<String>(
          map['Terms_And_Conditions_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(
            map['Terms_And_Conditions_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Terms_And_Conditions_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        attachEnUrl: Versioned.read<String>(
          map['Terms_And_Conditions_Attach_En_Url'], (v) => v?.toString() ?? '',
        ),
        attachArUrl: Versioned.read<String>(
          map['Terms_And_Conditions_Attach_Ar_Url'], (v) => v?.toString() ?? '',
        ),
        lastUpdate: Versioned.read<String?>(
          map['Terms_And_Conditions_Last_Update'], (v) => v?.toString(),
        ),
      ),

      // ── Privacy Policy (flattened) ────────────────────────────────────
      privacyPolicy: TermsSection(
        svgUrl: Versioned.read<String>(
          map['Privacy_Policy_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        description: AboutBilingualText(
          en: Versioned.read<String>(
            map['Privacy_Policy_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Privacy_Policy_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        attachEnUrl: Versioned.read<String>(
          map['Privacy_Policy_Attach_En_Url'], (v) => v?.toString() ?? '',
        ),
        attachArUrl: Versioned.read<String>(
          map['Privacy_Policy_Attach_Ar_Url'], (v) => v?.toString() ?? '',
        ),
        lastUpdate: Versioned.read<String?>(
          map['Privacy_Policy_Last_Update'], (v) => v?.toString(),
        ),
      ),

      lastUpdatedAt: lastUpdatedAt,
    );
  }

  // ── toMap — ALL fields flattened, Capital_Underscore naming ───────────────
  Map<String, dynamic> toMap() => {
    'Publish_Status': publishStatus,

    // ── Navigation Label (flattened) ─────────────────────────────────
    'Navigation_Label_Icon_Url': navigationLabel.iconUrl,
    'Navigation_Label_Title_En': navigationLabel.title.en,
    'Navigation_Label_Title_Ar': navigationLabel.title.ar,

    // ── Terms And Conditions (flattened) ─────────────────────────────
    'Terms_And_Conditions_Svg_Url':        termsAndConditions.svgUrl,
    'Terms_And_Conditions_Description_En': termsAndConditions.description.en,
    'Terms_And_Conditions_Description_Ar': termsAndConditions.description.ar,
    'Terms_And_Conditions_Attach_En_Url':  termsAndConditions.attachEnUrl,
    'Terms_And_Conditions_Attach_Ar_Url':  termsAndConditions.attachArUrl,
    if (termsAndConditions.lastUpdate != null)
      'Terms_And_Conditions_Last_Update':  termsAndConditions.lastUpdate,

    // ── Privacy Policy (flattened) ───────────────────────────────────
    'Privacy_Policy_Svg_Url':        privacyPolicy.svgUrl,
    'Privacy_Policy_Description_En': privacyPolicy.description.en,
    'Privacy_Policy_Description_Ar': privacyPolicy.description.ar,
    'Privacy_Policy_Attach_En_Url':  privacyPolicy.attachEnUrl,
    'Privacy_Policy_Attach_Ar_Url':  privacyPolicy.attachArUrl,
    if (privacyPolicy.lastUpdate != null)
      'Privacy_Policy_Last_Update':  privacyPolicy.lastUpdate,
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