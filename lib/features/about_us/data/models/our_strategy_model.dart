// ******************* FILE INFO *******************
// File Name: our_strategy_model.dart
// Description: StrategySection + OurStrategyModel — ALL fields flattened & versioned
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: about_us › data › models

import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_page_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STRATEGY SECTION — flattened into OurStrategyModel (no standalone toMap)
// ═══════════════════════════════════════════════════════════════════════════════

class StrategySection {
  final String svgUrl;
  final AboutBilingualText description;

  const StrategySection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
  });

  factory StrategySection.empty() => const StrategySection();

  StrategySection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
  }) =>
      StrategySection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════

class OurStrategyModel {
  final String publishStatus;
  final AboutNavigationLabel navigationLabel;
  final StrategySection vision;

  final String strategicHouseEnDesktopUrl;
  final String strategicHouseEnTabletUrl;
  final String strategicHouseEnMobileUrl;

  final String strategicHouseArDesktopUrl;
  final String strategicHouseArTabletUrl;
  final String strategicHouseArMobileUrl;

  final DateTime? lastUpdatedAt;

  const OurStrategyModel({
    this.publishStatus = 'draft',
    this.navigationLabel = const AboutNavigationLabel(),
    this.vision = const StrategySection(),
    this.strategicHouseEnDesktopUrl = '',
    this.strategicHouseEnTabletUrl = '',
    this.strategicHouseEnMobileUrl = '',
    this.strategicHouseArDesktopUrl = '',
    this.strategicHouseArTabletUrl = '',
    this.strategicHouseArMobileUrl = '',
    this.lastUpdatedAt,
  });

  factory OurStrategyModel.empty() => const OurStrategyModel();

  factory OurStrategyModel.fromMap(Map<String, dynamic> map) {
    DateTime? lastUpdatedAt;
    if (map['Last_Updated_At'] != null) {
      if (map['Last_Updated_At'] is Timestamp) {
        lastUpdatedAt = (map['Last_Updated_At'] as Timestamp).toDate();
      } else if (map['Last_Updated_At'] is String) {
        lastUpdatedAt = DateTime.tryParse(map['Last_Updated_At']);
      }
    }

    return OurStrategyModel(
      publishStatus: Versioned.read<String>(
        map['Publish_Status'], (v) => v?.toString() ?? 'draft',
      ),
      navigationLabel: AboutNavigationLabel(
        iconUrl: Versioned.read<String>(map['Navigation_Label_Icon_Url'], (v) => v?.toString() ?? ''),
        title: AboutBilingualText(
          en: Versioned.read<String>(map['Navigation_Label_Title_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Navigation_Label_Title_Ar'], (v) => v?.toString() ?? ''),
        ),
      ),
      vision: StrategySection(
        svgUrl: Versioned.read<String>(map['Vision_Svg_Url'], (v) => v?.toString() ?? ''),
        description: AboutBilingualText(
          en: Versioned.read<String>(map['Vision_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Vision_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
      ),
      strategicHouseEnDesktopUrl: Versioned.read<String>(
        map['Strategic_House_En_Desktop_Url'], (v) => v?.toString() ?? '',
      ),
      strategicHouseEnTabletUrl: Versioned.read<String>(
        map['Strategic_House_En_Tablet_Url'], (v) => v?.toString() ?? '',
      ),
      strategicHouseEnMobileUrl: Versioned.read<String>(
        map['Strategic_House_En_Mobile_Url'], (v) => v?.toString() ?? '',
      ),
      strategicHouseArDesktopUrl: Versioned.read<String>(
        map['Strategic_House_Ar_Desktop_Url'], (v) => v?.toString() ?? '',
      ),
      strategicHouseArTabletUrl: Versioned.read<String>(
        map['Strategic_House_Ar_Tablet_Url'], (v) => v?.toString() ?? '',
      ),
      strategicHouseArMobileUrl: Versioned.read<String>(
        map['Strategic_House_Ar_Mobile_Url'], (v) => v?.toString() ?? '',
      ),
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'Publish_Status': publishStatus,
    'Navigation_Label_Icon_Url': navigationLabel.iconUrl,
    'Navigation_Label_Title_En': navigationLabel.title.en,
    'Navigation_Label_Title_Ar': navigationLabel.title.ar,
    'Vision_Svg_Url':        vision.svgUrl,
    'Vision_Description_En': vision.description.en,
    'Vision_Description_Ar': vision.description.ar,
    'Strategic_House_En_Desktop_Url': strategicHouseEnDesktopUrl,
    'Strategic_House_En_Tablet_Url':  strategicHouseEnTabletUrl,
    'Strategic_House_En_Mobile_Url':  strategicHouseEnMobileUrl,
    'Strategic_House_Ar_Desktop_Url': strategicHouseArDesktopUrl,
    'Strategic_House_Ar_Tablet_Url':  strategicHouseArTabletUrl,
    'Strategic_House_Ar_Mobile_Url':  strategicHouseArMobileUrl,
  };

  OurStrategyModel copyWith({
    String? publishStatus,
    AboutNavigationLabel? navigationLabel,
    StrategySection? vision,
    String? strategicHouseEnDesktopUrl,
    String? strategicHouseEnTabletUrl,
    String? strategicHouseEnMobileUrl,
    String? strategicHouseArDesktopUrl,
    String? strategicHouseArTabletUrl,
    String? strategicHouseArMobileUrl,
    DateTime? lastUpdatedAt,
  }) =>
      OurStrategyModel(
        publishStatus: publishStatus ?? this.publishStatus,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        vision: vision ?? this.vision,
        strategicHouseEnDesktopUrl: strategicHouseEnDesktopUrl ?? this.strategicHouseEnDesktopUrl,
        strategicHouseEnTabletUrl: strategicHouseEnTabletUrl ?? this.strategicHouseEnTabletUrl,
        strategicHouseEnMobileUrl: strategicHouseEnMobileUrl ?? this.strategicHouseEnMobileUrl,
        strategicHouseArDesktopUrl: strategicHouseArDesktopUrl ?? this.strategicHouseArDesktopUrl,
        strategicHouseArTabletUrl: strategicHouseArTabletUrl ?? this.strategicHouseArTabletUrl,
        strategicHouseArMobileUrl: strategicHouseArMobileUrl ?? this.strategicHouseArMobileUrl,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
}
