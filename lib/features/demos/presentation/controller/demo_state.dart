// ******************* FILE INFO *******************
// File Name: demo_state.dart
// Description: Demo Cubit states
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › demos › presentation › controller

// ═══════════════════════════════════════════════════════════════════
// FILE: demo_state.dart
// Path: lib/controller/request_demo/demo_state.dart
// ═══════════════════════════════════════════════════════════════════



import '../../data/models/demo_model.dart';

abstract class RequestDemoState {}

// ─── Generic ──────────────────────────────────────────────────────────────────
class RequestDemoInitial extends RequestDemoState {}

class RequestDemoLoading extends RequestDemoState {}

class RequestDemoError extends RequestDemoState {
  final String message;
  RequestDemoError(this.message);
}

// ─── List / Main page ────────────────────────────────────────────────────────
class RequestDemoLoaded extends RequestDemoState {
  // All filtered items shown in table
  final List<RequestDemoModel> filtered;

  // Summary counts
  final int totalCount;
  final int newCount;
  final int repliedCount;
  final int closedCount;

  // Dashboard analytics
  final Map<int, int>    monthlySubmissions;   // month(1-12) → count
  final Map<String, int> entityTypeCounts;     // 'female'/'male'/…  → count
  final Map<String, int> noBranchesCounts;
  final Map<String, int> noEmployeesCounts;
  final Map<String, int> primaryReasonCounts;
  final Map<String, int> howDidYouHearCounts;
  final Map<String, int> priorityCounts;
  final Map<String, int> relevanceCounts;
  final Map<String, int> requiredActionCounts;

  // Filter options
  final List<String> uniqueStatuses;
  final List<String> uniqueEntityTypes;
  final List<String> uniqueCountries;
  final List<int>    uniqueMonths;

  // Active filters
  final String? statusFilter;
  final String? entityTypeFilter;
  final String? countryFilter;
  final int?    monthFilter;
  final String  searchQuery;

  RequestDemoLoaded({
    required this.filtered,
    required this.totalCount,
    required this.newCount,
    required this.repliedCount,
    required this.closedCount,
    required this.monthlySubmissions,
    required this.entityTypeCounts,
    required this.noBranchesCounts,
    required this.noEmployeesCounts,
    required this.primaryReasonCounts,
    required this.howDidYouHearCounts,
    required this.priorityCounts,
    required this.relevanceCounts,
    required this.requiredActionCounts,
    required this.uniqueStatuses,
    required this.uniqueEntityTypes,
    required this.uniqueCountries,
    required this.uniqueMonths,
    this.statusFilter,
    this.entityTypeFilter,
    this.countryFilter,
    this.monthFilter,
    this.searchQuery = '',
  });
}

// ─── Detail page ─────────────────────────────────────────────────────────────
class RequestDemoDetailLoaded extends RequestDemoState {
  final RequestDemoModel demo;
  RequestDemoDetailLoaded(this.demo);  // removed const
}

class RequestDemoUpdated extends RequestDemoState {
  final RequestDemoModel demo;
  RequestDemoUpdated(this.demo);  // removed const
}