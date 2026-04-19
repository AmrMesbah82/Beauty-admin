// ******************* FILE INFO *******************
// File Name: home_page_model.dart
// Description: Pure data model for the Home CMS.
//              No packages — only dart:core types.
// Created by: Amr Mesbah
// UPDATED: AppDownloadLinksModel now has labelEn, labelAr, iosIconUrl,
//          androidIconUrl fields for the "App Link" section ✅
// UPDATED: Versioned helper added — all scalar/object fields are now read
//          from a versioned list in Firestore (last item = active value) ✅
// UPDATED: Versioned.append() now has duplicate guard — only appends when
//          value actually changed, preventing duplicate history entries ✅

/// Bilingual text wrapper
class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  factory BiText.fromMap(Map<String, dynamic> map) =>
      BiText(en: map['en'] ?? '', ar: map['ar'] ?? '');

  @override
  String toString() => 'BiText(en: $en, ar: $ar)';
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

// ─────────────────────────────────────────────────────────────────────────────
// Nav Button — WITH STATUS FIELD AND ICON URL ✅
// ─────────────────────────────────────────────────────────────────────────────

class NavButtonModel {
  final String id;
  final BiText name;
  final String route;
  final String iconUrl;
  final bool   status;

  const NavButtonModel({
    required this.id,
    this.name    = const BiText(),
    this.route   = '',
    this.iconUrl = '',
    this.status  = true,
  });

  NavButtonModel copyWith({
    String? id,
    BiText? name,
    String? route,
    String? iconUrl,
    bool?   status,
  }) =>
      NavButtonModel(
        id:      id      ?? this.id,
        name:    name    ?? this.name,
        route:   route   ?? this.route,
        iconUrl: iconUrl ?? this.iconUrl,
        status:  status  ?? this.status,
      );

  Map<String, dynamic> toMap() => {
    'id':      id,
    'name':    name.toMap(),
    'route':   route,
    'iconUrl': iconUrl,
    'status':  status,
  };

