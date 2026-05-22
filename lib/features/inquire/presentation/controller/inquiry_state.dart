// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_state.dart  (UPDATED — Figma-aligned states)
// Path: lib/controller/inquire/inquiry_state.dart
// NEW: userTypeFilter, genderFilter, countryFilter,
//      reasonCounts, genderCounts, languageCounts,
//      priorityCounts, relevanceCounts, requiredActionCounts
// ═══════════════════════════════════════════════════════════════════

import '../../data/model/inquire_model.dart';

abstract class InquiryState {}

class InquiryInitial extends InquiryState {}
class InquiryLoading extends InquiryState {}

class InquiryLoaded extends InquiryState {
  final List<InquiryModel> inquiries;       // full unfiltered list
  final List<InquiryModel> filtered;        // after search + filters

  // summary
  final int totalCount;
  final int newCount;
  final int repliedCount;
  final int closedCount;

  // chart data
  final Map<int, int>    monthlySubmissions;
  final Map<String, int> reasonCounts;          // Figma "Reasons" pie
  final Map<String, int> languageCounts;        // Figma "Language" pie
  final Map<String, int> genderCounts;          // Figma "Gender" pie
  final Map<String, int> locationCounts;        // Figma "Location" bar
  final Map<String, int> priorityCounts;        // Figma "Inquiry Priority" donut
  final Map<String, int> relevanceCounts;       // Figma "Inquiry Relevance" donut (left)
  final Map<String, int> requiredActionCounts;  // Figma "Inquiry Relevance" donut (right)

  // filter options
  final List<String> uniqueStatuses;
  final List<String> uniqueGenders;
  final List<String> uniqueCountries;
  final List<int>    uniqueMonths;

  // active filters
  final String? statusFilter;
  final String? userTypeFilter;   // 'Client' | 'Owner'
  final String? genderFilter;
  final String? countryFilter;
  final int?    monthFilter;

  InquiryLoaded({
    required this.inquiries,
    required this.searchQuery,
    this.statusFilter,
    this.userTypeFilter,
    this.genderFilter,
    this.countryFilter,
    this.monthFilter,
  })  : filtered        = _applyFilters(inquiries, searchQuery, statusFilter, userTypeFilter, genderFilter, countryFilter, monthFilter),
        totalCount      = inquiries.length,
        newCount        = inquiries.where((i) => i.status == InquiryStatus.newInquiry).length,
        repliedCount    = inquiries.where((i) => i.status == InquiryStatus.replied).length,
        closedCount     = inquiries.where((i) => i.status == InquiryStatus.closed).length,
        monthlySubmissions  = _countByMonth(inquiries),
        reasonCounts        = _countByField(inquiries, (i) => i.reason),
        languageCounts      = _countByField(inquiries, (i) => i.preferredLanguage),
        genderCounts        = _countByField(inquiries, (i) => i.gender),
        locationCounts      = _countByField(inquiries, (i) => i.country),
        priorityCounts      = _countByField(inquiries, (i) => i.inquiryPriority?.label ?? ''),
        relevanceCounts     = _countByField(inquiries, (i) => i.inquiryRelevance?.label ?? ''),
        requiredActionCounts = _countByField(inquiries, (i) => i.requiredAction?.label ?? ''),
        uniqueStatuses   = _unique(inquiries, (i) => i.status.label),
        uniqueGenders    = _unique(inquiries, (i) => i.gender),
        uniqueCountries  = _unique(inquiries, (i) => i.country),
        uniqueMonths     = _uniqueMonths(inquiries);

  final String searchQuery;

  // ── helpers ──────────────────────────────────────────────────────────────

  static List<InquiryModel> _applyFilters(
      List<InquiryModel> all,
      String search,
      String? status,
      String? userType,
      String? gender,
      String? country,
      int? month,
      ) {
    return all.where((i) {
      if (status   != null && i.status.label.toLowerCase()  != status.toLowerCase())   return false;
      if (userType != null && i.userType.toLowerCase()       != userType.toLowerCase()) return false;
      if (gender   != null && i.gender.toLowerCase()         != gender.toLowerCase())   return false;
      if (country  != null && i.country.toLowerCase()        != country.toLowerCase())  return false;
      if (month    != null && i.submissionDate?.month        != month)                  return false;
      if (search.isNotEmpty) {
        final q = search.toLowerCase();
        final inName    = i.fullName.toLowerCase().contains(q);
        final inEmail   = i.email.toLowerCase().contains(q);
        final inSubject = i.subject.toLowerCase().contains(q);
        final inCountry = i.country.toLowerCase().contains(q);
        if (!inName && !inEmail && !inSubject && !inCountry) return false;
      }
      return true;
    }).toList();
  }

  static Map<int, int> _countByMonth(List<InquiryModel> list) {
    final map = <int, int>{};
    for (final i in list) {
      if (i.submissionDate != null) {
        final m = i.submissionDate!.month;
        map[m] = (map[m] ?? 0) + 1;
      }
    }
    return map;
  }

  static Map<String, int> _countByField(List<InquiryModel> list, String Function(InquiryModel) fn) {
    final map = <String, int>{};
    for (final i in list) {
      final key = fn(i).trim();
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  static List<String> _unique(List<InquiryModel> list, String Function(InquiryModel) fn) {
    final seen = <String>{};
    final result = <String>[];
    for (final i in list) {
      final v = fn(i).trim();
      if (v.isNotEmpty && seen.add(v)) result.add(v);
    }
    return result;
  }

  static List<int> _uniqueMonths(List<InquiryModel> list) {
    final seen = <int>{};
    final result = <int>[];
    for (final i in list) {
      if (i.submissionDate != null) {
        final m = i.submissionDate!.month;
        if (seen.add(m)) result.add(m);
      }
    }
    result.sort();
    return result;
  }
}

class InquiryDetailLoaded extends InquiryState {
  final InquiryModel inquiry;
  InquiryDetailLoaded(this.inquiry);
}

class InquiryUpdated extends InquiryState {
  final InquiryModel inquiry;
  InquiryUpdated(this.inquiry);
}

class InquiryError extends InquiryState {
  final String message;
  final List<InquiryModel>? lastInquiries;
  InquiryError(this.message, {this.lastInquiries});
}