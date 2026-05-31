// ******************* FILE INFO *******************
// File Name: bi_text.dart
// Description: Bilingual text helper (EN + AR)
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: request › data › models

class BiText {
  final String en;
  final String ar;

  const BiText({this.en = '', this.ar = ''});

  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);
}
