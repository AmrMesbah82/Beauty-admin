// ******************* FILE INFO *******************
// File Name: demo_question_model.dart
// Description: QuestionType enum, QuestionValueModel, DemoQuestionModel
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: request › data › models

import 'bi_text.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// QUESTION TYPE
// ═══════════════════════════════════════════════════════════════════════════════
enum QuestionType {
  text,
  dropdown;

  String toValue() => name;
  static QuestionType fromValue(String? v) =>
      v == 'dropdown' ? QuestionType.dropdown : QuestionType.text;
}

// ═══════════════════════════════════════════════════════════════════════════════
// QUESTION VALUE (for dropdown type)
// ═══════════════════════════════════════════════════════════════════════════════
class QuestionValueModel {
  final String id;
  final BiText label;
  const QuestionValueModel({this.id = '', this.label = const BiText()});

  QuestionValueModel copyWith({String? id, BiText? label}) =>
      QuestionValueModel(id: id ?? this.id, label: label ?? this.label);
}

// ═══════════════════════════════════════════════════════════════════════════════
// QUESTION ITEM
// ═══════════════════════════════════════════════════════════════════════════════
class DemoQuestionModel {
  final String id;
  final BiText question;
  final QuestionType type;
  final bool required;
  final List<QuestionValueModel> values;
  final int order;

  const DemoQuestionModel({
    this.id = '',
    this.question = const BiText(),
    this.type = QuestionType.text,
    this.required = false,
    this.values = const [],
    this.order = 0,
  });

  DemoQuestionModel copyWith({
    String? id,
    BiText? question,
    QuestionType? type,
    bool? required,
    List<QuestionValueModel>? values,
    int? order,
  }) =>
      DemoQuestionModel(
        id: id ?? this.id,
        question: question ?? this.question,
        type: type ?? this.type,
        required: required ?? this.required,
        values: values ?? this.values,
        order: order ?? this.order,
      );
}
