/// ******************* FILE INFO *******************
/// File Name: overview_model.dart
/// Description: Data models for the Overview CMS module.
/// Created by: Amr Mesbah
/// Last Update: 21/04/2026
/// UPDATED: All field names use Capital_Underscore naming convention ✅
/// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
/// UPDATED: Services_Items, Gallery_Images, Client_Comments_Comments
///          all flattened into indexed root-level keys ✅
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
// HEADINGS — flattened into OverviewPageModel
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewHeadingsModel {
  final BiText title;
  final BiText description;

  const OverviewHeadingsModel({
    this.title = const BiText(),
    this.description = const BiText(),
  });

  OverviewHeadingsModel copyWith({BiText? title, BiText? description}) =>
      OverviewHeadingsModel(
        title: title ?? this.title,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICE ITEM
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

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICES SECTION — flattened into OverviewPageModel
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewServicesSectionModel {
  final BiText title;
  final List<OverviewServiceItemModel> items;

  const OverviewServicesSectionModel({
    this.title = const BiText(),
    this.items = const [],
  });

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
// GALLERY IMAGE
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

// ═══════════════════════════════════════════════════════════════════════════════
// GALLERY SECTION — flattened into OverviewPageModel
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewGallerySectionModel {
  final List<OverviewGalleryImageModel> images;

  const OverviewGallerySectionModel({this.images = const []});

  OverviewGallerySectionModel copyWith({
    List<OverviewGalleryImageModel>? images,
  }) =>
      OverviewGallerySectionModel(images: images ?? this.images);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CLIENT COMMENT
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

// ═══════════════════════════════════════════════════════════════════════════════
// CLIENT COMMENTS SECTION — flattened into OverviewPageModel
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewClientCommentsSectionModel {
  final BiText title;
  final List<OverviewClientCommentModel> comments;

  const OverviewClientCommentsSectionModel({
    this.title = const BiText(),
    this.comments = const [],
  });

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
// DOWNLOAD SECTION — flattened into OverviewPageModel
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
// PUBLISH SCHEDULE — flattened into OverviewPageModel
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewPublishScheduleModel {
  final DateTime? publishDate;

  const OverviewPublishScheduleModel({this.publishDate});

  OverviewPublishScheduleModel copyWith({DateTime? publishDate}) =>
      OverviewPublishScheduleModel(
          publishDate: publishDate ?? this.publishDate);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════
class OverviewPageModel {
  final String id;
  final String status;
  final String gender;
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

  // ═══════════════════════════════════════════════════════════════════════════
  // toMap — ALL fields flattened, Capital_Underscore naming
  // Outputs plain primitives. Repo wraps EVERY key in Versioned.append().
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // ── Scalars ──────────────────────────────────────────────────────
    map['Id']     = id;
    map['Status'] = status;
    map['Gender'] = gender;

    // ── Headings (flattened) ─────────────────────────────────────────
    map['Headings_Title_En']       = headings.title.en;
    map['Headings_Title_Ar']       = headings.title.ar;
    map['Headings_Description_En'] = headings.description.en;
    map['Headings_Description_Ar'] = headings.description.ar;

    // ── Services title (flattened) ───────────────────────────────────
    map['Services_Title_En'] = services.title.en;
    map['Services_Title_Ar'] = services.title.ar;

    // ── Services_Items (flattened) ───────────────────────────────────
    map['Services_Items_Count'] = services.items.length;
    for (int i = 0; i < services.items.length; i++) {
      final item = services.items[i];
      map['Services_Items_${i}_Id']        = item.id;
      map['Services_Items_${i}_Name_En']   = item.name.en;
      map['Services_Items_${i}_Name_Ar']   = item.name.ar;
      map['Services_Items_${i}_Image_Url'] = item.imageUrl;
      map['Services_Items_${i}_Order']     = item.order;
    }

    // ── Gallery_Images (flattened) ───────────────────────────────────
    map['Gallery_Images_Count'] = gallery.images.length;
    for (int i = 0; i < gallery.images.length; i++) {
      final img = gallery.images[i];
      map['Gallery_Images_${i}_Id']        = img.id;
      map['Gallery_Images_${i}_Image_Url'] = img.imageUrl;
      map['Gallery_Images_${i}_Order']     = img.order;
    }

    // ── Client Comments title (flattened) ────────────────────────────
    map['Client_Comments_Title_En'] = clientComments.title.en;
    map['Client_Comments_Title_Ar'] = clientComments.title.ar;

    // ── Client_Comments_Comments (flattened) ─────────────────────────
    map['Client_Comments_Comments_Count'] = clientComments.comments.length;
    for (int i = 0; i < clientComments.comments.length; i++) {
      final c = clientComments.comments[i];
      map['Client_Comments_Comments_${i}_Id']            = c.id;
      map['Client_Comments_Comments_${i}_Image_Url']     = c.imageUrl;
      map['Client_Comments_Comments_${i}_First_Name_En'] = c.firstName.en;
      map['Client_Comments_Comments_${i}_First_Name_Ar'] = c.firstName.ar;
      map['Client_Comments_Comments_${i}_Last_Name_En']  = c.lastName.en;
      map['Client_Comments_Comments_${i}_Last_Name_Ar']  = c.lastName.ar;
      map['Client_Comments_Comments_${i}_Feedback_En']   = c.feedback.en;
      map['Client_Comments_Comments_${i}_Feedback_Ar']   = c.feedback.ar;
      map['Client_Comments_Comments_${i}_Order']         = c.order;
    }

    // ── Download (flattened) ─────────────────────────────────────────
    map['Download_Title_En']         = download.title.en;
    map['Download_Title_Ar']         = download.title.ar;
    map['Download_App_Store_Link']   = download.appStoreLink;
    map['Download_Google_Play_Link'] = download.googlePlayLink;

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

  factory OverviewPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {

    // ── Services Items (flattened, each field versioned) ─────────────
    final siCount = Versioned.read<int>(
      map['Services_Items_Count'], (v) => (v as int?) ?? 0,
    );
    final serviceItems = <OverviewServiceItemModel>[];
    for (int i = 0; i < siCount; i++) {
      serviceItems.add(OverviewServiceItemModel(
        id: Versioned.read<String>(
          map['Services_Items_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        name: BiText(
          en: Versioned.read<String>(
            map['Services_Items_${i}_Name_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Services_Items_${i}_Name_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        imageUrl: Versioned.read<String>(
          map['Services_Items_${i}_Image_Url'], (v) => v?.toString() ?? '',
        ),
        order: Versioned.read<int>(
          map['Services_Items_${i}_Order'], (v) => (v as int?) ?? i,
        ),
      ));
    }
    serviceItems.sort((a, b) => a.order.compareTo(b.order));

    // ── Gallery Images (flattened, each field versioned) ─────────────
    final giCount = Versioned.read<int>(
      map['Gallery_Images_Count'], (v) => (v as int?) ?? 0,
    );
    final galleryImages = <OverviewGalleryImageModel>[];
    for (int i = 0; i < giCount; i++) {
      galleryImages.add(OverviewGalleryImageModel(
        id: Versioned.read<String>(
          map['Gallery_Images_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        imageUrl: Versioned.read<String>(
          map['Gallery_Images_${i}_Image_Url'], (v) => v?.toString() ?? '',
        ),
        order: Versioned.read<int>(
          map['Gallery_Images_${i}_Order'], (v) => (v as int?) ?? i,
        ),
      ));
    }
    galleryImages.sort((a, b) => a.order.compareTo(b.order));

    // ── Client Comments (flattened, each field versioned) ────────────
    final ccCount = Versioned.read<int>(
      map['Client_Comments_Comments_Count'], (v) => (v as int?) ?? 0,
    );
    final comments = <OverviewClientCommentModel>[];
    for (int i = 0; i < ccCount; i++) {
      comments.add(OverviewClientCommentModel(
        id: Versioned.read<String>(
          map['Client_Comments_Comments_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        imageUrl: Versioned.read<String>(
          map['Client_Comments_Comments_${i}_Image_Url'], (v) => v?.toString() ?? '',
        ),
        firstName: BiText(
          en: Versioned.read<String>(
            map['Client_Comments_Comments_${i}_First_Name_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Client_Comments_Comments_${i}_First_Name_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        lastName: BiText(
          en: Versioned.read<String>(
            map['Client_Comments_Comments_${i}_Last_Name_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Client_Comments_Comments_${i}_Last_Name_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        feedback: BiText(
          en: Versioned.read<String>(
            map['Client_Comments_Comments_${i}_Feedback_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Client_Comments_Comments_${i}_Feedback_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        order: Versioned.read<int>(
          map['Client_Comments_Comments_${i}_Order'], (v) => (v as int?) ?? i,
        ),
      ));
    }
    comments.sort((a, b) => a.order.compareTo(b.order));

    // ── Last Updated (not versioned) ────────────────────────────────
    DateTime? lastUpdated;
    if (map['Last_Updated'] != null) {
      if (map['Last_Updated'] is Timestamp) {
        lastUpdated = (map['Last_Updated'] as Timestamp).toDate();
      } else if (map['Last_Updated'] is String) {
        lastUpdated = DateTime.tryParse(map['Last_Updated']);
      }
    }

    return OverviewPageModel(
      id: docId ?? Versioned.read<String>(
        map['Id'], (v) => v?.toString() ?? '',
      ),

      // ── Scalars ────────────────────────────────────────────────────
      status: Versioned.read<String>(
        map['Status'], (v) => v?.toString() ?? 'draft',
      ),
      gender: Versioned.read<String>(
        map['Gender'], (v) => v?.toString() ?? 'female',
      ),

      // ── Headings ───────────────────────────────────────────────────
      headings: OverviewHeadingsModel(
        title: BiText(
          en: Versioned.read<String>(
            map['Headings_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Headings_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        description: BiText(
          en: Versioned.read<String>(
            map['Headings_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Headings_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
      ),

      // ── Services ───────────────────────────────────────────────────
      services: OverviewServicesSectionModel(
        title: BiText(
          en: Versioned.read<String>(
            map['Services_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Services_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        items: serviceItems,
      ),

      // ── Gallery ────────────────────────────────────────────────────
      gallery: OverviewGallerySectionModel(images: galleryImages),

      // ── Client Comments ────────────────────────────────────────────
      clientComments: OverviewClientCommentsSectionModel(
        title: BiText(
          en: Versioned.read<String>(
            map['Client_Comments_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Client_Comments_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        comments: comments,
      ),

      // ── Download ───────────────────────────────────────────────────
      download: OverviewDownloadSectionModel(
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

      // ── Publish Schedule ───────────────────────────────────────────
      publishSchedule: OverviewPublishScheduleModel(
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