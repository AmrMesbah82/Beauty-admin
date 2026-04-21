/// ******************* FILE INFO *******************
/// File Name: master_model.dart
/// Description: Data models for the Master CMS module.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: Sections flattened into indexed root-level keys ✅
/// UPDATED: EVERY single field is versioned (array in Firestore,
///          .last = active value). fromMap uses Versioned.read() on ALL. ✅

import 'package:cloud_firestore/cloud_firestore.dart';

// ── Bilingual text helper ────────────────────────────────────────────────────
class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ─────────────────────────────────────────────────────────────────────────────
// Versioned Field Helper
// ─────────────────────────────────────────────────────────────────────────────

class Versioned {
  static T read<T>(dynamic raw, T Function(dynamic) parser) {
    if (raw is List && raw.isNotEmpty) {
      return parser(raw.last);
    }
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
      if (lastEncoded == newEncoded) {
        return history;
      }
    }

    history.add(newValue);
    return history;
  }

  static String _encode(dynamic value) {
    if (value == null) return 'null';
    if (value is Map) {
      final sorted = Map.fromEntries(
        (value.entries.toList()
          ..sort((a, b) =>
              a.key.toString().compareTo(b.key.toString())))
            .map((e) => MapEntry(e.key.toString(), _encode(e.value))),
      );
      return sorted.toString();
    }
    if (value is List) return value.map(_encode).toList().toString();
    return value.toString();
  }
}

// ── Section Model (Header / About Us / Footer) ──────────────────────────────
class MasterSectionModel {
  final String id;
  final String sectionKey;
  final BiText title;
  final BiText shortDescription;
  final BiText description;
  final String imageUrl;
  final String iconUrl;
  final String textBoxColor;
  final bool   visibility;
  final int    order;

  const MasterSectionModel({
    this.id               = '',
    this.sectionKey       = '',
    this.title            = const BiText(),
    this.shortDescription = const BiText(),
    this.description      = const BiText(),
    this.imageUrl         = '',
    this.iconUrl          = '',
    this.textBoxColor     = '#008037',
    this.visibility       = true,
    this.order            = 0,
  });

  MasterSectionModel copyWith({
    String? id,
    String? sectionKey,
    BiText? title,
    BiText? shortDescription,
    BiText? description,
    String? imageUrl,
    String? iconUrl,
    String? textBoxColor,
    bool?   visibility,
    int?    order,
  }) =>
      MasterSectionModel(
        id:               id               ?? this.id,
        sectionKey:       sectionKey       ?? this.sectionKey,
        title:            title            ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        description:      description      ?? this.description,
        imageUrl:         imageUrl         ?? this.imageUrl,
        iconUrl:          iconUrl          ?? this.iconUrl,
        textBoxColor:     textBoxColor     ?? this.textBoxColor,
        visibility:       visibility       ?? this.visibility,
        order:            order            ?? this.order,
      );
}

// ── App Link Model (Google Play / App Store) ─────────────────────────────────
class MasterAppLinkModel {
  final String appStoreLink;
  final String googlePlayLink;

  const MasterAppLinkModel({
    this.appStoreLink   = '',
    this.googlePlayLink = '',
  });

  MasterAppLinkModel copyWith({
    String? appStoreLink,
    String? googlePlayLink,
  }) =>
      MasterAppLinkModel(
        appStoreLink:   appStoreLink   ?? this.appStoreLink,
        googlePlayLink: googlePlayLink ?? this.googlePlayLink,
      );
}

// ── Publish Schedule Model ───────────────────────────────────────────────────
class MasterPublishScheduleModel {
  final DateTime? publishDate;

  const MasterPublishScheduleModel({this.publishDate});

  MasterPublishScheduleModel copyWith({DateTime? publishDate}) =>
      MasterPublishScheduleModel(
          publishDate: publishDate ?? this.publishDate);
}

// ── Master Page Model (root document) ────────────────────────────────────────
class MasterPageModel {
  final String                     id;
  final BiText                     title;
  final BiText                     shortDescription;
  final String                     status;
  final String                     gender;
  final List<MasterSectionModel>   sections;
  final MasterAppLinkModel         appLinks;
  final MasterPublishScheduleModel publishSchedule;
  final DateTime?                  lastUpdated;
  final String                     imageUrl;

