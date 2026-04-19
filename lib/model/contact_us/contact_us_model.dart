// ******************* FILE INFO *******************
// File Name: contact_us_model.dart
// Created by: Amr Mesbah
// UPDATED: Added gender and country to toMap() so InquiryModel can read them.
//          - gender = targetAudience value (Male/Female/Both from the dropdown)
//          - country = salonCountry value (from the Country dropdown)
//          Both Client and Owner forms use these same dropdowns.

class ContactSubmission {
  final String id;

  // ── User type ──
  final String userType; // 'client' | 'owner'

  // ── Personal info ──
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phoneNumber;
  final String preferredLanguage; // 'ar' | 'en' | 'other'

  // ── Salon info (Owner only) ──
  final String salonNameEn;
  final String salonNameAr;
  final String targetAudience; // 'Female' | 'Male' | 'Both'
  final String salonCountry;
  final String salonCity;
  final String noBranches;     // '1' | '2 To 4' | '5 To 10' | '+10'
  final String services;
  final String atLocation;     // 'At Salon' | 'At Home' | 'Both'

  // ── Message info ──
  final String subject;
  final String reason; // 'Suggestion' | 'Complaint' | 'Request' | 'Other'
  final String message;

  // ── Admin fields ──
  final String note;
  final String status; // 'New' | 'Replied' | 'Closed'
  final DateTime submissionDate;

  const ContactSubmission({
    required this.id,
    this.userType          = 'client',
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    this.preferredLanguage = 'en',
    this.salonNameEn       = '',
    this.salonNameAr       = '',
    this.targetAudience    = '',
    this.salonCountry      = '',
    this.salonCity         = '',
    this.noBranches        = '',
    this.services          = '',
    this.atLocation        = '',
    required this.subject,
    this.reason            = '',
    required this.message,
    this.note              = '',
    this.status            = 'New',
    required this.submissionDate,
  });

  /// Helper to get full name (for display / backward compat)
  String get fullName => '$firstName $lastName'.trim();

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory ContactSubmission.fromMap(String id, Map<String, dynamic> map) {
    // ── Backward compatibility: handle old docs that have 'fullName' ──
    String firstName = (map['firstName'] as String?) ?? '';
    String lastName  = (map['lastName']  as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map['fullName'] as String?) ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    // ── Backward compat: old entity fields → new salon fields ──
    String salonNameEn = (map['salonNameEn'] as String?) ?? '';
    if (salonNameEn.isEmpty) {
      salonNameEn = (map['entityName'] as String?) ?? '';
    }

    return ContactSubmission(
      id:                id,
      userType:          (map['userType']          as String?) ?? 'client',
      firstName:         firstName,
      lastName:          lastName,
      email:             (map['email']             as String?) ?? '',
      countryCode:       (map['countryCode']       as String?) ?? '',
      phoneNumber:       (map['phoneNumber']       as String?) ?? '',
      preferredLanguage: (map['preferredLanguage'] as String?) ?? 'en',
      salonNameEn:       salonNameEn,
      salonNameAr:       (map['salonNameAr']       as String?) ?? '',
      targetAudience:    (map['targetAudience']    as String?) ?? '',
      salonCountry:      (map['salonCountry']      as String?) ??
          (map['location'] as String?) ?? '',
      salonCity:         (map['salonCity']         as String?) ?? '',
      noBranches:        (map['noBranches']        as String?) ?? '',
      services:          (map['services']          as String?) ?? '',
      atLocation:        (map['atLocation']        as String?) ?? '',
      subject:           (map['subject']           as String?) ?? '',
      reason:            (map['reason']            as String?) ?? '',
      message:           (map['message']           as String?) ?? '',
      note:              (map['note']              as String?) ?? '',
      status:            (map['status']            as String?) ?? 'New',
      submissionDate:    map['submissionDate'] != null
          ? DateTime.parse(map['submissionDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userType':          userType,
    'firstName':         firstName,
    'lastName':          lastName,
    'fullName':          fullName, // ← keep for backward compat / easy queries
    'email':             email,
    'countryCode':       countryCode,
    'phoneNumber':       phoneNumber,
    'preferredLanguage': preferredLanguage,
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
    'status':            status,
    'submissionDate':    submissionDate.toIso8601String(),
    // ── NEW: write gender & country as dedicated fields ──
    // InquiryModel.fromMap() reads these for the admin table columns.
    // For Client: targetAudience = Gender dropdown value (Male/Female/Both)
    //             salonCountry   = Country dropdown value
    // For Owner:  same fields from Salon Info section
    'gender':            targetAudience,
    'country':           salonCountry,
  };

  ContactSubmission copyWith({
    String?   id,
    String?   userType,
    String?   firstName,
    String?   lastName,
    String?   email,
    String?   countryCode,
    String?   phoneNumber,
    String?   preferredLanguage,
    String?   salonNameEn,
    String?   salonNameAr,
    String?   targetAudience,
    String?   salonCountry,
    String?   salonCity,
    String?   noBranches,
    String?   services,
    String?   atLocation,
    String?   subject,
    String?   reason,
    String?   message,
    String?   note,
    String?   status,
    DateTime? submissionDate,
  }) =>
      ContactSubmission(
        id:                id                ?? this.id,
        userType:          userType          ?? this.userType,
        firstName:         firstName         ?? this.firstName,
        lastName:          lastName          ?? this.lastName,
        email:             email             ?? this.email,
        countryCode:       countryCode       ?? this.countryCode,
        phoneNumber:       phoneNumber       ?? this.phoneNumber,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
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
        status:            status            ?? this.status,
        submissionDate:    submissionDate    ?? this.submissionDate,
      );
}