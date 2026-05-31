// ******************* FILE INFO *******************
// File Name: demo_main_page.dart
// Description: Demo main page
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › demos › presentation › ui › pages

// ═══════════════════════════════════════════════════════════════════
// FILE: demo_main_page.dart
// ═══════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:beauty_admin/features/demos/presentation/ui/pages/demo_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:beauty_admin/core/widgets/custom_dropdown.dart';
import 'package:beauty_admin/core/widgets/button.dart';
import 'package:beauty_admin/core/widgets/search.dart';
import 'package:beauty_admin/core/widgets/textfield.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../../request/data/models/request_model.dart';
import '../../../../request/presentation/controller/request_cubit.dart';
import '../../../../request/presentation/controller/request_state.dart';
import '../../../data/models/demo_model.dart';
import '../../controller/demo_cubit.dart';
import '../../controller/demo_state.dart';

part '../widgets/demo_main_page/c.dart';
part '../widgets/demo_main_page/donut_painter.dart';
part '../widgets/demo_main_page/sections.dart';

class RequestDemoMainPage extends StatefulWidget {
  const RequestDemoMainPage({super.key});
  @override
  State<RequestDemoMainPage> createState() => _RequestDemoMainPageState();
}

class _RequestDemoMainPageState extends State<RequestDemoMainPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RequestDemoCubit>().loadDemos();
    context.read<RequestDemoCmsCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DemoQuestionModel> _getDynamicQuestions(RequestDemoCmsState cmsState) {
    if (cmsState is RequestDemoCmsLoaded) return cmsState.data.demoQuestions;
    return [];
  }

  List<String> _buildHeaders(List<DemoQuestionModel> dynamicQuestions) {
    return [
      ..._kStaticHeadersLeft,
      ...dynamicQuestions.map((q) => q.question.en),
      ..._kStaticHeadersRight,
    ];
  }

  String _getAnswer(RequestDemoModel d, String questionId) {
    final val = d.questionAnswers[questionId];
    if (val == null || val.isEmpty) return '-';
    return val;
  }

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

  void _showExportDialog(
    List<RequestDemoModel> demos,
    List<DemoQuestionModel> dynamicQuestions,
  ) {
    final fileNameCtrl = TextEditingController();
    bool isExporting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r)),
          child: Container(
            width: 400.w,
            padding: EdgeInsets.all(20.sp),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 30.sp, height: 30.sp,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: ColorPick.primary),
                      child: Icon(Icons.file_download_outlined,
                          size: 16.sp, color: Colors.white),
                    ),
                    SizedBox(width: 8.sp),
                    Text('Export',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text)),
                  ]),
                  SizedBox(height: 20.sp),
                  CustomValidatedTextFieldMaster(
                    label: 'File Name',
                    hint: 'Enter file name',
                    controller: fileNameCtrl,
                    height: 36,
                    submitted: false,
                    primaryColor: ColorPick.primary,
                    fillColor: const Color(0xFFF1F2ED),
                  ),
                  SizedBox(height: 20.sp),
                  Row(children: [
                    Expanded(
                        child: GestureDetector(
                      onTap:
                          isExporting ? null : () => Navigator.of(ctx).pop(),
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Center(
                            child: Text('Discard',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.text))),
                      ),
                    )),
                    SizedBox(width: 15.sp),
                    Expanded(
                        child: GestureDetector(
                      onTap: isExporting
                          ? null
                          : () {
                              final fn = fileNameCtrl.text.trim();
                              if (fn.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please enter a file name')));
                                return;
                              }
                              setDlg(() => isExporting = true);
                              _performExport(demos, dynamicQuestions, fn);
                              Navigator.of(ctx).pop();
                              _showExportSuccessDialog(fn);
                            },
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: isExporting
                              ? Colors.grey
                              : ColorPick.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                            child: isExporting
                                ? SizedBox(
                                    width: 16.sp, height: 16.sp,
                                    child: const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text('Download',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white))),
                      ),
                    )),
                  ]),
                ]),
          ),
        );
      }),
    );
  }

  void _performExport(
    List<RequestDemoModel> demos,
    List<DemoQuestionModel> dynamicQuestions,
    String fileName,
  ) {
    try {
      final buf = StringBuffer();
      final headers = [
        'No', 'Submission Date', 'Salon Name', 'Country', 'City',
        'No.Branches', 'No.Employees', 'First Name', 'Last Name',
        'Phone Number', 'Email',
        ...dynamicQuestions.map((q) => q.question.en),
        'Inquiry Priority', 'Inquiry Relevance', 'Required Action',
        'Notes', 'Status',
      ];
      buf.writeln(headers.map(_esc).join(','));

      for (int i = 0; i < demos.length; i++) {
        final d = demos[i];
        final dynamicValues =
            dynamicQuestions.map((q) => _getAnswer(d, q.id)).toList();
        buf.writeln([
          '${i + 1}', _fmtDate(d.submissionDate), d.salonName, d.country,
          d.city, d.noBranches, d.noEmployees, d.firstName, d.lastName,
          '${d.countryCode} ${d.phone}', d.email,
          ...dynamicValues,
          d.inquiryPriority?.label ?? '', d.inquiryRelevance?.label ?? '',
          d.requiredAction?.label ?? '', d.note, d.status.label,
        ].map(_esc).join(','));
      }

      final blob =
          html.Blob([utf8.encode(buf.toString())], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final fn = fileName.toLowerCase().endsWith('.csv')
          ? fileName : '$fileName.csv';
      html.AnchorElement(href: url)
        ..setAttribute('download', fn)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showExportSuccessDialog(String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64.sp, height: 64.sp,
              decoration: BoxDecoration(
                  color: ColorPick.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.check_circle,
                  color: ColorPick.primary, size: 40.sp),
            ),
            SizedBox(height: 16.h),
            Text('Export Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            SizedBox(height: 8.h),
            Text('$fileName\ndownloaded successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.secondaryText,
                    height: 1.4)),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('OK',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestDemoCmsCubit, RequestDemoCmsState>(
      builder: (context, demoCmsState) {
        final dynamicQuestions = _getDynamicQuestions(demoCmsState);

        return BlocListener<RequestDemoCubit, RequestDemoState>(
          listener: (context, state) {
            if (state is RequestDemoUpdated) {
              context.read<RequestDemoCubit>().loadDemos();
            }
          },
          child: BlocBuilder<RequestDemoCubit, RequestDemoState>(
            builder: (context, state) {
              if (state is RequestDemoInitial || state is RequestDemoLoading) {
                return const Scaffold(
                  backgroundColor: ColorPick.background,
                  body: Center(
                      child: CircularProgressIndicator(
                          color: ColorPick.primary)),
                );
              }

              final cubit = context.read<RequestDemoCubit>();
              List<RequestDemoModel> demos = [];
              int totalCount = 0, newCount = 0, repliedCount = 0,
                  closedCount = 0;
              Map<int, int>    monthlySubmissions  = {};
              Map<String, int> noBranchesCounts    = {};
              Map<String, int> noEmployeesCounts   = {};
              Map<String, int> primaryReasonCounts = {};
              Map<String, int> howDidYouHearCounts = {};
              Map<String, int> inquiryPriorityCounts  = {};
              Map<String, int> inquiryRelevanceCounts = {};
              Map<String, int> requiredActionCounts   = {};
              String? activeStatus, activeEntityType, activeCountry;
              List<String> uniqueStatuses    = [];
              List<String> uniqueEntityTypes = [];
              List<String> uniqueCountries   = [];
              List<int>    uniqueMonths      = [];
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

              final hasFilters = activeStatus != null ||
                  activeEntityType != null ||
                  activeCountry != null || activeMonth != null;

              final priorityTotal  =
                  inquiryPriorityCounts.values.fold(0, (a, b) => a + b);
              final relevanceTotal =
                  inquiryRelevanceCounts.values.fold(0, (a, b) => a + b);
              final reqActionTotal =
                  requiredActionCounts.values.fold(0, (a, b) => a + b);
              final howHearTotal   =
                  howDidYouHearCounts.values.fold(0, (a, b) => a + b);

              return Scaffold(
                backgroundColor: ColorPick.background,
                body: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppAdminNavbar(
                            activeLabel:    'Demos',
                            homePage:       HomeMainPage(),
                            webPage:        HomeMainPage(),
                            jobListingPage: HomeMainPage(),
                          ),
                          SizedBox(height: 20.h),
                          Text("Demo's",
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color: ColorPick.primary,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 16.h),
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
                                height: 36.h,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.w),
                                decoration: BoxDecoration(
                                  color: ColorPick.primary,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Filter',
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ]),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _summaryRow(totalCount, newCount, repliedCount,
                              closedCount),
                          SizedBox(height: 16.h),
                          _buildFiltersRow(
                            cubit: cubit,
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
                            dynamicQuestions: dynamicQuestions,
                          ),
                          SizedBox(height: 16.h),
                          _buildTable(demos, dynamicQuestions, context),
                          SizedBox(height: 40.h),
                          Text('Dashboard',
                              style: StyleText.fontSize24Weight600.copyWith(
                                  color: ColorPick.primary,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 16.h),
                          _chartRow(
                            left: _chartCard('Submission Received',
                                'Total: $totalCount',
                                _buildBarChart(monthlySubmissions)),
                            right: _chartCard('No.Branches', '',
                                _buildSegmentedBarChart(
                                  counts: noBranchesCounts,
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade300,
                                    ColorPick.primary,
                                    ColorPick.primary.withOpacity(0.7),
                                  ],
                                )),
                          ),
                          SizedBox(height: 16.h),
                          _chartRow(
                            left: _chartCard(
                                'Primary Reasons from Requesting a Demo', '',
                                _buildTwoColumnHorizontalBarChart(
                                    primaryReasonCounts)),
                            right: _chartCard('How did you hear about us?', '',
                                _buildDonutSection(
                                  counts: howDidYouHearCounts,
                                  centerTotal: howHearTotal,
                                  colors: _pieColors(
                                      howDidYouHearCounts.length),
                                )),
                          ),
                          SizedBox(height: 16.h),
                          _chartRow(
                            left: _chartCard('No. Employees', '',
                                _buildSegmentedBarChart(
                                  counts: noEmployeesCounts,
                                  colors: [
                                    ColorPick.primary,
                                    ColorPick.primary.withOpacity(0.7),
                                    ColorPick.primary.withOpacity(0.5),
                                    Colors.grey.shade400,
                                    Colors.grey.shade300,
                                  ],
                                )),
                            right: _chartCard('Inquiry Priority', '',
                                _buildDonutSection(
                                  counts: inquiryPriorityCounts,
                                  centerTotal: priorityTotal,
                                  colors: _priorityColors(
                                      inquiryPriorityCounts.keys.toList()),
                                  usePriorityColors: true,
                                )),
                          ),
                          SizedBox(height: 16.h),
                          _chartRow(
                            left: _chartCard('Inquiry Relevance', '',
                                _buildDonutSection(
                                  counts: inquiryRelevanceCounts,
                                  centerTotal: relevanceTotal,
                                  colors: _pieColors(
                                      inquiryRelevanceCounts.length),
                                )),
                            right: _chartCard('Required Action', '',
                                _buildDonutSection(
                                  counts: requiredActionCounts,
                                  centerTotal: reqActionTotal,
                                  colors:
                                      _pieColors(requiredActionCounts.length),
                                )),
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
}