  factory NavButtonModel.fromMap(Map<String, dynamic> map) => NavButtonModel(
    id:      map['id']      ?? '',
    name:    BiText.fromMap(map['name'] ?? {}),
    route:   map['route']   ?? '',
    iconUrl: map['iconUrl'] ?? '',
    status:  map['status']  ?? true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card (1–4)
// ─────────────────────────────────────────────────────────────────────────────

class SectionCardModel {
  final String imageUrl;
  final String iconUrl;
  final String textBoxColor;
  final BiText description;
  final bool   visibility;

  const SectionCardModel({
    this.imageUrl     = '',
    this.iconUrl      = '',
    this.textBoxColor = '#008037',
    this.description  = const BiText(),
    this.visibility   = true,
  });

  SectionCardModel copyWith({
    String? imageUrl,
    String? iconUrl,
    String? textBoxColor,
    BiText? description,
    bool?   visibility,
  }) =>
      SectionCardModel(
        imageUrl:     imageUrl     ?? this.imageUrl,
        iconUrl:      iconUrl      ?? this.iconUrl,
        textBoxColor: textBoxColor ?? this.textBoxColor,
        description:  description  ?? this.description,
        visibility:   visibility   ?? this.visibility,
      );

  Map<String, dynamic> toMap() => {
    'imageUrl':     imageUrl,
    'iconUrl':      iconUrl,
    'textBoxColor': textBoxColor,
    'description':  description.toMap(),
    'visibility':   visibility,
  };

  factory SectionCardModel.fromMap(Map<String, dynamic> map) =>
      SectionCardModel(
        imageUrl:     map['imageUrl']     ?? '',
        iconUrl:      map['iconUrl']      ?? '',
        textBoxColor: map['textBoxColor'] ?? '#008037',
        description:  BiText.fromMap(map['description'] ?? {}),
        visibility:   map['visibility']   ?? true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Item
// ─────────────────────────────────────────────────────────────────────────────

class HeaderItemModel {
  final String id;
  final BiText title;
  final bool   status;

  const HeaderItemModel({
    required this.id,
    this.title  = const BiText(),
    this.status = true,
  });

  HeaderItemModel copyWith({String? id, BiText? title, bool? status}) =>
      HeaderItemModel(
        id:     id     ?? this.id,
        title:  title  ?? this.title,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
    'id':     id,
    'title':  title.toMap(),
    'status': status,
  };

  factory HeaderItemModel.fromMap(Map<String, dynamic> map) =>
      HeaderItemModel(
        id:     map['id']     ?? '',
        title:  BiText.fromMap(map['title'] ?? {}),
        status: map['status'] ?? true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer Label Row
// ─────────────────────────────────────────────────────────────────────────────

class FooterLabelModel {
  final String id;
  final BiText label;
  final String route;

  const FooterLabelModel({
    required this.id,
    this.label = const BiText(),
    this.route = '',
  });

  FooterLabelModel copyWith({String? id, BiText? label, String? route}) =>
      FooterLabelModel(
        id:    id    ?? this.id,
        label: label ?? this.label,
        route: route ?? this.route,
      );

  Map<String, dynamic> toMap() => {
    'id':    id,
    'label': label.toMap(),
    'route': route,
  };

  factory FooterLabelModel.fromMap(Map<String, dynamic> map) =>
      FooterLabelModel(
        id:    map['id']    ?? '',
        label: BiText.fromMap(map['label'] ?? {}),
        route: map['route'] ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer Column
// ─────────────────────────────────────────────────────────────────────────────

class FooterColumnModel {
  final String                 id;
  final BiText                 title;
  final String                 route;
  final List<FooterLabelModel> labels;

  const FooterColumnModel({
    required this.id,
    this.title  = const BiText(),
    this.route  = '',
    this.labels = const [],
  });

  FooterColumnModel copyWith({
    String?                 id,
    BiText?                 title,
    String?                 route,
    List<FooterLabelModel>? labels,
  }) =>
      FooterColumnModel(
        id:     id     ?? this.id,
        title:  title  ?? this.title,
        route:  route  ?? this.route,
        labels: labels ?? this.labels,
      );

  Map<String, dynamic> toMap() => {
    'id':     id,
    'title':  title.toMap(),
    'route':  route,
    'labels': labels.map((l) => l.toMap()).toList(),
  };

  factory FooterColumnModel.fromMap(Map<String, dynamic> map) =>
      FooterColumnModel(
        id:     map['id']    ?? '',
        title:  BiText.fromMap(map['title'] ?? {}),
        route:  map['route'] ?? '',
        labels: (map['labels'] as List<dynamic>? ?? [])
            .map((l) =>
            FooterLabelModel.fromMap(l as Map<String, dynamic>))
            .toList(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Link — WITH VISIBILITY FIELD ✅
// ─────────────────────────────────────────────────────────────────────────────

class SocialLinkModel {
  final String id;
  final String iconUrl;
  final String url;
  final bool   visibility;

  const SocialLinkModel({
    required this.id,
    this.iconUrl    = '',
    this.url        = '',
    this.visibility = true,
  });

  SocialLinkModel copyWith({
    String? id,
    String? iconUrl,
    String? url,
    bool?   visibility,
  }) =>
      SocialLinkModel(
        id:         id         ?? this.id,
        iconUrl:    iconUrl    ?? this.iconUrl,
        url:        url        ?? this.url,
        visibility: visibility ?? this.visibility,
      );

  Map<String, dynamic> toMap() => {
    'id':         id,
    'iconUrl':    iconUrl,
    'url':        url,
    'visibility': visibility,
  };

  factory SocialLinkModel.fromMap(Map<String, dynamic> map) =>
      SocialLinkModel(
        id:         map['id']         ?? '',
        iconUrl:    map['iconUrl']    ?? '',
        url:        map['url']        ?? '',
        visibility: map['visibility'] ?? true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// App Download Links ✅ UPDATED — now has labelEn, labelAr, icon URLs
// ─────────────────────────────────────────────────────────────────────────────

class AppDownloadLinksModel {
  final String iosUrl;
  final String androidUrl;
  final String labelEn;
  final String labelAr;
  final String iosIconUrl;
  final String androidIconUrl;
  final bool   visibility;

  const AppDownloadLinksModel({
    this.iosUrl         = '',
    this.androidUrl     = '',
    this.labelEn        = '',
    this.labelAr        = '',
    this.iosIconUrl     = '',
    this.androidIconUrl = '',
    this.visibility     = true,
  });

  AppDownloadLinksModel copyWith({
    String? iosUrl,
    String? androidUrl,
    String? labelEn,
    String? labelAr,
    String? iosIconUrl,
    String? androidIconUrl,
    bool?   visibility,
  }) =>
      AppDownloadLinksModel(
        iosUrl:         iosUrl         ?? this.iosUrl,
        androidUrl:     androidUrl     ?? this.androidUrl,
        labelEn:        labelEn        ?? this.labelEn,
        labelAr:        labelAr        ?? this.labelAr,
        iosIconUrl:     iosIconUrl     ?? this.iosIconUrl,
        androidIconUrl: androidIconUrl ?? this.androidIconUrl,
        visibility:     visibility     ?? this.visibility,
      );

  Map<String, dynamic> toMap() => {
    'iosUrl':         iosUrl,
    'androidUrl':     androidUrl,
    'labelEn':        labelEn,
    'labelAr':        labelAr,
    'iosIconUrl':     iosIconUrl,
    'androidIconUrl': androidIconUrl,
    'visibility':     visibility,
  };

  factory AppDownloadLinksModel.fromMap(Map<String, dynamic> map) =>
      AppDownloadLinksModel(
        iosUrl:         map['iosUrl']         ?? '',
        androidUrl:     map['androidUrl']     ?? '',
        labelEn:        map['labelEn']        ?? '',
        labelAr:        map['labelAr']        ?? '',
        iosIconUrl:     map['iosIconUrl']     ?? '',
        androidIconUrl: map['androidIconUrl'] ?? '',
        visibility:     map['visibility']     ?? true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Branding
// ─────────────────────────────────────────────────────────────────────────────

class BrandingModel {
  final String logoUrl;
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String headerFooterColor;
  final String englishFont;
  final String arabicFont;

  const BrandingModel({
    this.logoUrl           = '',
    this.primaryColor      = '#008037',
    this.secondaryColor    = '#D9D9D9',
    this.backgroundColor   = '#D9D9D9',
    this.headerFooterColor = '#D9D9D9',
    this.englishFont       = 'Cairo',
    this.arabicFont        = 'Cairo',
  });

  BrandingModel copyWith({
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    String? headerFooterColor,
    String? englishFont,
    String? arabicFont,
  }) =>
      BrandingModel(
        logoUrl:           logoUrl           ?? this.logoUrl,
        primaryColor:      primaryColor      ?? this.primaryColor,
        secondaryColor:    secondaryColor    ?? this.secondaryColor,
        backgroundColor:   backgroundColor   ?? this.backgroundColor,
        headerFooterColor: headerFooterColor ?? this.headerFooterColor,
        englishFont:       englishFont       ?? this.englishFont,
        arabicFont:        arabicFont        ?? this.arabicFont,
      );

  Map<String, dynamic> toMap() => {
    'logoUrl':           logoUrl,
    'primaryColor':      primaryColor,
    'secondaryColor':    secondaryColor,
    'backgroundColor':   backgroundColor,
    'headerFooterColor': headerFooterColor,
    'englishFont':       englishFont,
    'arabicFont':        arabicFont,
  };

  factory BrandingModel.fromMap(Map<String, dynamic> map) => BrandingModel(
    logoUrl:           map['logoUrl']           ?? '',
    primaryColor:      map['primaryColor']      ?? '#008037',
    secondaryColor:    map['secondaryColor']    ?? '#D9D9D9',
    backgroundColor:   map['backgroundColor']   ?? '#D9D9D9',
    headerFooterColor: map['headerFooterColor'] ?? '#D9D9D9',
    englishFont:       map['englishFont']       ?? 'Cairo',
    arabicFont:        map['arabicFont']        ?? 'Cairo',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOT — HomePageModel
// ─────────────────────────────────────────────────────────────────────────────

class HomePageModel {
  final BiText                  title;
  final BiText                  shortDescription;
  final List<NavButtonModel>    navButtons;
  final List<SectionCardModel>  sections;
  final List<HeaderItemModel>   headerItems;
  final List<FooterColumnModel> footerColumns;
  final List<SocialLinkModel>   socialLinks;
  final BrandingModel           branding;
  final AppDownloadLinksModel   appDownloadLinks;
  final String                  publishStatus;
  final DateTime?               lastUpdatedAt;
  final DateTime?               scheduledPublishDate;
  final String                  gender;

  const HomePageModel({
    this.title               = const BiText(),
    this.shortDescription    = const BiText(),
    this.navButtons          = const [],
    this.sections            = const [],
    this.headerItems         = const [],
    this.footerColumns       = const [],
    this.socialLinks         = const [],
    this.branding            = const BrandingModel(),
    this.appDownloadLinks    = const AppDownloadLinksModel(),
    this.publishStatus       = 'draft',
    this.lastUpdatedAt,
    this.scheduledPublishDate,
    this.gender              = 'female',
  });

  HomePageModel copyWith({
    BiText?                  title,
    BiText?                  shortDescription,
    List<NavButtonModel>?    navButtons,
    List<SectionCardModel>?  sections,
    List<HeaderItemModel>?   headerItems,
    List<FooterColumnModel>? footerColumns,
    List<SocialLinkModel>?   socialLinks,
    BrandingModel?           branding,
    AppDownloadLinksModel?   appDownloadLinks,
    String?                  publishStatus,
    DateTime?                lastUpdatedAt,
    DateTime?                scheduledPublishDate,
    String?                  gender,
    bool                     clearScheduledPublishDate = false,
  }) =>
      HomePageModel(
        title:            title            ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        navButtons:       navButtons       ?? this.navButtons,
        sections:         sections         ?? this.sections,
        headerItems:      headerItems      ?? this.headerItems,
        footerColumns:    footerColumns    ?? this.footerColumns,
        socialLinks:      socialLinks      ?? this.socialLinks,
        branding:         branding         ?? this.branding,
        appDownloadLinks: appDownloadLinks ?? this.appDownloadLinks,
        publishStatus:    publishStatus    ?? this.publishStatus,
        lastUpdatedAt:    lastUpdatedAt    ?? this.lastUpdatedAt,
        gender:           gender           ?? this.gender,
        scheduledPublishDate: clearScheduledPublishDate
            ? null
            : (scheduledPublishDate ?? this.scheduledPublishDate),
      );

  // ── toMap — plain values (versioning is handled in the repo layer) ────────
  Map<String, dynamic> toMap() => {
    'title':               title.toMap(),
    'shortDescription':    shortDescription.toMap(),
    'navButtons':          navButtons.map((e)    => e.toMap()).toList(),
    'sections':            sections.map((e)      => e.toMap()).toList(),
    'headerItems':         headerItems.map((e)   => e.toMap()).toList(),
    'footerColumns':       footerColumns.map((e) => e.toMap()).toList(),
    'socialLinks':         socialLinks.map((e)   => e.toMap()).toList(),
    'branding':            branding.toMap(),
    'appDownloadLinks':    appDownloadLinks.toMap(),
    'publishStatus':       publishStatus,
    'lastUpdatedAt':       lastUpdatedAt?.toIso8601String(),
    'scheduledPublishDate': scheduledPublishDate?.toIso8601String(),
    'gender':              gender,
  };

  // ── fromMap — uses Versioned.read() for scalar/object fields ─────────────
  //
  //  • title, shortDescription, branding, appDownloadLinks, publishStatus,
  //    gender, scheduledPublishDate  →  versioned (stored as list in Firestore)
  //
  //  • navButtons, sections, headerItems, footerColumns, socialLinks
  //    →  NOT versioned at the root level (they are already lists and each
  //       item can carry its own history if needed in the future)
  // ─────────────────────────────────────────────────────────────────────────
  factory HomePageModel.fromMap(Map<String, dynamic> map) => HomePageModel(

    // ── versioned scalar / object fields ─────────────────────────────
    title: Versioned.read<BiText>(
      map['title'],
          (v) => BiText.fromMap(
          v is Map ? Map<String, dynamic>.from(v) : {}),
    ),

    shortDescription: Versioned.read<BiText>(
      map['shortDescription'],
          (v) => BiText.fromMap(
          v is Map ? Map<String, dynamic>.from(v) : {}),
    ),

    branding: Versioned.read<BrandingModel>(
      map['branding'],
          (v) => BrandingModel.fromMap(
          v is Map ? Map<String, dynamic>.from(v) : {}),
    ),

    appDownloadLinks: Versioned.read<AppDownloadLinksModel>(
      map['appDownloadLinks'],
          (v) => AppDownloadLinksModel.fromMap(
          v is Map ? Map<String, dynamic>.from(v) : {}),
    ),

    publishStatus: Versioned.read<String>(
      map['publishStatus'],
          (v) => v?.toString() ?? 'draft',
    ),

    gender: Versioned.read<String>(
      map['gender'],
          (v) => v?.toString() ?? 'female',
    ),

    scheduledPublishDate: Versioned.read<DateTime?>(
      map['scheduledPublishDate'],
          (v) => _parseDateTime(v),
    ),

    lastUpdatedAt: _parseDateTime(map['lastUpdatedAt']),

    // ── plain list fields (not wrapped in versioned list) ─────────────
    navButtons: (map['navButtons'] as List<dynamic>? ?? [])
        .map((e) =>
        NavButtonModel.fromMap(e as Map<String, dynamic>))
        .toList(),

    sections: (map['sections'] as List<dynamic>? ?? [])
        .map((e) =>
        SectionCardModel.fromMap(e as Map<String, dynamic>))
        .toList(),

    headerItems: (map['headerItems'] as List<dynamic>? ?? [])
        .map((e) =>
        HeaderItemModel.fromMap(e as Map<String, dynamic>))
        .toList(),

    footerColumns: (map['footerColumns'] as List<dynamic>? ?? [])
        .map((e) =>
        FooterColumnModel.fromMap(e as Map<String, dynamic>))
        .toList(),

    socialLinks: (map['socialLinks'] as List<dynamic>? ?? [])
        .map((e) =>
        SocialLinkModel.fromMap(e as Map<String, dynamic>))
        .toList(),
  );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value.runtimeType.toString().contains('Timestamp')) {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {}
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ── Default model ─────────────────────────────────────────────────────────
  static HomePageModel get defaultModel => HomePageModel(
    title: const BiText(en: 'Bayanatz', ar: 'بيانتز'),
    shortDescription: const BiText(
      en: "MENA'S Digital Transformation Pioneers",
      ar: 'رواد التحول الرقمي في منطقة الشرق الأوسط وشمال أفريقيا',
    ),
    navButtons: const [
      NavButtonModel(id: 'nb_1', name: BiText(en: 'Home',             ar: 'الرئيسية'),    route: '/',          status: true),
      NavButtonModel(id: 'nb_2', name: BiText(en: 'Overview',         ar: 'نظرة عامة'),   route: '/services',  status: true),
      NavButtonModel(id: 'nb_3', name: BiText(en: 'Our Products',     ar: 'منتجاتنا'),    route: '/about',     status: true),
      NavButtonModel(id: 'nb_4', name: BiText(en: 'About Us',         ar: 'من نحن'),      route: '/contact',   status: true),
      NavButtonModel(id: 'nb_5', name: BiText(en: 'Terms of Service', ar: 'شروط الخدمة'), route: '/terms',     status: true),
      NavButtonModel(id: 'nb_6', name: BiText(en: 'Contact Us',       ar: 'اتصل بنا'),    route: '/contactus', status: true),
    ],
    sections: List.generate(
      4,
          (i) => SectionCardModel(
        textBoxColor: '#008037',
        description: BiText(
          en: 'Section ${i + 1} description goes here.',
          ar: 'وصف القسم ${i + 1} يأتي هنا.',
        ),
      ),
    ),
    headerItems: List.generate(
      5,
          (i) => HeaderItemModel(
        id:     'hi_$i',
        title:  BiText(en: 'Header Title ${i + 1}', ar: 'عنوان ${i + 1}'),
        status: true,
      ),
    ),
    footerColumns: const [
      FooterColumnModel(
        id:    'fc_1',
        title: BiText(en: 'Our Products', ar: 'منتجاتنا'),
        route: '/about',
        labels: [
          FooterLabelModel(id: 'fl_1a', label: BiText(en: 'Client Services', ar: 'خدمات العملاء')),
          FooterLabelModel(id: 'fl_1b', label: BiText(en: 'Owner Services',  ar: 'خدمات المالك')),
        ],
      ),
      FooterColumnModel(
        id:    'fc_2',
        title: BiText(en: 'About Us', ar: 'من نحن'),
        route: '/contact',
        labels: [
          FooterLabelModel(id: 'fl_2a', label: BiText(en: 'Mission', ar: 'الرسالة'), route: '/about?tab=mission'),
          FooterLabelModel(id: 'fl_2b', label: BiText(en: 'Vision',  ar: 'الرؤية'),  route: '/about?tab=vision'),
          FooterLabelModel(id: 'fl_2c', label: BiText(en: 'Values',  ar: 'القيم'),   route: '/about?tab=values'),
        ],
      ),
      FooterColumnModel(
        id:    'fc_3',
        title: BiText(en: 'Terms of Service', ar: 'شروط الخدمة'),
        route: '/terms',
        labels: [
          FooterLabelModel(id: 'fl_3a', label: BiText(en: 'Terms and Conditions', ar: 'الشروط والأحكام'), route: '/about?tab=terms-and-conditions'),
          FooterLabelModel(id: 'fl_3b', label: BiText(en: 'Privacy Policy',       ar: 'سياسة الخصوصية'), route: '/about?tab=privacy-policy'),
        ],
      ),
      FooterColumnModel(
        id:    'fc_4',
        title: BiText(en: 'Contact Us', ar: 'اتصل بنا'),
        route: '/contactus',
        labels: [
          FooterLabelModel(id: 'fl_4a', label: BiText(en: 'Contact Form', ar: 'نموذج التواصل'), route: '/contactus'),
        ],
      ),
    ],
    socialLinks: [
      SocialLinkModel(id: 'sl_0', iconUrl: '', url: '', visibility: true),
      SocialLinkModel(id: 'sl_1', iconUrl: '', url: '', visibility: true),
      SocialLinkModel(id: 'sl_2', iconUrl: '', url: '', visibility: true),
      SocialLinkModel(id: 'sl_3', iconUrl: '', url: '', visibility: true),
    ],
    branding:         const BrandingModel(),
    appDownloadLinks: const AppDownloadLinksModel(),
    publishStatus:    'draft',
    lastUpdatedAt:    null,
    scheduledPublishDate: null,
    gender:           'female',
  );
}