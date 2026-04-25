// ═══════════════════════════════════════════════════════════════════
// FILE: request_demo_cubit.dart
// Path: lib/controller/request_demo/request_demo_cubit.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/demos/request_demo_model.dart';
import '../../repo/demos/request_demo_repo.dart';
import 'request_demo_state.dart';

class RequestDemoCubit extends Cubit<RequestDemoState> {
  final RequestDemoRepo _repo;

  // Internal full list (before any filtering)
  List<RequestDemoModel> _allItems = [];

  // Active filters
  String? _statusFilter;
  String? _entityTypeFilter;
  String? _countryFilter;
  int?    _monthFilter;
  String  _searchQuery = '';

  RequestDemoCubit({RequestDemoRepo? repo})
      : _repo = repo ?? RequestDemoRepo(),
        super(RequestDemoInitial()) {
    print('🟢 [CUBIT] RequestDemoCubit created');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  LOAD ALL
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadDemos() async {
    print('🟢 [CUBIT] loadDemos() called');
    print('🟢 [CUBIT] Current state: ${state.runtimeType}');

    emit(RequestDemoLoading());
    print('🟢 [CUBIT] Emitted RequestDemoLoading state');

    try {
      print('🟢 [CUBIT] Calling repo.fetchAll()...');
      _allItems = await _repo.fetchAll();
      print('🟢 [CUBIT] Received ${_allItems.length} items from repo');

      if (_allItems.isEmpty) {
        print('⚠️ [CUBIT] WARNING: _allItems is empty!');
      } else {
        print('✅ [CUBIT] Sample item: ${_allItems.first.salonName}');
      }

      print('🟢 [CUBIT] Calling _emitLoaded()...');
      _emitLoaded();
      print('✅ [CUBIT] loadDemos() completed successfully');

    } catch (e, stackTrace) {
      print('❌ [CUBIT] ERROR in loadDemos(): $e');
      print('❌ [CUBIT] StackTrace: $stackTrace');
      emit(RequestDemoError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  LOAD DETAIL
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadDetail(String id) async {
    print('🟢 [CUBIT] loadDetail() called for ID: $id');
    emit(RequestDemoLoading());

    try {
      final demo = await _repo.fetchById(id);
      if (demo != null) {
        print('✅ [CUBIT] Detail loaded successfully');
        emit(RequestDemoDetailLoaded(demo));
      } else {
        print('⚠️ [CUBIT] Demo not found: $id');
        emit(RequestDemoError('Demo request not found.'));
      }
    } catch (e) {
      print('❌ [CUBIT] ERROR in loadDetail($id): $e');
      emit(RequestDemoError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  UPDATE STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateStatus(String id, DemoStatus status) async {
    print('🟢 [CUBIT] updateStatus() - ID: $id, Status: ${status.label}');

    try {
      await _repo.updateStatus(id, status);
      final updated = await _repo.fetchById(id);
      if (updated != null) {
        // Refresh local list
        _allItems = _allItems.map((d) => d.id == id ? updated : d).toList();
        print('✅ [CUBIT] Status updated, emitting RequestDemoUpdated');
        emit(RequestDemoUpdated(updated));
      }
    } catch (e) {
      print('❌ [CUBIT] ERROR in updateStatus: $e');
      emit(RequestDemoError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  UPDATE COMMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateComments({
    required String id,
    required String note,
    DemoPriority?       priority,
    DemoRelevance?      relevance,
    DemoRequiredAction? action,
  }) async {
    print('🟢 [CUBIT] updateComments() called for ID: $id');

    try {
      await _repo.updateComments(
        id:        id,
        note:      note,
        priority:  priority,
        relevance: relevance,
        action:    action,
      );
      final updated = await _repo.fetchById(id);
      if (updated != null) {
        _allItems = _allItems.map((d) => d.id == id ? updated : d).toList();
        print('✅ [CUBIT] Comments updated, emitting RequestDemoUpdated');
        emit(RequestDemoUpdated(updated));
      }
    } catch (e) {
      print('❌ [CUBIT] ERROR in updateComments: $e');
      emit(RequestDemoError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FILTERS
  // ═══════════════════════════════════════════════════════════════════════════

  void setSearch(String query) {
    print('🟢 [CUBIT] setSearch: "$query"');
    _searchQuery = query;
    _emitLoaded();
  }

  void setStatusFilter(String? value) {
    print('🟢 [CUBIT] setStatusFilter: $value');
    _statusFilter = value;
    _emitLoaded();
  }

  void setEntityTypeFilter(String? value) {
    print('🟢 [CUBIT] setEntityTypeFilter: $value');
    _entityTypeFilter = value;
    _emitLoaded();
  }

  void setCountryFilter(String? value) {
    print('🟢 [CUBIT] setCountryFilter: $value');
    _countryFilter = value;
    _emitLoaded();
  }

  void setMonthFilter(int? value) {
    print('🟢 [CUBIT] setMonthFilter: $value');
    _monthFilter = value;
    _emitLoaded();
  }

  void clearAllFilters() {
    print('🟢 [CUBIT] clearAllFilters() called');
    _statusFilter     = null;
    _entityTypeFilter = null;
    _countryFilter    = null;
    _monthFilter      = null;
    _searchQuery      = '';
    _emitLoaded();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  INTERNAL: build & emit loaded state
  // ═══════════════════════════════════════════════════════════════════════════

  void _emitLoaded() {
    print('🟢 [CUBIT] _emitLoaded() started');
    print('🟢 [CUBIT] _allItems count: ${_allItems.length}');

    final all = _allItems;

    // ── Counts (always from full list) ──────────────────────────────────────
    final totalCount   = all.length;
    final newCount     = all.where((d) => d.status == DemoStatus.newDemo).length;
    final repliedCount = all.where((d) => d.status == DemoStatus.replied).length;
    final closedCount  = all.where((d) => d.status == DemoStatus.closed).length;

    print('🟢 [CUBIT] Counts - Total: $totalCount, New: $newCount, Replied: $repliedCount, Closed: $closedCount');

    // ── Analytics maps ──────────────────────────────────────────────────────
    final Map<int, int>    monthly        = {};
    final Map<String, int> entityTypes    = {};
    final Map<String, int> noBranches     = {};
    final Map<String, int> noEmployees    = {};
    final Map<String, int> primaryReasons = {};
    final Map<String, int> howDidYouHear  = {};
    final Map<String, int> priorities     = {};
    final Map<String, int> relevances     = {};
    final Map<String, int> actions        = {};

    for (final d in all) {
      if (d.submissionDate != null) {
        final m = d.submissionDate!.month;
        monthly[m] = (monthly[m] ?? 0) + 1;
      }
      if (d.entityType.isNotEmpty) {
        entityTypes[d.entityType] = (entityTypes[d.entityType] ?? 0) + 1;
      }
      if (d.noBranches.isNotEmpty) {
        noBranches[d.noBranches] = (noBranches[d.noBranches] ?? 0) + 1;
      }
      if (d.noEmployees.isNotEmpty) {
        noEmployees[d.noEmployees] = (noEmployees[d.noEmployees] ?? 0) + 1;
      }
      if (d.primaryReason.isNotEmpty) {
        primaryReasons[d.primaryReason] = (primaryReasons[d.primaryReason] ?? 0) + 1;
      }
      if (d.howDidYouHearAboutUs.isNotEmpty) {
        howDidYouHear[d.howDidYouHearAboutUs] =
            (howDidYouHear[d.howDidYouHearAboutUs] ?? 0) + 1;
      }
      if (d.inquiryPriority != null) {
        final lbl = d.inquiryPriority!.label;
        priorities[lbl] = (priorities[lbl] ?? 0) + 1;
      }
      if (d.inquiryRelevance != null) {
        final lbl = d.inquiryRelevance!.label;
        relevances[lbl] = (relevances[lbl] ?? 0) + 1;
      }
      if (d.requiredAction != null) {
        final lbl = d.requiredAction!.label;
        actions[lbl] = (actions[lbl] ?? 0) + 1;
      }
    }

    // ── Filter option lists ─────────────────────────────────────────────────
    final uniqueStatuses     = all.map((d) => d.status.label).toSet().toList()..sort();
    final uniqueEntityTypes  = all.map((d) => d.entityType).where((s) => s.isNotEmpty).toSet().toList()..sort();
    final uniqueCountries    = all.map((d) => d.country).where((s) => s.isNotEmpty).toSet().toList()..sort();
    final uniqueMonths       = all
        .where((d) => d.submissionDate != null)
        .map((d) => d.submissionDate!.month)
        .toSet()
        .toList()
      ..sort();

    print('🟢 [CUBIT] Filter options - Statuses: ${uniqueStatuses.length}, EntityTypes: ${uniqueEntityTypes.length}');

    // ── Apply filters ───────────────────────────────────────────────────────
    List<RequestDemoModel> filtered = all;

    if (_statusFilter != null) {
      filtered = filtered.where((d) => d.status.label == _statusFilter).toList();
      print('🟢 [CUBIT] After status filter: ${filtered.length}');
    }
    if (_entityTypeFilter != null) {
      filtered = filtered.where((d) => d.entityType == _entityTypeFilter).toList();
      print('🟢 [CUBIT] After entity type filter: ${filtered.length}');
    }
    if (_countryFilter != null) {
      filtered = filtered.where((d) => d.country == _countryFilter).toList();
      print('🟢 [CUBIT] After country filter: ${filtered.length}');
    }
    if (_monthFilter != null) {
      filtered = filtered
          .where((d) => d.submissionDate?.month == _monthFilter)
          .toList();
      print('🟢 [CUBIT] After month filter: ${filtered.length}');
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((d) {
        return d.firstName.toLowerCase().contains(q) ||
            d.lastName.toLowerCase().contains(q)  ||
            d.email.toLowerCase().contains(q)      ||
            d.salonName.toLowerCase().contains(q)  ||
            d.country.toLowerCase().contains(q)    ||
            d.city.toLowerCase().contains(q);
      }).toList();
      print('🟢 [CUBIT] After search filter: ${filtered.length}');
    }

    print('🟢 [CUBIT] Final filtered count: ${filtered.length}');
    print('🟢 [CUBIT] Emitting RequestDemoLoaded state');

    emit(RequestDemoLoaded(
      filtered:             filtered,
      totalCount:           totalCount,
      newCount:             newCount,
      repliedCount:         repliedCount,
      closedCount:          closedCount,
      monthlySubmissions:   monthly,
      entityTypeCounts:     entityTypes,
      noBranchesCounts:     noBranches,
      noEmployeesCounts:    noEmployees,
      primaryReasonCounts:  primaryReasons,
      howDidYouHearCounts:  howDidYouHear,
      priorityCounts:       priorities,
      relevanceCounts:      relevances,
      requiredActionCounts: actions,
      uniqueStatuses:       uniqueStatuses,
      uniqueEntityTypes:    uniqueEntityTypes,
      uniqueCountries:      uniqueCountries,
      uniqueMonths:         uniqueMonths,
      statusFilter:         _statusFilter,
      entityTypeFilter:     _entityTypeFilter,
      countryFilter:        _countryFilter,
      monthFilter:          _monthFilter,
      searchQuery:          _searchQuery,
    ));

    print('✅ [CUBIT] _emitLoaded() completed');
  }
}