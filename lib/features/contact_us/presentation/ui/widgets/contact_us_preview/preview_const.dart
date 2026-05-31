// ******************* FILE INFO *******************
// File Name: preview_const.dart
// Description: Preview constants for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _PreviewConst {
  static const List<String> preferredLanguages = ['ar', 'en', 'other'];
  static const Map<String, String> preferredLanguageLabelsEn = {
    'ar': 'Arabic', 'en': 'English', 'other': 'Other',
  };

  static const List<String> targetAudienceEn = ['Female', 'Male', 'Both'];
  static const List<String> countriesEn      = ['Egypt', 'Saudi Arabia', 'UAE', 'Kuwait', 'Qatar'];
  static const List<String> noBranchesEn     = ['1', '2 To 4', '5 To 10', '+10'];
  static const List<String> servicesEn       = ['Hair', 'Skin', 'Nails', 'Makeup', 'Spa'];
}

const List<Map<String, String>> _phoneCodes = [
  {'key': '+20',  'value': '🇪🇬 +20'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+44',  'value': '🇬🇧 +44'},
  {'key': '+1',   'value': '🇺🇸 +1'},
];

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  900.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1100.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  900.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY
// ═══════════════════════════════════════════════════════════════════════════════
