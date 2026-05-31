// ******************* FILE INFO *******************
// File Name: demo_detail_page.dart
// Description: Demo detail page
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › demos › presentation › ui › pages

// ═══════════════════════════════════════════════════════════════════
// FILE: demo_detail_page.dart
// Path: lib/pages/dashboard/demos/demo_detail_page.dart
//
// Figma layout (top to bottom):
//  1. AppAdminNavbar (Demo's | Web Page)
//  2. "Demo Details" title (pink)
//  3. "Submission Date: DD Mon YYYY" + Status dropdown (right)
//  4. Read-only fields in white card:
//       Salon Information:
//         Salon Name
//         No.Branches | No.Employees
//         Country | City
//       Contact Information:
//         First Name | Last Name
//         Email | Phone Number
//       Demo Related Questions:
//         Primary Reasons from Requesting a Demo | How did you hear about us?
//  5. "Our Comments" section in white card
//       Inquiry Priority | Inquiry Relevance | Required Action (3-col dropdowns)
//       Notes textarea
//  6. Discard (grey) | Submit (pink)
//  7. Dialogs: simple text with "Back" + "Confirm" buttons
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widgets/custom_dropdown.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/demo_model.dart';
import '../../controller/demo_cubit.dart';
import '../../controller/demo_state.dart';

part '../widgets/demo_detail_page/c.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────────────────────────────────────

class RequestDemoDetailPage extends StatefulWidget {
  final String demoId;
  const RequestDemoDetailPage({super.key, required this.demoId});
  @override State<RequestDemoDetailPage> createState() => _RequestDemoDetailPageState();
}

class _RequestDemoDetailPageState extends State<RequestDemoDetailPage> {
  final _noteCtrl = TextEditingController();

  bool _isSaving = false;
  bool _didLoad  = false;
  RequestDemoModel? _current;

  DemoPriority?  _priority;
  DemoRelevance? _relevance;
  DemoRequiredAction? _action;

  @override
  void initState() {
    super.initState();
    context.read<RequestDemoCubit>().loadDetail(widget.demoId);
  }

