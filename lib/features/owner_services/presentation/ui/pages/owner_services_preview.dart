/// ******************* FILE INFO *******************
/// File Name: owner_services_preview.dart
/// Description: Preview page for Owner Services CMS.
///              Toggles: Desktop / Tablet / Mobile, EN / AR.
///              Renders proper device frames (Desktop browser chrome,
///              Tablet frame, Mobile phone shell with notch).
///              Sections: Header (SVG + title + desc),
///              Download (store badges), Mockups (left/right/centered).
///              Buttons: Back / Save (with confirm dialog).
/// Created by: Amr Mesbah
/// Last Update: 10/05/2026
/// UPDATED: Full device frame rendering matching overview_preview_page pattern

import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segment_tab.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/owner_services_model.dart';
import '../../controller/owner_services_cubit.dart';
import '../../controller/owner_services_state.dart';

part '../widgets/owner_services_preview/c.dart';
part '../widgets/owner_services_preview/desktop_frame.dart';
part '../widgets/owner_services_preview/tablet_frame.dart';
part '../widgets/owner_services_preview/mobile_frame.dart';
part '../widgets/owner_services_preview/preview_content.dart';
part '../widgets/owner_services_preview/browser_chrome.dart';

// ── Colors ────────────────────────────────────────────────────────────────────

class OwnerServicesPreviewPage extends StatefulWidget {
  const OwnerServicesPreviewPage({super.key});

  @override
  State<OwnerServicesPreviewPage> createState() =>
      _OwnerServicesPreviewPageState();
}

class _OwnerServicesPreviewPageState extends State<OwnerServicesPreviewPage> {
  _PreviewDevice _device    = _PreviewDevice.desktop;
  bool           _isEnglish = true;

  // ── Accordion ─────────────────────────────────────────────────────────────
  final Map<String, bool> _open = {'view': true};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      builder: (context, state) {
        final cubit = context.read<OwnerServicesCmsCubit>();
        final data  = cubit.current;

        if (state is OwnerServicesCmsInitial || state is OwnerServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1000.w,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
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
                        AdminSubNavBar(activeIndex: 4),
                        SizedBox(height: 20.h),

                        Text(
                          'Preview Owner Services Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            color: ColorPick.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Device tabs + EN/AR toggle ──────────────────────
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
                                onTabSelected: (i) =>
                                    setState(() => _isEnglish = i == 0),
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

                        // ── View accordion ──────────────────────────────────
                        _accordionWrap('view', 'View', [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: LayoutBuilder(
                              builder: (ctx, box) =>
                                  _buildFrame(box.maxWidth, data),
                            ),
                          ),
                        ]),
                        SizedBox(height: 24.h),

                        // ── Action buttons ──────────────────────────────────
                        _actionRow(cubit),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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

  // ── Accordion wrapper ──────────────────────────────────────────────────────
  Widget _accordionWrap(String key, String title, List<Widget> children) {
    final isOpen = _open[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                topLeft: Radius.circular(6.r),
                topRight: Radius.circular(6.r),
              )
                  : BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
      ],
    );
  }

  // ── Frame dispatcher ───────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, OwnerServicesPageModel data) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _DesktopFrame(
            containerWidth: containerW,
            model: data,
          ),
        );
      case _PreviewDevice.tablet:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _TabletFrame(
            containerWidth: containerW,
            model: data,
          ),
        );
      case _PreviewDevice.mobile:
        return Localizations.override(
          context: context,
          locale: _isEnglish ? const Locale('en') : const Locale('ar'),
          child: _MobileFrame(
            containerWidth: containerW,
            model: data,
          ),
        );
    }
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionRow(OwnerServicesCmsCubit cubit) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.discard,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Back',
                style: StyleText.fontSize14Weight600
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 300.w),
      Expanded(
        child: GestureDetector(
          onTap: () => showPublishConfirmDialog(
            context: context,
            onConfirm: () async {
              await cubit.save(publishStatus: 'published');
              Get.forceAppUpdate();
              html.window.location.reload();
            },
          ),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Save',
                style: StyleText.fontSize14Weight600
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════