// ******************* FILE INFO *******************
// File Name: doc_item.dart
// Description: Document item row widget for Terms edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › terms_edit

part of '../../pages/terms_page/terms_edit.dart';

class _DocItem {
  Uint8List? bytes;
  String fileName;
  String existingUrl;

  _DocItem({this.bytes, this.fileName = '', this.existingUrl = ''});

  bool get hasFile => bytes != null || existingUrl.isNotEmpty;
  String get displayName =>
      bytes != null ? fileName : existingUrl.split('/').last.split('?').first;
}

// ═══════════════════════════════════════════════════════════════════════════════
