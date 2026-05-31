// ******************* FILE INFO *******************
// File Name: img.dart
// Description: Image upload widget for Request edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › presentation › ui › widget › request_edit

part of '../../pages/request_edit.dart';

class _Img {
  final Uint8List? bytes;
  final String? url;
  const _Img({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}


