/// File Name: request_demo_preview_page.dart
/// Description: Preview page for Request Demo CMS.
///              Renders: Confirm Message with SVG, title, description.
///              Desktop / Tablet / Mobile frames + EN / AR toggle.
///              Back + Save buttons at bottom.
/// UPDATED: Added proper device frame rendering (Desktop/Tablet/Mobile)
///   - Desktop: 1366×768 browser chrome frame
///   - Tablet: 768×1024 browser chrome frame (centered)
///   - Mobile: 375×812 phone shell with notch (centered)
///   - Maintained EN/AR toggle functionality
///   - Preserved confirm message layout (SVG + title + description)
/// Created by: Amr Mesbah
/// Last Update: 14/05/2026

import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_admin_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/request/request_demo_cubit.dart';
import '../../controller/request/request_demo_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/request/request_demo_model.dart';
import '../main_page/home_main_page.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color back = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFF5F5F5);
}

enum _PreviewDevice { desktop, tablet, mobile }

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH = 768.0;

const double _kTabletW = 768.0;
const double _kTabletH = 1024.0;

const double _kMobileW = 375.0;
const double _kMobileH = 812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

class RequestDemoPreviewPage extends StatefulWidget {
  const RequestDemoPreviewPage({super.key});

  @override
  State<RequestDemoPreviewPage> createState() =>
      _RequestDemoPreviewPageState();
}

