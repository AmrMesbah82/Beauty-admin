// ******************* FILE INFO *******************
// File Name: reason_item.dart
// Description: Reason item widget for Contact Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_edit

part of '../../pages/contact_us_edit.dart';

class _ReasonItem {
  final String id;
  final int    counter;
  final labelEnCtrl = TextEditingController();
  final labelArCtrl = TextEditingController();
  // isRequired REMOVED — lives at section level now
  _ReasonItem({required this.id, required this.counter});
}
