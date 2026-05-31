// ******************* FILE INFO *******************
// File Name: section_header.dart
// Description: Section header widget for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 13,
          fontWeight: FontWeight.w700, color: ColorPick.primary));
}
