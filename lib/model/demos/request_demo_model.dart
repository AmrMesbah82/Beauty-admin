// ═══════════════════════════════════════════════════════════════════
// FILE: request_demo_model.dart
// Path: lib/model/request_demo/request_demo_model.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum DemoStatus {
  newDemo,
  replied,
  closed;

  String get label => switch (this) {
    DemoStatus.newDemo => 'New',
    DemoStatus.replied => 'Replied',
    DemoStatus.closed  => 'Closed',
  };

  Color get color => switch (this) {
    DemoStatus.newDemo => const Color(0xFFD16F9A),
    DemoStatus.replied => const Color(0xFFFF9800),
    DemoStatus.closed  => const Color(0xFFE53935),
  };

  static DemoStatus fromString(String? v) {
    switch (v?.toLowerCase()) {
      case 'replied':  return DemoStatus.replied;
      case 'closed':   return DemoStatus.closed;
      case 'pending':  return DemoStatus.newDemo; // map pending → new
      default:         return DemoStatus.newDemo;
    }
  }
}

enum DemoPriority {
  critical,
  high,
  medium,
  low,
  informationalOnly;

  String get label => switch (this) {
    DemoPriority.critical         => 'Critical',
    DemoPriority.high             => 'High',
    DemoPriority.medium           => 'Medium',
    DemoPriority.low              => 'Low',
    DemoPriority.informationalOnly => 'Informational Only',
  };

  Color get color => switch (this) {
    DemoPriority.critical          => const Color(0xFFE53935),
    DemoPriority.high              => const Color(0xFFFF9800),
    DemoPriority.medium            => const Color(0xFFFFEB3B),
    DemoPriority.low               => const Color(0xFF42A5F5),
    DemoPriority.informationalOnly => const Color(0xFFBDBDBD),
  };

  static List<String> get allLabels =>
      DemoPriority.values.map((e) => e.label).toList();

  static DemoPriority? fromString(String? v) {
    if (v == null) return null;
    return DemoPriority.values.firstWhere(
          (e) => e.label == v,
      orElse: () => DemoPriority.low,
    );
  }
}

enum DemoRelevance {
  strategicOpportunity,
  potentialClient,
  existingClientMatter,
  partnershipOpportunity,
  lowRelevance,
  notRelevant;

  String get label => switch (this) {
    DemoRelevance.strategicOpportunity  => 'Strategic Opportunity',
    DemoRelevance.potentialClient        => 'Potential Client',
    DemoRelevance.existingClientMatter   => 'Existing Client Matter',
    DemoRelevance.partnershipOpportunity => 'Partnership Opportunity',
    DemoRelevance.lowRelevance           => 'Low Relevance',
    DemoRelevance.notRelevant            => 'Not Relevant / Ignore',
  };

  static List<String> get allLabels =>
      DemoRelevance.values.map((e) => e.label).toList();

  static DemoRelevance? fromString(String? v) {
    if (v == null) return null;
    return DemoRelevance.values.firstWhere(
          (e) => e.label == v,
      orElse: () => DemoRelevance.lowRelevance,
    );
  }
}

enum DemoRequiredAction {
  immediateResponseRequired,
  followUpNeeded,
  reviewInternally,
  assignToSales,
  assignToTechnicalTeam,
  monitorOnly,
  noActionRequired;

  String get label => switch (this) {
    DemoRequiredAction.immediateResponseRequired => 'Immediate Response Required',
    DemoRequiredAction.followUpNeeded            => 'Follow Up Needed',
    DemoRequiredAction.reviewInternally          => 'Review Internally',
    DemoRequiredAction.assignToSales             => 'Assign to Sales',
    DemoRequiredAction.assignToTechnicalTeam     => 'Assign to Technical Team',
    DemoRequiredAction.monitorOnly               => 'Monitor Only',
    DemoRequiredAction.noActionRequired          => 'No Action Required',
  };

  static List<String> get allLabels =>
      DemoRequiredAction.values.map((e) => e.label).toList();

