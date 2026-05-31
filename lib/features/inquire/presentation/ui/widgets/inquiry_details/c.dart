// ******************* FILE INFO *******************
// File Name: c.dart
// Description: Private constants/enums for Inquiry details
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › widget › inquiry_details

part of '../../pages/inquiry_details.dart';



Color _primaryFromCmsState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data)  => data.branding.primaryColor,
    _                          => '',
  };
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return ColorPick.primary;
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
