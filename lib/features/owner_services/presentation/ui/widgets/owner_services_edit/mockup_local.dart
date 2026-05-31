// ******************* FILE INFO *******************
// File Name: mockup_local.dart
// Description: Mockup local state helpers for Owner Services edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › owner_services › presentation › ui › widget › owner_services_edit

part of '../../pages/owner_services_edit.dart';

class _MockupLocal {
  final String id;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  String alignment; // 'left', 'centered', 'right'
  _PickedImage image;

  _MockupLocal({required this.id})
    : titleEn = TextEditingController(),
      titleAr = TextEditingController(),
      descEn = TextEditingController(),
      descAr = TextEditingController(),
      alignment = 'left',
      image = _PickedImage.empty();

  void dispose() {
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
  }
}
