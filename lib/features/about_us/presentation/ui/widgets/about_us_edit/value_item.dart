// ******************* FILE INFO *******************
// File Name: value_item.dart
// Description: ValueItem row widget for About Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_edit

part of '../../pages/about_us_edit.dart';

class _ValueItem {
  final String id;
  final int counter;
  final titleEnCtrl = TextEditingController();
  final titleArCtrl = TextEditingController();
  final shortDescEnCtrl = TextEditingController();
  final shortDescArCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _ValueItem({required this.id, required this.counter});
}
