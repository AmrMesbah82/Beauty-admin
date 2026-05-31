// ******************* FILE INFO *******************
// File Name: header_item.dart
// Description: Header item widget for Home edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_edit

part of '../../pages/home_edit.dart';

class _HeaderItem {
  final TextEditingController en;
  final TextEditingController ar;
  bool status;
  final String id;

  _HeaderItem({required this.id})
      : en     = TextEditingController(),
        ar     = TextEditingController(),
        status = true;

  void dispose() {
    en.dispose();
    ar.dispose();
  }
}
