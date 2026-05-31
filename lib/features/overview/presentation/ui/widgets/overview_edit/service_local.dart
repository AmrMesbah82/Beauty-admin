// ******************* FILE INFO *******************
// File Name: service_local.dart
// Description: Service local state helpers for Overview edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_edit

part of '../../pages/overview_edit.dart';

class _ServiceLocal {
  final String id;
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  _PickedImage image;

  _ServiceLocal({required this.id})
      : nameEn = TextEditingController(),
        nameAr = TextEditingController(),
        image = const _PickedImage();

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

// ── Local gallery item ───────────────────────────────────────────────────────
