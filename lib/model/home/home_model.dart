// ******************* FILE INFO *******************
// File Name: home_page_model.dart
// Description: Pure data model for the Home CMS.
//              No packages — only dart:core types.
// Created by: Amr Mesbah
// UPDATED: All field names use Capital_Underscore naming convention ✅
// UPDATED: ALL fields flattened — NO nested maps in Firestore ✅
// UPDATED: EVERY single field is versioned (array in Firestore,
//          .last = active value). fromMap uses Versioned.read() on ALL. ✅

/// Bilingual text wrapper
class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);

  @override
  String toString() => 'BiText(en: $en, ar: $ar)';
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

// ─────────────────────────────────────────────────────────────────────────────
// Nav Button
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Link
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
}

// ─────────────────────────────────────────────────────────────────────────────
// App Download Links — flattened into HomePageModel
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Branding — flattened into HomePageModel
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

  // ═══════════════════════════════════════════════════════════════════════════
  // toMap — ALL fields flattened, Capital_Underscore naming
  // Outputs plain primitives. Repo wraps EVERY key in Versioned.append().
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // ── Title ────────────────────────────────────────────────────────
    map['Title_En'] = title.en;
    map['Title_Ar'] = title.ar;

    // ── Short Description ────────────────────────────────────────────
    map['Short_Description_En'] = shortDescription.en;
    map['Short_Description_Ar'] = shortDescription.ar;

    // ── Nav_Buttons ──────────────────────────────────────────────────
    map['Nav_Buttons_Count'] = navButtons.length;
    for (int i = 0; i < navButtons.length; i++) {
      final nb = navButtons[i];
      map['Nav_Buttons_${i}_Id']       = nb.id;
      map['Nav_Buttons_${i}_Name_En']  = nb.name.en;
      map['Nav_Buttons_${i}_Name_Ar']  = nb.name.ar;
      map['Nav_Buttons_${i}_Route']    = nb.route;
      map['Nav_Buttons_${i}_Icon_Url'] = nb.iconUrl;
      map['Nav_Buttons_${i}_Status']   = nb.status;
    }

    // ── Sections ─────────────────────────────────────────────────────
    map['Sections_Count'] = sections.length;
    for (int i = 0; i < sections.length; i++) {
      final s = sections[i];
      map['Sections_${i}_Image_Url']      = s.imageUrl;
      map['Sections_${i}_Icon_Url']       = s.iconUrl;
      map['Sections_${i}_Text_Box_Color'] = s.textBoxColor;
      map['Sections_${i}_Description_En'] = s.description.en;
      map['Sections_${i}_Description_Ar'] = s.description.ar;
      map['Sections_${i}_Visibility']     = s.visibility;
    }

    // ── Header_Items ─────────────────────────────────────────────────
    map['Header_Items_Count'] = headerItems.length;
    for (int i = 0; i < headerItems.length; i++) {
      final hi = headerItems[i];
      map['Header_Items_${i}_Id']       = hi.id;
      map['Header_Items_${i}_Title_En'] = hi.title.en;
      map['Header_Items_${i}_Title_Ar'] = hi.title.ar;
      map['Header_Items_${i}_Status']   = hi.status;
    }

    // ── Footer_Columns ───────────────────────────────────────────────
    map['Footer_Columns_Count'] = footerColumns.length;
    for (int i = 0; i < footerColumns.length; i++) {
      final fc = footerColumns[i];
      map['Footer_Columns_${i}_Id']       = fc.id;
      map['Footer_Columns_${i}_Title_En'] = fc.title.en;
      map['Footer_Columns_${i}_Title_Ar'] = fc.title.ar;
      map['Footer_Columns_${i}_Route']    = fc.route;

      map['Footer_Columns_${i}_Labels_Count'] = fc.labels.length;
      for (int j = 0; j < fc.labels.length; j++) {
        final fl = fc.labels[j];
        map['Footer_Columns_${i}_Labels_${j}_Id']       = fl.id;
        map['Footer_Columns_${i}_Labels_${j}_Label_En'] = fl.label.en;
        map['Footer_Columns_${i}_Labels_${j}_Label_Ar'] = fl.label.ar;
        map['Footer_Columns_${i}_Labels_${j}_Route']    = fl.route;
      }
    }

    // ── Social_Links ─────────────────────────────────────────────────
    map['Social_Links_Count'] = socialLinks.length;
    for (int i = 0; i < socialLinks.length; i++) {
      final sl = socialLinks[i];
      map['Social_Links_${i}_Id']         = sl.id;
      map['Social_Links_${i}_Icon_Url']   = sl.iconUrl;
      map['Social_Links_${i}_Url']        = sl.url;
      map['Social_Links_${i}_Visibility'] = sl.visibility;
    }

    // ── Branding ─────────────────────────────────────────────────────
    map['Branding_Logo_Url']            = branding.logoUrl;
    map['Branding_Primary_Color']       = branding.primaryColor;
    map['Branding_Secondary_Color']     = branding.secondaryColor;
    map['Branding_Background_Color']    = branding.backgroundColor;
    map['Branding_Header_Footer_Color'] = branding.headerFooterColor;
    map['Branding_English_Font']        = branding.englishFont;
    map['Branding_Arabic_Font']         = branding.arabicFont;

    // ── App Download Links ───────────────────────────────────────────
    map['App_Download_Links_Ios_Url']          = appDownloadLinks.iosUrl;
    map['App_Download_Links_Android_Url']      = appDownloadLinks.androidUrl;
    map['App_Download_Links_Label_En']         = appDownloadLinks.labelEn;
    map['App_Download_Links_Label_Ar']         = appDownloadLinks.labelAr;
    map['App_Download_Links_Ios_Icon_Url']     = appDownloadLinks.iosIconUrl;
    map['App_Download_Links_Android_Icon_Url'] = appDownloadLinks.androidIconUrl;
    map['App_Download_Links_Visibility']       = appDownloadLinks.visibility;

    // ── Scalars ──────────────────────────────────────────────────────
    map['Publish_Status']         = publishStatus;
    map['Last_Updated_At']        = lastUpdatedAt?.toIso8601String();
    map['Scheduled_Publish_Date'] = scheduledPublishDate?.toIso8601String();
    map['Gender']                 = gender;

    return map;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // fromMap — EVERY field uses Versioned.read()
  //
  // In Firestore each key is an array: [v0, v1, v2, ...]
  // Versioned.read() picks .last as active value.
  // ═══════════════════════════════════════════════════════════════════════════

  factory HomePageModel.fromMap(Map<String, dynamic> map) {
    // ── Nav_Buttons ──────────────────────────────────────────────────
    final nbCount = Versioned.read<int>(
      map['Nav_Buttons_Count'], (v) => (v as int?) ?? 0,
    );
    final navButtons = <NavButtonModel>[];
    for (int i = 0; i < nbCount; i++) {
      navButtons.add(NavButtonModel(
        id: Versioned.read<String>(
          map['Nav_Buttons_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        name: BiText(
          en: Versioned.read<String>(
            map['Nav_Buttons_${i}_Name_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Nav_Buttons_${i}_Name_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        route: Versioned.read<String>(
          map['Nav_Buttons_${i}_Route'], (v) => v?.toString() ?? '',
        ),
        iconUrl: Versioned.read<String>(
          map['Nav_Buttons_${i}_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        status: Versioned.read<bool>(
          map['Nav_Buttons_${i}_Status'], (v) => v as bool? ?? true,
        ),
      ));
    }

    // ── Sections ─────────────────────────────────────────────────────
    final sCount = Versioned.read<int>(
      map['Sections_Count'], (v) => (v as int?) ?? 0,
    );
    final sections = <SectionCardModel>[];
    for (int i = 0; i < sCount; i++) {
      sections.add(SectionCardModel(
        imageUrl: Versioned.read<String>(
          map['Sections_${i}_Image_Url'], (v) => v?.toString() ?? '',
        ),
        iconUrl: Versioned.read<String>(
          map['Sections_${i}_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        textBoxColor: Versioned.read<String>(
          map['Sections_${i}_Text_Box_Color'], (v) => v?.toString() ?? '#008037',
        ),
        description: BiText(
          en: Versioned.read<String>(
            map['Sections_${i}_Description_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Sections_${i}_Description_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        visibility: Versioned.read<bool>(
          map['Sections_${i}_Visibility'], (v) => v as bool? ?? true,
        ),
      ));
    }

    // ── Header_Items ─────────────────────────────────────────────────
    final hiCount = Versioned.read<int>(
      map['Header_Items_Count'], (v) => (v as int?) ?? 0,
    );
    final headerItems = <HeaderItemModel>[];
    for (int i = 0; i < hiCount; i++) {
      headerItems.add(HeaderItemModel(
        id: Versioned.read<String>(
          map['Header_Items_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        title: BiText(
          en: Versioned.read<String>(
            map['Header_Items_${i}_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Header_Items_${i}_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        status: Versioned.read<bool>(
          map['Header_Items_${i}_Status'], (v) => v as bool? ?? true,
        ),
      ));
    }

    // ── Footer_Columns ───────────────────────────────────────────────
    final fcCount = Versioned.read<int>(
      map['Footer_Columns_Count'], (v) => (v as int?) ?? 0,
    );
    final footerColumns = <FooterColumnModel>[];
    for (int i = 0; i < fcCount; i++) {
      final flCount = Versioned.read<int>(
        map['Footer_Columns_${i}_Labels_Count'], (v) => (v as int?) ?? 0,
      );
      final labels = <FooterLabelModel>[];
      for (int j = 0; j < flCount; j++) {
        labels.add(FooterLabelModel(
          id: Versioned.read<String>(
            map['Footer_Columns_${i}_Labels_${j}_Id'], (v) => v?.toString() ?? '',
          ),
          label: BiText(
            en: Versioned.read<String>(
              map['Footer_Columns_${i}_Labels_${j}_Label_En'], (v) => v?.toString() ?? '',
            ),
            ar: Versioned.read<String>(
              map['Footer_Columns_${i}_Labels_${j}_Label_Ar'], (v) => v?.toString() ?? '',
            ),
          ),
          route: Versioned.read<String>(
            map['Footer_Columns_${i}_Labels_${j}_Route'], (v) => v?.toString() ?? '',
          ),
        ));
      }

      footerColumns.add(FooterColumnModel(
        id: Versioned.read<String>(
          map['Footer_Columns_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        title: BiText(
          en: Versioned.read<String>(
            map['Footer_Columns_${i}_Title_En'], (v) => v?.toString() ?? '',
          ),
          ar: Versioned.read<String>(
            map['Footer_Columns_${i}_Title_Ar'], (v) => v?.toString() ?? '',
          ),
        ),
        route: Versioned.read<String>(
          map['Footer_Columns_${i}_Route'], (v) => v?.toString() ?? '',
        ),
        labels: labels,
      ));
    }

    // ── Social_Links ─────────────────────────────────────────────────
    final slCount = Versioned.read<int>(
      map['Social_Links_Count'], (v) => (v as int?) ?? 0,
    );
    final socialLinks = <SocialLinkModel>[];
    for (int i = 0; i < slCount; i++) {
      socialLinks.add(SocialLinkModel(
        id: Versioned.read<String>(
          map['Social_Links_${i}_Id'], (v) => v?.toString() ?? '',
        ),
        iconUrl: Versioned.read<String>(
          map['Social_Links_${i}_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        url: Versioned.read<String>(
          map['Social_Links_${i}_Url'], (v) => v?.toString() ?? '',
        ),
        visibility: Versioned.read<bool>(
          map['Social_Links_${i}_Visibility'], (v) => v as bool? ?? true,
        ),
      ));
    }

    return HomePageModel(
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

      // ── Branding ───────────────────────────────────────────────────
      branding: BrandingModel(
        logoUrl: Versioned.read<String>(
          map['Branding_Logo_Url'], (v) => v?.toString() ?? '',
        ),
        primaryColor: Versioned.read<String>(
          map['Branding_Primary_Color'], (v) => v?.toString() ?? '#008037',
        ),
        secondaryColor: Versioned.read<String>(
          map['Branding_Secondary_Color'], (v) => v?.toString() ?? '#D9D9D9',
        ),
        backgroundColor: Versioned.read<String>(
          map['Branding_Background_Color'], (v) => v?.toString() ?? '#D9D9D9',
        ),
        headerFooterColor: Versioned.read<String>(
          map['Branding_Header_Footer_Color'], (v) => v?.toString() ?? '#D9D9D9',
        ),
        englishFont: Versioned.read<String>(
          map['Branding_English_Font'], (v) => v?.toString() ?? 'Cairo',
        ),
        arabicFont: Versioned.read<String>(
          map['Branding_Arabic_Font'], (v) => v?.toString() ?? 'Cairo',
        ),
      ),

      // ── App Download Links ─────────────────────────────────────────
      appDownloadLinks: AppDownloadLinksModel(
        iosUrl: Versioned.read<String>(
          map['App_Download_Links_Ios_Url'], (v) => v?.toString() ?? '',
        ),
        androidUrl: Versioned.read<String>(
          map['App_Download_Links_Android_Url'], (v) => v?.toString() ?? '',
        ),
        labelEn: Versioned.read<String>(
          map['App_Download_Links_Label_En'], (v) => v?.toString() ?? '',
        ),
        labelAr: Versioned.read<String>(
          map['App_Download_Links_Label_Ar'], (v) => v?.toString() ?? '',
        ),
        iosIconUrl: Versioned.read<String>(
          map['App_Download_Links_Ios_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        androidIconUrl: Versioned.read<String>(
          map['App_Download_Links_Android_Icon_Url'], (v) => v?.toString() ?? '',
        ),
        visibility: Versioned.read<bool>(
          map['App_Download_Links_Visibility'], (v) => v as bool? ?? true,
        ),
      ),

      // ── Scalars ────────────────────────────────────────────────────
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),
      gender: Versioned.read<String>(
        map['Gender'], (v) => v?.toString() ?? 'female',
      ),
      scheduledPublishDate: Versioned.read<DateTime?>(
        map['Scheduled_Publish_Date'], (v) => _parseDateTime(v),
      ),
      lastUpdatedAt: _parseDateTime(map['Last_Updated_At']),

      // ── Lists (parsed above) ───────────────────────────────────────
      navButtons:    navButtons,
      sections:      sections,
      headerItems:   headerItems,
      footerColumns: footerColumns,
      socialLinks:   socialLinks,
    );
  }

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