// ******************* FILE INFO *******************
// File Name: contact_form_constants.dart
// Description: Contact form option lists — user types, languages,
//   target audience, branches, at-location, reasons, services
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › constant

class ContactFormConstants {
  ContactFormConstants._();

  // ── User types ─────────────────────────────────────────────────────────────

  static const String userTypeClient = 'client';
  static const String userTypeOwner  = 'owner';

  // ── Preferred Language ─────────────────────────────────────────────────────

  static const List<String> preferredLanguages = ['ar', 'en', 'other'];

  static const Map<String, String> preferredLanguageLabelsEn = {
    'ar':    'Arabic',
    'en':    'English',
    'other': 'Other',
  };

  static const Map<String, String> preferredLanguageLabelsAr = {
    'ar':    'العربية',
    'en':    'الإنجليزية',
    'other': 'أخرى',
  };

  // ── Target Audience ────────────────────────────────────────────────────────

  static const List<String> targetAudienceEn = ['Female', 'Male', 'Both'];
  static const List<String> targetAudienceAr = ['إناث', 'ذكور', 'كلاهما'];

  static const Map<String, String> targetAudienceArToKey = {
    'إناث':   'Female',
    'ذكور':   'Male',
    'كلاهما': 'Both',
  };

  // ── No. Branches ───────────────────────────────────────────────────────────

  static const List<String> noBranchesEn = ['1', '2 To 4', '5 To 10', '+10'];
  static const List<String> noBranchesAr = ['1', '2 إلى 4', '5 إلى 10', '+10'];

  static const Map<String, String> noBranchesArToKey = {
    '1':         '1',
    '2 إلى 4':  '2 To 4',
    '5 إلى 10': '5 To 10',
    '+10':       '+10',
  };

  // ── At Location ────────────────────────────────────────────────────────────

  static const List<String> atLocationEn = ['At Salon', 'At Home', 'Both'];
  static const List<String> atLocationAr = ['في الصالون', 'في المنزل', 'كلاهما'];

  static const Map<String, String> atLocationArToKey = {
    'في الصالون': 'At Salon',
    'في المنزل':  'At Home',
    'كلاهما':     'Both',
  };

  // ── Reason ─────────────────────────────────────────────────────────────────

  static const List<String> reasonsEn = ['Suggestion', 'Complaint', 'Request', 'Other'];
  static const List<String> reasonsAr = ['اقتراح', 'شكوى', 'طلب', 'أخرى'];

  static const Map<String, String> reasonArToKey = {
    'اقتراح': 'Suggestion',
    'شكوى':   'Complaint',
    'طلب':    'Request',
    'أخرى':   'Other',
  };

  // ── Services ───────────────────────────────────────────────────────────────

  static const List<String> servicesEn = [
    'Hair Styling', 'Skin Care', 'Nail Care', 'Makeup', 'Massage', 'Other',
  ];
  static const List<String> servicesAr = [
    'تصفيف الشعر', 'العناية بالبشرة', 'العناية بالأظافر', 'مكياج', 'مساج', 'أخرى',
  ];

  static const Map<String, String> servicesArToKey = {
    'تصفيف الشعر':     'Hair Styling',
    'العناية بالبشرة':  'Skin Care',
    'العناية بالأظافر': 'Nail Care',
    'مكياج':            'Makeup',
    'مساج':             'Massage',
    'أخرى':             'Other',
  };
}
