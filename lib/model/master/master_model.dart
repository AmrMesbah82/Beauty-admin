/// ******************* FILE INFO *******************
/// File Name: master_model.dart
/// Description: Data models for the Master CMS module.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026
/// UPDATED: Versioned helper added — all scalar/object fields are now read
///          from a versioned list in Firestore (last item = active value) ✅
/// UPDATED: Versioned.append() now has duplicate guard — only appends when
///          value actually changed, preventing duplicate history entries ✅

import 'package:cloud_firestore/cloud_firestore.dart';

// ── Bilingual text helper ────────────────────────────────────────────────────
class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  factory BiText.fromMap(Map<String, dynamic>? map) => BiText(
    en: map?['en'] ?? '',
    ar: map?['ar'] ?? '',
  );

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ─────────────────────────────────────────────────────────────────────────────
// Versioned Field Helper
// Wraps any Firestore field in a list for full history tracking.
//
//  • Versioned.read()   → always returns the LAST item (active value)
//  • Versioned.append() → called in the repo; merges new value into the list
//                         ONLY appends if the value actually changed
//
// The UI and cubit never see the list — they work with plain values as before.
// ─────────────────────────────────────────────────────────────────────────────

class Versioned {
  /// Reads the LAST item from a versioned list.
  /// Falls back gracefully if the field is still a legacy plain value.
  static T read<T>(dynamic raw, T Function(dynamic) parser) {
    if (raw is List && raw.isNotEmpty) {
      return parser(raw.last);
    }
    // legacy plain value (before versioning was introduced)
    if (raw != null) return parser(raw);
    return parser(null);
  }

  /// Appends [newValue] to [existing] ONLY if the value has actually changed.
  ///
  /// • If [existing] is null/empty  → creates a new list with [newValue].
  /// • If [existing] is a legacy plain value → migrates it into a list first.
  /// • If the last item equals [newValue] (by deep string comparison) →
  ///   returns the existing list unchanged (no duplicate entry).
  static List<dynamic> append(dynamic existing, dynamic newValue) {
    final history = <dynamic>[];

    if (existing is List) {
      history.addAll(existing);
    } else if (existing != null) {
      // migrate legacy plain value into the list automatically
      history.add(existing);
    }

    // ── Duplicate guard ───────────────────────────────────────────────────
    // Only append if the new value is actually different from the last entry.
    // This prevents duplicate entries when save() is called multiple times
    // with the same data (e.g. re-saves, retries, or publish-status triggers).
    if (history.isNotEmpty) {
      final lastEncoded = _encode(history.last);
      final newEncoded  = _encode(newValue);
      if (lastEncoded == newEncoded) {
        // value unchanged — return existing history without appending
        return history;
      }
    }

    history.add(newValue);
    return history;
  }

  /// Normalises any value to a stable comparable string so that maps, lists,
  /// and primitives can all be compared with == regardless of runtime type.
  /// Maps are key-sorted so insertion-order differences don't cause false mismatches.
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

  factory MasterSectionModel.fromMap(Map<String, dynamic> map,
      {String? docId}) =>
      MasterSectionModel(
        id:               docId ?? map['id'] ?? '',
        sectionKey:       map['sectionKey']   ?? '',
        title:            BiText.fromMap(map['title']),
        shortDescription: BiText.fromMap(map['shortDescription']),
        description:      BiText.fromMap(map['description']),
        imageUrl:         map['imageUrl']     ?? '',
        iconUrl:          map['iconUrl']      ?? '',
        textBoxColor:     map['textBoxColor'] ?? '#008037',
        visibility:       map['visibility']   ?? true,
        order:            map['order']        ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id':               id,
    'sectionKey':       sectionKey,
    'title':            title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'description':      description.toMap(),
    'imageUrl':         imageUrl,
    'iconUrl':          iconUrl,
    'textBoxColor':     textBoxColor,
    'visibility':       visibility,
    'order':            order,
  };

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

