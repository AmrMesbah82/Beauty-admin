// ******************* FILE INFO *******************
// File Name: inquiry_details.dart
// Description: Inquiry details page
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › pages

// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_details.dart  (UPDATED — 100% Figma-aligned)
// Path: lib/pages/dashboard/inquiry/inquiry_details.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widgets/custom_dropdown.dart';
import '../../../../../core/widgets/format.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/inquire_model.dart';
import '../../controller/inquiry_cubit.dart';
import '../../controller/inquiry_state.dart';

part '../widgets/inquiry_details/c.dart';
part '../widgets/inquiry_details/helpers.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────────────────────────────────────

class InquiryDetailPage extends StatefulWidget {
  final String inquiryId;
  const InquiryDetailPage({super.key, required this.inquiryId});
  @override State<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends State<InquiryDetailPage> {
  final _noteCtrl = TextEditingController();

  bool _isSaving = false;
  bool _didLoad  = false;
  InquiryModel? _current;

  InquiryPriority?  _priority;
  InquiryRelevance? _relevance;
  RequiredAction?   _action;

  @override
  void initState() {
    super.initState();
    context.read<InquiryCubit>().loadDetail(widget.inquiryId);
  }

  void _seed(InquiryModel inq) {
    if (_didLoad) return;
    _didLoad  = true;
    _current  = inq;
    _noteCtrl.text = inq.note;
    _priority  = inq.inquiryPriority;
    _relevance = inq.inquiryRelevance;
    _action    = inq.requiredAction;
  }

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  // ── Status change dialog ──────────────────────────────────────────────────

  void _onStatusChange(InquiryModel inq, InquiryStatus newStatus, Color cmsPrimary) {
    _showSimpleDialog(
      cmsPrimary: cmsPrimary,
      title:      'CHANGE SUBMISSION STATUS',
      body:       'Are you sure you want to change this Submissions status from ${inq.status.label} to ${newStatus.label}?',
      onBack: () {
        Navigator.of(context).pop();
      },
      onConfirm: () {
        Navigator.of(context).pop();
        context.read<InquiryCubit>().updateStatus(inq.id, newStatus);
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
        await context.read<InquiryCubit>().updateComments(
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

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, cmsState) {
        final Color cmsPrimary = _primaryFromCmsState(cmsState);

        return BlocBuilder<InquiryCubit, InquiryState>(
          builder: (context, state) {
            InquiryModel? inq;
            if (state is InquiryDetailLoaded) inq = state.inquiry;
            if (state is InquiryUpdated)       inq = state.inquiry;

            if (inq == null) {
              return const Scaffold(
                backgroundColor: ColorPick.background,
                body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
              );
            }

            _seed(inq);
            _current = inq;

            final dateStr = inq.submissionDate != null
                ? '${inq.submissionDate!.day} ${_month(inq.submissionDate!.month)} ${inq.submissionDate!.year}'
                : '';

            final List<InquiryStatus> statusOptions = switch (inq.status) {
              InquiryStatus.newInquiry => [InquiryStatus.newInquiry, InquiryStatus.replied, InquiryStatus.closed],
              InquiryStatus.replied   => [InquiryStatus.replied, InquiryStatus.closed],
              InquiryStatus.closed    => [InquiryStatus.closed],
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
                              activeLabel:    'Inquiries',
                              homePage:       HomeMainPage(),
                              webPage:        HomeMainPage(),
                              jobListingPage: HomeMainPage(),
                            ),
                            SizedBox(height: 20.h),

                            // ── Title ──────────────────────────────────────
                            Text(
                              FormatHelper.capitalize('Submission Details'),
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color: cmsPrimary,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 16.h),

                            // ── Date + Status dropdown ─────────────────────
                            Row(
                              children: [
                                Text(
                                  FormatHelper.capitalize('Submission Date: '),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.text),
                                ),
                                Text(
                                  FormatHelper.capitalize(dateStr),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.secondaryText),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 140.w,
                                  child: CustomDropdownFormFieldInvMaster(
                                    selectedValue: inq.status.name,
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
                                      final ns = InquiryStatus.values
                                          .firstWhere((s) => s.name == val);
                                      if (ns != inq!.status) {
                                        _onStatusChange(inq!, ns, cmsPrimary);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // ── Read-only fields ───────────────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25.sp),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _readField('Preferred Language', inq.preferredLanguage)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: Column()),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('First Name', inq.firstName)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('Last Name', inq.lastName)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('Email', inq.email)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('Phone Number', '${inq.countryCode} ${inq.phone}')),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('Gender', inq.gender)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('Country', inq.country)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    Row(
                                      children: [
                                        Expanded(child: _readField('Subject', inq.subject)),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _readField('Reason', inq.reason)),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    _readField('Message', inq.message, multiLine: true),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Our Comments ───────────────────────────────
                            Text(
                              FormatHelper.capitalize('Our Comments'),
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text),
                            ),
                            SizedBox(height: 14.h),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25.sp),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _dropdownField(
                                          label:      'Inquiry Priority',
                                          hint:       'Select Priority',
                                          value:      _priority?.label,
                                          items:      InquiryPriority.allLabels,
                                          cmsPrimary: cmsPrimary,
                                          onChanged:  (v) => setState(() =>
                                          _priority = InquiryPriority.fromString(v)),
                                        )),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _dropdownField(
                                          label:      'Inquiry Relevance',
                                          hint:       'Select Relevance',
                                          value:      _relevance?.label,
                                          items:      InquiryRelevance.allLabels,
                                          cmsPrimary: cmsPrimary,
                                          onChanged:  (v) => setState(() =>
                                          _relevance = InquiryRelevance.fromString(v)),
                                        )),
                                        SizedBox(width: 16.w),
                                        Expanded(child: _dropdownField(
                                          label:      'Required Action',
                                          hint:       'Select Action',
                                          value:      _action?.label,
                                          items:      RequiredAction.allLabels,
                                          cmsPrimary: cmsPrimary,
                                          onChanged:  (v) => setState(() =>
                                          _action = RequiredAction.fromString(v)),
                                        )),
                                      ],
                                    ),
                                    SizedBox(height: 14.h),

                                    Row(
                                      children: [
                                        Text(
                                          FormatHelper.capitalize('Notes'),
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.text),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    SizedBox(
                                      height: 80.h,
                                      child: TextFormField(
                                        controller: _noteCtrl,
                                        maxLines: 4,
                                        style: TextStyle(fontSize: 12.sp, color: AppColors.text),
                                        decoration: InputDecoration(
                                          hoverColor: Colors.transparent,
                                          hintText: FormatHelper.capitalize('Text Here'),
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
                            SizedBox(height: 24.h),

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
                                      child: Text(
                                        FormatHelper.capitalize('Discard'),
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 300.w),
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
                                          : Text(
                                        FormatHelper.capitalize('Submit'),
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white),
                                      ),
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

}
