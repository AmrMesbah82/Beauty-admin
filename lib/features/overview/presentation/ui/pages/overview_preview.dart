/// ******************* FILE INFO *******************
/// File Name: overview_preview.dart
/// Description: Preview page for Master CMS (Overview-style).
///              Renders: Overview text, Top Services row,
///              Gallery grid, Client Comments cards,
///              Download section with store badges.
///              Desktop / Tablet / Mobile frames, EN / AR toggle.
///              Back + Publish buttons at bottom.
/// Updated: 14/05/2026
///   - Updated to match overview_page.dart UI exactly
///   - Uses proper SVG/image loading via HtmlElementView
///   - Applies mainWidgetColor background to sections
///   - Matches spacing, colors, and layout from user-facing page
///   - Maintains device frame rendering (Desktop/Tablet/Mobile)
///   - EN/AR toggle functionality preserved
/// Created by: Amr Mesbah

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/core/widgets/circle_progress.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segment_tab.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../data/models/overview_model.dart';
import '../../controller/overview_cubit.dart';
import '../../controller/overview_state.dart';

part '../widgets/overview_preview/c.dart';
part '../widgets/overview_preview/desktop_frame.dart';
part '../widgets/overview_preview/tablet_frame.dart';
part '../widgets/overview_preview/mobile_frame.dart';
part '../widgets/overview_preview/preview_content.dart';
part '../widgets/overview_preview/browser_chrome.dart';

class OverviewPreviewPage extends StatefulWidget {
  /// The draft model built from the edit-page form (unsaved data).
  /// When null the page falls back to cubit.current (saved data).
  final OverviewPageModel? previewModel;

  /// Called when the user confirms Publish from this preview page.
  /// Should be the edit-page's _save() so the full write-to-cubit
  /// + upload logic runs before persisting.
  final Future<void> Function()? onPublish;

  const OverviewPreviewPage({
    super.key,
    this.previewModel,
    this.onPublish,
  });

  @override
  State<OverviewPreviewPage> createState() => _OverviewPreviewPageState();
}

class _OverviewPreviewPageState extends State<OverviewPreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isEnglish        = true;
  bool _isPublishing     = false;

  late OverviewPageModel _effectiveModel;

  @override
  void initState() {
    super.initState();
    _effectiveModel = widget.previewModel ??
        context.read<OverviewCmsCubit>().current;
  }

  Future<void> _publish(OverviewCmsCubit cubit) async {
    setState(() => _isPublishing = true);
    try {
      if (widget.onPublish != null) {
        await widget.onPublish!();
      } else {
        await cubit.save(publishStatus: 'published');
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewCmsCubit, OverviewCmsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<OverviewCmsCubit>();

        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Stack(
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
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 2),
                        SizedBox(height: 16.h),

                        Text(
                          'Preview Overview Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            color: ColorPick.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Device tabs + Language toggle ────────────────
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
                                onTabSelected: (index) =>
                                    setState(() => _isEnglish = index == 0),
                                selectedColor: ColorPick.primary,
                                unselectedColor: Colors.white,
                                selectedTextColor: Colors.white,
                                unselectedTextColor: AppColors.text,
                                equalWidth: false,
                                containerPadding: EdgeInsets.symmetric(
                                    horizontal: 8.sp, vertical: 4.sp),
                              ),
                            ),
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

                        // ── Back + Publish ───────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF797979),
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
                                onTap: _isPublishing
                                    ? null
                                    : () => showPublishConfirmDialog(
                                  title: 'PUBLISHING OVERVIEW',
                                  subtitle: 'Do you want to publish this OVERVIEW?',
                                  context: context,
                                  onConfirm: () => _publish(cubit),
                                ),
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
            if (_isPublishing)
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                    child: CircularProgressIndicator(color: ColorPick.primary)),
              ),
          ],
        );
      },
    );
  }

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

  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _DesktopFrame(
            containerWidth: containerW,
            model: _effectiveModel,
          ),
        );
      case _PreviewDevice.tablet:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _TabletFrame(
            containerWidth: containerW,
            model: _effectiveModel,
          ),
        );
      case _PreviewDevice.mobile:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _MobileFrame(
            containerWidth: containerW,
            model: _effectiveModel,
          ),
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════