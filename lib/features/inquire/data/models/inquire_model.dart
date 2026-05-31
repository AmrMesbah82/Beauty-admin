// ******************* FILE INFO *******************
// File Name: inquire_model.dart
// Description: InquireModel data class
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › data › models

// ═══════════════════════════════════════════════════════════════════
// FILE: inquire_model.dart (FULLY UPDATED)
// Path: lib/model/inquire/inquire_model.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  STATUS
// ─────────────────────────────────────────────────────────────────────────────
enum InquiryStatus {
  newInquiry,
  replied,
  closed;

  String get label {
    switch (this) {
      case InquiryStatus.newInquiry: return 'New';
      case InquiryStatus.replied:    return 'Replied';
      case InquiryStatus.closed:     return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case InquiryStatus.newInquiry: return const Color(0xFFD16F9A);
      case InquiryStatus.replied:    return const Color(0xFFFF9800);
      case InquiryStatus.closed:     return const Color(0xFFE53935);
    }
  }

  static InquiryStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':     return InquiryStatus.newInquiry;
      case 'replied': return InquiryStatus.replied;
      case 'closed':  return InquiryStatus.closed;
      default:        return InquiryStatus.newInquiry;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INQUIRY PRIORITY
// ─────────────────────────────────────────────────────────────────────────────
enum InquiryPriority {
  critical,
  high,
  medium,
  low,
  informationalOnly;

  String get label {
    switch (this) {
      case InquiryPriority.critical:          return 'Critical';
      case InquiryPriority.high:              return 'High';
      case InquiryPriority.medium:            return 'Medium';
      case InquiryPriority.low:               return 'Low';
      case InquiryPriority.informationalOnly: return 'Informational Only';
    }
  }

  Color get color {
    switch (this) {
      case InquiryPriority.critical:          return const Color(0xFFE53935);
      case InquiryPriority.high:              return const Color(0xFFFF7043);
      case InquiryPriority.medium:            return const Color(0xFFFFC107);
      case InquiryPriority.low:               return const Color(0xFF42A5F5);
      case InquiryPriority.informationalOnly: return const Color(0xFF9E9E9E);
    }
  }

  static InquiryPriority? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'critical':           return InquiryPriority.critical;
      case 'high':               return InquiryPriority.high;
      case 'medium':             return InquiryPriority.medium;
      case 'low':                return InquiryPriority.low;
      case 'informational only': return InquiryPriority.informationalOnly;
      default:                   return null;
    }
  }

  static List<String> get allLabels =>
      ['Critical', 'High', 'Medium', 'Low', 'Informational Only'];
}

// ─────────────────────────────────────────────────────────────────────────────
//  INQUIRY RELEVANCE
// ─────────────────────────────────────────────────────────────────────────────
enum InquiryRelevance {
  strategicOpportunity,
  potentialClient,
  existingClientMatter,
  partnershipOpportunity,
  lowRelevance,
  notRelevantIgnore;

  String get label {
    switch (this) {
      case InquiryRelevance.strategicOpportunity:  return 'Strategic Opportunity';
      case InquiryRelevance.potentialClient:        return 'Potential Client';
      case InquiryRelevance.existingClientMatter:   return 'Existing Client Matter';
      case InquiryRelevance.partnershipOpportunity: return 'Partnership Opportunity';
      case InquiryRelevance.lowRelevance:           return 'Low Relevance';
      case InquiryRelevance.notRelevantIgnore:      return 'Not Relevant / Ignore';
    }
  }

