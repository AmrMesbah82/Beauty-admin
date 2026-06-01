/// ******************* FILE INFO *******************
/// File Name: master_preview.dart
/// Description: Preview page for the Master CMS module.
///              Accepts an optional [previewModel] so unsaved edits from the
///              edit page are reflected immediately without requiring a save.
///              Shows Desktop / Tablet / Mobile device frames with proper
///              viewport scaling (ClipRect + OverflowBox + Transform.scale),
///              EN / AR language toggle, and renders the Home View
///              inside an accordion with all sections.
///              Back + Publish buttons at bottom.
/// Created by: Amr Mesbah
/// Last Update: 09/05/2026

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:beauty_admin/core/widgets/circle_progress.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segment_tab.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/master_model.dart';
import '../../controller/master_cubit.dart';
import '../../controller/master_state.dart';

part '../widgets/master_preview/c.dart';
part '../widgets/master_preview/desktop_frame.dart';
part '../widgets/master_preview/tablet_frame.dart';
part '../widgets/master_preview/mobile_frame.dart';
part '../widgets/master_preview/preview_content.dart';
part '../widgets/master_preview/home_view_accordion.dart';
part '../widgets/master_preview/preview_header_section.dart';
part '../widgets/master_preview/preview_about_us_section.dart';
part '../widgets/master_preview/preview_footer_section.dart';
part '../widgets/master_preview/browser_chrome.dart';

// ── Color palette ─────────────────────────────────────────────────────────────

class MasterPreviewPage extends StatefulWidget {
  /// When provided, this model is used directly so that unsaved edits made
  /// on the edit page are visible in the preview without a save/publish step.
  /// Falls back to BLoC state when null.
  final MasterPageModel? previewModel;

  const MasterPreviewPage({super.key, this.previewModel});

  @override
  State<MasterPreviewPage> createState() => _MasterPreviewPageState();
}

class _MasterPreviewPageState extends State<MasterPreviewPage> {
  _PreviewDevice _device       = _PreviewDevice.desktop;
  bool           _isEnglish    = true;
  bool           _homeViewOpen = true;
  bool           _isSaving     = false;

  final List<String> _languageTabs = ['ENG', 'AR'];

  // ── Resolve the model ─────────────────────────────────────────────────────
  MasterPageModel? _resolveModel(BuildContext context, MasterCmsState state) {
    if (widget.previewModel != null) return widget.previewModel;
    if (state is MasterCmsLoaded) return state.data;
    if (state is MasterCmsSaved) return state.data;
    return context.read<MasterCmsCubit>().current;
  }

  Future<void> _publish(MasterCmsCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      if (widget.previewModel != null) {
        cubit.loadModel(widget.previewModel!);
      }
      await cubit.save(publishStatus: 'published');
      Get.forceAppUpdate();
      html.window.location.reload();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterCmsCubit, MasterCmsState>(
      builder: (context, state) {
        final model     = _resolveModel(context, state);
        final cubit     = context.read<MasterCmsCubit>();
        final isLoading = state is MasterCmsInitial || state is MasterCmsLoading;

        if (isLoading && model == null) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppAdminNavbar(
                      activeLabel: 'Web Page',
                      homePage:       HomeMainPage(),
                      webPage:        HomeMainPage(),
                      jobListingPage: HomeMainPage(),
                    ),
                    SizedBox(height: 20.h),
                    AdminSubNavBar(activeIndex: 1),

                    SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // ── Title ───────────────────────────────────
                          Text(
                            'Preview Home Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ── Device tabs + EN/AR toggle ───────────────
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
                                  containerColor: Colors.white,
                                  tabs: _languageTabs,
                                  selectedIndex: _isEnglish ? 0 : 1,
                                  onTabSelected: (index) =>
                                      setState(() => _isEnglish = index == 0),
                                  selectedColor: ColorPick.primary,
                                  unselectedColor: Colors.white,
                                  textStyle: StyleText.fontSize16Weight500,
                                  selectedTextColor: Colors.white,
                                  unselectedTextColor: AppColors.secondaryText,
                                  containerPadding: EdgeInsets.symmetric(
                                      horizontal: 8.sp, vertical: 4.sp),
                                  equalWidth: false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Device frame ─────────────────────────────
                          LayoutBuilder(
                            builder: (ctx, box) =>
                                _buildFrame(box.maxWidth, model),
                          ),

                          SizedBox(height: 24.h),

                          // ── Back + Publish ────────────────────────────
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
                                  onTap: _isSaving
                                      ? null
                                      : () => showPublishConfirmDialog(
                                    context: context,
                                    onConfirm: () => _publish(cubit),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _isSaving
                                          ? ColorPick.primary.withValues(alpha: 0.5)
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
                  ],
                ),
              ),
            ),

            // ── Full-screen saving overlay ────────────────────────────
            if (_isSaving)
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

  // ── Tab widget ─────────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? ColorPick.primary : AppColors.secondaryText,
              ),
            ),
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
  Widget _buildFrame(double containerW, MasterPageModel? model) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _DesktopFrame(
            containerWidth: containerW,
            model:          model,
            isEnglish:      _isEnglish,
            homeViewOpen:   _homeViewOpen,
            onToggleHome:   () => setState(() => _homeViewOpen = !_homeViewOpen),
          ),
        );
      case _PreviewDevice.tablet:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _TabletFrame(
            containerWidth: containerW,
            model:          model,
            isEnglish:      _isEnglish,
            homeViewOpen:   _homeViewOpen,
            onToggleHome:   () => setState(() => _homeViewOpen = !_homeViewOpen),
          ),
        );
      case _PreviewDevice.mobile:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _MobileFrame(
            containerWidth: containerW,
            model:          model,
            isEnglish:      _isEnglish,
            homeViewOpen:   _homeViewOpen,
            onToggleHome:   () => setState(() => _homeViewOpen = !_homeViewOpen),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop frame  (1366 × 768)
// ─────────────────────────────────────────────────────────────────────────────