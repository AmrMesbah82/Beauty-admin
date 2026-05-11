/// ******************* FILE INFO *******************
/// File Name: master_preview_page.dart
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

import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/master/master_cubit.dart';
import '../../controller/master/master_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../core/custom_svg.dart';
import '../../model/master/master_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

// ── Color palette ─────────────────────────────────────────────────────────────
class _C {
  static const Color primary    = Color(0xFFD16F9A);
  static const Color back       = Color(0xFFF1F2ED);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color sectionBg  = Color(0xFFF5F5F5);
  static const Color aboutBg    = Color(0xFFFFF0F5);
  static const Color downloadBg = Color(0xFFFCE4EC);
}

// ── Device enum ───────────────────────────────────────────────────────────────
enum _PreviewDevice { desktop, tablet, mobile }

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ─────────────────────────────────────────────────────────────────────────────
// MasterPreviewPage
// ─────────────────────────────────────────────────────────────────────────────
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
  _PreviewDevice _device      = _PreviewDevice.desktop;
  bool           _isEnglish   = true;
  bool           _homeViewOpen = true;
  bool           _isSaving    = false;

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
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.back,
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
                              color: _C.primary,
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
                                  selectedColor: _C.primary,
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
                                    duration:
                                    const Duration(milliseconds: 200),
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _isSaving
                                          ? _C.primary.withOpacity(0.5)
                                          : _C.primary,
                                      borderRadius:
                                      BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? SizedBox(
                                        width: 18.w,
                                        height: 18.h,
                                        child:
                                        const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                          : Text('Publish',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
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
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                    child: CircularProgressIndicator(color: _C.primary)),
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
                fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _C.primary : _C.hintText,
              ),
            ),
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

  // ── Frame dispatcher ───────────────────────────────────────────────────────
  Widget _buildFrame(double containerW, MasterPageModel? model) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW, model: model, isEnglish: _isEnglish,
            homeViewOpen: _homeViewOpen,
            onToggleHome: () => setState(() => _homeViewOpen = !_homeViewOpen));
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW, model: model, isEnglish: _isEnglish,
            homeViewOpen: _homeViewOpen,
            onToggleHome: () => setState(() => _homeViewOpen = !_homeViewOpen));
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW, model: model, isEnglish: _isEnglish,
            homeViewOpen: _homeViewOpen,
            onToggleHome: () => setState(() => _homeViewOpen = !_homeViewOpen));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop frame  (1366 × 768)
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopFrame extends StatelessWidget {
  final double          containerWidth;
  final MasterPageModel? model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return SizedBox(
      width: containerWidth,
      height: frameH + 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
                      height: _kDesktopH,
                      child: _PreviewContent(
                        fakeWidth:    _kDesktopW,
                        fakeHeight:   _kDesktopH,
                        model:        model,
                        isEnglish:    isEnglish,
                        homeViewOpen: homeViewOpen,
                        onToggleHome: onToggleHome,
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

// ─────────────────────────────────────────────────────────────────────────────
// Tablet frame  (768 × 1024 — centered, aspect-ratio preserved)
// ─────────────────────────────────────────────────────────────────────────────
class _TabletFrame extends StatelessWidget {
  final double          containerWidth;
  final MasterPageModel? model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Center(
      child: Container(
        width: displayW + 4,
        height: displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4)),
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
                    child: SizedBox(
                      width: _kTabletW,
                      height: _kTabletH,
                      child: _PreviewContent(
                        fakeWidth:    _kTabletW,
                        fakeHeight:   _kTabletH,
                        model:        model,
                        isEnglish:    isEnglish,
                        homeViewOpen: homeViewOpen,
                        onToggleHome: onToggleHome,
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

// ─────────────────────────────────────────────────────────────────────────────
// Mobile frame  (375 × 812 — phone shell with notch)
// ─────────────────────────────────────────────────────────────────────────────
class _MobileFrame extends StatelessWidget {
  final double          containerWidth;
  final MasterPageModel? model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    final double shellH = displayH + 24 + 12 + 4;
    final double shellW = displayW + 4;

    return Center(
      child: Container(
        width: shellW,
        height: shellH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Notch ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────
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
                    child: SizedBox(
                      width: _kMobileW,
                      height: _kMobileH,
                      child: _PreviewContent(
                        fakeWidth:    _kMobileW,
                        fakeHeight:   _kMobileH,
                        model:        model,
                        isEnglish:    isEnglish,
                        homeViewOpen: homeViewOpen,
                        onToggleHome: onToggleHome,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Home indicator ─────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(2),
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

// ─────────────────────────────────────────────────────────────────────────────
// Preview content — the actual page content rendered inside the frame
// ─────────────────────────────────────────────────────────────────────────────
class _PreviewContent extends StatelessWidget {
  final double          fakeWidth;
  final double          fakeHeight;
  final MasterPageModel? model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: SizedBox(
        width: fakeWidth,
        height: fakeHeight,
        child: ColoredBox(
          color: _C.back,
          child: model == null
              ? Center(
            child: Text(
              'No data available',
              style: TextStyle(
                  fontSize: 14, color: _C.hintText),
            ),
          )
              : SingleChildScrollView(
            child: _HomeViewAccordion(
              model:        model!,
              isEnglish:    isEnglish,
              homeViewOpen: homeViewOpen,
              onToggleHome: onToggleHome,
              frameWidth:   fakeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home View accordion — pulled out so _PreviewContent stays lean
// ─────────────────────────────────────────────────────────────────────────────
class _HomeViewAccordion extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;
  final double          frameWidth;

  const _HomeViewAccordion({
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
    required this.frameWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric( vertical: 16),
      child: Column(
        children: [
          // ── Accordion header ──────────────────────────────────────────
          GestureDetector(
            onTap: onToggleHome,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Expanded(
                  child: Text('Home View',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                AnimatedRotation(
                  turns: homeViewOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomSvg(
                    assetPath: 'assets/arrowdown.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                    color: Colors.white,
                  ),
                ),
              ]),
            ),
          ),

          // ── Accordion body ────────────────────────────────────────────
          if (homeViewOpen)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewHeaderSection(model: model, isEnglish: isEnglish),
                  _PreviewAboutUsSection(model: model, isEnglish: isEnglish),
                  _PreviewFooterSection(model: model, isEnglish: isEnglish),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widgets (stateless, pass model + isEnglish)
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewHeaderSection extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;

  const _PreviewHeaderSection({required this.model, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final header     = model.sectionByKey('header');
    final isVisible  = header?.visibility ?? true;
    if (!isVisible) return const SizedBox.shrink();

    final titleText = isEnglish
        ? (header?.title.en.isNotEmpty == true
        ? header!.title.en
        : (model.title.en.isNotEmpty ? model.title.en : 'Beauty App'))
        : (header?.title.ar.isNotEmpty == true
        ? header!.title.ar
        : (model.title.ar.isNotEmpty ? model.title.ar : 'تطبيق بيوتي'));

    final shortDescText = isEnglish
        ? (header?.shortDescription.en.isNotEmpty == true
        ? header!.shortDescription.en
        : (model.shortDescription.en.isNotEmpty
        ? model.shortDescription.en
        : 'Style & Simple Bright'))
        : (header?.shortDescription.ar.isNotEmpty == true
        ? header!.shortDescription.ar
        : (model.shortDescription.ar.isNotEmpty
        ? model.shortDescription.ar
        : 'أناقة وبساطة مشرقة'));

    final imageUrl = header?.imageUrl ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _previewImageBox(imageUrl, 200, 200),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _C.labelText),
                ),
                const SizedBox(height: 8),
                Text(
                  shortDescText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _C.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewAboutUsSection extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;

  const _PreviewAboutUsSection({required this.model, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final about     = model.sectionByKey('aboutUs');
    final isVisible = about?.visibility ?? true;
    if (!isVisible) return const SizedBox.shrink();

    final titleText = isEnglish
        ? (about?.title.en.isNotEmpty == true ? about!.title.en : 'About Us')
        : (about?.title.ar.isNotEmpty == true
        ? about!.title.ar
        : 'معلومات عنا');

    final descText = isEnglish
        ? (about?.description.en.isNotEmpty == true
        ? about!.description.en
        : 'Welcome to Beauty App, where beauty meets tranquility.')
        : (about?.description.ar.isNotEmpty == true
        ? about!.description.ar
        : 'مرحباً بكم في تطبيق بيوتي، حيث يلتقي الجمال بالهدوء.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment:
        isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            titleText,
            textDirection:
            isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD16F9A)),
          ),
          const SizedBox(height: 12),
          Text(
            descText,
            textDirection:
            isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400,
                color: _C.labelText, height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: isEnglish
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                isEnglish ? 'Read More' : 'اقرأ المزيد',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.primary),
              ),
              const SizedBox(width: 4),
              Icon(
                isEnglish
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: _C.primary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewFooterSection extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;

  const _PreviewFooterSection({required this.model, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final footer    = model.sectionByKey('footer');
    final isVisible = footer?.visibility ?? true;
    if (!isVisible) return const SizedBox.shrink();

    final titleText = isEnglish
        ? (footer?.title.en.isNotEmpty == true
        ? footer!.title.en
        : 'Download Beauty App Now')
        : (footer?.title.ar.isNotEmpty == true
        ? footer!.title.ar
        : 'حمل تطبيق بيوتي الآن');

    final descText = isEnglish
        ? (footer?.description.en.isNotEmpty == true
        ? footer!.description.en
        : 'At Beauty, you will find luxury services.')
        : (footer?.description.ar.isNotEmpty == true
        ? footer!.description.ar
        : 'ستجد لدينا أفضل الخدمات الفاخرة.');

    final imageUrl = footer?.imageUrl ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _previewImageBox(imageUrl, 200, 220,
              fallbackIcon: Icons.phone_iphone,
              fallbackBg: _C.downloadBg),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _C.labelText),
                ),
                const SizedBox(height: 10),
                Text(
                  descText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400,
                      color: _C.labelText, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Define button dimensions based on screen width
                        double buttonWidth;
                        double buttonHeight;
                        double spacing;

                        if (constraints.maxWidth >= 1024) {
                          // Desktop
                          buttonWidth = 200;
                          buttonHeight = 60;
                          spacing = 16;
                        } else if (constraints.maxWidth >= 600) {
                          // Tablet
                          buttonWidth = 180;
                          buttonHeight = 55;
                          spacing = 12;
                        } else {
                          // Mobile
                          buttonWidth = 150;
                          buttonHeight = 50;
                          spacing = 10;
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSvg(
                              assetPath: "assets/google play.svg",
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                            SizedBox(width: spacing),
                            CustomSvg(
                              assetPath: "assets/app_store.svg",
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers (top-level functions — accessible by all section widgets)
// ─────────────────────────────────────────────────────────────────────────────

Widget _previewImageBox(
    String imageUrl,
    double width,
    double height, {
      IconData fallbackIcon = Icons.image,
      Color    fallbackBg   = _C.sectionBg,
    }) {
  if (imageUrl.isNotEmpty) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.network(
        imageUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const CircleProgressMaster(),
      ),
    );
  }
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: fallbackBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Icon(fallbackIcon, size: 48, color: _C.hintText),
    ),
  );
}

Widget _storeBadge({required String label, required IconData icon}) {
  return Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.contains('جوجل') || label.contains('آب')
                  ? 'تحميل من'
                  : 'GET IT ON',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w400),
            ),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Browser chrome bar (dots + URL bar)
// ─────────────────────────────────────────────────────────────────────────────
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