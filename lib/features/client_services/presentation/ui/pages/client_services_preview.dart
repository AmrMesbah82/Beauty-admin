/// ******************* FILE INFO *******************
/// File Name: client_services_preview.dart
/// Description: Preview page for Client Services CMS.
///              Renders: Header hero, Download bar, Mockups with left/right/centered layouts.
///              Desktop / Tablet / Mobile frames + EN / AR toggle.
///              Back + Publish buttons at bottom.
/// UPDATED: Added proper device frame rendering (Desktop/Tablet/Mobile)
///   - Desktop: 1366×768 browser chrome frame
///   - Tablet: 768×1024 browser chrome frame (centered)
///   - Mobile: 375×812 phone shell with notch (centered)
///   - Maintained EN/AR toggle functionality
///   - Preserved mockup layouts (left/right/centered)
/// Created by: Amr Mesbah
/// Last Update: 13/05/2026

import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/core/widget/circle_progress.dart';

import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segmant_tab.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/model/client_services_model.dart';
import '../../controller/client_services_cubit.dart';
import '../../controller/client_services_state.dart';

part '../widget/client_services_preview/c.dart';
part '../widget/client_services_preview/desktop_frame.dart';
part '../widget/client_services_preview/tablet_frame.dart';
part '../widget/client_services_preview/mobile_frame.dart';
part '../widget/client_services_preview/preview_content.dart';
part '../widget/client_services_preview/browser_chrome.dart';

class ClientServicesPreviewPage extends StatefulWidget {
  final ClientServicesPageModel? previewModel;
  final Future<void> Function()? onPublish;

  const ClientServicesPreviewPage({
    super.key,
    this.previewModel,
    this.onPublish,
  });

  @override
  State<ClientServicesPreviewPage> createState() =>
      _ClientServicesPreviewPageState();
}

class _ClientServicesPreviewPageState extends State<ClientServicesPreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isEnglish = true;
  bool _isPublishing = false;
  late ClientServicesPageModel _effectiveModel;

  @override
  void initState() {
    super.initState();
    _effectiveModel = widget.previewModel ??
        context.read<ClientServicesCmsCubit>().current;
  }

  Future<void> _publish(ClientServicesCmsCubit cubit) async {
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
    return BlocConsumer<ClientServicesCmsCubit, ClientServicesCmsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<ClientServicesCmsCubit>();

        if (state is ClientServicesCmsInitial ||
            state is ClientServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
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
                        AdminSubNavBar(activeIndex: 3),
                        SizedBox(height: 20.h),

                        Text(
                          'Preview Client Services Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            color: _C.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Device tabs + Language toggle ────────────────
                        Row(
                          children: [
                            _tab('Desktop', _PreviewDevice.desktop),
                            SizedBox(width: 24.w),
                            _tab('Tablet', _PreviewDevice.tablet),
                            SizedBox(width: 24.w),
                            _tab('Mobile', _PreviewDevice.mobile),
                            const Spacer(),
                            SizedBox(
                              width: 95.w,
                              height: 36.h,
                              child: CustomSegmentedTabs(
                                tabs: const ['ENG', 'AR'],
                                selectedIndex: _isEnglish ? 0 : 1,
                                onTabSelected: (index) =>
                                    setState(() => _isEnglish = index == 0),
                                selectedColor: _C.primary,
                                unselectedColor: Colors.white,
                                selectedTextColor: Colors.white,
                                unselectedTextColor: _C.labelText,
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
                                  title: 'PUBLISHING CLIENT SERVICES',
                                  subtitle:
                                  'Do you want to publish this CLIENT SERVICES page?',
                                  context: context,
                                  onConfirm: () => _publish(cubit),
                                ),
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
                                      width: 18.w,
                                      height: 18.h,
                                      child:
                                      const CircularProgressIndicator(
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
                ),
              ),
            ),
            if (_isPublishing)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                    child: CircularProgressIndicator(color: _C.primary)),
              ),
          ],
        );
      },
    );
  }

  // ── Tab widget ───────────────────────────────────────────────────────────────
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

  // ── Frame dispatcher ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
          containerWidth: containerW,
          model: _effectiveModel,
          isEnglish: _isEnglish,
        );
      case _PreviewDevice.tablet:
        return _TabletFrame(
          containerWidth: containerW,
          model: _effectiveModel,
          isEnglish: _isEnglish,
        );
      case _PreviewDevice.mobile:
        return _MobileFrame(
          containerWidth: containerW,
          model: _effectiveModel,
          isEnglish: _isEnglish,
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
