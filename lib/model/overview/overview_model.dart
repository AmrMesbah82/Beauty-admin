/// ******************* FILE INFO *******************
/// File Name: overview_model.dart
/// Description: Data models for the Overview CMS module.
///              Sections: Headings (Title + Description),
///              Services (Title + repeating items with Image + Name),
///              Gallery (repeating image slots),
///              Client Comments (Title + repeating: Image, First/Last Name, Feedback),
///              Download Applications (Title + Apple/Android links),
///              Publish Schedule (date).
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

// ═══════════════════════════════════════════════════════════════════════════════
// HEADINGS
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewHeadingsModel {
  final BiText title;
  final BiText description;

  const OverviewHeadingsModel({
    this.title = const BiText(),
    this.description = const BiText(),
  });

  factory OverviewHeadingsModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OverviewHeadingsModel();
    return OverviewHeadingsModel(
      title: BiText.fromMap(map['title']),
      description: BiText.fromMap(map['description']),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title.toMap(),
    'description': description.toMap(),
  };

  OverviewHeadingsModel copyWith({BiText? title, BiText? description}) =>
      OverviewHeadingsModel(
        title: title ?? this.title,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICES
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewServiceItemModel {
  final String id;
  final BiText name;
  final String imageUrl;
  final int order;

  const OverviewServiceItemModel({
    this.id = '',
    this.name = const BiText(),
    this.imageUrl = '',
    this.order = 0,
  });

  factory OverviewServiceItemModel.fromMap(Map<String, dynamic> map) =>
      OverviewServiceItemModel(
        id: map['id'] ?? '',
        name: BiText.fromMap(map['name']),
        imageUrl: map['imageUrl'] ?? '',
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name.toMap(),
    'imageUrl': imageUrl,
    'order': order,
  };

  OverviewServiceItemModel copyWith({
    String? id,
    BiText? name,
    String? imageUrl,
    int? order,
  }) =>
      OverviewServiceItemModel(
        id: id ?? this.id,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        order: order ?? this.order,
      );
}

class OverviewServicesSectionModel {
  final BiText title;
  final List<OverviewServiceItemModel> items;

  const OverviewServicesSectionModel({
    this.title = const BiText(),
    this.items = const [],
  });

  factory OverviewServicesSectionModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OverviewServicesSectionModel();
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return OverviewServicesSectionModel(
      title: BiText.fromMap(map['title']),
      items: rawItems
          .map((e) =>
          OverviewServiceItemModel.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title.toMap(),
    'items': items.map((e) => e.toMap()).toList(),
  };

  OverviewServicesSectionModel copyWith({
    BiText? title,
    List<OverviewServiceItemModel>? items,
  }) =>
      OverviewServicesSectionModel(
        title: title ?? this.title,
        items: items ?? this.items,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// GALLERY
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewGalleryImageModel {
  final String id;
  final String imageUrl;
  final int order;

  const OverviewGalleryImageModel({
    this.id = '',
    this.imageUrl = '',
    this.order = 0,
  });

  factory OverviewGalleryImageModel.fromMap(Map<String, dynamic> map) =>
      OverviewGalleryImageModel(
        id: map['id'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'imageUrl': imageUrl,
    'order': order,
  };

  OverviewGalleryImageModel copyWith({
    String? id,
    String? imageUrl,
    int? order,
  }) =>
      OverviewGalleryImageModel(
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
        order: order ?? this.order,
      );
}

class OverviewGallerySectionModel {
  final List<OverviewGalleryImageModel> images;

  const OverviewGallerySectionModel({this.images = const []});

  factory OverviewGallerySectionModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OverviewGallerySectionModel();
    final rawImages = map['images'] as List<dynamic>? ?? [];
    return OverviewGallerySectionModel(
      images: rawImages
          .map((e) =>
          OverviewGalleryImageModel.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toMap() => {
    'images': images.map((e) => e.toMap()).toList(),
  };

  OverviewGallerySectionModel copyWith({
    List<OverviewGalleryImageModel>? images,
  }) =>
      OverviewGallerySectionModel(images: images ?? this.images);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CLIENT COMMENTS
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewClientCommentModel {
  final String id;
  final String imageUrl;
  final BiText firstName;
  final BiText lastName;
  final BiText feedback;
  final int order;

  const OverviewClientCommentModel({
    this.id = '',
    this.imageUrl = '',
    this.firstName = const BiText(),
    this.lastName = const BiText(),
    this.feedback = const BiText(),
    this.order = 0,
  });

  factory OverviewClientCommentModel.fromMap(Map<String, dynamic> map) =>
      OverviewClientCommentModel(
        id: map['id'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        firstName: BiText.fromMap(map['firstName']),
        lastName: BiText.fromMap(map['lastName']),
        feedback: BiText.fromMap(map['feedback']),
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'imageUrl': imageUrl,
    'firstName': firstName.toMap(),
    'lastName': lastName.toMap(),
    'feedback': feedback.toMap(),
    'order': order,
  };

  OverviewClientCommentModel copyWith({
    String? id,
    String? imageUrl,
    BiText? firstName,
    BiText? lastName,
    BiText? feedback,
    int? order,
  }) =>
      OverviewClientCommentModel(
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        feedback: feedback ?? this.feedback,
        order: order ?? this.order,
      );
}

class OverviewClientCommentsSectionModel {
  final BiText title;
  final List<OverviewClientCommentModel> comments;

  const OverviewClientCommentsSectionModel({
    this.title = const BiText(),
    this.comments = const [],
  });

  factory OverviewClientCommentsSectionModel.fromMap(
      Map<String, dynamic>? map) {
    if (map == null) return const OverviewClientCommentsSectionModel();
    final rawComments = map['comments'] as List<dynamic>? ?? [];
    return OverviewClientCommentsSectionModel(
      title: BiText.fromMap(map['title']),
      comments: rawComments
          .map((e) =>
          OverviewClientCommentModel.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title.toMap(),
    'comments': comments.map((e) => e.toMap()).toList(),
  };

  OverviewClientCommentsSectionModel copyWith({
    BiText? title,
    List<OverviewClientCommentModel>? comments,
  }) =>
      OverviewClientCommentsSectionModel(
        title: title ?? this.title,
        comments: comments ?? this.comments,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD APPLICATIONS
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewDownloadSectionModel {
  final BiText title;
  final String appStoreLink;
  final String googlePlayLink;

  const OverviewDownloadSectionModel({
    this.title = const BiText(),
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  factory OverviewDownloadSectionModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OverviewDownloadSectionModel();
    return OverviewDownloadSectionModel(
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

  OverviewDownloadSectionModel copyWith({
    BiText? title,
    String? appStoreLink,
    String? googlePlayLink,
  }) =>
      OverviewDownloadSectionModel(
        title: title ?? this.title,
        appStoreLink: appStoreLink ?? this.appStoreLink,
        googlePlayLink: googlePlayLink ?? this.googlePlayLink,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PUBLISH SCHEDULE
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewPublishScheduleModel {
  final DateTime? publishDate;

  const OverviewPublishScheduleModel({this.publishDate});

  factory OverviewPublishScheduleModel.fromMap(Map<String, dynamic>? map) {
    DateTime? date;
    if (map?['publishDate'] != null) {
      if (map!['publishDate'] is Timestamp) {
        date = (map['publishDate'] as Timestamp).toDate();
      } else if (map['publishDate'] is String) {
        date = DateTime.tryParse(map['publishDate']);
      }
    }
    return OverviewPublishScheduleModel(publishDate: date);
  }

  Map<String, dynamic> toMap() => {
    'publishDate':
    publishDate != null ? Timestamp.fromDate(publishDate!) : null,
  };

  OverviewPublishScheduleModel copyWith({DateTime? publishDate}) =>
      OverviewPublishScheduleModel(
          publishDate: publishDate ?? this.publishDate);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewPageModel {
  final String id;
  final String status; // 'published', 'scheduled', 'draft'
  final String gender; // 'female', 'male'
  final OverviewHeadingsModel headings;
  final OverviewServicesSectionModel services;
  final OverviewGallerySectionModel gallery;
  final OverviewClientCommentsSectionModel clientComments;
  final OverviewDownloadSectionModel download;
  final OverviewPublishScheduleModel publishSchedule;
  final DateTime? lastUpdated;

  const OverviewPageModel({
    this.id = '',
    this.status = 'draft',
    this.gender = 'female',
    this.headings = const OverviewHeadingsModel(),
    this.services = const OverviewServicesSectionModel(),
    this.gallery = const OverviewGallerySectionModel(),
    this.clientComments = const OverviewClientCommentsSectionModel(),
    this.download = const OverviewDownloadSectionModel(),
    this.publishSchedule = const OverviewPublishScheduleModel(),
    this.lastUpdated,
  });

  factory OverviewPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {
    DateTime? lastUpdated;
    if (map['lastUpdated'] != null) {
      if (map['lastUpdated'] is Timestamp) {
        lastUpdated = (map['lastUpdated'] as Timestamp).toDate();
      }
    }
    return OverviewPageModel(
      id: docId ?? map['id'] ?? '',
      status: map['status'] ?? 'draft',
      gender: map['gender'] ?? 'female',
      headings: OverviewHeadingsModel.fromMap(map['headings']),
      services: OverviewServicesSectionModel.fromMap(map['services']),
      gallery: OverviewGallerySectionModel.fromMap(map['gallery']),
      clientComments:
      OverviewClientCommentsSectionModel.fromMap(map['clientComments']),
      download: OverviewDownloadSectionModel.fromMap(map['download']),
      publishSchedule:
      OverviewPublishScheduleModel.fromMap(map['publishSchedule']),
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'status': status,
    'gender': gender,
    'headings': headings.toMap(),
    'services': services.toMap(),
    'gallery': gallery.toMap(),
    'clientComments': clientComments.toMap(),
    'download': download.toMap(),
    'publishSchedule': publishSchedule.toMap(),
    'lastUpdated':
    lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
  };

  OverviewPageModel copyWith({
    String? id,
    String? status,
    String? gender,
    OverviewHeadingsModel? headings,
    OverviewServicesSectionModel? services,
    OverviewGallerySectionModel? gallery,
    OverviewClientCommentsSectionModel? clientComments,
    OverviewDownloadSectionModel? download,
    OverviewPublishScheduleModel? publishSchedule,
    DateTime? lastUpdated,
  }) =>
      OverviewPageModel(
        id: id ?? this.id,
        status: status ?? this.status,
        gender: gender ?? this.gender,
        headings: headings ?? this.headings,
        services: services ?? this.services,
        gallery: gallery ?? this.gallery,
        clientComments: clientComments ?? this.clientComments,
        download: download ?? this.download,
        publishSchedule: publishSchedule ?? this.publishSchedule,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}