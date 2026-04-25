// ═══════════════════════════════════════════════════════════════════
// FILE: request_demo_main_page.dart
// Path: lib/pages/dashboard/demos/request_demo_main_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:beauty_admin/dashboard/demos/request_demo_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:beauty_admin/core/widget/custom_dropdwon.dart';
import 'package:beauty_admin/core/widget/button.dart';
import 'package:beauty_admin/core/widget/search.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/model/demos/request_demo_model.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/app_admin_navbar.dart';

import '../../controller/demos/request_demo_cubit.dart';
import '../../controller/demos/request_demo_state.dart';
import '../../controller/home/home_cubit.dart';
import '../../controller/home/home_state.dart';
import '../main_page/home_main_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const Color primary      = Color(0xFFD16F9A);
  static const Color primaryLight = Color(0xFFE8A0BE);
  static const Color back         = Color(0xFFF5F5F5);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color labelText    = Color(0xFF333333);
  static const Color hintText     = Color(0xFFAAAAAA);
  static const Color border       = Color(0xFFE0E0E0);
}

Color _primaryFromCmsState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data)  => data.branding.primaryColor,
    _                          => '',
  };
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return _C.primary;
}

const List<String> _kMonthNames = [
  'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
];

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
class RequestDemoMainPage extends StatefulWidget {
  const RequestDemoMainPage({super.key});
  @override State<RequestDemoMainPage> createState() => _RequestDemoMainPageState();
}

