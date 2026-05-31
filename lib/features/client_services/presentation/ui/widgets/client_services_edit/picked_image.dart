// ******************* FILE INFO *******************
// File Name: picked_image.dart
// Description: Picked image widget for Client Services edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › client_services › presentation › ui › widget › client_services_edit

part of '../../pages/client_services_edit.dart';

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});

  factory _PickedImage.empty() => const _PickedImage();

  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}
