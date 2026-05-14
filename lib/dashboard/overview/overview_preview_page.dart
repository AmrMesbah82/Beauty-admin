/// ******************* FILE INFO *******************
/// File Name: overview_preview_page.dart
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

import 'package:beauty_admin/controller/home/home_cubit.dart';
import 'package:beauty_admin/controller/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/overview/overview_cubit.dart';
import '../../controller/overview/overview_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/overview/overview_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

class _C {
  static const Color primary     = Color(0xFFD16F9A);
  static const Color back        = Color(0xFFF1F2ED);
  static const Color labelText   = Color(0xFF333333);
  static const Color hintText    = Color(0xFFAAAAAA);
  static const Color border      = Color(0xFFE0E0E0);
  static const Color sectionBg   = Color(0xFFF5F5F5);
}

// ══════════════════════════════════════════════════════════════════════════════
// Helper — parse hex color from branding
// ══════════════════════════════════════════════════════════════════════════════

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ══════════════════════════════════════════════════════════════════════════════
// Network Image Helper (matching overview_page.dart approach)
// ══════════════════════════════════════════════════════════════════════════════

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();

  final viewId = 'svg-preview-${url.hashCode}-${width?.toInt()}-${height?.toInt()}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : fit == BoxFit.scaleDown
          ? 'scale-down'
          : 'cover';
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    inner = SizedBox(width: width, height: height, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

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
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 2),
                        SizedBox(height: 16.h),

                        Text(
                          'Preview Overview Details',
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
                                        ? _C.primary.withOpacity(0.5)
                                        : _C.primary,
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
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                    child: CircularProgressIndicator(color: _C.primary)),
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
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final OverviewPageModel model;
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
      decoration: BoxDecoration(
          color: _C.back
      ),
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
  final OverviewPageModel model;
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
              border: Border.all(color: _C.border, width: 2),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
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
  final OverviewPageModel model;
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
// PREVIEW CONTENT (renders actual overview sections)
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatefulWidget {
  final double fakeWidth;
  final double fakeHeight;
  final OverviewPageModel model;
  final bool isEnglish;
  final bool isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  int _galleryActiveIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get background color from HomePage branding if available
    final homeState = context.watch<HomeCmsCubit>().state;
    final homeData = switch (homeState) {
      HomeCmsLoaded(:final data) => data,
      HomeCmsSaved(:final data) => data,
      HomeCmsSaving(:final data) => data,
      HomeCmsError(:final lastData) => lastData,
      _ => null,
    };

    final Color mainWidgetColor = homeData != null
        ? _parseHex(homeData.branding.mainWidgetColor, fallback: Colors.white)
        : Colors.white;

    final Color backgroundColor = homeData != null
        ? _parseHex(homeData.branding.backgroundColor, fallback: _C.back)
        : _C.back;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(widget.fakeWidth, widget.fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color: backgroundColor,
          width: widget.fakeWidth,
          height: widget.fakeHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildOverview(mainWidgetColor),
                const SizedBox(height: 50),
                _buildServices(),
                const SizedBox(height: 50),
                _buildGallery(mainWidgetColor),
                const SizedBox(height: 50),
                _buildComments(mainWidgetColor),
                const SizedBox(height: 50),
                _buildDownload(mainWidgetColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Overview section ───────────────────────────────────────────────────────
  Widget _buildOverview(Color mainWidgetColor) {
    final m = widget.model;
    final title = widget.isEnglish ? m.headings.title.en : m.headings.title.ar;
    final desc = widget.isEnglish
        ? m.headings.description.en
        : m.headings.description.ar;

    return Container(
      decoration: BoxDecoration(
        color: mainWidgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 32,
          horizontal: widget.isMobile ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.isNotEmpty ? title : 'Overview',
              style: TextStyle(
                color: _C.primary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              desc.isNotEmpty
                  ? desc
                  : 'Welcome to Beauty App, where beauty meets tranquility.',
              textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
              style: const TextStyle(
                height: 1.7,
                color: _C.labelText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isEnglish ? 'Read More' : 'اقرأ المزيد',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _C.primary.withOpacity(0.15),
                        ),
                        child: Icon(
                          widget.isEnglish ? Icons.arrow_forward : Icons.arrow_back,
                          size: 14,
                          color: _C.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Services section ───────────────────────────────────────────────────────
  Widget _buildServices() {
    final m = widget.model;
    if (m.services.items.isEmpty) return const SizedBox.shrink();

    final svcTitle = widget.isEnglish ? m.services.title.en : m.services.title.ar;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: widget.isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            svcTitle.isNotEmpty ? svcTitle : 'Top Services',
            textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: const TextStyle(
              color: _C.primary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: m.services.items.map((item) {
                final name = widget.isEnglish ? item.name.en : item.name.ar;
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _C.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Center(
                            child: item.imageUrl.isNotEmpty
                                ? _netImg(
                              url: item.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.scaleDown,
                              placeholder: Icon(
                                Icons.spa_outlined,
                                color: _C.primary.withOpacity(0.4),
                                size: 28,
                              ),
                              errorWidget: Icon(
                                Icons.spa_outlined,
                                color: _C.primary.withOpacity(0.4),
                                size: 28,
                              ),
                            )
                                : Icon(
                              Icons.spa_outlined,
                              color: _C.primary.withOpacity(0.4),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name.isNotEmpty ? name : 'Service',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _C.labelText,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gallery section ────────────────────────────────────────────────────────
  Widget _buildGallery(Color mainWidgetColor) {
    final m = widget.model;
    if (m.gallery.images.isEmpty) return const SizedBox.shrink();

    final visibleImages = m.gallery.images
        .where((img) => img.imageUrl.isNotEmpty)
        .toList();
    if (visibleImages.isEmpty) return const SizedBox.shrink();

    if (_galleryActiveIndex >= visibleImages.length) {
      _galleryActiveIndex = visibleImages.length - 1;
    }

    final isMobileView = widget.fakeWidth < 600;
    final double inactiveSize = isMobileView ? 110 : 200;
    final double activeSize   = isMobileView ? 160 : 284;

    return Container(
      decoration: BoxDecoration(
        color: mainWidgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 16 : 40,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEnglish ? 'Gallery' : 'المعرض',
              style: const TextStyle(
                color: _C.primary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: activeSize + 16,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(visibleImages.length, (i) {
                    final bool isActive = _galleryActiveIndex == i;
                    final double size = isActive ? activeSize : inactiveSize;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _galleryActiveIndex = i),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          width: size,
                          height: size,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _netImg(
                              url: visibleImages[i].imageUrl,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: _C.primary.withOpacity(0.12),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: _C.primary.withOpacity(0.4),
                                  size: 36,
                                ),
                              ),
                              errorWidget: Container(
                                color: _C.primary.withOpacity(0.08),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: _C.primary.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(visibleImages.length, (i) {
                final bool active = _galleryActiveIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _galleryActiveIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active ? _C.primary : _C.primary.withOpacity(0.3),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Comments section ───────────────────────────────────────────────────────
  Widget _buildComments(Color mainWidgetColor) {
    final m = widget.model;
    if (m.clientComments.comments.isEmpty) return const SizedBox.shrink();

    final cmtTitle = widget.isEnglish
        ? m.clientComments.title.en
        : m.clientComments.title.ar;
    final highlightWord = widget.isEnglish ? 'Clients' : 'عملائنا';
    final titleText = cmtTitle.isNotEmpty
        ? cmtTitle
        : (widget.isEnglish
        ? 'What Our Clients Say About Us'
        : 'ماذا يقول عملاؤنا عنّا');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: widget.isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          _buildHighlightedTitle(titleText, highlightWord),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: m.clientComments.comments.map((cmt) {
                final firstName = widget.isEnglish
                    ? cmt.firstName.en
                    : cmt.firstName.ar;
                final lastName = widget.isEnglish
                    ? cmt.lastName.en
                    : cmt.lastName.ar;
                final feedback = widget.isEnglish
                    ? cmt.feedback.en
                    : cmt.feedback.ar;
                final fullName = '$firstName $lastName'.trim();

                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: mainWidgetColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: cmt.imageUrl.isNotEmpty
                                ? _netImg(
                              url: cmt.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                _C.primary.withOpacity(0.15),
                                child: Icon(
                                  Icons.person_outline,
                                  color: _C.primary,
                                  size: 22,
                                ),
                              ),
                              errorWidget: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                _C.primary.withOpacity(0.15),
                                child: Icon(
                                  Icons.person_outline,
                                  color: _C.primary,
                                  size: 22,
                                ),
                              ),
                            )
                                : CircleAvatar(
                              radius: 24,
                              backgroundColor:
                              _C.primary.withOpacity(0.15),
                              child: Icon(
                                Icons.person_outline,
                                color: _C.primary,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fullName.isNotEmpty ? fullName : 'Client Name',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _C.labelText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        feedback.isNotEmpty
                            ? feedback
                            : 'Great service! Highly recommended.',
                        textDirection: widget.isEnglish
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: _C.labelText.withOpacity(0.75),
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedTitle(String title, String highlightWord) {
    final idx = title.toLowerCase().indexOf(highlightWord.toLowerCase());
    if (idx == -1) {
      return Text(
        title,
        style: const TextStyle(
          color: _C.labelText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      );
    }

    final before = title.substring(0, idx);
    final keyword = title.substring(idx, idx + highlightWord.length);
    final after = title.substring(idx + highlightWord.length);

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: _C.labelText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(text: keyword, style: const TextStyle(color: _C.primary)),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }

  // ── Download section ───────────────────────────────────────────────────────
  Widget _buildDownload(Color mainWidgetColor) {
    final m = widget.model;
    final title = widget.isEnglish ? m.download.title.en : m.download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (widget.isEnglish
        ? 'Download our app for the best experience'
        : 'قم بتنزيل تطبيقنا للحصول على أفضل تجربة');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        decoration: BoxDecoration(
          color: mainWidgetColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
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
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _storeBadge(
                        label: widget.isEnglish ? 'Google Play' : 'جوجل بلاي',
                        icon: Icons.play_arrow_rounded,
                      ),
                      const SizedBox(width: 12),
                      _storeBadge(
                        label: widget.isEnglish ? 'App Store' : 'آب ستور',
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
                  style: const TextStyle(
                    color: _C.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _storeBadge(
                      label: widget.isEnglish ? 'Google Play' : 'جوجل بلاي',
                      icon: Icons.play_arrow_rounded,
                    ),
                    _storeBadge(
                      label: widget.isEnglish ? 'App Store' : 'آب ستور',
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

  Widget _storeBadge({required String label, required IconData icon}) {
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
                widget.isEnglish ? 'GET IT ON' : 'تحميل من',
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