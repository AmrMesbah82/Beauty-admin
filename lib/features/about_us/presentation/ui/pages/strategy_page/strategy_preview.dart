// ******************* FILE INFO *******************
// File Name: strategy_preview.dart
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

import '../../../../../../core/constants/color.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../home/presentation/ui/pages/home_main.dart';
import '../../../../data/models/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';

part '../../widgets/strategy_preview/c.dart';
part '../../widgets/strategy_preview/desktop_frame.dart';
part '../../widgets/strategy_preview/tablet_frame.dart';
part '../../widgets/strategy_preview/mobile_frame.dart';
part '../../widgets/strategy_preview/preview_content.dart';
part '../../widgets/strategy_preview/browser_chrome.dart';

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
      backgroundColor: ColorPick.background,
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
                              color: ColorPick.primary,
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
                                      ? ColorPick.primary.withOpacity(0.5)
                                      : ColorPick.primary,
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
                    child: CircularProgressIndicator(color: ColorPick.primary)),
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
                  color: active ? ColorPick.primary : AppColors.secondaryText,
                )),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? ColorPick.primary : Colors.transparent,
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
        border: Border.all(color: ColorPick.white),
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
            color: isSelected ? ColorPick.primary : Colors.white,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Frame dispatcher ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    Widget frame;
    switch (_device) {
      case _PreviewDevice.desktop:
        frame = _DesktopFrame(
          containerWidth: containerW,
          model: widget.model,
          enBytes: _getEnBytesForMode(),
          enUrl: _getEnUrlForMode(),
          arBytes: _getArBytesForMode(),
          arUrl: _getArUrlForMode(),
          hasEnImage: _hasEnImageForMode(),
          hasArImage: _hasArImageForMode(),
        );
      case _PreviewDevice.tablet:
        frame = _TabletFrame(
          containerWidth: containerW,
          model: widget.model,
          enBytes: _getEnBytesForMode(),
          enUrl: _getEnUrlForMode(),
          arBytes: _getArBytesForMode(),
          arUrl: _getArUrlForMode(),
          hasEnImage: _hasEnImageForMode(),
          hasArImage: _hasArImageForMode(),
        );
      case _PreviewDevice.mobile:
        frame = _MobileFrame(
          containerWidth: containerW,
          model: widget.model,
          enBytes: _getEnBytesForMode(),
          enUrl: _getEnUrlForMode(),
          arBytes: _getArBytesForMode(),
          arUrl: _getArUrlForMode(),
          hasEnImage: _hasEnImageForMode(),
          hasArImage: _hasArImageForMode(),
        );
    }
    return Localizations.override(
      context: context,
      locale: _isEnglish ? const Locale('en') : const Locale('ar'),
      child: frame,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