  void _seed(RequestDemoModel demo) {
    if (_didLoad) return;
    _didLoad  = true;
    _current  = demo;
    _noteCtrl.text = demo.note;
    _priority  = demo.inquiryPriority;
    _relevance = demo.inquiryRelevance;
    _action    = demo.requiredAction;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Status change dialog ──────────────────────────────────────────────────

  void _onStatusChange(RequestDemoModel demo, DemoStatus newStatus, Color cmsPrimary) {
    _showSimpleDialog(
      cmsPrimary: cmsPrimary,
      title:      'CHANGE SUBMISSION STATUS',
      body:       'Are you sure you want to change this Submissions status from ${demo.status.label} to ${newStatus.label}?',
      onBack: () {
        Navigator.of(context).pop();
      },
      onConfirm: () {
        Navigator.of(context).pop();
        context.read<RequestDemoCubit>().updateStatus(demo.id, newStatus);
      },
    );
  }

  // ── Submit dialog ─────────────────────────────────────────────────────────

  Future<void> _onSubmit(Color cmsPrimary) async {
    if (_current == null) return;
    _showSimpleDialog(
      cmsPrimary: cmsPrimary,
      title:      'SAVING SUBMISSION',
      body:       'Are you sure you want to Edit This Submissions?',
      onBack: () {
        Navigator.of(context).pop();
      },
      onConfirm: () async {
        Navigator.of(context).pop();
        setState(() => _isSaving = true);
        await context.read<RequestDemoCubit>().updateComments(
          id:        _current!.id,
          note:      _noteCtrl.text,
          priority:  _priority,
          relevance: _relevance,
          action:    _action,
        );
        if (mounted) {
          setState(() => _isSaving = false);
          Navigator.pop(context);
        }
      },
    );
  }

  // ── Figma dialog: simple text + Back/Confirm buttons ──────────────────────

  void _showSimpleDialog({
    required Color cmsPrimary,
    required String title,
    required String body,
    required VoidCallback onBack,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          width: 344.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              SizedBox(height: 8.h),
              Text(body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.secondaryText,
                      height: 1.5)),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onBack,
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: ColorPick.white,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Back',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: cmsPrimary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Confirm',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

        return BlocBuilder<RequestDemoCubit, RequestDemoState>(
          builder: (context, state) {
            RequestDemoModel? demo;
            if (state is RequestDemoDetailLoaded) demo = state.demo;
            if (state is RequestDemoUpdated)      demo = state.demo;

            if (demo == null) {
              return const Scaffold(
                backgroundColor: ColorPick.background,
                body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
              );
            }

            _seed(demo);
            _current = demo;

            final dateStr = demo.submissionDate != null
                ? '${demo.submissionDate!.day} ${_month(demo.submissionDate!.month)} ${demo.submissionDate!.year}'
                : '';

            final List<DemoStatus> statusOptions = switch (demo.status) {
              DemoStatus.newDemo => [DemoStatus.newDemo, DemoStatus.replied, DemoStatus.closed],
              DemoStatus.replied => [DemoStatus.replied, DemoStatus.closed],
              DemoStatus.closed  => [DemoStatus.closed],
            };

            return Scaffold(
              backgroundColor: ColorPick.background,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Navbar ─────────────────────────────────────
                            AppAdminNavbar(
                              activeLabel:    "Demos",
                              homePage:       HomeMainPage(),
                              webPage:        HomeMainPage(),
                              jobListingPage: HomeMainPage(),
                            ),
                            SizedBox(height: 20.h),

                            // ── Title ──────────────────────────────────────
                            Text('Demo Details',
                                style: StyleText.fontSize45Weight600.copyWith(
                                    color: cmsPrimary,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),

                            // ── Date + Status dropdown ─────────────────────
                            Row(
                              children: [
                                Text('Submission Date: ',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.text)),
                                Text(dateStr,
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.secondaryText)),
                                const Spacer(),
                                SizedBox(
                                  width: 140.w,
                                  child: CustomDropdownFormFieldInvMaster(
                                    selectedValue: demo.status.name,
                                    widthIcon: 14, heightIcon: 14, height: 32,
                                    borderRadius: 4,
                                    dropdownColor: Colors.white,
                                    showColorDots: true,
                                    primaryColor: cmsPrimary,
                                    items: statusOptions
                                        .map((s) => {'key': s.name, 'value': s.label})
                                        .toList(),
                                    onChanged: (val) {
                                      if (val == null) return;
                                      final ns = DemoStatus.values
                                          .firstWhere((s) => s.name == val);
                                      if (ns != demo!.status) {
                                        _onStatusChange(demo!, ns, cmsPrimary);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // ── Read-only fields in white card ─────────────
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r)
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Salon Information
                                    Text('Salon Information',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text)),
                                    SizedBox(height: 12.h),

                                    _readField('Salon Name', demo.salonName),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('No.Branches', demo.noBranches)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('No.Employees', demo.noEmployees)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('Country', demo.country)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('City', demo.city)),
                                      ],
                                    ),
                                    SizedBox(height: 24.h),

                                    // Contact Information
                                    Text('Contact Information',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text)),
                                    SizedBox(height: 12.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('First Name', demo.firstName)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('Last Name', demo.lastName)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('Email', demo.email)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('Phone Number', '${demo.countryCode} ${demo.phone}')),
                                      ],
                                    ),
                                    SizedBox(height: 24.h),

                                    // Demo Related Questions
                                    Text('Demo Related Questions',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text)),
                                    SizedBox(height: 12.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('Primary Reasons from Requesting a Demo', demo.primaryReason)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('How did you hear about us?', demo.howDidYouHearAboutUs)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Our Comments ───────────────────────────────
                            Text('Our Comments',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text)),
                            SizedBox(height: 14.h),

                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r)
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _dropdownField(
                                          label:      'Inquiry Priority',
                                          hint:       'Select Priority',
                                          value:      _priority?.label,
                                          items:      DemoPriority.allLabels,
                                          cmsPrimary: cmsPrimary,
                                          onChanged:  (v) => setState(() =>
                                          _priority = DemoPriority.fromString(v)),
                                        )),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _dropdownField(
                                          label:      'Inquiry Relevance',
                                          hint:       'Select Relevance',
                                          value:      _relevance?.label,
                                          items:      DemoRelevance.allLabels,
                                          cmsPrimary: cmsPrimary,
                                          onChanged:  (v) => setState(() =>
                                          _relevance = DemoRelevance.fromString(v)),
                                        )),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _dropdownField(
                                          label:      'Required Action',
                                          hint:       'Select Action',
                                          value:      _action?.label,
                                          items:      DemoRequiredAction.allLabels,
                                          cmsPrimary: cmsPrimary,
                                          onChanged:  (v) => setState(() =>
                                          _action = DemoRequiredAction.fromString(v)),
                                        )),
                                      ],
                                    ),
                                    SizedBox(height: 14.h),

                                    Text('Notes',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.text)),
                                    SizedBox(height: 6.h),
                                    SizedBox(
                                      height: 80.h,
                                      child: TextFormField(
                                        controller: _noteCtrl,
                                        maxLines: 4,
                                        style: TextStyle(fontSize: 12.sp, color: AppColors.text),
                                        decoration: InputDecoration(
                                          hoverColor: Colors.transparent,
                                          hintText: 'Text Here',
                                          hintStyle: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
                                          filled: true,
                                          fillColor: ColorPick.white,
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.r),
                                              borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // ── Discard / Submit ───────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      height: 48.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF797979),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('Discard',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSaving ? null : () => _onSubmit(cmsPrimary),
                                    child: Container(
                                      height: 48.h,
                                      decoration: BoxDecoration(
                                        color: cmsPrimary,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: _isSaving
                                          ? SizedBox(
                                          width: 20.w, height: 20.h,
                                          child: const CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2))
                                          : Text('Submit',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isSaving)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                          child: CircularProgressIndicator(color: ColorPick.primary)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  READ-ONLY FIELD (Figma style: label above, #F5F5F5 bg)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _readField(String label, String value, {bool multiLine = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.text)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: multiLine ? 80.h : 36.h,
          padding: EdgeInsets.symmetric(
              horizontal: 10.w, vertical: multiLine ? 8.h : 0),
          decoration: BoxDecoration(
            color: ColorPick.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: multiLine ? Alignment.topLeft : Alignment.centerLeft,
          child: Text(
            value.isEmpty ? 'Text Here' : value,
            style: StyleText.fontSize12Weight400.copyWith(
                color: value.isEmpty ? AppColors.secondaryText : AppColors.text),
            maxLines: multiLine ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DROPDOWN FIELD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Color cmsPrimary,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.text)),
        SizedBox(height: 4.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items.map((s) => {'key': s, 'value': s}).toList(),
          widthIcon: 14, heightIcon: 14, height: 36,
          borderRadius: 4,
          dropdownColor: Color(0xFFF1F1F1),
          primaryColor: cmsPrimary,
          hint: Text(hint,
              style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}
