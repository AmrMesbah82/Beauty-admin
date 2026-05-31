// ******************* FILE INFO *******************
// File Name: mockup_local.dart
// Description: Mockup local state helpers for Client Services edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › client_services › presentation › ui › widget › client_services_edit

part of '../../pages/client_services_edit.dart';

class _MockupLocal {
  final String id;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage svg;
  MockupLayout layout;

  _MockupLocal({required this.id})
    : titleEn = TextEditingController(),
      titleAr = TextEditingController(),
      descEn = TextEditingController(),
      descAr = TextEditingController(),
      svg = _PickedImage.empty(),
      layout = MockupLayout.left;

  void dispose() {
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
  }
}
