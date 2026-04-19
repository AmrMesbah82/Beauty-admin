/// ******************* FILE INFO *******************
/// File Name: owner_services_model.dart
/// Description: Data models for the Owner Services CMS module.
///              Sections: Header (SVG + Title + Description),
///              Download Applications (Title + Apple/Android links),
///              Mockups (repeating: SVG + Alignment + Title + Description),
///              Publish Schedule (date).
/// Created by: Amr Mesbah
/// Last Update: 18/04/2026
/// UPDATED: ALL fields are now versioned — every field in Firestore is stored
///          as a list for full history tracking. fromMap() uses Versioned.read()
///          for every field. toMap() writes plain values (repo handles versioning).

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

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesHeaderModel {
  final String imageUrl;
  final BiText title;
  final BiText description;

  const OwnerServicesHeaderModel({
    this.imageUrl = '',
    this.title = const BiText(),
    this.description = const BiText(),
  });

  factory OwnerServicesHeaderModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OwnerServicesHeaderModel();
    return OwnerServicesHeaderModel(
      imageUrl: map['imageUrl'] ?? '',
      title: BiText.fromMap(map['title']),
      description: BiText.fromMap(map['description']),
    );
  }

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'title': title.toMap(),
    'description': description.toMap(),
  };

  OwnerServicesHeaderModel copyWith({
    String? imageUrl,
    BiText? title,
    BiText? description,
  }) =>
      OwnerServicesHeaderModel(
        imageUrl: imageUrl ?? this.imageUrl,
        title: title ?? this.title,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD APPLICATIONS
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesDownloadModel {
  final BiText title;
  final String appStoreLink;
  final String googlePlayLink;

  const OwnerServicesDownloadModel({
    this.title = const BiText(),
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  factory OwnerServicesDownloadModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OwnerServicesDownloadModel();
    return OwnerServicesDownloadModel(
      title: BiText.fromMap(map['title']),
      appStoreLink: map['appStoreLink'] ?? '',
      googlePlayLink: map['googlePlayLink'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title.toMap(),
    'appStoreLink': appStoreLink,
    'googlePlayLink': googlePlayLink,
  };

  OwnerServicesDownloadModel copyWith({
    BiText? title,
    String? appStoreLink,
    String? googlePlayLink,
  }) =>
      OwnerServicesDownloadModel(
        title: title ?? this.title,
        appStoreLink: appStoreLink ?? this.appStoreLink,
        googlePlayLink: googlePlayLink ?? this.googlePlayLink,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCKUP ITEM
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesMockupItemModel {
  final String id;
  final String imageUrl;
  final String alignment;
  final BiText title;
  final BiText description;
  final int order;

  const OwnerServicesMockupItemModel({
    this.id = '',
    this.imageUrl = '',
    this.alignment = 'left',
    this.title = const BiText(),
    this.description = const BiText(),
    this.order = 0,
  });

  factory OwnerServicesMockupItemModel.fromMap(Map<String, dynamic> map) =>
      OwnerServicesMockupItemModel(
        id: map['id'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        alignment: map['alignment'] ?? 'left',
        title: BiText.fromMap(map['title']),
        description: BiText.fromMap(map['description']),
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'imageUrl': imageUrl,
    'alignment': alignment,
    'title': title.toMap(),
    'description': description.toMap(),
    'order': order,
  };

  OwnerServicesMockupItemModel copyWith({
    String? id,
    String? imageUrl,
    String? alignment,
    BiText? title,
    BiText? description,
    int? order,
  }) =>
      OwnerServicesMockupItemModel(
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
        alignment: alignment ?? this.alignment,
        title: title ?? this.title,
        description: description ?? this.description,
        order: order ?? this.order,
      );
}

class OwnerServicesMockupsSectionModel {
  final List<OwnerServicesMockupItemModel> items;

  const OwnerServicesMockupsSectionModel({this.items = const []});

  factory OwnerServicesMockupsSectionModel.fromMap(
      Map<String, dynamic>? map) {
    if (map == null) return const OwnerServicesMockupsSectionModel();
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return OwnerServicesMockupsSectionModel(
      items: rawItems
          .map((e) =>
          OwnerServicesMockupItemModel.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toMap() => {
    'items': items.map((e) => e.toMap()).toList(),
  };

  OwnerServicesMockupsSectionModel copyWith({
    List<OwnerServicesMockupItemModel>? items,
  }) =>
      OwnerServicesMockupsSectionModel(items: items ?? this.items);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PUBLISH SCHEDULE
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesPublishScheduleModel {
  final DateTime? publishDate;

  const OwnerServicesPublishScheduleModel({this.publishDate});

  factory OwnerServicesPublishScheduleModel.fromMap(
      Map<String, dynamic>? map) {
    DateTime? date;
    if (map?['publishDate'] != null) {
      if (map!['publishDate'] is Timestamp) {
        date = (map['publishDate'] as Timestamp).toDate();
      } else if (map['publishDate'] is String) {
        date = DateTime.tryParse(map['publishDate']);
      }
    }
    return OwnerServicesPublishScheduleModel(publishDate: date);
  }

  Map<String, dynamic> toMap() => {
    'publishDate':
    publishDate != null ? Timestamp.fromDate(publishDate!) : null,
  };

  OwnerServicesPublishScheduleModel copyWith({DateTime? publishDate}) =>
      OwnerServicesPublishScheduleModel(
          publishDate: publishDate ?? this.publishDate);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields versioned
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesPageModel {
  final String id;
  final String status;
  final String gender;
  final OwnerServicesHeaderModel header;
  final OwnerServicesDownloadModel download;
  final OwnerServicesMockupsSectionModel mockups;
  final OwnerServicesPublishScheduleModel publishSchedule;
  final DateTime? lastUpdated;

  const OwnerServicesPageModel({
    this.id = '',
    this.status = 'draft',
    this.gender = 'female',
    this.header = const OwnerServicesHeaderModel(),
    this.download = const OwnerServicesDownloadModel(),
    this.mockups = const OwnerServicesMockupsSectionModel(),
    this.publishSchedule = const OwnerServicesPublishScheduleModel(),
    this.lastUpdated,
  });

  // ── fromMap — ALL fields use Versioned.read() ────────────────────────────
  factory OwnerServicesPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {
    return OwnerServicesPageModel(
      id: docId ?? Versioned.read<String>(
        map['id'],
            (v) => v?.toString() ?? '',
      ),

      status: Versioned.read<String>(
        map['status'],
            (v) => v?.toString() ?? 'draft',
      ),

      gender: Versioned.read<String>(
        map['gender'],
            (v) => v?.toString() ?? 'female',
      ),

      header: Versioned.read<OwnerServicesHeaderModel>(
        map['header'],
            (v) => OwnerServicesHeaderModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      download: Versioned.read<OwnerServicesDownloadModel>(
        map['download'],
            (v) => OwnerServicesDownloadModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      mockups: Versioned.read<OwnerServicesMockupsSectionModel>(
        map['mockups'],
            (v) => OwnerServicesMockupsSectionModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      publishSchedule: Versioned.read<OwnerServicesPublishScheduleModel>(
        map['publishSchedule'],
            (v) => OwnerServicesPublishScheduleModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      lastUpdated: Versioned.read<DateTime?>(
        map['lastUpdated'],
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
    'id': id,
    'status': status,
    'gender': gender,
    'header': header.toMap(),
    'download': download.toMap(),
    'mockups': mockups.toMap(),
    'publishSchedule': publishSchedule.toMap(),
    'lastUpdated':
    lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
  };

  OwnerServicesPageModel copyWith({
    String? id,
    String? status,
    String? gender,
    OwnerServicesHeaderModel? header,
    OwnerServicesDownloadModel? download,
    OwnerServicesMockupsSectionModel? mockups,
    OwnerServicesPublishScheduleModel? publishSchedule,
    DateTime? lastUpdated,
  }) =>
      OwnerServicesPageModel(
        id: id ?? this.id,
        status: status ?? this.status,
        gender: gender ?? this.gender,
        header: header ?? this.header,
        download: download ?? this.download,
        mockups: mockups ?? this.mockups,
        publishSchedule: publishSchedule ?? this.publishSchedule,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}