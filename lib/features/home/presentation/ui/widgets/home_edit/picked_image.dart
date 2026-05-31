// ******************* FILE INFO *******************
// File Name: picked_image.dart
// Description: Picked image widget for Home edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_edit

part of '../../pages/home_edit.dart';

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}
