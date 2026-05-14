// ******************* FILE INFO *******************
// File Name: terms_preview_page.dart
// Screen 3 of 3 — Terms of Service CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)
// Refactored to match overview_preview_page.dart style:
//   - Proper device frames with Transform.scale + OverflowBox
//   - Desktop: browser chrome frame (1366×768)
//   - Tablet:  browser chrome frame centered (768×1024)
//   - Mobile:  phone shell with notch/indicator (375×812)
//   - _PreviewContent architecture
//   - Underline tab switcher + CustomSegmentedTabs EN/AR toggle

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

import '../../../core/custom_dialog.dart';
import '../../../core/custom_segmant_tab.dart';
import '../../../model/about_us/about_us.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../../main_page/home_main_page.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _C {
  static const Color primary     = Color(0xFFD16F9A);
  static const Color back        = Color(0xFFF1F2ED);
  static const Color sectionBg   = Color(0xFFF5F5F5);
  static const Color labelText   = Color(0xFF333333);
  static const Color hintText    = Color(0xFF797979);
  static const Color border      = Color(0xFFE0E0E0);
  static const Color grey        = Color(0xFF9E9E9E);
}

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;
const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;
const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }
enum _PreviewLang   { eng, ar }

// ═══════════════════════════════════════════════════════════════════════════════

class TermsPreviewPage extends StatefulWidget {
  final TermsOfServiceModel    model;
  final Map<String, Uint8List> imageUploads;
  final Map<String, DocUpload> docUploads;

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
  _PreviewDevice _device       = _PreviewDevice.desktop;
  _PreviewLang   _lang         = _PreviewLang.eng;
  bool           _isPublishing = false;

  bool get _isEnglish => _lang == _PreviewLang.eng;

