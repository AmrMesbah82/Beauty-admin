// ******************* FILE INFO *******************
// File Name: v_local.dart
// Description: Value localisation helpers for Request edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › presentation › ui › widget › request_edit

part of '../../pages/request_edit.dart';

class _VLocal {
  final String id;
  final TextEditingController en, ar;
  _VLocal({required this.id})
      : en = TextEditingController(),
        ar = TextEditingController();
  void dispose() {
    en.dispose();
    ar.dispose();
  }
}