  static InquiryRelevance? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final v in InquiryRelevance.values) {
      if (v.label.toLowerCase() == value.toLowerCase()) return v;
    }
    return null;
  }

  static List<String> get allLabels => [
    'Strategic Opportunity', 'Potential Client', 'Existing Client Matter',
    'Partnership Opportunity', 'Low Relevance', 'Not Relevant / Ignore',
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  REQUIRED ACTION
// ─────────────────────────────────────────────────────────────────────────────
enum RequiredAction {
  immediateResponseRequired,
  followUpNeeded,
  reviewInternally,
  assignToSales,
  assignToTechnicalTeam,
  monitorOnly,
  noActionRequired,
  closed;

  String get label {
    switch (this) {
      case RequiredAction.immediateResponseRequired: return 'Immediate Response Required';
      case RequiredAction.followUpNeeded:            return 'Follow Up Needed';
      case RequiredAction.reviewInternally:          return 'Review Internally';
      case RequiredAction.assignToSales:             return 'Assign to Sales';
      case RequiredAction.assignToTechnicalTeam:     return 'Assign to Technical Team';
      case RequiredAction.monitorOnly:               return 'Monitor Only';
      case RequiredAction.noActionRequired:          return 'No Action Required';
      case RequiredAction.closed:                    return 'Closed';
    }
  }

  static RequiredAction? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final v in RequiredAction.values) {
      if (v.label.toLowerCase() == value.toLowerCase()) return v;
    }
    return null;
  }

  static List<String> get allLabels => [
    'Immediate Response Required', 'Follow Up Needed', 'Review Internally',
    'Assign to Sales', 'Assign to Technical Team', 'Monitor Only',
    'No Action Required', 'Closed',
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────────────────────
class InquiryModel {
  final String id;
  final String userType;
  final String preferredLanguage;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phone;
  final String gender;
  final String country;
  final String salonNameEn;
  final String salonNameAr;
  final String targetAudience;
  final String salonCountry;
  final String salonCity;
  final String noBranches;
  final String services;
  final String atLocation;
  final String subject;
  final String reason;
  final String message;
  final String note;
  final InquiryPriority?  inquiryPriority;
  final InquiryRelevance? inquiryRelevance;
  final RequiredAction?   requiredAction;
  final InquiryStatus status;
  final DateTime? submissionDate;

  const InquiryModel({
    required this.id,
    this.userType           = 'client',
    required this.preferredLanguage,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phone,
    this.gender             = '',
    this.country            = '',
    this.salonNameEn        = '',
    this.salonNameAr        = '',
    this.targetAudience     = '',
    this.salonCountry       = '',
    this.salonCity          = '',
    this.noBranches         = '',
    this.services           = '',
    this.atLocation         = '',
    required this.subject,
    this.reason             = '',
    required this.message,
    required this.note,
    this.inquiryPriority,
    this.inquiryRelevance,
    this.requiredAction,
    required this.status,
    this.submissionDate,
  });

  String get fullName => '$firstName $lastName'.trim();

  // ── From Firestore Map ──────────────────────────────────────────────────
  factory InquiryModel.fromMap(String id, Map<String, dynamic> map) {

    // ── Helper: try multiple key variants, return first non-empty string ──
    String str(List<String> keys) {
      for (final k in keys) {
        final v = map[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return '';
    }

    // ── Helper: parse DateTime from Timestamp or ISO string ──
    DateTime? parseDate(List<String> keys) {
      for (final k in keys) {
        final v = map[k];
        if (v is Timestamp) {
          return v.toDate();
        }
        if (v is String && v.isNotEmpty) {
          final parsed = DateTime.tryParse(v);
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return null;
    }

    // ── Name ──
    String firstName = str(['First_Name', 'firstName', 'first_name']);
    String lastName  = str(['Last_Name',  'lastName',  'last_name']);
    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = str(['Full_Name', 'fullName', 'full_name']);
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    // ── Gender with fallback ──
    String gender = str(['Gender', 'gender']);
    if (gender.isEmpty) {
      gender = str(['Target_Audience', 'targetAudience']);
      if (gender.isNotEmpty) {
      }
    }

    // ── Country with fallback ──
    String country = str(['Country', 'country']);
    if (country.isEmpty) {
      country = str(['Salon_Country', 'salonCountry', 'location', 'Location']);
      if (country.isNotEmpty) {
      }
    }

    // ── salonCountry ──
    String salonCountry = str(['Salon_Country', 'salonCountry']);
    if (salonCountry.isEmpty) {
      salonCountry = str(['location', 'Location']);
    }

    // ── salonNameEn ──
    String salonNameEn = str(['Salon_Name_En', 'salonNameEn', 'salon_name_en']);
    if (salonNameEn.isEmpty) {
      salonNameEn = str(['Entity_Name', 'entityName']);
    }

    final model = InquiryModel(
      id:                id,
      userType:          str(['User_Type',          'userType',          'user_type']),
      preferredLanguage: str(['Preferred_Language', 'preferredLanguage', 'preferred_language']),
      firstName:         firstName,
      lastName:          lastName,
      email:             str(['Email',              'email']),
      countryCode:       str(['Country_Code',       'countryCode',       'country_code']),
      phone:             str(['Phone_Number',       'phoneNumber',       'phone_number', 'phone']),
      gender:            gender,
      country:           country,
      salonNameEn:       salonNameEn,
      salonNameAr:       str(['Salon_Name_Ar',      'salonNameAr',       'salon_name_ar']),
      targetAudience:    str(['Target_Audience',    'targetAudience',    'target_audience']),
      salonCountry:      salonCountry,
      salonCity:         str(['Salon_City',         'salonCity',         'salon_city']),
      noBranches:        str(['No_Branches',        'noBranches',        'no_branches']),
      services:          str(['Services',           'services']),
      atLocation:        str(['At_Location',        'atLocation',        'at_location']),
      subject:           str(['Subject',            'subject']),
      reason:            str(['Reason',             'reason']),
      message:           str(['Message',            'message']),
      note:              str(['Note',               'note']),
      inquiryPriority:   InquiryPriority.fromString(
          str(['Inquiry_Priority',  'inquiryPriority',  'inquiry_priority'])),
      inquiryRelevance:  InquiryRelevance.fromString(
          str(['Inquiry_Relevance', 'inquiryRelevance', 'inquiry_relevance'])),
      requiredAction:    RequiredAction.fromString(
          str(['Required_Action',   'requiredAction',   'required_action'])),
      status: InquiryStatus.fromString(
          str(['Status', 'status']).isEmpty ? 'New' : str(['Status', 'status'])),
      submissionDate: parseDate([
        'Submission_Date', 'submissionDate', 'submission_date',
        'createdAt',       'created_at',     'Created_At',
      ]),
    );


    return model;
  }

  // ── To Firestore Map ────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'userType':          userType,
    'firstName':         firstName,
    'lastName':          lastName,
    'fullName':          fullName,
    'email':             email,
    'countryCode':       countryCode,
    'phoneNumber':       phone,
    'preferredLanguage': preferredLanguage,
    'gender':            gender,
    'country':           country,
    'salonNameEn':       salonNameEn,
    'salonNameAr':       salonNameAr,
    'targetAudience':    targetAudience,
    'salonCountry':      salonCountry,
    'salonCity':         salonCity,
    'noBranches':        noBranches,
    'services':          services,
    'atLocation':        atLocation,
    'subject':           subject,
    'reason':            reason,
    'message':           message,
    'note':              note,
    'inquiryPriority':   inquiryPriority?.label,
    'inquiryRelevance':  inquiryRelevance?.label,
    'requiredAction':    requiredAction?.label,
    'status':            status.label,
    'submissionDate':    submissionDate?.toIso8601String(),
  };

  // ── copyWith ────────────────────────────────────────────────────────────
  InquiryModel copyWith({
    String? id,
    String? userType,
    String? preferredLanguage,
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    String? phone,
    String? gender,
    String? country,
    String? salonNameEn,
    String? salonNameAr,
    String? targetAudience,
    String? salonCountry,
    String? salonCity,
    String? noBranches,
    String? services,
    String? atLocation,
    String? subject,
    String? reason,
    String? message,
    String? note,
    Object? inquiryPriority  = _sentinel,
    Object? inquiryRelevance = _sentinel,
    Object? requiredAction   = _sentinel,
    InquiryStatus? status,
    DateTime? submissionDate,
  }) =>
      InquiryModel(
        id:                id                ?? this.id,
        userType:          userType          ?? this.userType,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        firstName:         firstName         ?? this.firstName,
        lastName:          lastName          ?? this.lastName,
        email:             email             ?? this.email,
        countryCode:       countryCode       ?? this.countryCode,
        phone:             phone             ?? this.phone,
        gender:            gender            ?? this.gender,
        country:           country           ?? this.country,
        salonNameEn:       salonNameEn       ?? this.salonNameEn,
        salonNameAr:       salonNameAr       ?? this.salonNameAr,
        targetAudience:    targetAudience    ?? this.targetAudience,
        salonCountry:      salonCountry      ?? this.salonCountry,
        salonCity:         salonCity         ?? this.salonCity,
        noBranches:        noBranches        ?? this.noBranches,
        services:          services          ?? this.services,
        atLocation:        atLocation        ?? this.atLocation,
        subject:           subject           ?? this.subject,
        reason:            reason            ?? this.reason,
        message:           message           ?? this.message,
        note:              note              ?? this.note,
        inquiryPriority:  inquiryPriority  == _sentinel
            ? this.inquiryPriority  : inquiryPriority  as InquiryPriority?,
        inquiryRelevance: inquiryRelevance == _sentinel
            ? this.inquiryRelevance : inquiryRelevance as InquiryRelevance?,
        requiredAction:   requiredAction   == _sentinel
            ? this.requiredAction   : requiredAction   as RequiredAction?,
        status:            status            ?? this.status,
        submissionDate:    submissionDate    ?? this.submissionDate,
      );
}

const Object _sentinel = Object();