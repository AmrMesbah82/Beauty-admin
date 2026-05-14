// ******************* FILE INFO *******************
// File Name: strategy_preview_page.dart
// Screen 3 of 3 — Our Strategy CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)
// UPDATED: Complete redesign following Client Services preview pattern
//   - Full browser chrome frames for Desktop/Tablet/Mobile
//   - Proper device viewport scaling (1366×768, 768×1024, 375×812)
//   - EN/AR language toggle
//   - Preserved Strategic House sections with multi-device image support
//   - Professional frame rendering with shadow and borders
// Created by: Amr Mesbah
// Last Update: 14/05/2026

import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_admin_navbar.dart';

import '../../../model/about_us/about_us.dart';
import '../../main_page/home_main_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color grey      = Color(0xFF9E9E9E);
  static const Color hintText  = Color(0xFF797979);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
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

class StrategyPreviewPage extends StatefulWidget {
  final OurStrategyModel model;
  final Map<String, Uint8List> imageUploads;

  const StrategyPreviewPage({
    super.key,
    required this.model,
    this.imageUploads = const {},
  });

  @override
  State<StrategyPreviewPage> createState() => _StrategyPreviewPageState();
}

class _StrategyPreviewPageState extends State<StrategyPreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isEnglish = true;
  bool _isSaving = false;

  bool _strategicHouseEnOpen = true;
  bool _strategicHouseArOpen = true;

  // In-memory bytes for new uploads (per device)
  Uint8List? get _strategicHouseEnDesktopBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/en/desktop'];
  Uint8List? get _strategicHouseEnTabletBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/en/tablet'];
  Uint8List? get _strategicHouseEnMobileBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/en/mobile'];

  Uint8List? get _strategicHouseArDesktopBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/ar/desktop'];
  Uint8List? get _strategicHouseArTabletBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/ar/tablet'];
  Uint8List? get _strategicHouseArMobileBytes =>
      widget.imageUploads['strategy_cms/strategicHouse/ar/mobile'];

  // Get the appropriate bytes for current preview mode (EN)
  Uint8List? _getEnBytesForMode() {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _strategicHouseEnDesktopBytes;
      case _PreviewDevice.tablet:
        return _strategicHouseEnTabletBytes;
      case _PreviewDevice.mobile:
        return _strategicHouseEnMobileBytes;
    }
  }

  // Get the appropriate URL for current preview mode (EN)
  String _getEnUrlForMode() {
    switch (_device) {
      case _PreviewDevice.desktop:
        return widget.model.strategicHouseEnDesktopUrl;
      case _PreviewDevice.tablet:
        return widget.model.strategicHouseEnTabletUrl;
      case _PreviewDevice.mobile:
        return widget.model.strategicHouseEnMobileUrl;
    }
  }

  // Get the appropriate bytes for current preview mode (AR)
  Uint8List? _getArBytesForMode() {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _strategicHouseArDesktopBytes;
      case _PreviewDevice.tablet:
        return _strategicHouseArTabletBytes;
      case _PreviewDevice.mobile:
        return _strategicHouseArMobileBytes;
    }
  }

  // Get the appropriate URL for current preview mode (AR)
  String _getArUrlForMode() {
    switch (_device) {
      case _PreviewDevice.desktop:
        return widget.model.strategicHouseArDesktopUrl;
      case _PreviewDevice.tablet:
        return widget.model.strategicHouseArTabletUrl;
      case _PreviewDevice.mobile:
        return widget.model.strategicHouseArMobileUrl;
    }
  }

  // Check if EN has image for current mode
  bool _hasEnImageForMode() {
    final bytes = _getEnBytesForMode();
    final url = _getEnUrlForMode();
    return (bytes != null && bytes.isNotEmpty) || url.isNotEmpty;
  }

  // Check if AR has image for current mode
  bool _hasArImageForMode() {
    final bytes = _getArBytesForMode();
    final url = _getArUrlForMode();
    return (bytes != null && bytes.isNotEmpty) || url.isNotEmpty;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _onSave() async {
    final ok = await _confirm(context);
    if (ok == true && mounted) {
      setState(() => _isSaving = true);
      context.read<StrategyCubit>().save(
        model: widget.model,
        imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.back,
      body: BlocListener<StrategyCubit, StrategyState>(
        listener: (context, state) {
          if (state is StrategySaved) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Our Strategy saved!')),
            );
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is StrategyError) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
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
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Text(
                            'Preview Our Strategy Details',
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
                          builder: (ctx, box) => _buildFrame(box.maxWidth),
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
                              onTap: _isSaving ? null : _onSave,
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
      ),
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
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
          containerWidth: containerW,
          model: widget.model,
          isEnglish: _isEnglish,
          enBytes: _getEnBytesForMode(),
          enUrl: _getEnUrlForMode(),
          arBytes: _getArBytesForMode(),
          arUrl: _getArUrlForMode(),
          hasEnImage: _hasEnImageForMode(),
          hasArImage: _hasArImageForMode(),
        );
      case _PreviewDevice.tablet:
        return _TabletFrame(
          containerWidth: containerW,
          model: widget.model,
          isEnglish: _isEnglish,
          enBytes: _getEnBytesForMode(),
          enUrl: _getEnUrlForMode(),
          arBytes: _getArBytesForMode(),
          arUrl: _getArUrlForMode(),
          hasEnImage: _hasEnImageForMode(),
          hasArImage: _hasArImageForMode(),
        );
      case _PreviewDevice.mobile:
        return _MobileFrame(
          containerWidth: containerW,
          model: widget.model,
          isEnglish: _isEnglish,
          enBytes: _getEnBytesForMode(),
          enUrl: _getEnUrlForMode(),
          arBytes: _getArBytesForMode(),
          arUrl: _getArUrlForMode(),
          hasEnImage: _hasEnImageForMode(),
          hasArImage: _hasArImageForMode(),
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final OurStrategyModel model;
  final bool isEnglish;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
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
                        enBytes: enBytes,
                        enUrl: enUrl,
                        arBytes: arBytes,
                        arUrl: arUrl,
                        hasEnImage: hasEnImage,
                        hasArImage: hasArImage,
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
  final OurStrategyModel model;
  final bool isEnglish;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
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
                      enBytes: enBytes,
                      enUrl: enUrl,
                      arBytes: arBytes,
                      arUrl: arUrl,
                      hasEnImage: hasEnImage,
                      hasArImage: hasArImage,
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
  final OurStrategyModel model;
  final bool isEnglish;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
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
                      enBytes: enBytes,
                      enUrl: enUrl,
                      arBytes: arBytes,
                      arUrl: arUrl,
                      hasEnImage: hasEnImage,
                      hasArImage: hasArImage,
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
// PREVIEW CONTENT (renders Strategic House sections)
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final OurStrategyModel model;
  final bool isEnglish;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;
  final bool isMobile;
  final bool isTablet;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTabletOrMobile = isMobile || isTablet;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final verticalPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strategic House Section
                  _buildStrategicHouseSection(),
                  SizedBox(height: isMobile ? 24.h : 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Strategic House Section ────────────────────────────────────────────────
  Widget _buildStrategicHouseSection() {
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final title = isEnglish ? 'Strategic House' : 'البيت الاستراتيجي';
    final hasImage = isEnglish ? hasEnImage : hasArImage;
    final bytes = isEnglish ? enBytes : arBytes;
    final url = isEnglish ? enUrl : arUrl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.w : 20.w,
              vertical: isMobile ? 12.h : 16.h,
            ),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(8.r)
              ),
            child: Text(
              title,
              textDirection: dir,
              style: TextStyle(
                fontSize: isMobile ? 16.sp : 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Image
          Padding(
            padding: EdgeInsets.all(isMobile ? 12.r : 20.r),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _buildImage(
                  bytes: bytes,
                  url: url,
                  hasImage: hasImage,
                  height: isMobile ? 180 : (isTablet ? 240 : 300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Widget ────────────────────────────────────────────────────────────
  Widget _buildImage({
    required Uint8List? bytes,
    required String url,
    required bool hasImage,
    required double height,
  }) {
    if (!hasImage) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _C.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined,
                  color: Colors.grey[400], size: isMobile ? 40.sp : 48.sp),
              SizedBox(height: 8.h),
              Text(
                'No image uploaded',
                style: TextStyle(
                  fontSize: isMobile ? 11.sp : 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle uploaded bytes (new upload)
    if (bytes != null && bytes.isNotEmpty) {
      final isSvg = _isSvgBytes(bytes);
      if (isSvg) {
        return SvgPicture.memory(
          bytes,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Center(
            child: CircularProgressIndicator(
              color: _C.primary,
              strokeWidth: 2,
            ),
          ),
        );
      } else {
        return Image.memory(
          bytes,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            height: height,
            color: _C.cardBg,
            child: Icon(Icons.broken_image,
                color: Colors.grey[400], size: 48),
          ),
        );
      }
    }

    // Handle existing URL (from database)
    if (url.isNotEmpty) {
      final isSvg = _isSvgUrl(url);
      if (isSvg) {
        return FutureBuilder<Uint8List>(
          future: _loadSvgBytes(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: height,
                child: Center(
                  child: CircularProgressIndicator(
                    color: _C.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              return SvgPicture.memory(
                snapshot.data!,
                width: double.infinity,
                height: height,
                fit: BoxFit.contain,
              );
            }
            return Container(
              height: height,
              color: _C.cardBg,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        color: Colors.grey[400], size: 48),
                    SizedBox(height: 8.h),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return Image.network(
          url,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: height,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: _C.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: height,
            color: _C.cardBg,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image,
                      color: Colors.grey[400], size: 48),
                  SizedBox(height: 8.h),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  bool _isSvgBytes(Uint8List? bytes) {
    if (bytes == null || bytes.length < 5) return false;
    final header = bytes.sublist(0, bytes.length > 5 ? 5 : bytes.length);
    final headerStr = String.fromCharCodes(header);
    return headerStr.contains('<svg') || headerStr.contains('<?xml');
  }

  bool _isSvgUrl(String url) {
    final decoded = Uri.decodeFull(url).toLowerCase();
    return decoded.contains('.svg') ||
        decoded.contains('/svg?') ||
        decoded.contains('/svg/') ||
        decoded.endsWith('/svg');
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (response.status != 200) {
        throw Exception('Failed to load SVG: ${response.status}');
      }
      return (response.response as ByteBuffer).asUint8List();
    } catch (e) {
      rethrow;
    }
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

// ── Confirm Dialog ────────────────────────────────────────────────────────────
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
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EE),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Icon(Icons.edit_note,
              size: 40.sp, color: const Color(0xFF008037)),
        ),
        SizedBox(height: 16.h),
        Text(
          'EDITING OUR STRATEGY DETAILS',
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight600
              .copyWith(color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: 8.h),
        Text(
          'Do you want to save the changes made to this Our Strategy?',
          textAlign: TextAlign.center,
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryBlack),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Back',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008037),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Confirm',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);