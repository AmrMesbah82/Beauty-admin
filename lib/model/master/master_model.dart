/// ******************* FILE INFO *******************
/// File Name: master_model.dart
/// Description: Data models for the Master CMS module.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

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

// ── Section Model (Header / About Us / Footer) ──────────────────────────────
class MasterSectionModel {
  final String id;
  final String sectionKey; // e.g. 'header', 'aboutUs', 'footer'
  final BiText title;
  final BiText shortDescription;
  final BiText description;
  final String imageUrl;
  final String iconUrl;
  final String textBoxColor;
  final bool visibility;
  final int order;

  const MasterSectionModel({
    this.id = '',
    this.sectionKey = '',
    this.title = const BiText(),
    this.shortDescription = const BiText(),
    this.description = const BiText(),
    this.imageUrl = '',
    this.iconUrl = '',
    this.textBoxColor = '#008037',
    this.visibility = true,
    this.order = 0,
  });

  factory MasterSectionModel.fromMap(Map<String, dynamic> map,
      {String? docId}) =>
      MasterSectionModel(
        id: docId ?? map['id'] ?? '',
        sectionKey: map['sectionKey'] ?? '',
        title: BiText.fromMap(map['title']),
        shortDescription: BiText.fromMap(map['shortDescription']),
        description: BiText.fromMap(map['description']),
        imageUrl: map['imageUrl'] ?? '',
        iconUrl: map['iconUrl'] ?? '',
        textBoxColor: map['textBoxColor'] ?? '#008037',
        visibility: map['visibility'] ?? true,
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'sectionKey': sectionKey,
    'title': title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'description': description.toMap(),
    'imageUrl': imageUrl,
    'iconUrl': iconUrl,
    'textBoxColor': textBoxColor,
    'visibility': visibility,
    'order': order,
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
    bool? visibility,
    int? order,
  }) =>
      MasterSectionModel(
        id: id ?? this.id,
        sectionKey: sectionKey ?? this.sectionKey,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        iconUrl: iconUrl ?? this.iconUrl,
        textBoxColor: textBoxColor ?? this.textBoxColor,
        visibility: visibility ?? this.visibility,
        order: order ?? this.order,
      );
}

// ── App Link Model (Google Play / App Store) ─────────────────────────────────
class MasterAppLinkModel {
  final String appStoreLink;
  final String googlePlayLink;

  const MasterAppLinkModel({
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  factory MasterAppLinkModel.fromMap(Map<String, dynamic>? map) =>
      MasterAppLinkModel(
        appStoreLink: map?['appStoreLink'] ?? '',
        googlePlayLink: map?['googlePlayLink'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'appStoreLink': appStoreLink,
    'googlePlayLink': googlePlayLink,
  };

  MasterAppLinkModel copyWith({
    String? appStoreLink,
    String? googlePlayLink,
  }) =>
      MasterAppLinkModel(
        appStoreLink: appStoreLink ?? this.appStoreLink,
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
class MasterPageModel {
  final String id;
  final BiText title;
  final BiText shortDescription;
  final String status; // 'published', 'scheduled', 'draft'
  final String gender; // 'female', 'male'
  final List<MasterSectionModel> sections;
  final MasterAppLinkModel appLinks;
  final MasterPublishScheduleModel publishSchedule;
  final DateTime? lastUpdated;
  final String imageUrl;

  const MasterPageModel({
    this.id = '',
    this.title = const BiText(),
    this.shortDescription = const BiText(),
    this.status = 'draft',
    this.gender = 'female',
    this.sections = const [],
    this.appLinks = const MasterAppLinkModel(),
    this.publishSchedule = const MasterPublishScheduleModel(),
    this.lastUpdated,
    this.imageUrl = '',
  });

  /// Default sections for a new master page
  static List<MasterSectionModel> defaultSections() => [
    const MasterSectionModel(
        id: 'header', sectionKey: 'header', order: 0),
    const MasterSectionModel(
        id: 'aboutUs', sectionKey: 'aboutUs', order: 1),
    const MasterSectionModel(
        id: 'footer', sectionKey: 'footer', order: 2),
  ];

  factory MasterPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {
    final rawSections = map['sections'] as List<dynamic>? ?? [];
    final sections = rawSections
        .map((e) => MasterSectionModel.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    DateTime? lastUpdated;
    if (map['lastUpdated'] != null) {
      if (map['lastUpdated'] is Timestamp) {
        lastUpdated = (map['lastUpdated'] as Timestamp).toDate();
      }
    }

    return MasterPageModel(
      id: docId ?? map['id'] ?? '',
      title: BiText.fromMap(map['title']),
      shortDescription: BiText.fromMap(map['shortDescription']),
      status: map['status'] ?? 'draft',
      gender: map['gender'] ?? 'female',
      sections: sections.isEmpty ? defaultSections() : sections,
      appLinks: MasterAppLinkModel.fromMap(map['appLinks']),
      publishSchedule:
      MasterPublishScheduleModel.fromMap(map['publishSchedule']),
      lastUpdated: lastUpdated,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title.toMap(),
    'shortDescription': shortDescription.toMap(),
    'status': status,
    'gender': gender,
    'sections': sections.map((s) => s.toMap()).toList(),
    'appLinks': appLinks.toMap(),
    'publishSchedule': publishSchedule.toMap(),
    'lastUpdated':
    lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    'imageUrl': imageUrl,
  };

  MasterPageModel copyWith({
    String? id,
    BiText? title,
    BiText? shortDescription,
    String? status,
    String? gender,
    List<MasterSectionModel>? sections,
    MasterAppLinkModel? appLinks,
    MasterPublishScheduleModel? publishSchedule,
    DateTime? lastUpdated,
    String? imageUrl,
  }) =>
      MasterPageModel(
        id: id ?? this.id,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        status: status ?? this.status,
        gender: gender ?? this.gender,
        sections: sections ?? this.sections,
        appLinks: appLinks ?? this.appLinks,
        publishSchedule: publishSchedule ?? this.publishSchedule,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        imageUrl: imageUrl ?? this.imageUrl,
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