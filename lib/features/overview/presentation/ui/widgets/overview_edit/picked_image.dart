// ******************* FILE INFO *******************
// File Name: picked_image.dart
// Description: Picked image widget for Overview edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_edit

part of '../../pages/overview_edit.dart';

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
  bool get isValid => bytes != null || (url != null && url!.isNotEmpty);
}

// ── Local service item for editing ───────────────────────────────────────────
