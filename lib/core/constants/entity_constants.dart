// ******************* FILE INFO *******************
// File Name: entity_constants.dart
// Description: Entity type and size constants + countries list (EN + AR)
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › constant

class EntityConstants {
  EntityConstants._();

  // ── Entity Type ────────────────────────────────────────────────────────────

  static const List<String> entityTypesEn = [
    'Public Sector',
    'Semi-Government',
    'Private Sector',
    'Non-Profit',
    'Academic / Research',
    'International Organization',
    'Financial Institution',
    'Other',
  ];

  static const List<String> entityTypesAr = [
    'القطاع العام',
    'شبه حكومي',
    'القطاع الخاص',
    'غير ربحي',
    'أكاديمي / بحثي',
    'منظمة دولية',
    'مؤسسة مالية',
    'أخرى',
  ];

  // ── Entity Size ────────────────────────────────────────────────────────────

  static const List<String> entitySizes = [
    '1 to 50', '51 to 150', '151 to 500', '501 to 750', '+750',
  ];

  static const List<String> entitySizesAr = [
    '١ إلى ٥٠', '٥١ إلى ١٥٠', '١٥١ إلى ٥٠٠', '٥٠١ إلى ٧٥٠', '+٧٥٠',
  ];
}
