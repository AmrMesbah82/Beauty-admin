/// ******************* FILE INFO *******************
/// File Name: client_services_model.dart
/// Description: Data models for the Client Services CMS module.
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
// HEADER SECTION — flattened into root
// ═══════════════════════════════════════════════════════════════════════════════
class ClientServicesHeaderModel {
  final String svgUrl;
  final BiText title;
  final BiText description;

  const ClientServicesHeaderModel({
    this.svgUrl = '',
    this.title = const BiText(),
    this.description = const BiText(),
  });

  ClientServicesHeaderModel copyWith({
    String? svgUrl,
    BiText? title,
    BiText? description,
  }) =>
      ClientServicesHeaderModel(
        svgUrl: svgUrl ?? this.svgUrl,
        title: title ?? this.title,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD SECTION — flattened into root
// ═══════════════════════════════════════════════════════════════════════════════
class ClientServicesDownloadModel {
  final BiText title;
  final String appStoreLink;
  final String googlePlayLink;

  const ClientServicesDownloadModel({
    this.title = const BiText(),
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  ClientServicesDownloadModel copyWith({
    BiText? title,
    String? appStoreLink,
    String? googlePlayLink,
  }) =>
      ClientServicesDownloadModel(
        title: title ?? this.title,
        appStoreLink: appStoreLink ?? this.appStoreLink,
        googlePlayLink: googlePlayLink ?? this.googlePlayLink,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCKUP LAYOUT ENUM
// ═══════════════════════════════════════════════════════════════════════════════
enum MockupLayout {
  left,
  centered,
  right;

  String toValue() => name;

  static MockupLayout fromValue(String? val) {
    switch (val) {
      case 'left':     return MockupLayout.left;
      case 'centered': return MockupLayout.centered;
      case 'right':    return MockupLayout.right;
      default:         return MockupLayout.left;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCKUP ITEM
// ═══════════════════════════════════════════════════════════════════════════════
class ClientServicesMockupItemModel {
  final String id;
  final String svgUrl;
  final MockupLayout layout;
  final BiText title;
  final BiText description;
  final int order;

  const ClientServicesMockupItemModel({
    this.id = '',
    this.svgUrl = '',
    this.layout = MockupLayout.left,
    this.title = const BiText(),
    this.description = const BiText(),
    this.order = 0,
  });

  ClientServicesMockupItemModel copyWith({
    String? id,
    String? svgUrl,
    MockupLayout? layout,
    BiText? title,
    BiText? description,
    int? order,
  }) =>
      ClientServicesMockupItemModel(
        id: id ?? this.id,
        svgUrl: svgUrl ?? this.svgUrl,
        layout: layout ?? this.layout,
        title: title ?? this.title,
        description: description ?? this.description,
        order: order ?? this.order,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCKUPS SECTION — flattened into root
// ═══════════════════════════════════════════════════════════════════════════════
class ClientServicesMockupsSectionModel {
  final List<ClientServicesMockupItemModel> items;

  const ClientServicesMockupsSectionModel({this.items = const []});

  ClientServicesMockupsSectionModel copyWith({
    List<ClientServicesMockupItemModel>? items,
  }) =>
      ClientServicesMockupsSectionModel(items: items ?? this.items);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════
class ClientServicesPageModel {
  final String id;
  final String status;
  final String gender;
  final ClientServicesHeaderModel header;
  final ClientServicesDownloadModel download;
  final ClientServicesMockupsSectionModel mockups;
  final DateTime? lastUpdated;

  const ClientServicesPageModel({
    this.id = '',
    this.status = 'draft',
    this.gender = 'female',
    this.header = const ClientServicesHeaderModel(),
    this.download = const ClientServicesDownloadModel(),
    this.mockups = const ClientServicesMockupsSectionModel(),
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
    map['Header_Svg_Url']        = header.svgUrl;
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
      map['Mockups_Items_${i}_Svg_Url']        = m.svgUrl;
      map['Mockups_Items_${i}_Layout']         = m.layout.toValue();
      map['Mockups_Items_${i}_Title_En']       = m.title.en;
      map['Mockups_Items_${i}_Title_Ar']       = m.title.ar;
      map['Mockups_Items_${i}_Description_En'] = m.description.en;
      map['Mockups_Items_${i}_Description_Ar'] = m.description.ar;
      map['Mockups_Items_${i}_Order']          = m.order;
    }

    // ── Last Updated ─────────────────────────────────────────────────
    map['Last_Updated'] = lastUpdated != null
        ? Timestamp.fromDate(lastUpdated!)
        : null;

    return map;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // fromMap — EVERY field uses Versioned.read()
  // ═══════════════════════════════════════════════════════════════════════════
  factory ClientServicesPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {

    // ── Mockup Items (flattened, each field versioned) ───────────────
    final mCount = Versioned.read<int>(
      map['Mockups_Items_Count'], (v) => (v as int?) ?? 0,
    );
    final mockupItems = <ClientServicesMockupItemModel>[];
    for (int i = 0; i < mCount; i++) {
      mockupItems.add(ClientServicesMockupItemModel(
        id: Versioned.read<String>(
          map['Mockups_Items_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        svgUrl: Versioned.read<String>(
          map['Mockups_Items_${i}_Svg_Url'], (v) => v?.toString() ?? '',
        ),
        layout: MockupLayout.fromValue(Versioned.read<String>(
          map['Mockups_Items_${i}_Layout'], (v) => v?.toString() ?? 'left',
        )),
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

    return ClientServicesPageModel(
      id: docId ?? Versioned.read<String>(
        map['Id'], (v) => v?.toString() ?? '',
      ),
      status: Versioned.read<String>(
        map['Status'], (v) => v?.toString() ?? 'draft',
      ),
      gender: Versioned.read<String>(
        map['Gender'], (v) => v?.toString() ?? 'female',
      ),

      header: ClientServicesHeaderModel(
        svgUrl: Versioned.read<String>(
          map['Header_Svg_Url'], (v) => v?.toString() ?? '',
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

      download: ClientServicesDownloadModel(
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

      mockups: ClientServicesMockupsSectionModel(items: mockupItems),
      lastUpdated: lastUpdated,
    );
  }

  ClientServicesPageModel copyWith({
    String? id,
    String? status,
    String? gender,
    ClientServicesHeaderModel? header,
    ClientServicesDownloadModel? download,
    ClientServicesMockupsSectionModel? mockups,
    DateTime? lastUpdated,
  }) =>
      ClientServicesPageModel(
        id: id ?? this.id,
        status: status ?? this.status,
        gender: gender ?? this.gender,
        header: header ?? this.header,
        download: download ?? this.download,
        mockups: mockups ?? this.mockups,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}