  const MasterPageModel({
    this.id               = '',
    this.title            = const BiText(),
    this.shortDescription = const BiText(),
    this.status           = 'draft',
    this.gender           = 'female',
    this.sections         = const [],
    this.appLinks         = const MasterAppLinkModel(),
    this.publishSchedule  = const MasterPublishScheduleModel(),
    this.lastUpdated,
    this.imageUrl         = '',
  });

  /// Default sections for a new master page
  static List<MasterSectionModel> defaultSections() => [
    const MasterSectionModel(id: 'header',  sectionKey: 'header',  order: 0),
    const MasterSectionModel(id: 'aboutUs', sectionKey: 'aboutUs', order: 1),
    const MasterSectionModel(id: 'footer',  sectionKey: 'footer',  order: 2),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // toMap — ALL fields flattened, Capital_Underscore naming
  // Outputs plain primitives. Repo wraps EVERY key in Versioned.append().
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // ── Id ───────────────────────────────────────────────────────────
    map['Id'] = id;

    // ── Title ────────────────────────────────────────────────────────
    map['Title_En'] = title.en;
    map['Title_Ar'] = title.ar;

    // ── Short Description ────────────────────────────────────────────
    map['Short_Description_En'] = shortDescription.en;
    map['Short_Description_Ar'] = shortDescription.ar;

    // ── Scalars ──────────────────────────────────────────────────────
    map['Status']    = status;
    map['Gender']    = gender;
    map['Image_Url'] = imageUrl;

    // ── Sections (flattened) ─────────────────────────────────────────
    map['Sections_Count'] = sections.length;
    for (int i = 0; i < sections.length; i++) {
      final s = sections[i];
      map['Sections_${i}_Id']                   = s.id;
      map['Sections_${i}_Section_Key']          = s.sectionKey;
      map['Sections_${i}_Title_En']             = s.title.en;
      map['Sections_${i}_Title_Ar']             = s.title.ar;
      map['Sections_${i}_Short_Description_En'] = s.shortDescription.en;
      map['Sections_${i}_Short_Description_Ar'] = s.shortDescription.ar;
      map['Sections_${i}_Description_En']       = s.description.en;
      map['Sections_${i}_Description_Ar']       = s.description.ar;
      map['Sections_${i}_Image_Url']            = s.imageUrl;
      map['Sections_${i}_Icon_Url']             = s.iconUrl;
      map['Sections_${i}_Text_Box_Color']       = s.textBoxColor;
      map['Sections_${i}_Visibility']           = s.visibility;
      map['Sections_${i}_Order']                = s.order;
    }

    // ── App Links (flattened) ────────────────────────────────────────
    map['App_Links_App_Store_Link']   = appLinks.appStoreLink;
    map['App_Links_Google_Play_Link'] = appLinks.googlePlayLink;

    // ── Publish Schedule (flattened) ─────────────────────────────────
    map['Publish_Schedule_Publish_Date'] = publishSchedule.publishDate != null
        ? Timestamp.fromDate(publishSchedule.publishDate!)
        : null;

    // ── Last Updated ─────────────────────────────────────────────────
    map['Last_Updated'] = lastUpdated != null
        ? Timestamp.fromDate(lastUpdated!)
        : null;

    return map;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // fromMap — EVERY field uses Versioned.read()
  //
  // In Firestore each key is an array: [v0, v1, v2, ...]
  // Versioned.read() picks .last as active value.
  // ═══════════════════════════════════════════════════════════════════════════

  factory MasterPageModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    // ── Sections (flattened, each field versioned) ────────────────────
    final sCount = Versioned.read<int>(
      map['Sections_Count'], (v) => (v as int?) ?? 0,
    );
    final sections = <MasterSectionModel>[];
    for (int i = 0; i < sCount; i++) {
      sections.add(MasterSectionModel(
        id: Versioned.read<String>(
          map['Sections_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        sectionKey: Versioned.read<String>(
          map['Sections_${i}_Section_Key'], (v) => v?.toString() ?? '',
        ),
        title: BiText(
          en: Versioned.read<String>(
            map['Sections_${i}_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Sections_${i}_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        shortDescription: BiText(
          en: Versioned.read<String>(
            map['Sections_${i}_Short_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Sections_${i}_Short_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        description: BiText(
          en: Versioned.read<String>(
            map['Sections_${i}_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Sections_${i}_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        imageUrl: Versioned.read<String>(
          map['Sections_${i}_Image_Url'], (v) => v?.toString() ?? '',
        ),
        iconUrl: Versioned.read<String>(
          map['Sections_${i}_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        textBoxColor: Versioned.read<String>(
          map['Sections_${i}_Text_Box_Color'], (v) => v?.toString() ?? '#008037',
        ),
        visibility: Versioned.read<bool>(
          map['Sections_${i}_Visibility'], (v) => v as bool? ?? true,
        ),
        order: Versioned.read<int>(
          map['Sections_${i}_Order'], (v) => (v as int?) ?? i,
        ),
      ));
    }
    sections.sort((a, b) => a.order.compareTo(b.order));

    // ── Last Updated (server timestamp, not versioned) ───────────────
    DateTime? lastUpdated;
    if (map['Last_Updated'] != null) {
      if (map['Last_Updated'] is Timestamp) {
        lastUpdated = (map['Last_Updated'] as Timestamp).toDate();
      }
    }

    return MasterPageModel(
      id: docId ?? Versioned.read<String>(
        map['Id'], (v) => v?.toString() ?? '',
      ),

      // ── Title ──────────────────────────────────────────────────────
      title: BiText(
        en: Versioned.read<String>(
          map['Title_En'], (v) => v?.toString() ?? '',
        ),
        ar: Versioned.read<String>(
          map['Title_Ar'], (v) => v?.toString() ?? '',
        ),
      ),

      // ── Short Description ──────────────────────────────────────────
      shortDescription: BiText(
        en: Versioned.read<String>(
          map['Short_Description_En'], (v) => v?.toString() ?? '',
        ),
        ar: Versioned.read<String>(
          map['Short_Description_Ar'], (v) => v?.toString() ?? '',
        ),
      ),

      // ── Scalars ────────────────────────────────────────────────────
      status: Versioned.read<String>(
        map['Status'], (v) => v?.toString() ?? 'draft',
      ),
      gender: Versioned.read<String>(
        map['Gender'], (v) => v?.toString() ?? 'female',
      ),
      imageUrl: Versioned.read<String>(
        map['Image_Url'], (v) => v?.toString() ?? '',
      ),

      // ── App Links ──────────────────────────────────────────────────
      appLinks: MasterAppLinkModel(
        appStoreLink: Versioned.read<String>(
          map['App_Links_App_Store_Link'], (v) => v?.toString() ?? '',
        ),
        googlePlayLink: Versioned.read<String>(
          map['App_Links_Google_Play_Link'], (v) => v?.toString() ?? '',
        ),
      ),

      // ── Publish Schedule ───────────────────────────────────────────
      publishSchedule: MasterPublishScheduleModel(
        publishDate: Versioned.read<DateTime?>(
          map['Publish_Schedule_Publish_Date'],
              (v) {
            if (v == null) return null;
            if (v is Timestamp) return v.toDate();
            if (v is String) return DateTime.tryParse(v);
            return null;
          },
        ),
      ),

      // ── Lists & plain ──────────────────────────────────────────────
      sections:    sections.isEmpty ? defaultSections() : sections,
      lastUpdated: lastUpdated,
    );
  }

  MasterPageModel copyWith({
    String?                     id,
    BiText?                     title,
    BiText?                     shortDescription,
    String?                     status,
    String?                     gender,
    List<MasterSectionModel>?   sections,
    MasterAppLinkModel?         appLinks,
    MasterPublishScheduleModel? publishSchedule,
    DateTime?                   lastUpdated,
    String?                     imageUrl,
  }) =>
      MasterPageModel(
        id:               id               ?? this.id,
        title:            title            ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        status:           status           ?? this.status,
        gender:           gender           ?? this.gender,
        sections:         sections         ?? this.sections,
        appLinks:         appLinks         ?? this.appLinks,
        publishSchedule:  publishSchedule  ?? this.publishSchedule,
        lastUpdated:      lastUpdated      ?? this.lastUpdated,
        imageUrl:         imageUrl         ?? this.imageUrl,
      );

  /// Helper to get a section by key
  MasterSectionModel? sectionByKey(String key) {
    try {
      return sections.firstWhere((s) => s.sectionKey == key);
    } catch (_) {
      return null;
    }
  }
}