  factory MasterAppLinkModel.fromMap(Map<String, dynamic>? map) =>
      MasterAppLinkModel(
        appStoreLink:   map?['appStoreLink']   ?? '',
        googlePlayLink: map?['googlePlayLink'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'appStoreLink':   appStoreLink,
    'googlePlayLink': googlePlayLink,
  };

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

  factory MasterPublishScheduleModel.fromMap(Map<String, dynamic>? map) {
    DateTime? date;
    if (map?['publishDate'] != null) {
      if (map!['publishDate'] is Timestamp) {
        date = (map['publishDate'] as Timestamp).toDate();
      } else if (map['publishDate'] is String) {
        date = DateTime.tryParse(map['publishDate']);
      }
    }
    return MasterPublishScheduleModel(publishDate: date);
  }

  Map<String, dynamic> toMap() => {
    'publishDate':
    publishDate != null ? Timestamp.fromDate(publishDate!) : null,
  };

  MasterPublishScheduleModel copyWith({DateTime? publishDate}) =>
      MasterPublishScheduleModel(
          publishDate: publishDate ?? this.publishDate);
}

// ── Master Page Model (root document) ────────────────────────────────────────
//
// fromMap() uses Versioned.read() for scalar/object fields:
//   title | shortDescription | status | gender | appLinks |
//   publishSchedule | imageUrl
//
// sections (already a list of items) is NOT wrapped — it stays as-is.
// ─────────────────────────────────────────────────────────────────────────────
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
    const MasterSectionModel(id: 'header', sectionKey: 'header', order: 0),
    const MasterSectionModel(id: 'aboutUs', sectionKey: 'aboutUs', order: 1),
    const MasterSectionModel(id: 'footer',  sectionKey: 'footer',  order: 2),
  ];

  // ── fromMap — uses Versioned.read() for scalar/object fields ─────────────
  factory MasterPageModel.fromMap(Map<String, dynamic> map, {String? docId}) {

    // sections — plain list, not versioned at root level
    final rawSections = map['sections'] as List<dynamic>? ?? [];
    final sections = rawSections
        .map((e) => MasterSectionModel.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // lastUpdated — server timestamp, not versioned
    DateTime? lastUpdated;
    if (map['lastUpdated'] != null) {
      if (map['lastUpdated'] is Timestamp) {
        lastUpdated = (map['lastUpdated'] as Timestamp).toDate();
      }
    }

    return MasterPageModel(
      id: docId ?? map['id'] ?? '',

      // ── versioned scalar / object fields ─────────────────────────────
      title: Versioned.read<BiText>(
        map['title'],
            (v) => BiText.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      shortDescription: Versioned.read<BiText>(
        map['shortDescription'],
            (v) => BiText.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      status: Versioned.read<String>(
        map['status'],
            (v) => v?.toString() ?? 'draft',
      ),

      gender: Versioned.read<String>(
        map['gender'],
            (v) => v?.toString() ?? 'female',
      ),

      appLinks: Versioned.read<MasterAppLinkModel>(
        map['appLinks'],
            (v) => MasterAppLinkModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      publishSchedule: Versioned.read<MasterPublishScheduleModel>(
        map['publishSchedule'],
            (v) => MasterPublishScheduleModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      imageUrl: Versioned.read<String>(
        map['imageUrl'],
            (v) => v?.toString() ?? '',
      ),

      // ── plain fields ──────────────────────────────────────────────────
      sections:    sections.isEmpty ? defaultSections() : sections,
      lastUpdated: lastUpdated,
    );
  }

  // ── toMap — plain values (versioning handled in repo layer) ──────────────
  Map<String, dynamic> toMap() => {
    'id':               id,
    'title':            title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'status':           status,
    'gender':           gender,
    'sections':         sections.map((s) => s.toMap()).toList(),
    'appLinks':         appLinks.toMap(),
    'publishSchedule':  publishSchedule.toMap(),
    'lastUpdated':
    lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    'imageUrl':         imageUrl,
  };

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