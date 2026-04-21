// ******************* FILE INFO *******************
// File Name: terms_preview_page.dart
// Screen 3 of 3 — Terms of Service CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)
// FIXED:
//   1. Mobile preview now constrained to ~390 px wide (phone frame)
//   2. Tablet preview now constrained to ~768 px wide (tablet frame)
//   3. Download PDF links (ENG + ARB) rendered in all three preview layouts

import 'dart:typed_data';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../core/custom_segmant_tab.dart';
import '../../../model/about_us/about_us.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../../main_page/home_main_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color hintText  = Color(0xFF797979);
}

/// Simulated device widths for the preview frames
const double _kMobileWidth = 390.0;
const double _kTabletWidth = 768.0;

enum _PreviewMode { desktop, tablet, mobile }
enum _PreviewLang { eng, ar }

// ═══════════════════════════════════════════════════════════════════════════════

class TermsPreviewPage extends StatefulWidget {
  final TermsOfServiceModel      model;
  final Map<String, Uint8List>   imageUploads;
  final Map<String, DocUpload>   docUploads;

  const TermsPreviewPage({
    super.key,
    required this.model,
    this.imageUploads = const {},
    this.docUploads   = const {},
  });

  @override
  State<TermsPreviewPage> createState() => _TermsPreviewPageState();
}

class _TermsPreviewPageState extends State<TermsPreviewPage> {
  _PreviewMode _mode        = _PreviewMode.desktop;
  _PreviewLang _lang        = _PreviewLang.eng;
  bool         _termsOpen   = true;
  bool         _privacyOpen = true;

  bool get _isRtl => _lang == _PreviewLang.ar;

  // Convenience getters for in-memory bytes
  Uint8List? get _termsSvgBytes    => widget.imageUploads['terms_cms/terms/svg'];
  Uint8List? get _privacySvgBytes  => widget.imageUploads['terms_cms/privacy/svg'];

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() async {
    showPublishConfirmDialog(
      context: context,
      title: 'EDITING TERMS OF SERVICE DETAILS',
      subtitle: 'Do you want to save the changes made to Terms of Service?',
      onConfirm: () async {
        await context.read<TermsCubit>().save(
          model:        widget.model,
          imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
          docUploads:   widget.docUploads.isEmpty   ? null : widget.docUploads,
        );
      },
    );
  }

