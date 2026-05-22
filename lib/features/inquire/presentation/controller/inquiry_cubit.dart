// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_cubit.dart  (UPDATED — Figma-aligned filters)
// Path: lib/controller/inquire/inquiry_cubit.dart
// NEW: userTypeFilter, genderFilter, countryFilter
//      updateComments (priority + relevance + requiredAction + note)
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';


import '../../data/model/inquire_model.dart';
import '../../domain/repo/inquiry_repo.dart';
import 'inquiry_state.dart';

class InquiryCubit extends Cubit<InquiryState> {
  final InquiryRepo _repo;

  InquiryCubit({required InquiryRepo repo})
      : _repo = repo,
        super(InquiryInitial());

  List<InquiryModel> _allInquiries = [];
  String  _searchQuery    = '';
  String? _statusFilter;
  String? _userTypeFilter;   // 'Client' | 'Owner'
  String? _genderFilter;
  String? _countryFilter;
  int?    _monthFilter;

  List<InquiryModel> get allInquiries => _allInquiries;

  // ── Load ────────────────────────────────────────────────────────────────

  Future<void> loadInquiries() async {
    try {
      emit(InquiryLoading());
      _allInquiries = await _repo.fetchAllInquiries();
      _emitLoaded();
    } catch (e) {
      emit(InquiryError('Failed to load: $e', lastInquiries: _allInquiries));
    }
  }

  // ── Filter setters ──────────────────────────────────────────────────────

  void setSearch(String query) { _searchQuery = query; _emitLoaded(); }

  void setStatusFilter(String? v)   { _statusFilter   = v; _emitLoaded(); }
  void setUserTypeFilter(String? v) { _userTypeFilter  = v; _emitLoaded(); }
  void setGenderFilter(String? v)   { _genderFilter    = v; _emitLoaded(); }
  void setCountryFilter(String? v)  { _countryFilter   = v; _emitLoaded(); }
  void setMonthFilter(int? v)       { _monthFilter     = v; _emitLoaded(); }

  // keep old names as aliases so existing call-sites still compile
  void setEntityTypeFilter(String? v) => setUserTypeFilter(v);
  void setLocationFilter(String? v)   => setCountryFilter(v);

  void clearAllFilters() {
    _searchQuery = '';
    _statusFilter = _userTypeFilter = _genderFilter = _countryFilter = null;
    _monthFilter  = null;
    _emitLoaded();
  }

  // ── Detail ──────────────────────────────────────────────────────────────

  Future<void> loadDetail(String id) async {
    try {
      final local = _allInquiries.where((i) => i.id == id).toList();
      if (local.isNotEmpty) { emit(InquiryDetailLoaded(local.first)); return; }
      final inquiry = await _repo.fetchInquiryById(id);
      if (inquiry != null) emit(InquiryDetailLoaded(inquiry));
      else emit(InquiryError('Inquiry not found', lastInquiries: _allInquiries));
    } catch (e) {
      emit(InquiryError('Failed to load: $e', lastInquiries: _allInquiries));
    }
  }

  // ── Update status ────────────────────────────────────────────────────────

  Future<void> updateStatus(String id, InquiryStatus newStatus) async {
    try {
      await _repo.updateStatus(id, newStatus);
      _allInquiries = _allInquiries.map((i) => i.id == id ? i.copyWith(status: newStatus) : i).toList();
      final updated = _allInquiries.firstWhere((i) => i.id == id);
      emit(InquiryUpdated(updated));
      Future.delayed(const Duration(milliseconds: 100), () { if (!isClosed) _emitLoaded(); });
    } catch (e) {
      emit(InquiryError('Failed to update: $e', lastInquiries: _allInquiries));
    }
  }

  // ── Update note ──────────────────────────────────────────────────────────

  Future<void> updateNote(String id, String note) async {
    try {
      final inquiry = _allInquiries.firstWhere((i) => i.id == id);
      final updated = inquiry.copyWith(note: note);
      await _repo.updateInquiry(updated);
      _allInquiries = _allInquiries.map((i) => i.id == id ? updated : i).toList();
      emit(InquiryUpdated(updated));
      Future.delayed(const Duration(milliseconds: 100), () { if (!isClosed) _emitLoaded(); });
    } catch (e) {
      emit(InquiryError('Failed to save: $e', lastInquiries: _allInquiries));
    }
  }

  // ── Update "Our Comments" fields (priority + relevance + action + note) ──

  Future<void> updateComments({
    required String          id,
    required String          note,
    required InquiryPriority?  priority,
    required InquiryRelevance? relevance,
    required RequiredAction?   action,
  }) async {
    try {
      final inquiry = _allInquiries.firstWhere((i) => i.id == id);
      final updated = inquiry.copyWith(
        note:             note,
        inquiryPriority:  priority,
        inquiryRelevance: relevance,
        requiredAction:   action,
      );
      await _repo.updateInquiry(updated);
      _allInquiries = _allInquiries.map((i) => i.id == id ? updated : i).toList();
      emit(InquiryUpdated(updated));
      Future.delayed(const Duration(milliseconds: 100), () { if (!isClosed) _emitLoaded(); });
    } catch (e) {
      emit(InquiryError('Failed to save: $e', lastInquiries: _allInquiries));
    }
  }

  void backToList() => _emitLoaded();

  void _emitLoaded() {
    emit(InquiryLoaded(
      inquiries:      _allInquiries,
      searchQuery:    _searchQuery,
      statusFilter:   _statusFilter,
      userTypeFilter: _userTypeFilter,
      genderFilter:   _genderFilter,
      countryFilter:  _countryFilter,
      monthFilter:    _monthFilter,
    ));
  }
}