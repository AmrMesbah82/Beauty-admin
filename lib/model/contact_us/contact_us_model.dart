// ******************* FILE INFO *******************
// File Name: contact_us_model.dart
// Created by: Amr Mesbah
// UPDATED: All field names use Capital_Underscore naming convention ✅

class ContactSubmission {
  final String id;

  // ── User type ──
  final String userType;

  // ── Personal info ──
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phoneNumber;
  final String preferredLanguage;

  // ── Salon info (Owner only) ──
  final String salonNameEn;
  final String salonNameAr;
  final String targetAudience;
  final String salonCountry;
  final String salonCity;
  final String noBranches;
  final String services;
  final String atLocation;

  // ── Message info ──
  final String subject;
  final String reason;
  final String message;

  // ── Admin fields ──
  final String note;
  final String status;
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

  /// Helper to get full name
  String get fullName => '$firstName $lastName'.trim();

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory ContactSubmission.fromMap(String id, Map<String, dynamic> map) {
    // ── Backward compatibility: handle old docs that have 'Full_Name' ──
    String firstName = (map['First_Name'] as String?) ?? '';
    String lastName  = (map['Last_Name']  as String?) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (map['Full_Name'] as String?) ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(' ');
        firstName = parts.first;
        lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    // ── Backward compat: old entity fields → new salon fields ──
    String salonNameEn = (map['Salon_Name_En'] as String?) ?? '';
    if (salonNameEn.isEmpty) {
      salonNameEn = (map['Entity_Name'] as String?) ?? '';
    }

    return ContactSubmission(
      id:                id,
      userType:          (map['User_Type']          as String?) ?? 'client',
      firstName:         firstName,
      lastName:          lastName,
      email:             (map['Email']              as String?) ?? '',
      countryCode:       (map['Country_Code']       as String?) ?? '',
      phoneNumber:       (map['Phone_Number']       as String?) ?? '',
      preferredLanguage: (map['Preferred_Language'] as String?) ?? 'en',
      salonNameEn:       salonNameEn,
      salonNameAr:       (map['Salon_Name_Ar']      as String?) ?? '',
      targetAudience:    (map['Target_Audience']    as String?) ?? '',
      salonCountry:      (map['Salon_Country']      as String?) ?? '',
      salonCity:         (map['Salon_City']          as String?) ?? '',
      noBranches:        (map['No_Branches']        as String?) ?? '',
      services:          (map['Services']           as String?) ?? '',
      atLocation:        (map['At_Location']        as String?) ?? '',
      subject:           (map['Subject']            as String?) ?? '',
      reason:            (map['Reason']             as String?) ?? '',
      message:           (map['Message']            as String?) ?? '',
      note:              (map['Note']               as String?) ?? '',
      status:            (map['Status']             as String?) ?? 'New',
      submissionDate:    map['Submission_Date'] != null
          ? DateTime.parse(map['Submission_Date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'User_Type':          userType,
    'First_Name':         firstName,
    'Last_Name':          lastName,
    'Full_Name':          fullName,
    'Email':              email,
    'Country_Code':       countryCode,
    'Phone_Number':       phoneNumber,
    'Preferred_Language': preferredLanguage,
    'Salon_Name_En':      salonNameEn,
    'Salon_Name_Ar':      salonNameAr,
    'Target_Audience':    targetAudience,
    'Salon_Country':      salonCountry,
    'Salon_City':         salonCity,
    'No_Branches':        noBranches,
    'Services':           services,
    'At_Location':        atLocation,
    'Subject':            subject,
    'Reason':             reason,
    'Message':            message,
    'Note':               note,
    'Status':             status,
    'Submission_Date':    submissionDate.toIso8601String(),
    'Gender':             targetAudience,
    'Country':            salonCountry,
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