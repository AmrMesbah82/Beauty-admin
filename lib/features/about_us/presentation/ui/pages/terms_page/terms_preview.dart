// ******************* FILE INFO *******************
// File Name: terms_preview.dart
// Screen 3 of 3 — Terms of Service CMS: Preview (Desktop/Tablet/Mobile + ENG/AR)
// Refactored to match overview_preview.dart style:
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

import '../../../../../../core/constants/color.dart';
import '../../../../../../core/custom_dialog.dart';
import '../../../../../../core/custom_segment_tab.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_font_style.dart';

import '../../../../../home/presentation/ui/pages/home_main.dart';
import '../../../../data/models/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';
import 'package:beauty_admin/core/constants/color.dart';

part '../../widgets/terms_preview/c.dart';
part '../../widgets/terms_preview/desktop_frame.dart';
part '../../widgets/terms_preview/tablet_frame.dart';
part '../../widgets/terms_preview/mobile_frame.dart';
part '../../widgets/terms_preview/preview_content.dart';
part '../../widgets/terms_preview/browser_chrome.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

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
            backgroundColor: ColorPick.background,
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
                          color: ColorPick.primary,
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
                              selectedColor:      ColorPick.primary,
                              unselectedColor:    Colors.white,
                              selectedTextColor:  Colors.white,
                              unselectedTextColor: AppColors.secondaryText,
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
                                  color: ColorPick.back,
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
                                      ? ColorPick.primary.withValues(alpha: 0.5)
                                      : ColorPick.primary,
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
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                  child: CircularProgressIndicator(color: ColorPick.primary)),
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

  // ── Frame dispatcher ───────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    Widget frame;
    switch (_device) {
      case _PreviewDevice.desktop:
        frame = _DesktopFrame(
          containerWidth: containerW,
          model:          widget.model,
          termsSvgBytes:  _termsSvgBytes,
          privacySvgBytes: _privacySvgBytes,
        );
      case _PreviewDevice.tablet:
        frame = _TabletFrame(
          containerWidth: containerW,
          model:          widget.model,
          termsSvgBytes:  _termsSvgBytes,
          privacySvgBytes: _privacySvgBytes,
        );
      case _PreviewDevice.mobile:
        frame = _MobileFrame(
          containerWidth: containerW,
          model:          widget.model,
          termsSvgBytes:  _termsSvgBytes,
          privacySvgBytes: _privacySvgBytes,
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
// DESKTOP FRAME  (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
