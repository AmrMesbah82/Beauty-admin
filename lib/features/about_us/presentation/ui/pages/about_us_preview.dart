/// ******************* FILE INFO *******************
/// File Name: about_us_preview.dart
/// Description: Preview page for About Us CMS.
///              Renders: About Us content with Vision/Mission/Values tabs.
///              Desktop / Tablet / Mobile frames + EN / AR toggle.
///              Back + Save buttons at bottom.
/// UPDATED: Added proper device frame rendering (Desktop/Tablet/Mobile)
///   - Desktop: 1366×768 browser chrome frame
///   - Tablet: 768×1024 browser chrome frame (centered)
///   - Mobile: 375×812 phone shell with notch (centered)
///   - Maintained EN/AR toggle functionality
///   - Preserved all about_page.dart UI components
/// Created by: Amr Mesbah
/// Last Update: 13/05/2026

import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../client_services/data/model/client_services_model.dart';
import '../../../data/model/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';

part '../widget/about_us_preview/c.dart';
part '../widget/about_us_preview/desktop_frame.dart';
part '../widget/about_us_preview/tablet_frame.dart';
part '../widget/about_us_preview/mobile_frame.dart';
part '../widget/about_us_preview/preview_content.dart';
part '../widget/about_us_preview/desktop_top_tab_item.dart';
part '../widget/about_us_preview/desktop_tab_item.dart';
part '../widget/about_us_preview/desktop_right_panel.dart';
part '../widget/about_us_preview/tablet_top_tab_item.dart';
part '../widget/about_us_preview/tablet_tab_item.dart';
part '../widget/about_us_preview/tablet_content_panel.dart';
part '../widget/about_us_preview/values_grid_desktop_preview.dart';
part '../widget/about_us_preview/values_grid_tablet_preview.dart';
part '../widget/about_us_preview/mobile_top_tab_item_preview.dart';
part '../widget/about_us_preview/mobile_tab_data_preview.dart';
part '../widget/about_us_preview/mobile_accordion_item_preview.dart';
part '../widget/about_us_preview/values_grid_mobile_preview.dart';
part '../widget/about_us_preview/value_grid_card_preview.dart';
part '../widget/about_us_preview/value_detail_panel_preview.dart';
part '../widget/about_us_preview/browser_chrome.dart';

// ── Shared constants (mirrors about_page.dart) ────────────────────────────────
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);

// ── Preview-page-only colours ─────────────────────────────────────────────────

class AboutPreviewPage extends StatefulWidget {
  final AboutPageModel? previewModel;
  final Future<void> Function()? onPublish;

  const AboutPreviewPage({
    super.key,
    this.previewModel,
    this.onPublish,
  });

  @override
  State<AboutPreviewPage> createState() => _AboutPreviewPageState();
}

class _AboutPreviewPageState extends State<AboutPreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isEnglish = true;
  bool _isPublishing = false;
  late AboutPageModel _effectiveModel;

  @override
  void initState() {
    super.initState();

    // Helper function to get current model from cubit state
    AboutPageModel _getCurrentModel() {
      final state = context.read<AboutCubit>().state;
      if (state is AboutLoaded) {
        return state.data;
      } else if (state is AboutSaved) {
        return state.data;
      }
      // Return empty model if no data
      return AboutPageModel.empty();
    }

    _effectiveModel = widget.previewModel ?? _getCurrentModel();
  }

  bool get _isRtl => !_isEnglish;

  Future<void> _publish(AboutCubit cubit) async {
    setState(() => _isPublishing = true);
    try {
      if (widget.onPublish != null) {
        await widget.onPublish!();
      } else {
        await cubit.save(model: _effectiveModel);
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AboutCubit, AboutState>(
      listener: (context, state) {
        if (state is AboutSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('About Us saved successfully!')),
          );
        }
        if (state is AboutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AboutCubit>();

        if (state is AboutInitial || state is AboutLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.sectionBg,
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 5),
                        SizedBox(height: 16.h),

                        Text(
                          'Preview About Us Details',
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
                            _buildLangToggle(),
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
                                onTap: _isPublishing
                                    ? null
                                    : () => showPublishConfirmDialog(
                                  title: 'SAVING ABOUT US',
                                  subtitle:
                                  'Do you want to save the changes made to this About Us?',
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

  // ── ENG / AR toggle ────────────────────────────────────────────────────────
  Widget _buildLangToggle() {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _kDivider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langToggleItem('ENG', true),
          _langToggleItem('AR', false),
        ],
      ),
    );
  }

  Widget _langToggleItem(String label, bool isEnglish) {
    final selected = (_isEnglish == isEnglish);
    return GestureDetector(
      onTap: () => setState(() => _isEnglish = isEnglish),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        height: 34.h,
        decoration: BoxDecoration(
          color: selected ? _C.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _C.hintText,
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
          model: _effectiveModel,
          isRtl: _isRtl,
        );
      case _PreviewDevice.tablet:
        return _TabletFrame(
          containerWidth: containerW,
          model: _effectiveModel,
          isRtl: _isRtl,
        );
      case _PreviewDevice.mobile:
        return _MobileFrame(
          containerWidth: containerW,
          model: _effectiveModel,
          isRtl: _isRtl,
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME (1366 × 768)
// ═════════════════════════════════════════════════════════════════════════════
