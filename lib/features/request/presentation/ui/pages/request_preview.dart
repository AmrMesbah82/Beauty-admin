/// File Name: request_preview.dart
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

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/model/request_model.dart';
import '../../controller/request_cubit.dart';
import '../../controller/request_state.dart';

part '../widget/request_preview/c.dart';
part '../widget/request_preview/desktop_frame.dart';
part '../widget/request_preview/tablet_frame.dart';
part '../widget/request_preview/mobile_frame.dart';
part '../widget/request_preview/preview_content.dart';
part '../widget/request_preview/browser_chrome.dart';

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
              backgroundColor: ColorPick.primary,
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
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Scaffold(
          backgroundColor: ColorPick.background,
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
                                    color: AppColors.secondaryText,
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
