/// ******************* FILE INFO *******************
/// File Name: client_services_model.dart
/// Description: Data models for the Client Services CMS module.
///              Sections: Header (SVG + Title + Description),
///              Download Applications (Title + Apple/Android links),
///              Mockups (repeating: SVG + Layout[left/centered/right] + Title + Description).
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
// HEADER SECTION
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

  factory ClientServicesHeaderModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ClientServicesHeaderModel();
    return ClientServicesHeaderModel(
      svgUrl: map['svgUrl'] ?? '',
      title: BiText.fromMap(map['title']),
      description: BiText.fromMap(map['description']),
    );
  }

  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'title': title.toMap(),
    'description': description.toMap(),
  };

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
// DOWNLOAD APPLICATIONS SECTION
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

  factory ClientServicesDownloadModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ClientServicesDownloadModel();
    return ClientServicesDownloadModel(
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
// MOCKUP ITEM — repeating section with layout control
// ═══════════════════════════════════════════════════════════════════════════════

enum MockupLayout {
  left,
  centered,
  right;

  String toValue() => name;

  static MockupLayout fromValue(String? val) {
    switch (val) {
      case 'left':
        return MockupLayout.left;
      case 'centered':
        return MockupLayout.centered;
      case 'right':
        return MockupLayout.right;
      default:
        return MockupLayout.left;
    }
  }
}

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

  factory ClientServicesMockupItemModel.fromMap(Map<String, dynamic> map) =>
      ClientServicesMockupItemModel(
        id: map['id'] ?? '',
        svgUrl: map['svgUrl'] ?? '',
        layout: MockupLayout.fromValue(map['layout']),
        title: BiText.fromMap(map['title']),
        description: BiText.fromMap(map['description']),
        order: map['order'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'svgUrl': svgUrl,
    'layout': layout.toValue(),
    'title': title.toMap(),
    'description': description.toMap(),
    'order': order,
  };

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
// MOCKUPS SECTION (list of mockup items)
// ═══════════════════════════════════════════════════════════════════════════════
class ClientServicesMockupsSectionModel {
  final List<ClientServicesMockupItemModel> items;

  const ClientServicesMockupsSectionModel({this.items = const []});

  factory ClientServicesMockupsSectionModel.fromMap(
      Map<String, dynamic>? map) {
    if (map == null) return const ClientServicesMockupsSectionModel();
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return ClientServicesMockupsSectionModel(
      items: rawItems
          .map((e) => ClientServicesMockupItemModel.fromMap(
          e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toMap() => {
    'items': items.map((e) => e.toMap()).toList(),
  };

  ClientServicesMockupsSectionModel copyWith({
    List<ClientServicesMockupItemModel>? items,
  }) =>
      ClientServicesMockupsSectionModel(items: items ?? this.items);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields versioned
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

  // ── fromMap — ALL fields use Versioned.read() ────────────────────────────
  factory ClientServicesPageModel.fromMap(Map<String, dynamic> map,
      {String? docId}) {
    return ClientServicesPageModel(
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

      header: Versioned.read<ClientServicesHeaderModel>(
        map['header'],
            (v) => ClientServicesHeaderModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      download: Versioned.read<ClientServicesDownloadModel>(
        map['download'],
            (v) => ClientServicesDownloadModel.fromMap(
            v is Map ? Map<String, dynamic>.from(v) : null),
      ),

      mockups: Versioned.read<ClientServicesMockupsSectionModel>(
        map['mockups'],
            (v) => ClientServicesMockupsSectionModel.fromMap(
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
    'lastUpdated':
    lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
  };

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