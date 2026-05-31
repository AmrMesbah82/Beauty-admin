// ******************* FILE INFO *******************
// File Name: picked_image.dart
// Description: Picked image widget for Master edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_edit

part of '../../pages/master_edit.dart';

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
  bool get isValid => bytes != null || (url != null && url!.isNotEmpty);
}