class _RequestDemoMainPageState extends State<RequestDemoMainPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RequestDemoCubit>().loadDemos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CSV EXPORT
  // ═══════════════════════════════════════════════════════════════════════════

  String _esc(String v) {
    if (v.isEmpty) return '';
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${_kMonthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _showExportDialog(List<RequestDemoModel> demos) {
    final fileNameCtrl = TextEditingController();
    bool isExporting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Container(
            width: 400.w,
            padding: EdgeInsets.all(20.sp),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 30.sp, height: 30.sp,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.primary),
                  child: Icon(Icons.file_download_outlined, size: 16.sp, color: Colors.white),
                ),
                SizedBox(width: 8.sp),
                Text('Export', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: _C.labelText)),
              ]),
              SizedBox(height: 20.sp),
              CustomValidatedTextFieldMaster(
                label: 'File Name', hint: 'Enter file name',
                controller: fileNameCtrl, height: 36, submitted: false,
                primaryColor: _C.primary, fillColor: const Color(0xFFF1F2ED),
              ),
              SizedBox(height: 20.sp),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: isExporting ? null : () => Navigator.of(ctx).pop(),
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8.r)),
                    child: Center(child: Text('Discard', style: TextStyle(fontSize: 14.sp, color: _C.labelText))),
                  ),
                )),
                SizedBox(width: 15.sp),
                Expanded(child: GestureDetector(
                  onTap: isExporting ? null : () {
                    final fn = fileNameCtrl.text.trim();
                    if (fn.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a file name')));
                      return;
                    }
                    setDlg(() => isExporting = true);
                    _performExport(demos, fn);
                    Navigator.of(ctx).pop();
                    _showExportSuccessDialog(fn);
                  },
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: isExporting ? Colors.grey : _C.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(child: isExporting
                        ? SizedBox(width: 16.sp, height: 16.sp, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Download', style: TextStyle(fontSize: 14.sp, color: Colors.white))),
                  ),
                )),
              ]),
            ]),
          ),
        );
      }),
    );
  }

  void _performExport(List<RequestDemoModel> demos, String fileName) {
    try {
      final buf = StringBuffer();
      final headers = [
        'No', 'Submission Date', 'Salon Name', 'Country', 'City',
        'No.Branches', 'No.Employees', 'First Name', 'Last Name',
        'Phone Number', 'Email', 'Primary Reasons from Requesting a Demo',
        'How did you hear about us?', 'Inquiry Priority', 'Inquiry Relevance',
        'Required Action', 'Notes', 'Status',
      ];
      buf.writeln(headers.map(_esc).join(','));
      for (int i = 0; i < demos.length; i++) {
        final d = demos[i];
        buf.writeln([
          '${i + 1}',
          _fmtDate(d.submissionDate),
          d.salonName,
          d.country,
          d.city,
          d.noBranches,
          d.noEmployees,
          d.firstName,
          d.lastName,
          '${d.countryCode} ${d.phone}',
          d.email,
          d.primaryReason,
          d.howDidYouHearAboutUs,
          d.inquiryPriority?.label ?? '',
          d.inquiryRelevance?.label ?? '',
          d.requiredAction?.label ?? '',
          d.note,
          d.status.label,
        ].map(_esc).join(','));
      }
      final blob = html.Blob([utf8.encode(buf.toString())], 'text/csv;charset=utf-8');
      final url  = html.Url.createObjectUrlFromBlob(blob);
      final fn   = fileName.toLowerCase().endsWith('.csv') ? fileName : '$fileName.csv';
      html.AnchorElement(href: url)..setAttribute('download', fn)..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showExportSuccessDialog(String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64.sp, height: 64.sp,
              decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: _C.primary, size: 40.sp),
            ),
            SizedBox(height: 16.h),
            Text('Export Successful', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
            SizedBox(height: 8.h),
            Text('$fileName\ndownloaded successfully', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: _C.hintText, height: 1.4)),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('OK', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, cmsState) {
        final Color cmsPrimary = _primaryFromCmsState(cmsState);

        return BlocListener<RequestDemoCubit, RequestDemoState>(
          listener: (context, state) {
            if (state is RequestDemoUpdated) {
              context.read<RequestDemoCubit>().loadDemos();
            }
          },
          child: BlocBuilder<RequestDemoCubit, RequestDemoState>(
            builder: (context, state) {
              if (state is RequestDemoInitial || state is RequestDemoLoading) {
                return Scaffold(
                  backgroundColor: _C.back,
                  body: Center(child: CircularProgressIndicator(color: cmsPrimary)),
                );
              }

              final cubit = context.read<RequestDemoCubit>();
              List<RequestDemoModel> demos = [];
              int totalCount = 0, newCount = 0, repliedCount = 0, closedCount = 0;
              Map<int, int>    monthlySubmissions  = {};
              Map<String, int> noBranchesCounts    = {};
              Map<String, int> noEmployeesCounts   = {};
              Map<String, int> primaryReasonCounts = {};
              Map<String, int> howDidYouHearCounts = {};
              Map<String, int> inquiryPriorityCounts  = {};
              Map<String, int> inquiryRelevanceCounts = {};
              Map<String, int> requiredActionCounts   = {};
              List<String> uniqueStatuses    = [];
              List<String> uniqueEntityTypes = [];
              List<String> uniqueCountries   = [];
              List<int>    uniqueMonths      = [];
              String? activeStatus, activeEntityType, activeCountry;
              int?    activeMonth;

              if (state is RequestDemoLoaded) {
                demos                  = state.filtered;
                totalCount             = state.totalCount;
                newCount               = state.newCount;
                repliedCount           = state.repliedCount;
                closedCount            = state.closedCount;
                monthlySubmissions     = state.monthlySubmissions;
                noBranchesCounts       = state.noBranchesCounts;
                noEmployeesCounts      = state.noEmployeesCounts;
                primaryReasonCounts    = state.primaryReasonCounts;
                howDidYouHearCounts    = state.howDidYouHearCounts;
                inquiryPriorityCounts  = state.priorityCounts;
                inquiryRelevanceCounts = state.relevanceCounts;
                requiredActionCounts   = state.requiredActionCounts;
                uniqueStatuses         = state.uniqueStatuses;
                uniqueEntityTypes      = state.uniqueEntityTypes;
                uniqueCountries        = state.uniqueCountries;
                uniqueMonths           = state.uniqueMonths;
                activeStatus           = state.statusFilter;
                activeEntityType       = state.entityTypeFilter;
                activeCountry          = state.countryFilter;
                activeMonth            = state.monthFilter;
              }

              final hasFilters = activeStatus != null || activeEntityType != null ||
                  activeCountry != null || activeMonth != null;

              final priorityTotal    = inquiryPriorityCounts.values.fold(0, (a, b) => a + b);
              final relevanceTotal   = inquiryRelevanceCounts.values.fold(0, (a, b) => a + b);
              final reqActionTotal   = requiredActionCounts.values.fold(0, (a, b) => a + b);
              final howHearTotal     = howDidYouHearCounts.values.fold(0, (a, b) => a + b);

              return Scaffold(
                backgroundColor: _C.back,
                body: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Navbar ───────────────────────────────────────
                          AppAdminNavbar(
                            activeLabel:    "Demos",
                            homePage:       HomeMainPage(),
                            webPage:        HomeMainPage(),
                            jobListingPage: HomeMainPage(),
                          ),
                          SizedBox(height: 20.h),

                          // ── Title ────────────────────────────────────────
                          Text("Demo's",
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color: cmsPrimary, fontWeight: FontWeight.w700)),
                          SizedBox(height: 16.h),

                          // ── Search + Filter row ──────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: AppSearchTextField(
                                  controller: _searchController,
                                  onChanged: cubit.setSearch,
                                  hintText: 'Search',
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                height: 40.h,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                decoration: BoxDecoration(
                                  color: cmsPrimary,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.tune, size: 16.sp, color: Colors.white),
                                  SizedBox(width: 6.w),
                                  Text('Filter',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                                ]),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Summary cards ────────────────────────────────
                          _summaryRow(totalCount, newCount, repliedCount, closedCount, cmsPrimary),
                          SizedBox(height: 16.h),

                          // ── Filters row ──────────────────────────────────
                          _buildFiltersRow(
                            cubit: cubit,
                            cmsPrimary: cmsPrimary,
                            uniqueStatuses: uniqueStatuses,
                            uniqueEntityTypes: uniqueEntityTypes,
                            uniqueCountries: uniqueCountries,
                            uniqueMonths: uniqueMonths,
                            activeStatus: activeStatus,
                            activeEntityType: activeEntityType,
                            activeCountry: activeCountry,
                            activeMonth: activeMonth,
                            hasFilters: hasFilters,
                            demos: demos,
                          ),
                          SizedBox(height: 16.h),

                          // ── Table ────────────────────────────────────────
                          _buildTable(demos, context, cmsPrimary),
                          SizedBox(height: 40.h),

                          // ── Dashboard heading ────────────────────────────
                          Text('Dashboard',
                              style: StyleText.fontSize24Weight600.copyWith(
                                  color: cmsPrimary, fontWeight: FontWeight.w700)),
                          SizedBox(height: 16.h),

                          // ═══════════════════════════════════════════════
                          //  ROW 1: Submission Received | No.Branches
                          // ═══════════════════════════════════════════════
                          _chartRow(
                            left: _chartCard(
                              'Submission Received',
                              'Total: $totalCount',
                              _buildBarChart(monthlySubmissions, cmsPrimary),
                              cmsPrimary,
                            ),
                            right: _chartCard(
                              'No.Branches',
                              '',
                              _buildSegmentedBarChart(
                                counts: noBranchesCounts,
                                colors: [
                                  Colors.grey.shade400,
                                  Colors.grey.shade300,
                                  cmsPrimary,
                                  cmsPrimary.withOpacity(0.7),
                                ],
                              ),
                              cmsPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ═══════════════════════════════════════════════
                          //  ROW 2: Primary Reasons | How did you hear
                          // ═══════════════════════════════════════════════
                          _chartRow(
                            left: _chartCard(
                              'Primary Reasons from Requesting a Demo',
                              '',
                              _buildTwoColumnHorizontalBarChart(primaryReasonCounts, cmsPrimary),
                              cmsPrimary,
                            ),
                            right: _chartCard(
                              'How did you hear about us?',
                              '',
                              _buildDonutSection(
                                counts: howDidYouHearCounts,
                                centerTotal: howHearTotal,
                                colors: _pieColors(howDidYouHearCounts.length, cmsPrimary),
                              ),
                              cmsPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ═══════════════════════════════════════════════
                          //  ROW 3: No.Employees | Inquiry Priority
                          // ═══════════════════════════════════════════════
                          _chartRow(
                            left: _chartCard(
                              'No. Employees',
                              '',
                              _buildSegmentedBarChart(
                                counts: noEmployeesCounts,
                                colors: [
                                  cmsPrimary,
                                  cmsPrimary.withOpacity(0.7),
                                  cmsPrimary.withOpacity(0.5),
                                  Colors.grey.shade400,
                                  Colors.grey.shade300,
                                ],
                              ),
                              cmsPrimary,
                            ),
                            right: _chartCard(
                              'Inquiry Priority',
                              '',
                              _buildDonutSection(
                                counts: inquiryPriorityCounts,
                                centerTotal: priorityTotal,
                                colors: _priorityColors(inquiryPriorityCounts.keys.toList()),
                                usePriorityColors: true,
                              ),
                              cmsPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ═══════════════════════════════════════════════
                          //  ROW 4: Inquiry Relevance | Required Action
                          // ═══════════════════════════════════════════════
                          _chartRow(
                            left: _chartCard(
                              'Inquiry Relevance',
                              '',
                              _buildDonutSection(
                                counts: inquiryRelevanceCounts,
                                centerTotal: relevanceTotal,
                                colors: _pieColors(inquiryRelevanceCounts.length, cmsPrimary),
                              ),
                              cmsPrimary,
                            ),
                            right: _chartCard(
                              'Required Action',           // ← was incorrectly "Inquiry Relevance"
                              '',
                              _buildDonutSection(
                                counts: requiredActionCounts,
                                centerTotal: reqActionTotal,
                                colors: _pieColors(requiredActionCounts.length, cmsPrimary),
                              ),
                              cmsPrimary,
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  LAYOUT HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// ── FIX 1: IntrinsicHeight makes both cards stretch to the taller sibling ──
  Widget _chartRow({required Widget left, required Widget right}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // both children fill height
        children: [
          Expanded(child: left),
          SizedBox(width: 16.w),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _summaryRow(int total, int newC, int replied, int closed, Color primary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _summaryCard('Total Submission', total,  Colors.grey)),
        SizedBox(width: 10.w),
        Expanded(child: _summaryCard('New',     newC,    primary)),
        SizedBox(width: 10.w),
        Expanded(child: _summaryCard('Replied', replied, const Color(0xFFFF9800))),
        SizedBox(width: 10.w),
        Expanded(child: _summaryCard('Closed',  closed,  const Color(0xFFE53935))),
      ],
    );
  }

  Widget _buildFiltersRow({
    required RequestDemoCubit cubit,
    required Color cmsPrimary,
    required List<String> uniqueStatuses,
    required List<String> uniqueEntityTypes,
    required List<String> uniqueCountries,
    required List<int>    uniqueMonths,
    required String?      activeStatus,
    required String?      activeEntityType,
    required String?      activeCountry,
    required int?         activeMonth,
    required bool         hasFilters,
    required List<RequestDemoModel> demos,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Wrap(spacing: 8.w, runSpacing: 6.h, children: [
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeStatus,
              items: uniqueStatuses.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: cmsPrimary,
              hint: Text('Status', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: cubit.setStatusFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeEntityType,
              items: uniqueEntityTypes.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: cmsPrimary,
              hint: Text('Entity Type', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: cubit.setEntityTypeFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeCountry,
              items: uniqueCountries.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: cmsPrimary,
              hint: Text('Location', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: cubit.setCountryFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeMonth?.toString(),
              items: uniqueMonths.map((m) => {
                'key': m.toString(),
                'value': m >= 1 && m <= 12 ? _kMonthNames[m - 1] : m.toString(),
              }).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: cmsPrimary,
              hint: Text('Calendar', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: (v) => cubit.setMonthFilter(v != null ? int.tryParse(v) : null),
            ),
          ),
          if (hasFilters)
            GestureDetector(
              onTap: () { cubit.clearAllFilters(); _searchController.clear(); },
              child: Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: _C.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.clear, size: 12.sp, color: _C.hintText),
                  SizedBox(width: 4.w),
                  Text('Clear', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
                ]),
              ),
            ),
        ]),
        const Spacer(),
        customButtonWithImage(
          title: 'Export',
          function: () => _showExportDialog(demos),
          textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
          height: 32.h, space: 4.w, radius: 6, color: cmsPrimary,
          image: 'assets/images/export.svg',
          widthImage: 14.sp, heightImage: 14.sp,
          colorBorder: cmsPrimary, svgColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SUMMARY CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _summaryCard(String title, int count, Color topColor) {
    return Container(
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(8.r)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(title,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText))),
            Text('$count',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE
  // ─────────────────────────────────────────────────────────────────────────

  static const _headers = [
    'Submission Date', 'Salon Name', 'Country', 'City', 'No.Branches',
    'No.Employees', 'First Name', 'Last Name', 'Phone Number', 'Email',
    'Primary Reasons from Requesting a Demo', 'How did you hear about us?',
    'Inquiry Priority', 'Inquiry Relevance', 'Required Action', 'Notes', 'Status',
  ];

  Map<int, TableColumnWidth> get _columnWidths => {
    0:  FixedColumnWidth(110.sp),
    1:  FixedColumnWidth(120.sp),
    2:  FixedColumnWidth(100.sp),
    3:  FixedColumnWidth(90.sp),
    4:  FixedColumnWidth(90.sp),
    5:  FixedColumnWidth(90.sp),
    6:  FixedColumnWidth(100.sp),
    7:  FixedColumnWidth(100.sp),
    8:  FixedColumnWidth(110.sp),
    9:  FixedColumnWidth(160.sp),
    10: FixedColumnWidth(160.sp),
    11: FixedColumnWidth(150.sp),
    12: FixedColumnWidth(110.sp),
    13: FixedColumnWidth(150.sp),
    14: FixedColumnWidth(160.sp),
    15: FixedColumnWidth(140.sp),
    16: FixedColumnWidth(80.sp),
  };

  TextStyle get _cellStyle => TextStyle(fontSize: 11.sp, color: _C.labelText);

  Widget _cell(Widget child) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
    child: DefaultTextStyle.merge(style: _cellStyle, child: child),
  );

  Widget _tc(String text, {int ml = 2}) =>
      _cell(Text(text.isEmpty ? '-' : text, maxLines: ml, overflow: TextOverflow.ellipsis));

  Widget _buildTable(List<RequestDemoModel> demos, BuildContext context, Color cmsPrimary) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: _columnWidths,
          children: [
            TableRow(
              decoration: BoxDecoration(color: cmsPrimary),
              children: _headers
                  .map((h) => Padding(
                padding: EdgeInsets.all(8.sp),
                child: Text(h, maxLines: 2,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ))
                  .toList(),
            ),
            ...List.generate(demos.length, (idx) {
              final d        = demos[idx];
              final rowColor = idx.isEven ? const Color(0xFFF7F8FA) : Colors.white;
              final dateStr  = d.submissionDate != null
                  ? '${d.submissionDate!.day}/${d.submissionDate!.month}/${d.submissionDate!.year}'
                  : '-';
              final cells = [
                _tc(dateStr, ml: 1),
                _tc(d.salonName),
                _tc(d.country),
                _tc(d.city),
                _tc(d.noBranches, ml: 1),
                _tc(d.noEmployees, ml: 1),
                _tc(d.firstName),
                _tc(d.lastName),
                _tc('${d.countryCode} ${d.phone}'.trim()),
                _tc(d.email),
                _tc(d.primaryReason),
                _tc(d.howDidYouHearAboutUs),
                _cell(_priorityChip(d.inquiryPriority)),
                _tc(d.inquiryRelevance?.label ?? '-'),
                _tc(d.requiredAction?.label ?? '-'),
                _tc(d.note),
                _cell(Text(d.status.label,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: d.status.color))),
              ];
              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: cells.map((cell) => InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<RequestDemoCubit>(),
                        child: RequestDemoDetailPage(demoId: d.id),
                      ),
                    ),
                  ),
                  child: cell,
                )).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(DemoPriority? p) {
    if (p == null) return Text('-', style: TextStyle(fontSize: 11.sp, color: _C.hintText));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8.sp, height: 8.sp,
          decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
      SizedBox(width: 4.w),
      Flexible(child: Text(p.label,
          style: TextStyle(fontSize: 11.sp, color: _C.labelText),
          overflow: TextOverflow.ellipsis)),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CHART CARD WRAPPER
  //  ── FIX 2: expand vertically so both siblings fill the IntrinsicHeight ──
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _chartCard(String title, String subtitle, Widget chart, Color cmsPrimary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        mainAxisSize: MainAxisSize.max,   // ← stretch to parent height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: cmsPrimary)),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(subtitle, style: TextStyle(fontSize: 11.sp, color: _C.labelText)),
          ],
          SizedBox(height: 12.h),
          chart,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  1. BAR CHART — Monthly Submissions
  //  ── FIX 3: always renders 12 months; zero months show empty placeholder bar
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBarChart(Map<int, int> monthly, Color cmsPrimary) {
    // Always treat maxVal as at least 1 so layout doesn't collapse
    final maxVal  = monthly.values.fold(0, (a, b) => a > b ? a : b);
    const maxBarH = 130.0;
    const labelH  = 16.0;
    return SizedBox(
      height: 175.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final val  = monthly[i + 1] ?? 0;
          // Give zero-value bars a minimal visible height so axes stay intact
          final barH = maxVal > 0
              ? (val / maxVal) * maxBarH
              : 0.0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: labelH.h,
                    child: val > 0
                        ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Text('$val',
                          style: TextStyle(
                              fontSize: 7.sp,
                              color: _C.labelText,
                              fontWeight: FontWeight.w600)),
                    )
                        : const SizedBox(),
                  ),
                  // When val == 0 show a thin grey placeholder so the row is visible
                  Container(
                    height: val > 0 ? barH.h : 4.h,
                    decoration: BoxDecoration(
                      color: val > 0 ? cmsPrimary : _C.border,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3.r),
                          topRight: Radius.circular(3.r)),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(_kMonthNames[i],
                      style: TextStyle(fontSize: 8.sp, color: _C.hintText)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  2. SEGMENTED BAR CHART — No.Branches & No.Employees
  //  ── FIX 4: when empty show a full-width grey placeholder bar + "No data" ──
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSegmentedBarChart({
    required Map<String, int> counts,
    required List<Color> colors,
  }) {
    // ── Empty / all-zero state ───────────────────────────────────────────────
    if (counts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              height: 28.h,
              color: _C.border,
              child: Center(
                child: Text('No data',
                    style: TextStyle(fontSize: 10.sp, color: _C.hintText)),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      );
    }

    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();

    // When total == 0, render equal-width grey segments so layout is preserved
    final isAllZero = total == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Legend row ──────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(entries.length, (i) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entries[i].key,
                    style: TextStyle(fontSize: 9.sp, color: _C.hintText)),
                SizedBox(height: 3.h),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 8.sp, height: 8.sp,
                    decoration: BoxDecoration(
                        color: isAllZero
                            ? _C.border
                            : colors[i % colors.length],
                        shape: BoxShape.circle),
                  ),
                  SizedBox(width: 3.w),
                  Text('${entries[i].value}',
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _C.labelText)),
                ]),
              ],
            );
          }),
        ),
        SizedBox(height: 12.h),
        // ── Segmented bar ────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: isAllZero
          // All-zero: equal grey segments
              ? Row(
            children: List.generate(entries.length, (i) => Expanded(
              child: Container(
                height: 28.h,
                color: _C.border,
              ),
            )),
          )
              : Row(
            children: List.generate(entries.length, (i) {
              final pct = entries[i].value / total;
              return Flexible(
                flex: (pct * 100).round().clamp(1, 100),
                child: Container(
                  height: 28.h,
                  color: colors[i % colors.length],
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  3. TWO-COLUMN HORIZONTAL BAR CHART — Primary Reasons
  //  ── FIX 5: show zero-width bars (grey track visible) when all values are 0 ─
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTwoColumnHorizontalBarChart(
      Map<String, int> counts, Color cmsPrimary) {
    // ── Empty state ──────────────────────────────────────────────────────────
    if (counts.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text('No data',
              style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
        ),
      );
    }

    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    final half    = (entries.length / 2).ceil();
    final left    = entries.sublist(0, half);
    final right   = entries.length > half ? entries.sublist(half) : <MapEntry<String,int>>[];

    Widget buildEntry(MapEntry<String, int> e) {
      // When total == 0 pct shows "0%" and fill = 0 → grey track only
      final pct  = total > 0 ? (e.value / total * 100).round() : 0;
      final fill = total > 0 ? e.value / total : 0.0;
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.key,
              style: TextStyle(fontSize: 9.sp, color: _C.labelText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 3.h),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: Stack(children: [
                  Container(height: 12.h, color: _C.border),
                  if (fill > 0)
                    FractionallySizedBox(
                      widthFactor: fill.clamp(0.0, 1.0),
                      child: Container(height: 12.h, color: cmsPrimary),
                    ),
                ]),
              ),
            ),
            SizedBox(width: 5.w),
            SizedBox(
              width: 26.w,
              child: Text('$pct%',
                  style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: _C.labelText)),
            ),
          ]),
        ]),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: left.map(buildEntry).toList())),
        SizedBox(width: 12.w),
        Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: right.map(buildEntry).toList())),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  4. DONUT SECTION
  //  ── FIX 6: empty counts → show placeholder grey donut (single segment = 1)
  //            all-zero counts → same placeholder, legend shows "0%"
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDonutSection({
    required Map<String, int> counts,
    required int centerTotal,
    required List<Color> colors,
    bool usePriorityColors = false,
  }) {
    // ── Completely empty: show grey placeholder donut + "No data" legend ─────
    if (counts.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text('No data',
                style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
          ),
          SizedBox(width: 16.w),
          SizedBox(
            width: 110.w,
            height: 110.w,
            child: CustomPaint(
              painter: _DonutPainter(
                values: const [1],
                colors: const [Color(0xFFE0E0E0)],
                centerLabel: 'Total',
                centerValue: '0',
              ),
            ),
          ),
        ],
      );
    }

    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();

    // Resolve per-entry dot colours
    final dotColors = List.generate(entries.length, (i) {
      if (usePriorityColors) return _priorityColorForLabel(entries[i].key);
      if (colors.isEmpty) return _C.border;
      return colors[i % colors.length];
    });

    // When total == 0 paint equal grey slices so the donut still looks good
    final paintValues = total == 0
        ? List<double>.filled(entries.length, 1.0)
        : entries.map((e) => e.value.toDouble()).toList();
    final paintColors = total == 0
        ? List<Color>.filled(entries.length, _C.border)
        : dotColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Legend list ──────────────────────────────────────────────────────
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final pct = total > 0
                  ? (entries[i].value / total * 100).round()
                  : 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(children: [
                  Container(
                    width: 10.sp, height: 10.sp,
                    decoration: BoxDecoration(
                        color: dotColors[i],
                        shape: BoxShape.circle),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(entries[i].key,
                        style: TextStyle(fontSize: 10.sp, color: _C.labelText),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text('$pct%',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: _C.hintText,
                          fontWeight: FontWeight.w600)),
                ]),
              );
            }),
          ),
        ),
        SizedBox(width: 16.w),
        // ── Donut chart ──────────────────────────────────────────────────────
        SizedBox(
          width: 110.w,
          height: 110.w,
          child: CustomPaint(
            painter: _DonutPainter(
              values: paintValues,
              colors: paintColors,
              centerLabel: 'Total',
              centerValue: '$centerTotal',
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  COLOR HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  List<Color> _pieColors(int n, Color primary) {
    if (n == 0) return [];
    return List.generate(n, (i) {
      final opacity = 1.0 - (i * 0.15).clamp(0.0, 0.6);
      return primary.withOpacity(opacity);
    });
  }

  List<Color> _priorityColors(List<String> labels) =>
      labels.map(_priorityColorForLabel).toList();

  Color _priorityColorForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('critical'))      return const Color(0xFFE53935);
    if (l.contains('high'))          return const Color(0xFFEF6C00);
    if (l.contains('medium'))        return const Color(0xFFFFB300);
    if (l.contains('low'))           return const Color(0xFF5B9BD5);
    if (l.contains('informational')) return const Color(0xFFBDBDBD);
    return const Color(0xFFBDBDBD);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DONUT PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  final String centerLabel;
  final String centerValue;

  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.centerLabel,
    required this.centerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.54;
    final rect   = Rect.fromCircle(center: centre, radius: outerR);

    double startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, true,
          Paint()
            ..color = colors[i % colors.length]
            ..style = PaintingStyle.fill);
      canvas.drawArc(rect, startAngle, sweep, true,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      startAngle += sweep;
    }

    canvas.drawCircle(centre, innerR, Paint()..color = Colors.white);

    final labelSp = TextSpan(
      text: centerLabel,
      style: TextStyle(
        fontSize: size.width * 0.11,
        color: const Color(0xFFAAAAAA),
        fontWeight: FontWeight.w500,
      ),
    );
    final valueSp = TextSpan(
      text: centerValue,
      style: TextStyle(
        fontSize: size.width * 0.20,
        color: const Color(0xFF333333),
        fontWeight: FontWeight.w700,
      ),
    );

    final labelTp = TextPainter(text: labelSp, textDirection: TextDirection.ltr)..layout();
    final valueTp = TextPainter(text: valueSp, textDirection: TextDirection.ltr)..layout();

    const gap = 1.0;
    final totalTextH = labelTp.height + gap + valueTp.height;
    final topY       = centre.dy - totalTextH / 2;

    labelTp.paint(canvas, Offset(centre.dx - labelTp.width / 2, topY));
    valueTp.paint(canvas, Offset(centre.dx - valueTp.width / 2, topY + labelTp.height + gap));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.values != values ||
          old.colors != colors ||
          old.centerValue != centerValue;
}