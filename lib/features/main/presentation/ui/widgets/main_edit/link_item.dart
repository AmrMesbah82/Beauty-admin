// ******************* FILE INFO *******************
// File Name: link_item.dart
// Description: Link item widget for Main edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › main › presentation › ui › widget › main_edit

part of '../../pages/main_edit.dart';

class _LinkItem {
  final TextEditingController text;
  _PickedImage icon;
  bool visibility;

  _LinkItem()
      : text       = TextEditingController(),
        icon       = const _PickedImage(),
        visibility = true;

  void dispose() { text.dispose(); }
}

// ── Color Picker Field ────────────────────────────────────────────────────────
