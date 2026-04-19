// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_detail_page.dart  (UPDATED — 100% Figma-aligned)
// Path: lib/pages/dashboard/inquiry/inquiry_detail_page.dart
//
// Figma layout (top to bottom):
//  1. AppAdminNavbar (Inquiries | Web Page)
//  2. "Submission Details" title (pink)
//  3. "Submission Date: DD Mon YYYY" + Status dropdown (right)
//  4. Read-only fields (NO card wrapper — directly on page bg):
//       Preferred Language (full)
//       First Name | Last Name
//       Email | Phone Number
//       Gender | Country
//       Subject | Reason
//       Message (full, taller)
//  5. "Our Comments" label
//       Inquiry Priority | Inquiry Relevance | Required Action (3-col dropdowns)
//       Notes textarea
//  6. Legend section — 3 columns:
//       Priority colours | Relevance list | Required Action list
//  7. Discard (grey) | Submit (pink)
//  8. Dialogs: simple text with "Back" button only
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/controller/inquire/inquiry_cubit.dart';
import 'package:beauty_admin/controller/inquire/inquiry_state.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/app_admin_navbar.dart';

import '../../../core/widget/custom_dropdwon.dart';
import '../../controller/home/home_cubit.dart';
import '../../controller/home/home_state.dart';
import '../../model/inquire/inquire.dart';
import '../main_page/home_main_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color back      = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color fieldBg   = Color(0xFFF5F5F5);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
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

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
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
                      color: _C.labelText)),
              SizedBox(height: 8.h),
              Text(body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: _C.hintText,
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
                          color: _C.fieldBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Back',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _C.labelText)),
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

        return BlocBuilder<InquiryCubit, InquiryState>(
          builder: (context, state) {
            InquiryModel? inq;
            if (state is InquiryDetailLoaded) inq = state.inquiry;
            if (state is InquiryUpdated)       inq = state.inquiry;

            if (inq == null) {
              return const Scaffold(
                backgroundColor: _C.back,
                body: Center(child: CircularProgressIndicator(color: _C.primary)),
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
              backgroundColor: _C.back,
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
                            Text('Submission Details',
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
                                        color: _C.labelText)),
                                Text(dateStr,
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: _C.hintText)),
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

                            // ── Read-only fields (NO card wrapper) ─────────
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r)
                              ),
                              child: Padding(
                                padding:  EdgeInsets.all(25.sp),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _readField('Preferred Language', inq.preferredLanguage)),
                                        SizedBox(width: 16.w),
Expanded(child: Column())
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
                            Text('Our Comments',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _C.labelText)),
                            SizedBox(height: 14.h),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r)
                              ),
                              child: Padding(
                                padding:  EdgeInsets.all(25.sp),
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

                                    Text('Notes',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: _C.labelText)),
                                    SizedBox(height: 6.h),
                                    SizedBox(
                                      height: 80.h,
                                      child: TextFormField(
                                        controller: _noteCtrl,
                                        maxLines: 4,
                                        style: TextStyle(fontSize: 12.sp, color: _C.labelText),
                                        decoration: InputDecoration(
                                          hoverColor: Colors.transparent,
                                          hintText: 'Text Here',
                                          hintStyle: TextStyle(fontSize: 12.sp, color: _C.hintText),
                                          filled: true,
                                          fillColor: _C.fieldBg,
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

                            // // ── Legend section — 3 columns ─────────────────
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     // Priority (colored tiles)
                            //     Expanded(child: _priorityLegend(cmsPrimary)),
                            //     SizedBox(width: 12.w),
                            //     // Relevance (pink shaded list)
                            //     Expanded(child: _listLegend(
                            //       title: 'Strategic Opportunity',
                            //       items: InquiryRelevance.values
                            //           .map((r) => r.label)
                            //           .toList(),
                            //       baseColor: cmsPrimary,
                            //     )),
                            //     SizedBox(width: 12.w),
                            //     // Required Action (pink shaded list)
                            //     Expanded(child: _listLegend(
                            //       title: 'Immediate Response Required',
                            //       items: RequiredAction.values
                            //           .map((a) => a.label)
                            //           .toList(),
                            //       baseColor: cmsPrimary,
                            //     )),
                            //   ],
                            // ),
                            // SizedBox(height: 30.h),

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
                          child: CircularProgressIndicator(color: _C.primary)),
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
  //  READ-ONLY FIELD (Figma style: label above, #F5F5F5 bg, no card wrapper)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _readField(String label, String value, {bool multiLine = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: _C.labelText)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: multiLine ? 80.h : 36.h,
          padding: EdgeInsets.symmetric(
              horizontal: 10.w, vertical: multiLine ? 8.h : 0),
          decoration: BoxDecoration(
            color: _C.fieldBg,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: multiLine ? Alignment.topLeft : Alignment.centerLeft,
          child: Text(
            value.isEmpty ? 'Text Here' : value,
            style: StyleText.fontSize12Weight400.copyWith(
                color: value.isEmpty ? _C.hintText : _C.labelText),
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
                color: _C.labelText)),
        SizedBox(height: 4.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items.map((s) => {'key': s, 'value': s}).toList(),
          widthIcon: 14, heightIcon: 14, height: 36,
          borderRadius: 4,
          dropdownColor: Color(0xFFF1F1F1),
          primaryColor: cmsPrimary,
          hint: Text(hint,
              style: TextStyle(fontSize: 11.sp, color: _C.hintText)),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PRIORITY LEGEND (Figma: colored tiles — Critical/High/Medium/Low/Info)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _priorityLegend(Color cmsPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Critical (full width, top tile)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: InquiryPriority.critical.color,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text('Critical',
                style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(height: 6.h),
        // High
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text('High',
              style: TextStyle(fontSize: 10.sp, color: _C.labelText)),
        ),
        // Medium
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text('Medium',
              style: TextStyle(fontSize: 10.sp, color: _C.labelText)),
        ),
        // Low
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text('Low',
              style: TextStyle(fontSize: 10.sp, color: _C.labelText)),
        ),
        // Informational Only
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text('Informational Only',
              style: TextStyle(fontSize: 10.sp, color: _C.labelText)),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LIST LEGEND (Figma: pink header tile + text list below)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _listLegend({
    required String title,
    required List<String> items,
    required Color baseColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header tile (pink)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(title,
                style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
        ),
        SizedBox(height: 6.h),
        // List items (plain text)
        ...items.skip(1).map((item) => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text(item,
              style: TextStyle(fontSize: 10.sp, color: _C.labelText)),
        )),
      ],
    );
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}