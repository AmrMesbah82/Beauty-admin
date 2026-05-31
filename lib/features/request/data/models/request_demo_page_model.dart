// ******************* FILE INFO *******************
// File Name: request_demo_page_model.dart
// Description: RequestDemoPageModel — ALL fields flattened & versioned.
//   Root model for the Request Demo CMS module.
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: request › data › models

import 'package:cloud_firestore/cloud_firestore.dart';
import 'bi_text.dart';
import 'demo_question_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Versioned Field Helper (local to request feature)
// ─────────────────────────────────────────────────────────────────────────────

class Versioned {
  static T read<T>(dynamic raw, T Function(dynamic) parser) {
    if (raw is List && raw.isNotEmpty) return parser(raw.last);
    if (raw != null) return parser(raw);
    return parser(null);
  }

  static List<dynamic> append(dynamic existing, dynamic newValue) {
    final history = <dynamic>[];
    if (existing is List) {
      history.addAll(existing);
    } else if (existing != null) {
      history.add(existing);
    }
    if (history.isNotEmpty) {
      final lastEncoded = _encode(history.last);
      final newEncoded  = _encode(newValue);
      if (lastEncoded == newEncoded) return history;
    }
    history.add(newValue);
    return history;
  }

  static String _encode(dynamic value) {
    if (value == null) return 'null';
    if (value is Map) {
      final sorted = Map.fromEntries(
        (value.entries.toList()
          ..sort((a, b) => a.key.toString().compareTo(b.key.toString())))
            .map((e) => MapEntry(e.key.toString(), _encode(e.value))),
      );
      return sorted.toString();
    }
    if (value is List) return value.map(_encode).toList().toString();
    return value.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL — ALL fields flattened & versioned
// ═══════════════════════════════════════════════════════════════════════════════
class RequestDemoPageModel {
  final String id;
  final String status;
  final String gender;

  // Header
  final String headerSvgUrl;
  final BiText headerTitle;

  // Demo Questions
  final List<DemoQuestionModel> demoQuestions;

  // Confirm Message
  final String confirmSvgUrl;
  final BiText confirmTitle;
  final BiText confirmDescription;

  final DateTime? lastUpdated;

  const RequestDemoPageModel({
    this.id = '',
    this.status = 'draft',
    this.gender = 'female',
    this.headerSvgUrl = '',
    this.headerTitle = const BiText(),
    this.demoQuestions = const [],
    this.confirmSvgUrl = '',
    this.confirmTitle = const BiText(),
    this.confirmDescription = const BiText(),
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['Id']     = id;
    map['Status'] = status;
    map['Gender'] = gender;

    map['Header_Svg_Url']   = headerSvgUrl;
    map['Header_Title_En']  = headerTitle.en;
    map['Header_Title_Ar']  = headerTitle.ar;

    map['Demo_Questions_Count'] = demoQuestions.length;
    for (int i = 0; i < demoQuestions.length; i++) {
      final q = demoQuestions[i];
      map['Demo_Questions_${i}_Id']          = q.id;
      map['Demo_Questions_${i}_Question_En'] = q.question.en;
      map['Demo_Questions_${i}_Question_Ar'] = q.question.ar;
      map['Demo_Questions_${i}_Type']        = q.type.toValue();
      map['Demo_Questions_${i}_Required']    = q.required;
      map['Demo_Questions_${i}_Order']       = q.order;

      map['Demo_Questions_${i}_Values_Count'] = q.values.length;
      for (int vi = 0; vi < q.values.length; vi++) {
        final v = q.values[vi];
        map['Demo_Questions_${i}_Values_${vi}_Id']       = v.id;
        map['Demo_Questions_${i}_Values_${vi}_Label_En'] = v.label.en;
        map['Demo_Questions_${i}_Values_${vi}_Label_Ar'] = v.label.ar;
      }
    }

    map['Confirm_Message_Svg_Url']        = confirmSvgUrl;
    map['Confirm_Message_Title_En']       = confirmTitle.en;
    map['Confirm_Message_Title_Ar']       = confirmTitle.ar;
    map['Confirm_Message_Description_En'] = confirmDescription.en;
    map['Confirm_Message_Description_Ar'] = confirmDescription.ar;

    map['Last_Updated'] = lastUpdated != null
        ? Timestamp.fromDate(lastUpdated!)
        : null;

    return map;
  }

  factory RequestDemoPageModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final dqCount = Versioned.read<int>(
      map['Demo_Questions_Count'], (v) => (v as int?) ?? 0,
    );
    final questions = <DemoQuestionModel>[];
    for (int i = 0; i < dqCount; i++) {
      final vCount = Versioned.read<int>(
        map['Demo_Questions_${i}_Values_Count'], (v) => (v as int?) ?? 0,
      );
      final values = <QuestionValueModel>[];
      for (int vi = 0; vi < vCount; vi++) {
        values.add(QuestionValueModel(
          id: Versioned.read<String>(
            map['Demo_Questions_${i}_Values_${vi}_Id'], (v) => v?.toString() ?? '',
          ),
          label: BiText(
            en: Versioned.read<String>(
              map['Demo_Questions_${i}_Values_${vi}_Label_En'], (v) => v?.toString() ?? '',
            ),
            ar: Versioned.read<String>(
              map['Demo_Questions_${i}_Values_${vi}_Label_Ar'], (v) => v?.toString() ?? '',
            ),
          ),
        ));
      }

      questions.add(DemoQuestionModel(
        id: Versioned.read<String>(map['Demo_Questions_${i}_Id'], (v) => v?.toString() ?? ''),
        question: BiText(
          en: Versioned.read<String>(map['Demo_Questions_${i}_Question_En'], (v) => v?.toString() ?? ''),
          ar: Versioned.read<String>(map['Demo_Questions_${i}_Question_Ar'], (v) => v?.toString() ?? ''),
        ),
        type: QuestionType.fromValue(
          Versioned.read<String>(map['Demo_Questions_${i}_Type'], (v) => v!.toString()),
        ),
        required: Versioned.read<bool>(map['Demo_Questions_${i}_Required'], (v) => (v as bool?) ?? false),
        values: values,
        order: Versioned.read<int>(map['Demo_Questions_${i}_Order'], (v) => (v as int?) ?? i),
      ));
    }
    questions.sort((a, b) => a.order.compareTo(b.order));

    DateTime? lastUpdated;
    if (map['Last_Updated'] != null) {
      if (map['Last_Updated'] is Timestamp) {
        lastUpdated = (map['Last_Updated'] as Timestamp).toDate();
      } else if (map['Last_Updated'] is String) {
        lastUpdated = DateTime.tryParse(map['Last_Updated']);
      }
    }

    return RequestDemoPageModel(
      id: docId ?? Versioned.read<String>(map['Id'], (v) => v?.toString() ?? ''),
      status: Versioned.read<String>(map['Status'], (v) => v?.toString() ?? 'draft'),
      gender: Versioned.read<String>(map['Gender'], (v) => v?.toString() ?? 'female'),
      headerSvgUrl: Versioned.read<String>(map['Header_Svg_Url'], (v) => v?.toString() ?? ''),
      headerTitle: BiText(
        en: Versioned.read<String>(map['Header_Title_En'], (v) => v?.toString() ?? ''),
        ar: Versioned.read<String>(map['Header_Title_Ar'], (v) => v?.toString() ?? ''),
      ),
      demoQuestions: questions,
      confirmSvgUrl: Versioned.read<String>(map['Confirm_Message_Svg_Url'], (v) => v?.toString() ?? ''),
      confirmTitle: BiText(
        en: Versioned.read<String>(map['Confirm_Message_Title_En'], (v) => v?.toString() ?? ''),
        ar: Versioned.read<String>(map['Confirm_Message_Title_Ar'], (v) => v?.toString() ?? ''),
      ),
      confirmDescription: BiText(
        en: Versioned.read<String>(map['Confirm_Message_Description_En'], (v) => v?.toString() ?? ''),
        ar: Versioned.read<String>(map['Confirm_Message_Description_Ar'], (v) => v?.toString() ?? ''),
      ),
      lastUpdated: lastUpdated,
    );
  }

  RequestDemoPageModel copyWith({
    String? id,
    String? status,
    String? gender,
    String? headerSvgUrl,
    BiText? headerTitle,
    List<DemoQuestionModel>? demoQuestions,
    String? confirmSvgUrl,
    BiText? confirmTitle,
    BiText? confirmDescription,
    DateTime? lastUpdated,
  }) =>
      RequestDemoPageModel(
        id: id ?? this.id,
        status: status ?? this.status,
        gender: gender ?? this.gender,
        headerSvgUrl: headerSvgUrl ?? this.headerSvgUrl,
        headerTitle: headerTitle ?? this.headerTitle,
        demoQuestions: demoQuestions ?? this.demoQuestions,
        confirmSvgUrl: confirmSvgUrl ?? this.confirmSvgUrl,
        confirmTitle: confirmTitle ?? this.confirmTitle,
        confirmDescription: confirmDescription ?? this.confirmDescription,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}
