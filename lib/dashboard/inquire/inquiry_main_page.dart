// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_main_page.dart  (UPDATED)
// Path: lib/dashboard/inquire/inquiry_main_page.dart
// UPDATED: Client/Owner toggle now uses CustomSegmentedTabs
// ═══════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:beauty_admin/controller/inquire/inquiry_cubit.dart';
import 'package:beauty_admin/controller/inquire/inquiry_state.dart';
import 'package:beauty_admin/core/widget/custom_dropdwon.dart';
import 'package:beauty_admin/core/widget/button.dart';
import 'package:beauty_admin/core/widget/search.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/model/inquire/inquire.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../core/custom_segmant_tab.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';
import 'inquiry_detail_page.dart';

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

const List<String> _kMonthNames = [
  'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
];

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
class InquiryMainPage extends StatefulWidget {
  const InquiryMainPage({super.key});
  @override State<InquiryMainPage> createState() => _InquiryMainPageState();
}

class _InquiryMainPageState extends State<InquiryMainPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InquiryCubit>().loadInquiries();
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

  void _showExportDialog(List<InquiryModel> inquiries) {
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
                    _performExport(inquiries, fn);
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

  void _performExport(List<InquiryModel> inquiries, String fileName) {
    try {
      final buf = StringBuffer();
      final headers = [
        'No','Submission Date','Preferred Language','First Name','Last Name',
        'Email','Country Code','Phone Number','Gender','Country','Subject',
        'Reason','Message','Inquiry Priority','Inquiry Relevance',
        'Required Action','Notes','Status',
      ];
      buf.writeln(headers.map(_esc).join(','));
      for (int i = 0; i < inquiries.length; i++) {
        final inq = inquiries[i];
        buf.writeln([
          '${i + 1}', _fmtDate(inq.submissionDate), inq.preferredLanguage,
          inq.firstName, inq.lastName, inq.email, inq.countryCode, inq.phone,
          inq.gender, inq.country, inq.subject, inq.reason, inq.message,
          inq.inquiryPriority?.label ?? '', inq.inquiryRelevance?.label ?? '',
          inq.requiredAction?.label ?? '', inq.note, inq.status.label,
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
            Text('Export Successful', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
            SizedBox(height: 8.h),
            Text('$fileName\ndownloaded successfully', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: _C.hintText, height: 1.4)),
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
  //  HELPER: convert activeUserType to selectedIndex for CustomSegmentedTabs
  // ═══════════════════════════════════════════════════════════════════════════

  // null = no filter (neither selected), 'Client' = 0, 'Owner' = 1
  // We use a 3-state approach: tap same tab again = deselect (clear filter)
  int _userTypeToIndex(String? activeUserType) {
    if (activeUserType == 'Client') return 0;
    if (activeUserType == 'Owner')  return 1;
    return -1; // no selection
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocListener<InquiryCubit, InquiryState>(
      listener: (context, state) {
        if (state is InquiryUpdated) context.read<InquiryCubit>().loadInquiries();
      },
      child: BlocBuilder<InquiryCubit, InquiryState>(
        builder: (context, state) {
          if (state is InquiryInitial || state is InquiryLoading) {
            return const Scaffold(
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)),
            );
          }

          final cubit = context.read<InquiryCubit>();
          List<InquiryModel> inquiries = [];
          int totalCount = 0, newCount = 0, repliedCount = 0, closedCount = 0;
          Map<int, int>    monthlySubmissions   = {};
          Map<String, int> reasonCounts         = {};
          Map<String, int> languageCounts       = {};
          Map<String, int> genderCounts         = {};
          Map<String, int> locationCounts       = {};
          Map<String, int> priorityCounts       = {};
          Map<String, int> relevanceCounts      = {};
          Map<String, int> requiredActionCounts = {};
          List<String> uniqueStatuses  = [];
          List<String> uniqueGenders   = [];
          List<String> uniqueCountries = [];
          List<int>    uniqueMonths    = [];
          String? activeStatus, activeUserType, activeGender, activeCountry;
          int?    activeMonth;

          if (state is InquiryLoaded) {
            inquiries            = state.filtered;
            totalCount           = state.totalCount;
            newCount             = state.newCount;
            repliedCount         = state.repliedCount;
            closedCount          = state.closedCount;
            monthlySubmissions   = state.monthlySubmissions;
            reasonCounts         = state.reasonCounts;
            languageCounts       = state.languageCounts;
            genderCounts         = state.genderCounts;
            locationCounts       = state.locationCounts;
            priorityCounts       = state.priorityCounts;
            relevanceCounts      = state.relevanceCounts;
            requiredActionCounts = state.requiredActionCounts;
            uniqueStatuses       = state.uniqueStatuses;
            uniqueGenders        = state.uniqueGenders;
            uniqueCountries      = state.uniqueCountries;
            uniqueMonths         = state.uniqueMonths;
            activeStatus         = state.statusFilter;
            activeUserType       = state.userTypeFilter;
            activeGender         = state.genderFilter;
            activeCountry        = state.countryFilter;
            activeMonth          = state.monthFilter;
          }
          if (state is InquiryError && state.lastInquiries != null) {
            inquiries = state.lastInquiries!;
          }

          final hasFilters = activeStatus != null || activeUserType != null ||
              activeGender != null || activeCountry != null || activeMonth != null;

          final int segmentIndex = _userTypeToIndex(activeUserType);

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
                      AppAdminNavbar(
                        activeLabel: 'Inquiries',

                        homePage:       HomeMainPage(),
                        webPage:        HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),

                      SizedBox(height: 20.h),

                      // ── Title ──────────────────────────────────────────────
                      Text(
                        'Inquires',
                        style: StyleText.fontSize45Weight600.copyWith(
                            color: _C.primary, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 16.h),

                      // ── Client / Owner toggle — CustomSegmentedTabs ────────
                      SizedBox(
                        width: 220.w,
                        height: 36.h,
                        child: CustomSegmentedTabs(
                          tabs: const ['Client', 'Owner'],
                          selectedIndex: segmentIndex,
                          onTabSelected: (index) {
                            final label = index == 0 ? 'Client' : 'Owner';
                            // Tap same tab again → clear filter
                            if (activeUserType == label) {
                              cubit.setUserTypeFilter(null);
                            } else {
                              cubit.setUserTypeFilter(label);
                            }
                          },
                          selectedColor:       _C.primary,
                          unselectedColor:     Colors.transparent,
                          selectedTextColor:   Colors.white,
                          unselectedTextColor: Colors.grey.shade500,
                          containerColor:      _C.cardBg,
                          equalWidth:          true,
                          spacing:             8.w,
                          tabHorizontalPadding: 16.w,
                          tabVerticalPadding:   8.h,
                          borderRadius:         8.r,
                          containerPadding:     EdgeInsets.all(3.r),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // ── Search ─────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: AppSearchTextField(
                          controller: _searchController,
                          onChanged: cubit.setSearch,
                          hintText: 'Search',
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Summary cards ──────────────────────────────────────
                      _summaryRow(totalCount, newCount, repliedCount, closedCount),
                      SizedBox(height: 16.h),

                      // ── Filters row ────────────────────────────────────────
                      _buildFiltersRow(
                        cubit: cubit,
                        uniqueStatuses: uniqueStatuses,
                        uniqueGenders: uniqueGenders,
                        uniqueCountries: uniqueCountries,
                        uniqueMonths: uniqueMonths,
                        activeStatus: activeStatus,
                        activeGender: activeGender,
                        activeCountry: activeCountry,
                        activeMonth: activeMonth,
                        hasFilters: hasFilters,
                        inquiries: inquiries,
                      ),
                      SizedBox(height: 16.h),

                      // ── Table ──────────────────────────────────────────────
                      _buildTable(inquiries, context),
                      SizedBox(height: 40.h),

                      // ── Dashboard heading ──────────────────────────────────
                      Text(
                        'Dashboard',
                        style: StyleText.fontSize24Weight600.copyWith(
                            color: _C.primary, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 16.h),

                      // ── Chart rows ─────────────────────────────────────────
                      _chartRow(
                        left:  _chartCard('Submission Received', 'Total: $totalCount', _buildBarChart(monthlySubmissions)),
                        right: _chartCard('Reasons', '',          _buildPieSection(reasonCounts,   _pieColors(reasonCounts.length))),
                      ),
                      SizedBox(height: 16.h),

                      _chartRow(
                        left:  _chartCard('Language', '', _buildPieSection(languageCounts, _pieColors(languageCounts.length))),
                        right: _chartCard('Gender',   '', _buildPieSection(genderCounts,   _pieColors(genderCounts.length))),
                      ),
                      SizedBox(height: 16.h),

                      _chartRow(
                        left:  _chartCard('Location',        '', _buildLocationChart(locationCounts)),
                        right: _chartCard('Inquiry Priority','', _buildDonutSection(priorityCounts, _priorityColors())),
                      ),
                      SizedBox(height: 16.h),

                      _chartRow(
                        left:  _chartCard('Inquiry Relevance', '', _buildDonutSection(relevanceCounts,      _relevanceColors())),
                        right: _chartCard('Required Action',   '', _buildDonutSection(requiredActionCounts, _actionColors())),
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
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  LAYOUT HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _chartRow({required Widget left, required Widget right}) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final half = (constraints.maxWidth - 16.w) / 2;
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: half, child: left),
          SizedBox(width: 16.w),
          SizedBox(width: half, child: right),
        ],
      );
    });
  }

  Widget _summaryRow(int total, int newC, int replied, int closed) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = (constraints.maxWidth - 30.w) / 4;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: w, child: _summaryCard('Total Submission', total,  Colors.grey)),
          SizedBox(width: 10.w),
          SizedBox(width: w, child: _summaryCard('New',     newC,    _C.primary)),
          SizedBox(width: 10.w),
          SizedBox(width: w, child: _summaryCard('Replied', replied, const Color(0xFFFF9800))),
          SizedBox(width: 10.w),
          SizedBox(width: w, child: _summaryCard('Closed',  closed,  const Color(0xFFE53935))),
        ],
      );
    });
  }

  Widget _buildFiltersRow({
    required InquiryCubit cubit,
    required List<String> uniqueStatuses,
    required List<String> uniqueGenders,
    required List<String> uniqueCountries,
    required List<int>    uniqueMonths,
    required String?      activeStatus,
    required String?      activeGender,
    required String?      activeCountry,
    required int?         activeMonth,
    required bool         hasFilters,
    required List<InquiryModel> inquiries,
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
              dropdownColor: _C.cardBg, primaryColor: _C.primary,
              hint: Text('Status', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: cubit.setStatusFilter,
            ),
          ),
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeGender,
              items: uniqueGenders.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: _C.primary,
              hint: Text('Gender', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: cubit.setGenderFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeCountry,
              items: uniqueCountries.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: _C.primary,
              hint: Text('Country', style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
              onChanged: cubit.setCountryFilter,
            ),
          ),
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeMonth?.toString(),
              items: uniqueMonths.map((m) => {
                'key': m.toString(),
                'value': m >= 1 && m <= 12 ? _kMonthNames[m - 1] : m.toString(),
              }).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: _C.cardBg, primaryColor: _C.primary,
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
          function: () => _showExportDialog(inquiries),
          textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
          height: 32.h, space: 4.w, radius: 6, color: _C.primary,
          image: 'assets/images/export.svg',
          widthImage: 14.sp, heightImage: 14.sp,
          colorBorder: _C.primary, svgColor: Colors.white,
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
            Flexible(child: Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: _C.labelText))),
            Text('$count', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE
  // ─────────────────────────────────────────────────────────────────────────

  static const _headers = [
    'No', 'Submission Date', 'Preferred Language', 'First Name', 'Last Name',
    'Email', 'Country Code', 'Phone Number', 'Gender', 'Country',
    'Subject', 'Reason', 'Message', 'Inquiry Priority', 'Inquiry Relevance',
    'Required Action', 'Notes', 'Status',
  ];

  Map<int, TableColumnWidth> get _columnWidths => {
    0:  FixedColumnWidth(45.sp),  1:  FixedColumnWidth(110.sp), 2:  FixedColumnWidth(120.sp),
    3:  FixedColumnWidth(110.sp), 4:  FixedColumnWidth(110.sp), 5:  FixedColumnWidth(170.sp),
    6:  FixedColumnWidth(90.sp),  7:  FixedColumnWidth(110.sp), 8:  FixedColumnWidth(80.sp),
    9:  FixedColumnWidth(100.sp), 10: FixedColumnWidth(140.sp), 11: FixedColumnWidth(120.sp),
    12: FixedColumnWidth(160.sp), 13: FixedColumnWidth(110.sp), 14: FixedColumnWidth(150.sp),
    15: FixedColumnWidth(160.sp), 16: FixedColumnWidth(140.sp), 17: FixedColumnWidth(90.sp),
  };

  TextStyle get _cellStyle => TextStyle(fontSize: 11.sp, color: _C.labelText);

  Widget _cell(Widget child) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
    child: DefaultTextStyle.merge(style: _cellStyle, child: child),
  );

  Widget _tc(String text, {int ml = 2}) =>
      _cell(Text(text.isEmpty ? '-' : text, maxLines: ml, overflow: TextOverflow.ellipsis));

  Widget _buildTable(List<InquiryModel> inquiries, BuildContext context) {
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
              decoration: const BoxDecoration(color: _C.primary),
              children: _headers
                  .map((h) => Padding(
                padding: EdgeInsets.all(8.sp),
                child: Text(h,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ))
                  .toList(),
            ),
            ...List.generate(inquiries.length, (idx) {
              final i        = inquiries[idx];
              final rowColor = idx.isEven ? const Color(0xFFF7F8FA) : Colors.white;
              final dateStr  = i.submissionDate != null
                  ? '${i.submissionDate!.day}/${i.submissionDate!.month}/${i.submissionDate!.year}'
                  : '-';
              final cells = [
                _tc('${idx + 1}', ml: 1),
                _tc(dateStr, ml: 1),
                _tc(i.preferredLanguage, ml: 1),
                _tc(i.firstName),
                _tc(i.lastName),
                _tc(i.email),
                _tc(i.countryCode, ml: 1),
                _tc(i.phone),
                _tc(i.gender, ml: 1),
                _tc(i.country),
                _tc(i.subject),
                _tc(i.reason),
                _tc(i.message, ml: 1),
                _cell(_priorityChip(i.inquiryPriority)),
                _tc(i.inquiryRelevance?.label ?? '-'),
                _tc(i.requiredAction?.label ?? '-'),
                _tc(i.note),
                _cell(Text(i.status.label,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: i.status.color))),
              ];
              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: cells
                    .map((cell) => InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<InquiryCubit>(),
                        child: InquiryDetailPage(inquiryId: i.id),
                      ),
                    ),
                  ),
                  child: cell,
                ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(InquiryPriority? p) {
    if (p == null) return Text('-', style: TextStyle(fontSize: 11.sp, color: _C.hintText));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8.sp, height: 8.sp, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
      SizedBox(width: 4.w),
      Flexible(child: Text(p.label, style: TextStyle(fontSize: 11.sp, color: _C.labelText), overflow: TextOverflow.ellipsis)),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CHART CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _chartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(color: _C.cardBg, borderRadius: BorderRadius.circular(8.r)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _C.primary)),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(subtitle, style: TextStyle(fontSize: 11.sp, color: _C.labelText)),
        ],
        SizedBox(height: 12.h),
        chart,
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BAR CHART
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBarChart(Map<int, int> monthly) {
    final maxVal   = monthly.values.fold(1, (a, b) => a > b ? a : b);
    const maxBarH  = 130.0;
    const labelH   = 16.0;
    return SizedBox(
      height: 175.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final val  = monthly[i + 1] ?? 0;
          final barH = maxVal > 0 ? (val / maxVal) * maxBarH : 0.0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: labelH.h,
                  child: val > 0
                      ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('$val', style: TextStyle(fontSize: 7.sp, color: _C.labelText, fontWeight: FontWeight.w600)),
                  )
                      : const SizedBox(),
                ),
                Container(
                  height: barH.h,
                  decoration: BoxDecoration(
                    color: val > 0 ? _C.primary : Colors.transparent,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(3.r), topRight: Radius.circular(3.r)),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(_kMonthNames[i], style: TextStyle(fontSize: 8.sp, color: _C.hintText)),
              ]),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PIE CHART SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPieSection(Map<String, int> counts, List<Color> colors) {
    if (counts.isEmpty) return const SizedBox(height: 120);
    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) {
            final pct = total > 0 ? (entries[i].value / total * 100).round() : 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(children: [
                Container(width: 10.sp, height: 10.sp, decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 6.w),
                Expanded(child: Text(entries[i].key, style: TextStyle(fontSize: 10.sp, color: _C.labelText), overflow: TextOverflow.ellipsis)),
                Text('$pct%', style: TextStyle(fontSize: 10.sp, color: _C.hintText, fontWeight: FontWeight.w600)),
              ]),
            );
          }),
        ),
      ),
      SizedBox(width: 16.w),
      SizedBox(
        width: 110.w, height: 110.w,
        child: CustomPaint(painter: _PiePainter(
          values: entries.map((e) => e.value.toDouble()).toList(),
          colors: colors,
        )),
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LOCATION BAR CHART
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLocationChart(Map<String, int> counts) {
    if (counts.isEmpty) return const SizedBox(height: 160);
    final total = counts.values.fold(0, (a, b) => a + b);
    const barH  = 120.0;
    return SizedBox(
      height: 160.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: counts.entries.map((e) {
          final pct    = total > 0 ? (e.value / total * 100).round() : 0;
          final fillH  = (pct / 100) * barH;
          final emptyH = barH - fillH;
          return Expanded(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(height: emptyH.h, color: _C.primaryLight.withOpacity(0.3)),
                  Container(height: fillH.h,  color: _C.primary),
                ]),
              ),
              SizedBox(height: 5.h),
              Text('$pct%', style: TextStyle(fontSize: 8.sp, color: _C.labelText, fontWeight: FontWeight.w600)),
              SizedBox(height: 2.h),
              Text(e.key, style: TextStyle(fontSize: 7.sp, color: _C.hintText), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ]),
          ));
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DONUT CHART SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDonutSection(Map<String, int> counts, List<Color> colors) {
    if (counts.isEmpty) return const SizedBox(height: 120);
    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(children: [
              Container(width: 8.sp, height: 8.sp, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
              SizedBox(width: 5.w),
              Expanded(child: Text(entries[i].key, style: TextStyle(fontSize: 9.sp, color: _C.labelText), overflow: TextOverflow.ellipsis)),
            ]),
          )),
        ),
      ),
      SizedBox(width: 12.w),
      SizedBox(
        width: 110.w, height: 110.w,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
            painter: _DonutPainter(
              values: entries.map((e) => e.value.toDouble()).toList(),
              colors: colors,
            ),
            size: Size(110.w, 110.w),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Total', style: TextStyle(fontSize: 9.sp, color: _C.hintText)),
            Text('$total', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _C.labelText)),
          ]),
        ]),
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  COLOUR PALETTES
  // ─────────────────────────────────────────────────────────────────────────

  List<Color> _pieColors(int n) {
    const palette = [
      Color(0xFFD16F9A), Color(0xFFE8A0BE), Color(0xFFF2C8DA),
      Color(0xFFA0522D), Color(0xFFF4A460), Color(0xFFDEB887),
    ];
    return List.generate(n, (i) => palette[i % palette.length]);
  }

  List<Color> _priorityColors() => [
    InquiryPriority.critical.color,
    InquiryPriority.high.color,
    InquiryPriority.medium.color,
    InquiryPriority.low.color,
    InquiryPriority.informationalOnly.color,
  ];

  List<Color> _relevanceColors() => const [
    Color(0xFFD16F9A), Color(0xFFE8A0BE), Color(0xFFF2C8DA),
    Color(0xFFB0BEC5), Color(0xFF90A4AE), Color(0xFF607D8B),
  ];

  List<Color> _actionColors() => const [
    Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A),
    Color(0xFF9CCC65), Color(0xFFD4E157), Color(0xFFFFF176),
    Color(0xFFFFCC02), Color(0xFFF4511E),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  PIE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  const _PiePainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final rect   = Rect.fromLTWH(0, 0, size.width, size.height);
    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill);
      canvas.drawArc(rect, start, sweep, true, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.values != values;
}

// ─────────────────────────────────────────────────────────────────────────────
//  DONUT PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  const _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final rect   = Rect.fromLTWH(0, 0, size.width, size.height);
    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill);
      canvas.drawArc(rect, start, sweep, true, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      start += sweep;
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 * 0.55,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.values != values;
}