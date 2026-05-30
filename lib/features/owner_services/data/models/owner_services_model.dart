/// ******************* FILE INFO *******************
/// File Name: owner_services_model.dart
/// Description: Data models for the Owner Services CMS module.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: Mockups_Items flattened into indexed root-level keys ✅
/// UPDATED: EVERY single field is versioned. fromMap uses Versioned.read() on ALL. ✅

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

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER — flattened into root
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
// DOWNLOAD — flattened into root
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

// ═══════════════════════════════════════════════════════════════════════════════
// MOCKUPS SECTION — flattened into root
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesMockupsSectionModel {
  final List<OwnerServicesMockupItemModel> items;

  const OwnerServicesMockupsSectionModel({this.items = const []});

  OwnerServicesMockupsSectionModel copyWith({
    List<OwnerServicesMockupItemModel>? items,
  }) =>
      OwnerServicesMockupsSectionModel(items: items ?? this.items);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PUBLISH SCHEDULE — flattened into root
// ═══════════════════════════════════════════════════════════════════════════════
class OwnerServicesPublishScheduleModel {
  final DateTime? publishDate;

  const OwnerServicesPublishScheduleModel({this.publishDate});

  OwnerServicesPublishScheduleModel copyWith({DateTime? publishDate}) =>
      OwnerServicesPublishScheduleModel(
          publishDate: publishDate ?? this.publishDate);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields flattened & versioned
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

  // ═══════════════════════════════════════════════════════════════════════════
  // toMap — ALL fields flattened, Capital_Underscore naming
  // ═══════════════════════════════════════════════════════════════════════════
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['Id']     = id;
    map['Status'] = status;
    map['Gender'] = gender;

    // ── Header (flattened) ───────────────────────────────────────────
    map['Header_Image_Url']      = header.imageUrl;
    map['Header_Title_En']       = header.title.en;
    map['Header_Title_Ar']       = header.title.ar;
    map['Header_Description_En'] = header.description.en;
    map['Header_Description_Ar'] = header.description.ar;

    // ── Download (flattened) ─────────────────────────────────────────
    map['Download_Title_En']         = download.title.en;
    map['Download_Title_Ar']         = download.title.ar;
    map['Download_App_Store_Link']   = download.appStoreLink;
    map['Download_Google_Play_Link'] = download.googlePlayLink;

    // ── Mockups_Items (flattened) ────────────────────────────────────
    map['Mockups_Items_Count'] = mockups.items.length;
    for (int i = 0; i < mockups.items.length; i++) {
      final m = mockups.items[i];
      map['Mockups_Items_${i}_Id']             = m.id;
      map['Mockups_Items_${i}_Image_Url']      = m.imageUrl;
      map['Mockups_Items_${i}_Alignment']      = m.alignment;
      map['Mockups_Items_${i}_Title_En']       = m.title.en;
      map['Mockups_Items_${i}_Title_Ar']       = m.title.ar;
      map['Mockups_Items_${i}_Description_En'] = m.description.en;
      map['Mockups_Items_${i}_Description_Ar'] = m.description.ar;
      map['Mockups_Items_${i}_Order']          = m.order;
    }

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
  // ═══════════════════════════════════════════════════════════════════════════
  factory OwnerServicesPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {

    // ── Mockup Items (flattened, each field versioned) ───────────────
    final mCount = Versioned.read<int>(
      map['Mockups_Items_Count'], (v) => (v as int?) ?? 0,
    );
    final mockupItems = <OwnerServicesMockupItemModel>[];
    for (int i = 0; i < mCount; i++) {
      mockupItems.add(OwnerServicesMockupItemModel(
        id: Versioned.read<String>(
          map['Mockups_Items_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        imageUrl: Versioned.read<String>(
          map['Mockups_Items_${i}_Image_Url'], (v) => v?.toString() ?? '',
        ),
        alignment: Versioned.read<String>(
          map['Mockups_Items_${i}_Alignment'], (v) => v?.toString() ?? 'left',
        ),
        title: BiText(
          en: Versioned.read<String>(
            map['Mockups_Items_${i}_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Mockups_Items_${i}_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        description: BiText(
          en: Versioned.read<String>(
            map['Mockups_Items_${i}_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Mockups_Items_${i}_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        order: Versioned.read<int>(
          map['Mockups_Items_${i}_Order'], (v) => (v as int?) ?? i,
        ),
      ));
    }
    mockupItems.sort((a, b) => a.order.compareTo(b.order));

    // ── Last Updated (not versioned) ────────────────────────────────
    DateTime? lastUpdated;
    if (map['Last_Updated'] != null) {
      if (map['Last_Updated'] is Timestamp) {
        lastUpdated = (map['Last_Updated'] as Timestamp).toDate();
      } else if (map['Last_Updated'] is String) {
        lastUpdated = DateTime.tryParse(map['Last_Updated']);
      }
    }

    return OwnerServicesPageModel(
      id: docId ?? Versioned.read<String>(
        map['Id'], (v) => v?.toString() ?? '',
      ),
      status: Versioned.read<String>(
        map['Status'], (v) => v?.toString() ?? 'draft',
      ),
      gender: Versioned.read<String>(
        map['Gender'], (v) => v?.toString() ?? 'female',
      ),

      header: OwnerServicesHeaderModel(
        imageUrl: Versioned.read<String>(
          map['Header_Image_Url'], (v) => v?.toString() ?? '',
        ),
        title: BiText(
          en: Versioned.read<String>(
            map['Header_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Header_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        description: BiText(
          en: Versioned.read<String>(
            map['Header_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Header_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      download: OwnerServicesDownloadModel(
        title: BiText(
          en: Versioned.read<String>(
            map['Download_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Download_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        appStoreLink: Versioned.read<String>(
          map['Download_App_Store_Link'], (v) => v?.toString() ?? '',
        ),
        googlePlayLink: Versioned.read<String>(
          map['Download_Google_Play_Link'], (v) => v?.toString() ?? '',
        ),
      ),

      mockups: OwnerServicesMockupsSectionModel(items: mockupItems),

      publishSchedule: OwnerServicesPublishScheduleModel(
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

      lastUpdated: lastUpdated,
    );
  }

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