class _RequestDemoPreviewPageState extends State<RequestDemoPreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isEnglish = true;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestDemoCmsCubit, RequestDemoCmsState>(
      listener: (context, state) {
        if (state is RequestDemoCmsSaved) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request Demo saved!'),
              backgroundColor: _C.primary,
            ),
          );
          Get.forceAppUpdate();
          html.window.location.reload();
        }
        if (state is RequestDemoCmsError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (ctx, state) {
        RequestDemoPageModel? m;
        if (state is RequestDemoCmsLoaded) m = state.data;
        if (state is RequestDemoCmsSaved) m = state.data;
        m ??= ctx.read<RequestDemoCmsCubit>().current;
        final cubit = ctx.read<RequestDemoCmsCubit>();

        if (state is RequestDemoCmsInitial || state is RequestDemoCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Scaffold(
          backgroundColor: _C.back,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: 1000.w,
                    child: Column(
                      children: [
                        AppAdminNavbar(
                          activeLabel: 'Web Page',
                          homePage: HomeMainPage(),
                          webPage: HomeMainPage(),
                          jobListingPage: HomeMainPage(),
                        ),
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 7),
                        SizedBox(height: 20.h),

                        Row(
                          children: [
                            Text(
                              'Preview Request Demo Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── Device tabs + Language toggle ────────────────
                        Row(
                          children: [
                            _buildDeviceTab('Desktop', _PreviewDevice.desktop),
                            SizedBox(width: 24.w),
                            _buildDeviceTab('Tablet', _PreviewDevice.tablet),
                            SizedBox(width: 24.w),
                            _buildDeviceTab('Mobile', _PreviewDevice.mobile),
                            const Spacer(),
                            _buildLanguageToggle(),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── Preview area ─────────────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: LayoutBuilder(
                            builder: (ctx, box) => _buildFrame(box.maxWidth, m!),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // ── Back + Save ──────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: _C.hintText,
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
                                onTap: _isSaving
                                    ? null
                                    : () {
                                  showPublishConfirmDialog(
                                    context: context,
                                    title: 'PUBLISHING REQUEST DEMO',
                                    subtitle:
                                    'Do you want to publish this Request Demo page?',
                                    onConfirm: () async {
                                      setState(() => _isSaving = true);
                                      await cubit.save(
                                        publishStatus: 'published',
                                      );
                                    },
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: _isSaving
                                        ? _C.primary.withOpacity(0.5)
                                        : _C.primary,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Center(
                                    child: _isSaving
                                        ? SizedBox(
                                      width: 18.w,
                                      height: 18.h,
                                      child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2),
                                    )
                                        : Text('Save',
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
              if (_isSaving)
                Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(
                      child: CircularProgressIndicator(color: _C.primary)),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Device Tab Widget ──────────────────────────────────────────────────────
  Widget _buildDeviceTab(String label, _PreviewDevice device) {
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

  // ── Language Toggle ────────────────────────────────────────────────────────
  Widget _buildLanguageToggle() {
    return Container(
      width: 95.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          _buildLangOption('ENG', 0),
          _buildLangOption('AR', 1),
        ],
      ),
    );
  }

  Widget _buildLangOption(String text, int index) {
    final isSelected = (index == 0 && _isEnglish) || (index == 1 && !_isEnglish);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isEnglish = index == 0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? _C.primary : Colors.white,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _C.labelText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Frame dispatcher ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, RequestDemoPageModel model) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
          containerWidth: containerW,
          model: model,
          isEnglish: _isEnglish,
        );
      case _PreviewDevice.tablet:
        return _TabletFrame(
          containerWidth: containerW,
          model: model,
          isEnglish: _isEnglish,
        );
      case _PreviewDevice.mobile:
        return _MobileFrame(
          containerWidth: containerW,
          model: model,
          isEnglish: _isEnglish,
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final RequestDemoPageModel model;
  final bool isEnglish;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final scale = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(
        color: _C.back,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width: containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _PreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        model: model,
                        isEnglish: isEnglish,
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
// TABLET FRAME (768 × 1024)
// ═════════════════════════════════════════════════════════════════════════════
class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final RequestDemoPageModel model;
  final bool isEnglish;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Center(
      child: Container(
        width: displayW + 4,
        height: displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _C.border, width: 2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const _BrowserChrome(compact: true),
            SizedBox(
              width: displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kTabletW,
                  maxHeight: _kTabletH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth: _kTabletW,
                      fakeHeight: _kTabletH,
                      model: model,
                      isEnglish: isEnglish,
                      isTablet: true,
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
// MOBILE FRAME (375 × 812)
// ═════════════════════════════════════════════════════════════════════════════
class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final RequestDemoPageModel model;
  final bool isEnglish;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    final double shellH = displayH + 24 + 12 + 4;
    final double shellW = displayW + 4;

    return Center(
      child: Container(
        width: shellW,
        height: shellH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Notch ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ),
            // ── Content ────────────────────────────────────────────
            SizedBox(
              width: displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kMobileW,
                  maxHeight: _kMobileH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth: _kMobileW,
                      fakeHeight: _kMobileH,
                      model: model,
                      isEnglish: isEnglish,
                      isMobile: true,
                    ),
                  ),
                ),
              ),
            ),
            // ── Home indicator ─────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(2.r),
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
// PREVIEW CONTENT (renders confirm message with SVG, title, description)
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final RequestDemoPageModel model;
  final bool isEnglish;
  final bool isMobile;
  final bool isTablet;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTabletOrMobile = isMobile || isTablet;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final verticalPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

    final title = isEnglish ? model.confirmTitle.en : model.confirmTitle.ar;
    final desc =
    isEnglish ? model.confirmDescription.en : model.confirmDescription.ar;
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final svgUrl = model.confirmSvgUrl;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          width: fakeWidth,
          height: fakeHeight,
          color: _C.back,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 500.w,
                  ),
                  padding: EdgeInsets.all(isMobile ? 20.r : 32.r),
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── SVG Image ────────────────────────────────────────
                      if (svgUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: SvgPicture.network(
                            svgUrl,
                            height: isMobile ? 120.h : 160.h,
                            width: isMobile ? 120.w : 160.w,
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) => SizedBox(
                              height: isMobile ? 120.h : 160.h,
                              width: isMobile ? 120.w : 160.w,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: _C.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorBuilder: (_, __, ___) => Container(
                              height: isMobile ? 120.h : 160.h,
                              width: isMobile ? 120.w : 160.w,
                              decoration: BoxDecoration(
                                color: _C.sectionBg,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                size: isMobile ? 40.sp : 60.sp,
                                color: _C.hintText,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: isMobile ? 120.h : 160.h,
                          width: isMobile ? 120.w : 160.w,
                          decoration: BoxDecoration(
                            color: _C.sectionBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: isMobile ? 40.sp : 60.sp,
                            color: _C.hintText,
                          ),
                        ),

                      SizedBox(height: isMobile ? 20.h : 24.h),

                      // ── Title ────────────────────────────────────────────
                      Text(
                        title.isNotEmpty
                            ? title
                            : 'Waiting till Customer Services Call You',
                        textDirection: dir,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 16.sp : 18.sp,
                          fontWeight: FontWeight.w700,
                          color: _C.primary,
                        ),
                      ),

                      SizedBox(height: isMobile ? 12.h : 16.h),

                      // ── Description ──────────────────────────────────────
                      Text(
                        desc.isNotEmpty
                            ? desc
                            : 'Your demo request has been successfully submitted, thank you! We\'ll be in touch soon to confirm the details.',
                        textDirection: dir,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13.sp : 14.sp,
                          fontWeight: FontWeight.w400,
                          color: _C.labelText,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
      height: h,
      color: const Color(0xFFF5F5F5),
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
                color: const Color(0xFFE9E9E9),
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
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

