// ******************* FILE INFO *******************
// File Name: form_label.dart
// Description: Form label widget for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 12,
          fontWeight: FontWeight.w500, color: Color(0xFF333333)));
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════
