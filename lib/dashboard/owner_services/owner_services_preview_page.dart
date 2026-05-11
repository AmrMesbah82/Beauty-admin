/// ******************* FILE INFO *******************
/// File Name: owner_services_preview_page.dart
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

import '../../../core/custom_dialog.dart';
import '../../controller/owner_services/owner_services_cubit.dart';
import '../../controller/owner_services/owner_services_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../core/widget/circle_progress.dart';
import '../../model/owner_services/owner_services_model.dart';
import '../../theme/new_theme.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class _C {
  static const Color primary    = Color(0xFFD16F9A);
  static const Color back       = Color(0xFFF1F2ED);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color sectionBg  = Color(0xFFFDF5F8);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color addBtn     = Color(0xFF797979);
}

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

enum _PreviewDevice { desktop, tablet, mobile }

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ═════════════════════════════════════════════════════════════════════════════
// PAGE
// ═════════════════════════════════════════════════════════════════════════════
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
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Scaffold(
          backgroundColor: _C.back,
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
                            color: _C.primary,
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
              color: _C.primary,
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
        return _DesktopFrame(
          containerWidth: containerW,
          model: data,
          isEnglish: _isEnglish,
        );
      case _PreviewDevice.tablet:
        return _TabletFrame(
          containerWidth: containerW,
          model: data,
          isEnglish: _isEnglish,
        );
      case _PreviewDevice.mobile:
        return _MobileFrame(
          containerWidth: containerW,
          model: data,
          isEnglish: _isEnglish,
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
              color: _C.addBtn,
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
              color: _C.primary,
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
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final OwnerServicesPageModel model;
  final bool isEnglish;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(color: _C.back),
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
                      child: _PreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        model: model,
                        isEnglish: isEnglish,
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
  final OwnerServicesPageModel model;
  final bool isEnglish;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Column(
      children: [
        Center(
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
                  offset: const Offset(0, 4),
                )
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
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE FRAME (375 × 812)
// ═════════════════════════════════════════════════════════════════════════════
class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final OwnerServicesPageModel model;
  final bool isEnglish;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    final double shellH = displayH + 24 + 12 + 4;
    final double shellW = displayW + 4;

    return Column(
      children: [
        Center(
          child: Container(
            width: shellW,
            height: shellH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
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
                        child: _PreviewContent(
                          fakeWidth: _kMobileW,
                          fakeHeight: _kMobileH,
                          model: model,
                          isEnglish: isEnglish,
                          isMobile: true,
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
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT (renders actual Owner Services sections)
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final OwnerServicesPageModel model;
  final bool isEnglish;
  final bool isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    this.isMobile = false,
  });

  // ── Helper: renders an SVG from URL ───────────────────────────────────────
  Widget _buildSvg({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    final placeholder = Container(
      width: width,
      height: height,
      color: _C.primary.withOpacity(0.08),
      child: Icon(Icons.image_outlined,
          color: _C.primary.withOpacity(0.35), size: 28),
    );

    if (url.isEmpty) return placeholder;

    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = isMobile ? 16 : 40;

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
          color: _C.back,
          width: fakeWidth,
          height: fakeHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(hPad),
                const SizedBox(height: 40),
                _buildDownload(hPad),
                const SizedBox(height: 40),
                ..._buildMockups(hPad),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header section ─────────────────────────────────────────────────────────
  Widget _buildHeader(double hPad) {
    final title = isEnglish
        ? model.header.title.en
        : model.header.title.ar;
    final desc = isEnglish
        ? model.header.description.en
        : model.header.description.ar;

    final isRtl = !isEnglish;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text side
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: isRtl
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      textDirection: isRtl
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      style: const TextStyle(
                        color: _C.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  if (title.isNotEmpty) const SizedBox(height: 12),
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      textDirection: isRtl
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      style: const TextStyle(
                        color: _C.labelText,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Learn More link
                  Align(
                    alignment: isRtl
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEnglish ? 'Learn More' : 'اعرف المزيد',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _C.primary.withOpacity(0.15),
                          ),
                          child: Icon(
                            isEnglish
                                ? Icons.arrow_forward
                                : Icons.arrow_back,
                            size: 13,
                            color: _C.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // SVG image side
            if (model.header.imageUrl.isNotEmpty)
              Expanded(
                flex: 2,
                child: _buildSvg(
                  url: model.header.imageUrl,
                  width: double.infinity,
                  height: isMobile ? 140 : 180,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Download section ───────────────────────────────────────────────────────
  Widget _buildDownload(double hPad) {
    final hasLinks = model.download.appStoreLink.isNotEmpty ||
        model.download.googlePlayLink.isNotEmpty;
    if (!hasLinks) return const SizedBox.shrink();

    final title = isEnglish
        ? model.download.title.en
        : model.download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (isEnglish
        ? 'Download our app for the best experience'
        : 'قم بتنزيل تطبيقنا للحصول على أفضل تجربة');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 480;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        color: _C.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (model.download.googlePlayLink.isNotEmpty)
                        _storeBadge(
                          isEnglish: isEnglish,
                          label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                          icon: Icons.play_arrow_rounded,
                        ),
                      if (model.download.googlePlayLink.isNotEmpty &&
                          model.download.appStoreLink.isNotEmpty)
                        const SizedBox(width: 12),
                      if (model.download.appStoreLink.isNotEmpty)
                        _storeBadge(
                          isEnglish: isEnglish,
                          label: isEnglish ? 'App Store' : 'آب ستور',
                          icon: Icons.apple,
                        ),
                    ],
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _C.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (model.download.googlePlayLink.isNotEmpty)
                      _storeBadge(
                        isEnglish: isEnglish,
                        label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                        icon: Icons.play_arrow_rounded,
                      ),
                    if (model.download.appStoreLink.isNotEmpty)
                      _storeBadge(
                        isEnglish: isEnglish,
                        label: isEnglish ? 'App Store' : 'آب ستور',
                        icon: Icons.apple,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _storeBadge({
    required bool isEnglish,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
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
                isEnglish ? 'GET IT ON' : 'تحميل من',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mockups ────────────────────────────────────────────────────────────────
  List<Widget> _buildMockups(double hPad) {
    if (model.mockups.items.isEmpty) return [];

    return model.mockups.items.map((item) {
      return Padding(
        padding: EdgeInsets.only(
            left: hPad, right: hPad, bottom: 32),
        child: _buildMockupItem(item),
      );
    }).toList();
  }

  Widget _buildMockupItem(OwnerServicesMockupItemModel item) {
    final title = isEnglish ? item.title.en : item.title.ar;
    final desc  = isEnglish ? item.description.en : item.description.ar;
    final isRtl = !isEnglish;

    final textWidget = Expanded(
      flex: 3,
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Column(
          crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _C.labelText,
                  height: 1.3,
                ),
              ),
            if (title.isNotEmpty && desc.isNotEmpty)
              const SizedBox(height: 10),
            if (desc.isNotEmpty)
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: _C.labelText,
                  height: 1.7,
                ),
              ),
          ],
        ),
      ),
    );

    final imageWidget = item.imageUrl.isNotEmpty
        ? Expanded(
      flex: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildSvg(
          url: item.imageUrl,
          width: double.infinity,
          height: isMobile ? 160 : 200,
        ),
      ),
    )
        : const SizedBox.shrink();

    Widget rowContent;
    switch (item.alignment) {
      case 'right':
        rowContent = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textWidget,
            const SizedBox(width: 20),
            imageWidget,
          ],
        );
        break;
      case 'centered':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _C.sectionBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (item.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildSvg(
                    url: item.imageUrl,
                    width: isMobile ? 160 : 200,
                    height: isMobile ? 160 : 200,
                  ),
                ),
              if (item.imageUrl.isNotEmpty) const SizedBox(height: 16),
              if (title.isNotEmpty)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _C.labelText,
                  ),
                ),
              if (title.isNotEmpty && desc.isNotEmpty)
                const SizedBox(height: 8),
              if (desc.isNotEmpty)
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _C.labelText,
                    height: 1.7,
                  ),
                ),
            ],
          ),
        );
      case 'left':
      default:
        rowContent = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imageWidget,
            const SizedBox(width: 20),
            textWidget,
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: rowContent,
    );
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