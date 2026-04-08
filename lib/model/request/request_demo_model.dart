/// ******************* FILE INFO *******************
/// File Name: request_demo_model.dart
/// Description: Data models for Request Demo CMS module.
///              Sections: Header (SVG + Title),
///              Demo Related Questions (repeating: Question EN/AR,
///              Type [text/dropdown], Required toggle, Values list for dropdown),
///              Confirm Message (SVG + Title + Description).
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import 'package:cloud_firestore/cloud_firestore.dart';

class BiText {
  final String en;
  final String ar;
  const BiText({this.en = '', this.ar = ''});
  factory BiText.fromMap(Map<String, dynamic>? m) =>
      BiText(en: m?['en'] ?? '', ar: m?['ar'] ?? '');
  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};
  BiText copyWith({String? en, String? ar}) =>
      BiText(en: en ?? this.en, ar: ar ?? this.ar);
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════
class RequestDemoHeaderModel {
  final String svgUrl;
  final BiText title;
  const RequestDemoHeaderModel({this.svgUrl = '', this.title = const BiText()});

  factory RequestDemoHeaderModel.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const RequestDemoHeaderModel();
    return RequestDemoHeaderModel(
        svgUrl: m['svgUrl'] ?? '', title: BiText.fromMap(m['title']));
  }
  Map<String, dynamic> toMap() => {'svgUrl': svgUrl, 'title': title.toMap()};
  RequestDemoHeaderModel copyWith({String? svgUrl, BiText? title}) =>
      RequestDemoHeaderModel(
          svgUrl: svgUrl ?? this.svgUrl, title: title ?? this.title);
}

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

  factory QuestionValueModel.fromMap(Map<String, dynamic> m) =>
      QuestionValueModel(id: m['id'] ?? '', label: BiText.fromMap(m['label']));
  Map<String, dynamic> toMap() => {'id': id, 'label': label.toMap()};
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

  factory DemoQuestionModel.fromMap(Map<String, dynamic> m) {
    final rawVals = m['values'] as List<dynamic>? ?? [];
    return DemoQuestionModel(
      id: m['id'] ?? '',
      question: BiText.fromMap(m['question']),
      type: QuestionType.fromValue(m['type']),
      required: m['required'] ?? false,
      values: rawVals
          .map((e) => QuestionValueModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      order: m['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question.toMap(),
    'type': type.toValue(),
    'required': required,
    'values': values.map((v) => v.toMap()).toList(),
    'order': order,
  };

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

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO QUESTIONS SECTION
// ═══════════════════════════════════════════════════════════════════════════════
class DemoQuestionsSectionModel {
  final List<DemoQuestionModel> questions;
  const DemoQuestionsSectionModel({this.questions = const []});

  factory DemoQuestionsSectionModel.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const DemoQuestionsSectionModel();
    final raw = m['questions'] as List<dynamic>? ?? [];
    return DemoQuestionsSectionModel(
      questions: raw
          .map((e) => DemoQuestionModel.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }
  Map<String, dynamic> toMap() =>
      {'questions': questions.map((q) => q.toMap()).toList()};
  DemoQuestionsSectionModel copyWith({List<DemoQuestionModel>? questions}) =>
      DemoQuestionsSectionModel(questions: questions ?? this.questions);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRM MESSAGE
// ═══════════════════════════════════════════════════════════════════════════════
class RequestDemoConfirmModel {
  final String svgUrl;
  final BiText title;
  final BiText description;

  const RequestDemoConfirmModel({
    this.svgUrl = '',
    this.title = const BiText(),
    this.description = const BiText(),
  });

  factory RequestDemoConfirmModel.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const RequestDemoConfirmModel();
    return RequestDemoConfirmModel(
      svgUrl: m['svgUrl'] ?? '',
      title: BiText.fromMap(m['title']),
      description: BiText.fromMap(m['description']),
    );
  }
  Map<String, dynamic> toMap() => {
    'svgUrl': svgUrl,
    'title': title.toMap(),
    'description': description.toMap(),
  };
  RequestDemoConfirmModel copyWith(
      {String? svgUrl, BiText? title, BiText? description}) =>
      RequestDemoConfirmModel(
        svgUrl: svgUrl ?? this.svgUrl,
        title: title ?? this.title,
        description: description ?? this.description,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOT MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class RequestDemoPageModel {
  final String id;
  final String status;
  final String gender;
  final RequestDemoHeaderModel header;
  final DemoQuestionsSectionModel demoQuestions;
  final RequestDemoConfirmModel confirmMessage;
  final DateTime? lastUpdated;

  const RequestDemoPageModel({
    this.id = '',
    this.status = 'draft',
    this.gender = 'female',
    this.header = const RequestDemoHeaderModel(),
    this.demoQuestions = const DemoQuestionsSectionModel(),
    this.confirmMessage = const RequestDemoConfirmModel(),
    this.lastUpdated,
  });

  factory RequestDemoPageModel.fromMap(Map<String, dynamic> m,
      {String? docId}) {
    DateTime? lu;
    if (m['lastUpdated'] is Timestamp) {
      lu = (m['lastUpdated'] as Timestamp).toDate();
    }
    return RequestDemoPageModel(
      id: docId ?? m['id'] ?? '',
      status: m['status'] ?? 'draft',
      gender: m['gender'] ?? 'female',
      header: RequestDemoHeaderModel.fromMap(m['header']),
      demoQuestions: DemoQuestionsSectionModel.fromMap(m['demoQuestions']),
      confirmMessage: RequestDemoConfirmModel.fromMap(m['confirmMessage']),
      lastUpdated: lu,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'status': status,
    'gender': gender,
    'header': header.toMap(),
    'demoQuestions': demoQuestions.toMap(),
    'confirmMessage': confirmMessage.toMap(),
    'lastUpdated':
    lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
  };

  RequestDemoPageModel copyWith({
    String? id,
    String? status,
    String? gender,
    RequestDemoHeaderModel? header,
    DemoQuestionsSectionModel? demoQuestions,
    RequestDemoConfirmModel? confirmMessage,
    DateTime? lastUpdated,
  }) =>
      RequestDemoPageModel(
        id: id ?? this.id,
        status: status ?? this.status,
        gender: gender ?? this.gender,
        header: header ?? this.header,
        demoQuestions: demoQuestions ?? this.demoQuestions,
        confirmMessage: confirmMessage ?? this.confirmMessage,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}