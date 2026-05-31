// ******************* FILE INFO *******************
// File Name: terms_of_service_model.dart
// Description: TermsSection + TermsOfServiceModel — ALL fields flattened & versioned
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: about_us › data › models

import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_page_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS SECTION — flattened into TermsOfServiceModel (no standalone toMap)
// ═══════════════════════════════════════════════════════════════════════════════

class TermsSection {
  final String svgUrl;
  final AboutBilingualText description;
  final String attachEnUrl;
  final String attachArUrl;
  final String? lastUpdate;

  const TermsSection({
    this.svgUrl = '',
    this.description = const AboutBilingualText(),
    this.attachEnUrl = '',
    this.attachArUrl = '',
    this.lastUpdate,
  });

  TermsSection copyWith({
    String? svgUrl,
    AboutBilingualText? description,
    String? attachEnUrl,
    String? attachArUrl,
    String? lastUpdate,
  }) =>
      TermsSection(
        svgUrl: svgUrl ?? this.svgUrl,
        description: description ?? this.description,
        attachEnUrl: attachEnUrl ?? this.attachEnUrl,
        attachArUrl: attachArUrl ?? this.attachArUrl,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS OF SERVICE MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════

class TermsOfServiceModel {
  final String publishStatus;
  final AboutNavigationLabel navigationLabel;
  final TermsSection termsAndConditions;
  final TermsSection privacyPolicy;
  final DateTime? lastUpdatedAt;

  const TermsOfServiceModel({
    this.publishStatus = 'draft',
    this.navigationLabel = const AboutNavigationLabel(),
    this.termsAndConditions = const TermsSection(),
    this.privacyPolicy = const TermsSection(),
    this.lastUpdatedAt,
  });

  factory TermsOfServiceModel.empty() => const TermsOfServiceModel();

  factory TermsOfServiceModel.fromMap(Map<String, dynamic> map) {
    DateTime? lastUpdatedAt;
    if (map['Last_Updated_At'] != null) {
      if (map['Last_Updated_At'] is Timestamp) {
        lastUpdatedAt = (map['Last_Updated_At'] as Timestamp).toDate();
      } else if (map['Last_Updated_At'] is String) {
        lastUpdatedAt = DateTime.tryParse(map['Last_Updated_At']);
      }
    }

    return TermsOfServiceModel(
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
      termsAndConditions: TermsSection(
        svgUrl: Versioned.read<String>(map['Terms_And_Conditions_Svg_Url'], (v) => v?.toString() ?? ''),
        description: AboutBilingualText(
          en: Versioned.read<String>(map['Terms_And_Conditions_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Terms_And_Conditions_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
        attachEnUrl: Versioned.read<String>(map['Terms_And_Conditions_Attach_En_Url'], (v) => v?.toString() ?? ''),
        attachArUrl: Versioned.read<String>(map['Terms_And_Conditions_Attach_Ar_Url'], (v) => v?.toString() ?? ''),
        lastUpdate: Versioned.read<String?>(map['Terms_And_Conditions_Last_Update'], (v) => v?.toString()),
      ),
      privacyPolicy: TermsSection(
        svgUrl: Versioned.read<String>(map['Privacy_Policy_Svg_Url'], (v) => v?.toString() ?? ''),
        description: AboutBilingualText(
          en: Versioned.read<String>(map['Privacy_Policy_Description_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Privacy_Policy_Description_Ar'], (v) => v?.toString() ?? ''),
        ),
        attachEnUrl: Versioned.read<String>(map['Privacy_Policy_Attach_En_Url'], (v) => v?.toString() ?? ''),
        attachArUrl: Versioned.read<String>(map['Privacy_Policy_Attach_Ar_Url'], (v) => v?.toString() ?? ''),
        lastUpdate: Versioned.read<String?>(map['Privacy_Policy_Last_Update'], (v) => v?.toString()),
      ),
      lastUpdatedAt: lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'Publish_Status': publishStatus,
    'Navigation_Label_Icon_Url': navigationLabel.iconUrl,
    'Navigation_Label_Title_En': navigationLabel.title.en,
    'Navigation_Label_Title_Ar': navigationLabel.title.ar,
    'Terms_And_Conditions_Svg_Url':        termsAndConditions.svgUrl,
    'Terms_And_Conditions_Description_En': termsAndConditions.description.en,
    'Terms_And_Conditions_Description_Ar': termsAndConditions.description.ar,
    'Terms_And_Conditions_Attach_En_Url':  termsAndConditions.attachEnUrl,
    'Terms_And_Conditions_Attach_Ar_Url':  termsAndConditions.attachArUrl,
    if (termsAndConditions.lastUpdate != null)
      'Terms_And_Conditions_Last_Update':  termsAndConditions.lastUpdate,
    'Privacy_Policy_Svg_Url':        privacyPolicy.svgUrl,
    'Privacy_Policy_Description_En': privacyPolicy.description.en,
    'Privacy_Policy_Description_Ar': privacyPolicy.description.ar,
    'Privacy_Policy_Attach_En_Url':  privacyPolicy.attachEnUrl,
    'Privacy_Policy_Attach_Ar_Url':  privacyPolicy.attachArUrl,
    if (privacyPolicy.lastUpdate != null)
      'Privacy_Policy_Last_Update':  privacyPolicy.lastUpdate,
  };

  TermsOfServiceModel copyWith({
    String? publishStatus,
    AboutNavigationLabel? navigationLabel,
    TermsSection? termsAndConditions,
    TermsSection? privacyPolicy,
    DateTime? lastUpdatedAt,
  }) =>
      TermsOfServiceModel(
        publishStatus: publishStatus ?? this.publishStatus,
        navigationLabel: navigationLabel ?? this.navigationLabel,
        termsAndConditions: termsAndConditions ?? this.termsAndConditions,
        privacyPolicy: privacyPolicy ?? this.privacyPolicy,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
}