  final List<String> _languageTabs = ['ENG', 'AR'];

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.sectionBg,
      body: BlocListener<TermsCubit, TermsState>(
        listener: (context, state) {
          if (state is TermsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service saved!')));
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is TermsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppAdminNavbar(
                        activeLabel: 'Web Page',
                        homePage: HomeMainPage(),
                        webPage: HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),

                            Text('Preview Terms of Service Details',
                                style: StyleText.fontSize45Weight600.copyWith(
                                    color: _C.primary,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 16.h),

                            // ── Mode tabs + ENG|AR toggle ──────────────────────────
                            Row(children: [
                              ..._PreviewMode.values.map((m) {
                                final sel   = m == _mode;
                                final label = switch (m) {
                                  _PreviewMode.desktop => 'Desktop',
                                  _PreviewMode.tablet  => 'Tablet',
                                  _PreviewMode.mobile  => 'Mobile',
                                };
                                return GestureDetector(
                                  onTap: () => setState(() => _mode = m),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 24.w),
                                    child: Text(label,
                                        style: sel
                                            ? StyleText.fontSize14Weight600.copyWith(
                                            color: _C.primary,
                                            decoration: TextDecoration.underline,
                                            decorationColor: _C.primary)
                                            : StyleText.fontSize14Weight400
                                            .copyWith(color: _C.hintText)),
                                  ),
                                );
                              }),
                              const Spacer(),
                              CustomSegmentedTabs(
                                tabs: _languageTabs,
                                selectedIndex: _lang == _PreviewLang.eng ? 0 : 1,
                                onTabSelected: (index) =>
                                    setState(() => _lang = index == 0
                                        ? _PreviewLang.eng
                                        : _PreviewLang.ar),
                                selectedColor: _C.primary,
                                unselectedColor: Colors.white,
                                selectedTextColor: Colors.white,
                                unselectedTextColor: _C.hintText,
                                equalWidth: false,
                                containerPadding: EdgeInsets.symmetric(
                                    horizontal: 8.sp, vertical: 4.sp),
                              ),
                            ]),
                            SizedBox(height: 16.h),

                            // ── Terms and Conditions accordion ─────────────────────
                            _previewAccordion(
                              title: _isRtl
                                  ? 'الشروط والأحكام'
                                  : 'Terms and Conditions',
                              isOpen: _termsOpen,
                              onToggle: () =>
                                  setState(() => _termsOpen = !_termsOpen),
                              child: _sectionPreview(
                                section:  widget.model.termsAndConditions,
                                svgBytes: _termsSvgBytes,
                                labelEn:  'Download PDF of Terms and Conditions (ENG)',
                                labelAr:  'Download PDF of Terms and Conditions (ARB)',
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ── Privacy Policy accordion ───────────────────────────
                            _previewAccordion(
                              title: _isRtl
                                  ? 'سياسة الخصوصية'
                                  : 'Privacy Policy',
                              isOpen: _privacyOpen,
                              onToggle: () =>
                                  setState(() => _privacyOpen = !_privacyOpen),
                              child: _sectionPreview(
                                section:  widget.model.privacyPolicy,
                                svgBytes: _privacySvgBytes,
                                labelEn:  'Download PDF of Privacy Policy (ENG)',
                                labelAr:  'Download PDF of Privacy Policy (ARB)',
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Back | Save ────────────────────────────────────────
                            Row(children: [
                              Expanded(child: SizedBox(
                                  height: 44.h,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.grey,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.r))),
                                    child: Text('Back',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white)),
                                  ))),
                              SizedBox(width: 12.w),
                              Expanded(child: SizedBox(
                                  height: 44.h,
                                  child: ElevatedButton(
                                    onPressed: _onSave,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.r))),
                                    child: Text('Published',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white)),
                                  ))),
                            ]),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Accordion wrapper ─────────────────────────────────────────────────────
  Widget _previewAccordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Container(
      decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(6.r)),
      child: Column(children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(child: Text(title,
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          Padding(padding: EdgeInsets.all(16.w), child: child),
      ]),
    );
  }

  // ── Section preview — wraps mobile/tablet in a constrained device frame ───
  Widget _sectionPreview({
    required TermsSection section,
    required Uint8List?   svgBytes,
    required String       labelEn,
    required String       labelAr,
  }) {
    final desc   = _isRtl ? section.description.ar : section.description.en;
    final svgUrl = section.svgUrl;

    // The actual preview content widget
    Widget content = Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: switch (_mode) {
        _PreviewMode.desktop => _TermsDesktopPreview(
            desc: desc, svgUrl: svgUrl, svgBytes: svgBytes,
            attachEnUrl: section.attachEnUrl,
            attachArUrl: section.attachArUrl,
            labelEn: labelEn, labelAr: labelAr,
            primaryColor: _C.primary),
        _PreviewMode.tablet  => _TermsTabletPreview(
            desc: desc, svgUrl: svgUrl, svgBytes: svgBytes,
            attachEnUrl: section.attachEnUrl,
            attachArUrl: section.attachArUrl,
            labelEn: labelEn, labelAr: labelAr,
            primaryColor: _C.primary),
        _PreviewMode.mobile  => _TermsMobilePreview(
            desc: desc, svgUrl: svgUrl, svgBytes: svgBytes,
            attachEnUrl: section.attachEnUrl,
            attachArUrl: section.attachArUrl,
            labelEn: labelEn, labelAr: labelAr,
            primaryColor: _C.primary),
      },
    );

    // For tablet/mobile wrap in a constrained frame so the preview respects
    // the simulated device width instead of stretching to full desktop width.
    if (_mode == _PreviewMode.mobile) {
      return Center(
        child: _DeviceFrame(
          width: _kMobileWidth,
          label: '',
          child: content,
        ),
      );
    }
    if (_mode == _PreviewMode.tablet) {
      return Center(
        child: _DeviceFrame(
          width: _kTabletWidth,
          label: '',
          child: content,
        ),
      );
    }

    return content; // desktop: full width
  }
}

// ── Device frame — gives mobile/tablet a visible boundary in the preview ─────
class _DeviceFrame extends StatelessWidget {
  final double width;
  final String label;
  final Widget child;
  const _DeviceFrame({
    required this.width,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Small label at top
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: _C.hintText,
                  fontWeight: FontWeight.w500)),
        ),
        Container(
          width: width,
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12.r),
            // border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.black.withOpacity(0.07),
            //       blurRadius: 12,
            //       offset: const Offset(0, 4))
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: child,
          ),
        ),
      ],
    );
  }
}

// ── Shared SVG renderer — bytes take priority over url ────────────────────────
Widget _svgWidget({
  required Uint8List? bytes,
  required String     url,
  required double     width,
  required double     height,
}) {
  if (bytes != null && bytes.isNotEmpty) {
    return SvgPicture.memory(bytes,
        width: width, height: height, fit: BoxFit.contain);
  }
  if (url.isNotEmpty) {
    return SvgPicture.network(
      url,
      width: width, height: height, fit: BoxFit.contain,
      placeholderBuilder: (_) => SizedBox(
        width: width, height: height,
        child: const Center(child: CircularProgressIndicator(
            color: Color(0xFF008037), strokeWidth: 2)),
      ),
    );
  }
  return SizedBox(
    width: width, height: height,
    child: Icon(Icons.image_outlined,
        color: Colors.grey[400], size: width * 0.4),
  );
}

// ── Shared download link row ──────────────────────────────────────────────────
Widget _downloadRow({
  required String attachEnUrl,
  required String attachArUrl,
  required String labelEn,
  required String labelAr,
  required Color  primaryColor,
  bool isColumn = false,   // stacked layout for narrow views
}) {
  Widget btn(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        // In admin preview we just show a snackbar; real navigation is on user side
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvg(assetPath: "assets/images/export.svg",color: primaryColor,),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label,
                style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor)),
          ),
        ],
      ),
    );
  }

  if (isColumn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        btn(labelEn, attachEnUrl),
        if (attachArUrl.isNotEmpty) SizedBox(height: 6.h),
        btn(labelAr, attachArUrl),
      ],
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      btn(labelEn, attachEnUrl),
      btn(labelAr, attachArUrl),
    ],
  );
}