  static DemoRequiredAction? fromString(String? v) {
    if (v == null) return null;
    return DemoRequiredAction.values.firstWhere(
          (e) => e.label == v,
      orElse: () => DemoRequiredAction.noActionRequired,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DEMO QUESTION  (dynamic questions from Firestore)
// ─────────────────────────────────────────────────────────────────────────────

class DemoQuestion {
  final String id;
  final int    order;
  final String questionAr;
  final String questionEn;
  final bool   required;
  final String type;       // 'text' | 'dropdown' | etc.
  final int    valuesCount;

  const DemoQuestion({
    required this.id,
    required this.order,
    required this.questionAr,
    required this.questionEn,
    required this.required,
    required this.type,
    required this.valuesCount,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN MODEL
// ─────────────────────────────────────────────────────────────────────────────

class RequestDemoModel {
  final String id;
  final DateTime? submissionDate;

  // Contact info
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phone;
  final String gender;
  final String country;

  // Salon / business info
  final String salonName;
  final String noBranches;
  final String noEmployees;
  final String city;

  // Demo questions (dynamic answers stored as map: questionId -> answer)
  final Map<String, String> questionAnswers;

  // How did you hear about us / primary reason (mapped from dynamic questions)
  final String primaryReason;
  final String howDidYouHearAboutUs;

  // Admin comments
  final DemoPriority?        inquiryPriority;
  final DemoRelevance?       inquiryRelevance;
  final DemoRequiredAction?  requiredAction;
  final String               note;

  // Status
  final DemoStatus status;

  // Entity type (female / male / etc.)
  final String entityType;

  const RequestDemoModel({
    required this.id,
    this.submissionDate,
    this.firstName        = '',
    this.lastName         = '',
    this.email            = '',
    this.countryCode      = '',
    this.phone            = '',
    this.gender           = '',
    this.country          = '',
    this.salonName        = '',
    this.noBranches       = '',
    this.noEmployees      = '',
    this.city             = '',
    this.questionAnswers  = const {},
    this.primaryReason    = '',
    this.howDidYouHearAboutUs = '',
    this.inquiryPriority  ,
    this.inquiryRelevance ,
    this.requiredAction   ,
    this.note             = '',
    this.status           = DemoStatus.newDemo,
    this.entityType       = '',
  });

  factory RequestDemoModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final d = doc.data() ?? {};

    // ── Helper: get first element from array field ──────────────────
    String _str(String key) {
      final v = d[key];
      if (v is List && v.isNotEmpty) return v[0]?.toString() ?? '';
      return v?.toString() ?? '';
    }

    DateTime? parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return null;
    }

    // ── Dynamic answers: array of maps → flatten to Map<String,String>
    Map<String, String> answers = {};
    final rawAnswers = d['Dynamic_Answers'];
    if (rawAnswers is List) {
      for (final item in rawAnswers) {
        if (item is Map) {
          item.forEach((k, v) {
            answers[k.toString()] = v?.toString() ?? '';
          });
        }
      }
    }

    return RequestDemoModel(
      id:               doc.id,
      submissionDate:   parseDate(d['Created_At']),
      firstName:        _str('First_Name'),
      lastName:         _str('Last_Name'),
      email:            _str('Email'),
      countryCode:      _str('Phone_Code'),
      phone:            _str('Phone_Number'),
      gender:           _str('Gender'),
      country:          _str('Country'),
      salonName:        _str('Salon_Name'),
      noBranches:       _str('No_Branches'),
      noEmployees:      _str('No_Employees'),
      city:             _str('City'),
      questionAnswers:  answers,
      primaryReason:    _str('Primary_Reason'),
      howDidYouHearAboutUs: _str('How_Did_You_Hear'),
      inquiryPriority:  DemoPriority.fromString(_str('Inquiry_Priority')),
      inquiryRelevance: DemoRelevance.fromString(_str('Inquiry_Relevance')),
      requiredAction:   DemoRequiredAction.fromString(_str('Required_Action')),
      note:             _str('Note'),
      status:           DemoStatus.fromString(_str('Status')),
      entityType:       _str('Gender'),
    );
  }

  // ── Model → Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'firstName':         firstName,
    'lastName':          lastName,
    'email':             email,
    'countryCode':       countryCode,
    'phone':             phone,
    'gender':            gender,
    'country':           country,
    'salonName':         salonName,
    'noBranches':        noBranches,
    'noEmployees':       noEmployees,
    'city':              city,
    'questionAnswers':   questionAnswers,
    'primaryReason':     primaryReason,
    'howDidYouHearAboutUs': howDidYouHearAboutUs,
    'inquiryPriority':   inquiryPriority?.label,
    'inquiryRelevance':  inquiryRelevance?.label,
    'requiredAction':    requiredAction?.label,
    'note':              note,
    'status':            status.label,
    'entityType':        entityType,
  };

  RequestDemoModel copyWith({
    String?              id,
    DateTime?            submissionDate,
    String?              firstName,
    String?              lastName,
    String?              email,
    String?              countryCode,
    String?              phone,
    String?              gender,
    String?              country,
    String?              salonName,
    String?              noBranches,
    String?              noEmployees,
    String?              city,
    Map<String, String>? questionAnswers,
    String?              primaryReason,
    String?              howDidYouHearAboutUs,
    DemoPriority?        inquiryPriority,
    DemoRelevance?       inquiryRelevance,
    DemoRequiredAction?  requiredAction,
    String?              note,
    DemoStatus?          status,
    String?              entityType,
  }) =>
      RequestDemoModel(
        id:                   id               ?? this.id,
        submissionDate:       submissionDate   ?? this.submissionDate,
        firstName:            firstName        ?? this.firstName,
        lastName:             lastName         ?? this.lastName,
        email:                email            ?? this.email,
        countryCode:          countryCode      ?? this.countryCode,
        phone:                phone            ?? this.phone,
        gender:               gender           ?? this.gender,
        country:              country          ?? this.country,
        salonName:            salonName        ?? this.salonName,
        noBranches:           noBranches       ?? this.noBranches,
        noEmployees:          noEmployees      ?? this.noEmployees,
        city:                 city             ?? this.city,
        questionAnswers:      questionAnswers  ?? this.questionAnswers,
        primaryReason:        primaryReason    ?? this.primaryReason,
        howDidYouHearAboutUs: howDidYouHearAboutUs ?? this.howDidYouHearAboutUs,
        inquiryPriority:      inquiryPriority  ?? this.inquiryPriority,
        inquiryRelevance:     inquiryRelevance ?? this.inquiryRelevance,
        requiredAction:       requiredAction   ?? this.requiredAction,
        note:                 note             ?? this.note,
        status:               status           ?? this.status,
        entityType:           entityType       ?? this.entityType,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  REQUEST DEMO PAGE CONFIG  (from requestDemoPages collection)
// ─────────────────────────────────────────────────────────────────────────────

class RequestDemoPageConfig {
  final String id;           // 'female' | 'male' | etc.
  final String gender;
  final String headerTitleAr;
  final String headerTitleEn;
  final String headerSvgUrl;
  final String confirmTitleAr;
  final String confirmTitleEn;
  final String confirmDescAr;
  final String confirmDescEn;
  final String confirmSvgUrl;
  final String status;       // 'draft' | 'published'
  final List<DemoQuestion> questions;
  final int    demoQuestionsCount;
  final DateTime? lastUpdated;

  const RequestDemoPageConfig({
    required this.id,
    this.gender           = '',
    this.headerTitleAr    = '',
    this.headerTitleEn    = '',
    this.headerSvgUrl     = '',
    this.confirmTitleAr   = '',
    this.confirmTitleEn   = '',
    this.confirmDescAr    = '',
    this.confirmDescEn    = '',
    this.confirmSvgUrl    = '',
    this.status           = 'draft',
    this.questions        = const [],
    this.demoQuestionsCount = 0,
    this.lastUpdated,
  });

  factory RequestDemoPageConfig.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final d = doc.data() ?? {};

    // Helper: get last value from Firestore array field
    T? _last<T>(dynamic v) {
      if (v is List && v.isNotEmpty) return v.last as T?;
      return null;
    }

    String _str(dynamic v) => _last<String>(v) ?? '';
    int    _int(dynamic v) {
      final val = _last<dynamic>(v);
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }
    bool   _bool(dynamic v) => _last<bool>(v) ?? false;

    // Parse dynamic questions
    // Fields follow pattern: Demo_Questions_N_Field (array)
    final int count = _int(d['Demo_Questions_Count']);
    final List<DemoQuestion> questions = [];
    for (int i = 0; i < count; i++) {
      questions.add(DemoQuestion(
        id:          _str(d['Demo_Questions_${i}_Id']),
        order:       _int(d['Demo_Questions_${i}_Order']),
        questionAr:  _str(d['Demo_Questions_${i}_Question_Ar']),
        questionEn:  _str(d['Demo_Questions_${i}_Question_En']),
        required:    _bool(d['Demo_Questions_${i}_Required']),
        type:        _str(d['Demo_Questions_${i}_Type']),
        valuesCount: _int(d['Demo_Questions_${i}_Values_Count']),
      ));
    }
    questions.sort((a, b) => a.order.compareTo(b.order));

    DateTime? parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return null;
    }

    return RequestDemoPageConfig(
      id:                  doc.id,
      gender:              _str(d['Gender']),
      headerTitleAr:       _str(d['Header_Title_Ar']),
      headerTitleEn:       _str(d['Header_Title_En']),
      headerSvgUrl:        _str(d['Header_Svg_Url']),
      confirmTitleAr:      _str(d['Confirm_Message_Title_Ar']),
      confirmTitleEn:      _str(d['Confirm_Message_Title_En']),
      confirmDescAr:       _str(d['Confirm_Message_Description_Ar']),
      confirmDescEn:       _str(d['Confirm_Message_Description_En']),
      confirmSvgUrl:       _str(d['Confirm_Message_Svg_Url']),
      status:              _str(d['Status']),
      questions:           questions,
      demoQuestionsCount:  count,
      lastUpdated:         parseDate(d['Last_Updated']),
    );
  }
}