  // Convenience getters for in-memory bytes
  Uint8List? get _termsSvgBytes   => widget.imageUploads['terms_cms/terms/svg'];
  Uint8List? get _privacySvgBytes => widget.imageUploads['terms_cms/privacy/svg'];

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() {
    showPublishConfirmDialog(
      context: context,
      title: 'PUBLISHING TERMS OF SERVICE',
      subtitle: 'Do you want to publish the Terms of Service?',
      onConfirm: () async {
        setState(() => _isPublishing = true);
        try {
          await context.read<TermsCubit>().save(
            model:        widget.model,
            imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
            docUploads:   widget.docUploads.isEmpty   ? null : widget.docUploads,
          );
        } finally {
          if (mounted) setState(() => _isPublishing = false);
        }
      },
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsCubit, TermsState>(
      listener: (context, state) {
        if (state is TermsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service published!')));
          Navigator.popUntil(context, (r) => r.isFirst);
        }
        if (state is TermsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red));
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: _C.back,
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAdminNavbar(
                        activeLabel: 'Web Page',
                        homePage: HomeMainPage(),
                        webPage: HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(height: 16.h),

                      // ── Page title ─────────────────────────────────────
                      Text(
                        'Preview Terms of Service',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Device tabs + EN|AR toggle ─────────────────────
                      Row(
                        children: [
                          _tab('Desktop', _PreviewDevice.desktop),
                          SizedBox(width: 24.w),
                          _tab('Tablet',  _PreviewDevice.tablet),
                          SizedBox(width: 24.w),
                          _tab('Mobile',  _PreviewDevice.mobile),
                          const Spacer(),
                          SizedBox(
                            width: 95.w,
                            height: 36.h,
                            child: CustomSegmentedTabs(
                              tabs: const ['ENG', 'AR'],
                              selectedIndex: _isEnglish ? 0 : 1,
                              onTabSelected: (i) => setState(
                                      () => _lang = i == 0 ? _PreviewLang.eng : _PreviewLang.ar),
                              selectedColor:      _C.primary,
                              unselectedColor:    Colors.white,
                              selectedTextColor:  Colors.white,
                              unselectedTextColor: _C.hintText,
                              equalWidth: false,
                              containerPadding: EdgeInsets.symmetric(
                                  horizontal: 8.sp, vertical: 4.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // ── Preview area ───────────────────────────────────
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: LayoutBuilder(
                          builder: (ctx, box) => _buildFrame(box.maxWidth),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Back + Publish ─────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: _C.grey,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Center(
                                  child: Text('Back',
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 300.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isPublishing ? null : _onSave,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: _isPublishing
                                      ? _C.primary.withOpacity(0.5)
                                      : _C.primary,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Center(
                                  child: _isPublishing
                                      ? SizedBox(
                                    width: 18.w, height: 18.h,
                                    child: const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                      : Text('Publish',
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(color: Colors.white)),
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
          ),

          // ── Full-screen publishing overlay ─────────────────────────────
          if (_isPublishing)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                  child: CircularProgressIndicator(color: _C.primary)),
            ),
        ],
      ),
    );
  }

  // ── Underline tab ──────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? _C.primary : _C.hintText,
                )),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? _C.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame dispatcher ───────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
          containerWidth: containerW,
          model:          widget.model,
          termsSvgBytes:  _termsSvgBytes,
          privacySvgBytes: _privacySvgBytes,
          isEnglish:      _isEnglish,
        );
      case _PreviewDevice.tablet:
        return _TabletFrame(
          containerWidth: containerW,
          model:          widget.model,
          termsSvgBytes:  _termsSvgBytes,
          privacySvgBytes: _privacySvgBytes,
          isEnglish:      _isEnglish,
        );
      case _PreviewDevice.mobile:
        return _MobileFrame(
          containerWidth: containerW,
          model:          widget.model,
          termsSvgBytes:  _termsSvgBytes,
          privacySvgBytes: _privacySvgBytes,
          isEnglish:      _isEnglish,
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME  (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
class _DesktopFrame extends StatelessWidget {
  final double         containerWidth;
  final TermsOfServiceModel model;
  final Uint8List?     termsSvgBytes;
  final Uint8List?     privacySvgBytes;
  final bool           isEnglish;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    this.termsSvgBytes,
    this.privacySvgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width:  containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(color: _C.back),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width:  containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth:  _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale:     scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _PreviewContent(
                        fakeWidth:       _kDesktopW,
                        fakeHeight:      _kDesktopH,
                        model:           model,
                        termsSvgBytes:   termsSvgBytes,
                        privacySvgBytes: privacySvgBytes,
                        isEnglish:       isEnglish,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TABLET FRAME  (768 × 1024)
// ═════════════════════════════════════════════════════════════════════════════
class _TabletFrame extends StatelessWidget {
  final double         containerWidth;
  final TermsOfServiceModel model;
  final Uint8List?     termsSvgBytes;
  final Uint8List?     privacySvgBytes;
  final bool           isEnglish;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    this.termsSvgBytes,
    this.privacySvgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Column(
      children: [
        Center(
          child: Container(
            width:  displayW + 4,
            height: displayH + 28 + 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border, width: 2),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _BrowserChrome(compact: true),
                SizedBox(
                  width:  displayW,
                  height: displayH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kTabletW,
                      maxHeight: _kTabletH,
                      child: Transform.scale(
                        scale:     scale,
                        alignment: Alignment.topLeft,
                        child: _PreviewContent(
                          fakeWidth:       _kTabletW,
                          fakeHeight:      _kTabletH,
                          model:           model,
                          termsSvgBytes:   termsSvgBytes,
                          privacySvgBytes: privacySvgBytes,
                          isEnglish:       isEnglish,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE FRAME  (375 × 812)
// ═════════════════════════════════════════════════════════════════════════════
class _MobileFrame extends StatelessWidget {
  final double         containerWidth;
  final TermsOfServiceModel model;
  final Uint8List?     termsSvgBytes;
  final Uint8List?     privacySvgBytes;
  final bool           isEnglish;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    this.termsSvgBytes,
    this.privacySvgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;
    final double shellH   = displayH + 24 + 12 + 4;
    final double shellW   = displayW + 4;

    return Column(
      children: [
        Center(
          child: Container(
            width:        shellW,
            height:       shellH,
            decoration:   BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // ── Notch ────────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 12,
                      decoration: BoxDecoration(
                        color:        _C.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────────
                SizedBox(
                  width:  displayW,
                  height: displayH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kMobileW,
                      maxHeight: _kMobileH,
                      child: Transform.scale(
                        scale:     scale,
                        alignment: Alignment.topLeft,
                        child: _PreviewContent(
                          fakeWidth:       _kMobileW,
                          fakeHeight:      _kMobileH,
                          model:           model,
                          termsSvgBytes:   termsSvgBytes,
                          privacySvgBytes: privacySvgBytes,
                          isEnglish:       isEnglish,
                          isMobile:        true,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Home indicator ────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width:  displayW * 0.3,
                      height: 4,
                      decoration: BoxDecoration(
                        color:        _C.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatefulWidget {
  final double              fakeWidth;
  final double              fakeHeight;
  final TermsOfServiceModel model;
  final Uint8List?          termsSvgBytes;
  final Uint8List?          privacySvgBytes;
  final bool                isEnglish;
  final bool                isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    this.termsSvgBytes,
    this.privacySvgBytes,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  bool _termsOpen   = true;
  bool _privacyOpen = true;

  bool get _isMobileView => widget.fakeWidth < 600;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:        Size(widget.fakeWidth, widget.fakeHeight),
        padding:     EdgeInsets.zero,
        viewInsets:  EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color:  _C.back,
          width:  widget.fakeWidth,
          height: widget.fakeHeight,
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: widget.isEnglish
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const SizedBox(height: 24),
                  // _buildHero(),
                  const SizedBox(height: 32),
                  _buildAccordion(
                    title:    widget.isEnglish ? 'Terms and Conditions' : 'الشروط والأحكام',
                    isOpen:   _termsOpen,
                    onToggle: () => setState(() => _termsOpen = !_termsOpen),
                    child:    _buildSection(
                      section:  widget.model.termsAndConditions,
                      svgBytes: widget.termsSvgBytes,
                      labelEn:  'Download PDF of Terms and Conditions (ENG)',
                      labelAr:  'تحميل PDF للشروط والأحكام (عربي)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAccordion(
                    title:    widget.isEnglish ? 'Privacy Policy' : 'سياسة الخصوصية',
                    isOpen:   _privacyOpen,
                    onToggle: () => setState(() => _privacyOpen = !_privacyOpen),
                    child:    _buildSection(
                      section:  widget.model.privacyPolicy,
                      svgBytes: widget.privacySvgBytes,
                      labelEn:  'Download PDF of Privacy Policy (ENG)',
                      labelAr:  'تحميل PDF لسياسة الخصوصية (عربي)',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────────
  Widget _buildHero() {
    final h = _isMobileView ? 100.0 : 140.0;
    return Container(
      width:  double.infinity,
      height: h,
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      decoration: BoxDecoration(
        color:        _C.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isEnglish ? 'Legal' : 'قانوني',
              style: TextStyle(
                color:      Colors.white.withOpacity(0.65),
                fontSize:   _isMobileView ? 11 : 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isEnglish
                  ? 'Terms & Privacy'
                  : 'الشروط والخصوصية',
              style: TextStyle(
                color:      Colors.white,
                fontSize:   _isMobileView ? 20 : 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _buildAccordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    final hPad = widget.isMobile ? 16.0 : 40.0;
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset:     const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width:   double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color:        _C.primary,
                borderRadius: isOpen
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size:  20,
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
        ],
      ),
    );
  }

  // ── Section body ───────────────────────────────────────────────────────────
  Widget _buildSection({
    required TermsSection section,
    required Uint8List?   svgBytes,
    required String       labelEn,
    required String       labelAr,
  }) {
    final desc   = widget.isEnglish
        ? section.description.en
        : section.description.ar;
    final svgUrl = section.svgUrl;
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;

    if (_isMobileView) {
      // ── Mobile / narrow layout: stacked ──────────────────────────────
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSvg) ...[
            Center(
              child: _svgWidget(
                  bytes: svgBytes, url: svgUrl,
                  width: 100, height: 100),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            desc.isEmpty ? 'Description text here…' : desc,
            textDirection: widget.isEnglish
                ? TextDirection.ltr
                : TextDirection.rtl,
            style: const TextStyle(
                fontSize: 12, height: 1.75, color: _C.labelText),
          ),
          const SizedBox(height: 16),
          _downloadLinks(
            section:  section,
            labelEn:  labelEn,
            labelAr:  labelAr,
            stacked:  true,
          ),
        ],
      );
    }

    // ── Desktop / tablet layout: side-by-side ──────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                desc.isEmpty ? 'Description text here…' : desc,
                textDirection: widget.isEnglish
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 13, height: 1.75, color: _C.labelText),
              ),
            ),
            if (hasSvg) ...[
              const SizedBox(width: 28),
              _svgWidget(
                  bytes: svgBytes, url: svgUrl,
                  width: 160, height: 160),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _downloadLinks(
          section: section,
          labelEn: labelEn,
          labelAr: labelAr,
          stacked: false,
        ),
      ],
    );
  }

  // ── Download links row/column ───────────────────────────────────────────────
  Widget _downloadLinks({
    required TermsSection section,
    required String       labelEn,
    required String       labelAr,
    required bool         stacked,
  }) {
    Widget _btn(String label, String url) {
      if (url.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvg(
              assetPath: 'assets/images/export.svg',
              color:     _C.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize:        11,
                  fontWeight:      FontWeight.w500,
                  color:           _C.primary,
                  decoration:      TextDecoration.underline,
                  decorationColor: _C.primary),
            ),
          ),
        ],
      );
    }

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _btn(labelEn, section.attachEnUrl),
          if (section.attachArUrl.isNotEmpty) const SizedBox(height: 6),
          _btn(labelAr, section.attachArUrl),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn(labelEn, section.attachEnUrl),
        _btn(labelAr, section.attachArUrl),
      ],
    );
  }
}

// ── Shared SVG renderer ───────────────────────────────────────────────────────
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

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════
class _BrowserChrome extends StatelessWidget {
  final bool compact;
  const _BrowserChrome({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double h = compact ? 22 : 28;
    return Container(
      height:  h,
      color:   const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 4),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 4),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: compact ? 10 : 14,
              decoration: BoxDecoration(
                color:        const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width:       8,
    height:      8,
    decoration:  BoxDecoration(color: color, shape: BoxShape.circle),
  );
}