// ─── Desktop ──────────────────────────────────────────────────────────────────
class _TermsDesktopPreview extends StatelessWidget {
  final String    desc, svgUrl;
  final Uint8List? svgBytes;
  final String    attachEnUrl, attachArUrl, labelEn, labelAr;
  final Color     primaryColor;

  const _TermsDesktopPreview({
    required this.desc,
    required this.svgUrl,
    this.svgBytes,
    required this.attachEnUrl,
    required this.attachArUrl,
    required this.labelEn,
    required this.labelAr,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(12.r)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(
                  desc.isEmpty ? 'Description text here…' : desc,
                  style: StyleText.fontSize14Weight400
                      .copyWith(fontSize: 13.sp, height: 1.75)),
            ),
            if (hasSvg) ...[
              SizedBox(width: 24.w),
              _svgWidget(bytes: svgBytes, url: svgUrl,
                  width: 200.w, height: 200.h),
            ],
          ]),
        ),
        SizedBox(height: 12.h),
        _downloadRow(
          attachEnUrl:  attachEnUrl,
          attachArUrl:  attachArUrl,
          labelEn:      labelEn,
          labelAr:      labelAr,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}

// ─── Tablet ───────────────────────────────────────────────────────────────────
class _TermsTabletPreview extends StatelessWidget {
  final String    desc, svgUrl;
  final Uint8List? svgBytes;
  final String    attachEnUrl, attachArUrl, labelEn, labelAr;
  final Color     primaryColor;

  const _TermsTabletPreview({
    required this.desc,
    required this.svgUrl,
    this.svgBytes,
    required this.attachEnUrl,
    required this.attachArUrl,
    required this.labelEn,
    required this.labelAr,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSvg) ...[
            Center(child: _svgWidget(bytes: svgBytes, url: svgUrl,
                width: 160.w, height: 160.h)),
            SizedBox(height: 12.h),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(12.r)),
            child: Text(
                desc.isEmpty ? 'Description text here…' : desc,
                style: StyleText.fontSize14Weight400
                    .copyWith(fontSize: 12.sp, height: 1.75)),
          ),
          SizedBox(height: 12.h),
          _downloadRow(
            attachEnUrl:  attachEnUrl,
            attachArUrl:  attachArUrl,
            labelEn:      labelEn,
            labelAr:      labelAr,
            primaryColor: primaryColor,
            isColumn:     true,   // stacked for narrow frame
          ),
        ],
      ),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────
class _TermsMobilePreview extends StatelessWidget {
  final String    desc, svgUrl;
  final Uint8List? svgBytes;
  final String    attachEnUrl, attachArUrl, labelEn, labelAr;
  final Color     primaryColor;

  const _TermsMobilePreview({
    required this.desc,
    required this.svgUrl,
    this.svgBytes,
    required this.attachEnUrl,
    required this.attachArUrl,
    required this.labelEn,
    required this.labelAr,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;
    return Padding(
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSvg) ...[
            Center(child: _svgWidget(bytes: svgBytes, url: svgUrl,
                width: 120.w, height: 120.h)),
            SizedBox(height: 10.h),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(12.r)),
            child: Text(
                desc.isEmpty ? 'Description text here…' : desc,
                style: StyleText.fontSize14Weight400
                    .copyWith(fontSize: 11.sp, height: 1.7)),
          ),
          SizedBox(height: 12.h),
          _downloadRow(
            attachEnUrl:  attachEnUrl,
            attachArUrl:  attachArUrl,
            labelEn:      labelEn,
            labelAr:      labelAr,
            primaryColor: primaryColor,
            isColumn:     true,   // stacked for narrow frame
          ),
        ],
      ),
    );
  }
}

// ── Confirm dialog ────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r)),
    contentPadding: EdgeInsets.all(24.r),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w, height: 80.w,
          decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(40.r)),
          child: Icon(Icons.edit_note,
              size: 40.sp, color: const Color(0xFF008037)),
        ),
        SizedBox(height: 16.h),
        Text('EDITING TERMS OF SERVICE DETAILS',
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight600
                .copyWith(color: const Color(0xFF1A1A1A))),
        SizedBox(height: 8.h),
        Text(
            'Do you want to save the changes made to Terms of Service?',
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack)),
        SizedBox(height: 20.h),
        Row(children: [
          Expanded(child: SizedBox(
              height: 40.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r))),
                child: Text('Back',
                    style: StyleText.fontSize13Weight500
                        .copyWith(color: Colors.white)),
              ))),
          SizedBox(width: 12.w),
          Expanded(child: SizedBox(
              height: 40.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008037),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r))),
                child: Text('Confirm',
                    style: StyleText.fontSize13Weight500
                        .copyWith(color: Colors.white)),
              ))),
        ]),
      ],
    ),
  ),
);