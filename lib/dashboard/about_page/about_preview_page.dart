/// ******************* FILE INFO *******************
/// File Name: about_preview_page.dart
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

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/controller/home/home_cubit.dart';
import 'package:beauty_admin/controller/home/home_state.dart';
import 'package:beauty_admin/controller/home/lang_state.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../model/about_us/about_us.dart';
import '../../model/client_services/client_services_model.dart';

// ── Shared constants (mirrors about_page.dart) ────────────────────────────────
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);

// ── Preview-page-only colours ─────────────────────────────────────────────────
class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color secondary = Color(0xFFE8F5EE);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color labelText = Color(0xFF1A1A1A);
  static const Color border = Color(0xFFE0E0E0);
}

Color _hoverTint(Color primary) => primary.withOpacity(0.12);

enum _PreviewDevice { desktop, tablet, mobile }

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH = 768.0;

const double _kTabletW = 768.0;
const double _kTabletH = 1024.0;

const double _kMobileW = 375.0;
const double _kMobileH = 812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ═══════════════════════════════════════════════════════════════════════════════
// XHR IMAGE CACHE — identical to about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: isSvg ? 'image/svg+xml' : null,
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header = String.fromCharCodes(
    b.sublist(0, b.length.clamp(0, 100)),
  ).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();

  final fitStr = fit == BoxFit.contain
      ? 'contain'
      : fit == BoxFit.scaleDown
      ? 'scale-down'
      : fit == BoxFit.fill
      ? 'fill'
      : 'cover';

  String _safeSize(double? v) {
    if (v == null) return 'null';
    if (v.isInfinite || v.isNaN) return 'fill';
    return v.toInt().toString();
  }

  final viewId =
      'svg-about-preview-${url.hashCode}-${_safeSize(width)}-${_safeSize(height)}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fitStr;
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    final safeW = (width != null && !width.isNaN && !width.isInfinite)
        ? width
        : double.infinity;
    final safeH = (height != null && !height.isNaN && !height.isInfinite)
        ? height
        : null;
    inner = SizedBox(width: safeW, height: safeH, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

double _desktopContentWidth(BuildContext context) {
  final double screen = MediaQuery.of(context).size.width;
  final double natural = (248.w * 4) + (8.w * 3);
  return natural.clamp(0.0, screen - 64.0);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE
// ═══════════════════════════════════════════════════════════════════════════════

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
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final AboutPageModel model;
  final bool isRtl;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final scale = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(
        color: _C.sectionBg,
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
                        isRtl: isRtl,
                        isMobile: false,
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
  final AboutPageModel model;
  final bool isRtl;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale = _safeScale(displayW / _kTabletW);
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
                          isRtl: isRtl,
                          isMobile: false,
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
  final AboutPageModel model;
  final bool isRtl;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale = _safeScale(displayW / _kMobileW);
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
                // ── Notch ──────────────────────────────────────────────
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
                // ── Content ────────────────────────────────────────────
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
                          isRtl: isRtl,
                          isMobile: true,
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Home indicator ─────────────────────────────────────
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
// PREVIEW CONTENT (renders actual about us sections)
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatefulWidget {
  final double fakeWidth;
  final double fakeHeight;
  final AboutPageModel model;
  final bool isRtl;
  final bool isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isRtl,
    required this.isMobile,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  late int _selectedTopTab;
  late int _selectedSubTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = 0;
    _selectedSubTab = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !widget.isMobile && widget.fakeWidth >= 900;
    final isTablet = !widget.isMobile && widget.fakeWidth >= 600 && widget.fakeWidth < 900;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(widget.fakeWidth, widget.fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Directionality(
          textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            color: AppColors.background,
            width: widget.fakeWidth,
            height: widget.fakeHeight,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildHeroSection(),
                  const SizedBox(height: 20),
                  isDesktop
                      ? _buildDesktopBody()
                      : (isTablet ? _buildTabletBody() : _buildMobileBody()),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Section ───────────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    final svgHero = widget.model.svgUrl.isNotEmpty && !widget.isMobile
        ? SizedBox(
      width: 260.w,
      height: 220.h,
      child: _netImg(
        url: widget.model.svgUrl,
        width: 260.w,
        height: 220.h,
        fit: BoxFit.contain,
      ),
    )
        : (widget.model.svgUrl.isNotEmpty && widget.isMobile
        ? SizedBox(
      width: 160.w,
      height: 160.h,
      child: _netImg(
        url: widget.model.svgUrl,
        width: 160.w,
        height: 160.h,
        fit: BoxFit.contain,
      ),
    )
        : const SizedBox.shrink());

    final titleHero = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 16.w : 24.w,
            vertical: widget.isMobile ? 20.h : 36.h),
        child: Text(
          _ab(widget.model.title, widget.isRtl).isNotEmpty
              ? _ab(widget.model.title, widget.isRtl)
              : (widget.isRtl ? 'من نحن' : 'About Us'),
          textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
          style: StyleText.fontSize45Weight600.copyWith(
            fontSize: widget.isMobile ? 28.sp : 48.sp,
            fontWeight: FontWeight.w700,
            color: _C.primary,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.fakeWidth * 0.17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.isRtl
            ? [titleHero, svgHero]
            : [svgHero, titleHero],
      ),
    );
  }

  // ── Desktop Body ───────────────────────────────────────────────────────────
  Widget _buildDesktopBody() {
    final screenW = widget.fakeWidth;
    final contentW = _desktopContentWidth(context);
    final hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity);

    final topTabs = [
      BiText(ar: 'من نحن', en: 'About Us'),
      BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Tab Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(topTabs.length, (i) {
                final label = widget.isRtl
                    ? (topTabs[i].ar.isNotEmpty ? topTabs[i].ar : topTabs[i].en)
                    : topTabs[i].en;
                final svgAsset = i == 0
                    ? widget.model.navigationLabel.iconUrl
                    : '';
                return _DesktopTopTabItem(
                  index: i,
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: _selectedTopTab == i,
                  primaryColor: _C.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 10.h),

          // Tab 0: About Us
          if (_selectedTopTab == 0) _buildDesktopAboutUsContent(),

          // Tab 1: Our Strategy
          if (_selectedTopTab == 1) _buildDesktopStrategyContent(),

          SizedBox(height: 36.h),
        ],
      ),
    );
  }

  Widget _buildDesktopAboutUsContent() {
    var gap = 16.w;
    var leftW = 280.w;

    final tabLabels = [
      widget.isRtl ? 'الرؤية' : 'Vision',
      widget.isRtl ? 'الرسالة' : 'Mission',
      widget.isRtl ? 'القيم' : 'Values',
    ];
    final tabIconUrls = [
      widget.model.vision.iconUrl,
      widget.model.mission.iconUrl,
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
    ];
    final tabDescs = [
      _ab(widget.model.vision.subDescription, widget.isRtl),
      _ab(widget.model.mission.subDescription, widget.isRtl),
      widget.model.values.isNotEmpty
          ? _ab(widget.model.values.first.shortDescription, widget.isRtl)
          : '',
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (i) {
                final isLast = i == 2;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                  child: _DesktopTabItem(
                    label: tabLabels[i],
                    iconUrl: tabIconUrls[i],
                    selectedDesc: _selectedSubTab == i ? tabDescs[i] : '',
                    isSelected: _selectedSubTab == i,
                    primaryColor: _C.primary,
                    secondaryColor: _C.secondary,
                    onTap: () => setState(() => _selectedSubTab = i),
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _DesktopRightPanel(
              model: widget.model,
              tabIndex: _selectedSubTab,
              isRtl: widget.isRtl,
              primaryColor: _C.primary,
              secondaryColor: _C.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStrategyContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          widget.isRtl ? 'استراتيجيتنا قيد التطوير' : 'Our Strategy content goes here',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  // ── Tablet Body ────────────────────────────────────────────────────────────
  Widget _buildTabletBody() {
    final topTabs = [
      BiText(ar: 'من نحن', en: 'About Us'),
      BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(topTabs.length, (i) {
                final label = widget.isRtl
                    ? (topTabs[i].ar.isNotEmpty ? topTabs[i].ar : topTabs[i].en)
                    : topTabs[i].en;
                final svgAsset = i == 0
                    ? widget.model.navigationLabel.iconUrl
                    : '';
                return _TabletTopTabItem(
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: _selectedTopTab == i,
                  primaryColor: _C.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),
          if (_selectedTopTab == 0) _buildTabletAboutUsContent(),
          if (_selectedTopTab == 1) _buildTabletStrategyContent(),
        ],
      ),
    );
  }

  Widget _buildTabletAboutUsContent() {
    final tabLabels = [
      widget.isRtl ? 'الرؤية' : 'Vision',
      widget.isRtl ? 'الرسالة' : 'Mission',
      widget.isRtl ? 'القيم' : 'Values',
    ];
    final tabIconUrls = [
      widget.model.vision.iconUrl,
      widget.model.mission.iconUrl,
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
    ];

    return Column(
      children: [
        Row(
          children: List.generate(3, (i) {
            final isLast = i == 2;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: isLast ? 0 : 10.w),
                child: _TabletTabItem(
                  label: tabLabels[i],
                  iconUrl: tabIconUrls[i],
                  isSelected: _selectedSubTab == i,
                  primaryColor: _C.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedSubTab = i),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 14.h),
        _TabletContentPanel(
          model: widget.model,
          tabIndex: _selectedSubTab,
          isRtl: widget.isRtl,
          primaryColor: _C.primary,
          secondaryColor: _C.secondary,
        ),
      ],
    );
  }

  Widget _buildTabletStrategyContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          widget.isRtl ? 'استراتيجيتنا قيد التطوير' : 'Our Strategy content goes here',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  // ── Mobile Body ────────────────────────────────────────────────────────────
  Widget _buildMobileBody() {
    final topTabs = [
      BiText(ar: 'من نحن', en: 'About Us'),
      BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(topTabs.length, (i) {
                final label = widget.isRtl
                    ? (topTabs[i].ar.isNotEmpty ? topTabs[i].ar : topTabs[i].en)
                    : topTabs[i].en;
                final svgAsset = i == 0
                    ? widget.model.navigationLabel.iconUrl
                    : '';
                return _MobileTopTabItemPreview(
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: _selectedTopTab == i,
                  primaryColor: _C.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),
          if (_selectedTopTab == 0) _buildMobileAboutUsContent(),
          if (_selectedTopTab == 1) _buildMobileStrategyContent(),
        ],
      ),
    );
  }

  Widget _buildMobileAboutUsContent() {
    final tabs = [
      _MobileTabDataPreview(
        label: widget.isRtl ? 'الرؤية' : 'Vision',
        iconUrl: widget.model.vision.iconUrl,
        svgUrl: widget.model.vision.svgUrl,
        fullText: _ab(widget.model.vision.description, widget.isRtl),
        tabIndex: 0,
      ),
      _MobileTabDataPreview(
        label: widget.isRtl ? 'الرسالة' : 'Mission',
        iconUrl: widget.model.mission.iconUrl,
        svgUrl: widget.model.mission.svgUrl,
        fullText: _ab(widget.model.mission.description, widget.isRtl),
        tabIndex: 1,
      ),
      _MobileTabDataPreview(
        label: widget.isRtl ? 'القيم' : 'Values',
        iconUrl: widget.model.values.isNotEmpty
            ? widget.model.values.first.iconUrl
            : '',
        svgUrl: '',
        fullText: '',
        tabIndex: 2,
      ),
    ];

    return Column(
      children: tabs.map((tab) {
        final isOpen = _selectedSubTab == tab.tabIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _MobileAccordionItemPreview(
            tab: tab,
            values: widget.model.values,
            isExpanded: isOpen,
            isRtl: widget.isRtl,
            primaryColor: _C.primary,
            secondaryColor: _C.secondary,
            fakeWidth: widget.fakeWidth,
            onTap: () => setState(() => _selectedSubTab = isOpen ? -1 : tab.tabIndex),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileStrategyContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          widget.isRtl ? 'استراتيجيتنا قيد التطوير' : 'Our Strategy content goes here',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

class _DesktopTopTabItem extends StatefulWidget {
  final int index;
  final String label;
  final String svgAsset;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _DesktopTopTabItem({
    required this.index,
    required this.label,
    required this.svgAsset,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_DesktopTopTabItem> createState() => _DesktopTopTabItemState();
}

class _DesktopTopTabItemState extends State<_DesktopTopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: widget.svgAsset.isNotEmpty
                      ? _netImg(
                    url: widget.svgAsset,
                    width: 24.sp,
                    height: 24.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : Icon(
                    Icons.image_outlined,
                    size: 24.sp,
                    color: sel ? Colors.white : widget.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                widget.label,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: sel ? widget.primaryColor : AppColors.secondaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopTabItem extends StatefulWidget {
  final String label, iconUrl, selectedDesc;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _DesktopTabItem({
    required this.label,
    required this.iconUrl,
    required this.selectedDesc,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_DesktopTabItem> createState() => _DesktopTabItemState();
}

class _DesktopTabItemState extends State<_DesktopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
    widget.isSelected ? Colors.white : widget.primaryColor;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _kSurface
                : (_hovered ? hoverBg : _kSurface),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.primaryColor
                          : widget.secondaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: widget.iconUrl.isNotEmpty
                          ? _netImg(
                        url: widget.iconUrl,
                        width: 20.sp,
                        height: 20.sp,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      )
                          : Icon(
                        Icons.image_outlined,
                        size: 20.sp,
                        color: iconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isSelected && widget.selectedDesc.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  widget.selectedDesc,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 11.sp,
                    height: 1.65,
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopRightPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _DesktopRightPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridDesktopPreview(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 13.sp,
                height: 1.75,
              ),
            ),
          ),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            _netImg(
              url: section.svgUrl,
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TABLET COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

class _TabletTopTabItem extends StatefulWidget {
  final String label;
  final String svgAsset;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _TabletTopTabItem({
    required this.label,
    required this.svgAsset,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_TabletTopTabItem> createState() => _TabletTopTabItemState();
}

class _TabletTopTabItemState extends State<_TabletTopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border(
              bottom: BorderSide(
                color: sel ? widget.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: widget.svgAsset.isNotEmpty
                      ? _netImg(
                    url: widget.svgAsset,
                    width: 22.sp,
                    height: 22.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : Icon(
                    Icons.image_outlined,
                    size: 22.sp,
                    color: sel ? Colors.white : widget.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.label,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: sel ? widget.primaryColor : AppColors.secondaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletTabItem extends StatefulWidget {
  final String label, iconUrl;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _TabletTabItem({
    required this.label,
    required this.iconUrl,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_TabletTabItem> createState() => _TabletTabItemState();
}

class _TabletTabItemState extends State<_TabletTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverBg = _hoverTint(widget.primaryColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.primaryColor
                : (_hovered ? hoverBg : _kSurface),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: widget.isSelected
                  ? widget.primaryColor
                  : (_hovered ? widget.primaryColor.withOpacity(0.3) : _kDivider),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.iconUrl.isNotEmpty)
                _netImg(
                  url: widget.iconUrl,
                  width: 16.sp,
                  height: 16.sp,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    widget.isSelected ? Colors.white : widget.primaryColor,
                    BlendMode.srcIn,
                  ),
                )
              else
                Icon(Icons.image_outlined,
                    size: 16.sp,
                    color: widget.isSelected ? Colors.white : widget.primaryColor),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected
                        ? Colors.white
                        : (_hovered ? widget.primaryColor : widget.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletContentPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _TabletContentPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridTabletPreview(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.svgUrl.isNotEmpty) ...[
            Center(
              child: _netImg(
                url: section.svgUrl,
                width: 160.w,
                height: 160.h,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Text(
            _ab(section.description, isRtl),
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: 11.sp,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALUES GRIDS
// ═════════════════════════════════════════════════════════════════════════════

class _ValuesGridDesktopPreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _ValuesGridDesktopPreview({
    required this.values,
    required this.primaryColor,
    required this.secondaryColor,
    this.isRtl = false,
  });

  @override
  State<_ValuesGridDesktopPreview> createState() => _ValuesGridDesktopPreviewState();
}

class _ValuesGridDesktopPreviewState extends State<_ValuesGridDesktopPreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: List.generate(widget.values.length, (i) {
              final v = widget.values[i];
              return _ValueGridCardPreview(
                title: _ab(v.title, widget.isRtl),
                iconUrl: v.iconUrl,
                isSelected: i == idx,
                primaryColor: widget.primaryColor,
                width: 100.w,
                iconSize: 22.sp,
                fontSize: 9.sp,
                padding: 10.r,
                onTap: () => setState(() => _selectedIndex = i),
              );
            }),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanelPreview(
            value: selected,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

class _ValuesGridTabletPreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _ValuesGridTabletPreview({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_ValuesGridTabletPreview> createState() => _ValuesGridTabletPreviewState();
}

class _ValuesGridTabletPreviewState extends State<_ValuesGridTabletPreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: widget.secondaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(widget.values.length, (i) {
                final v = widget.values[i];
                return _ValueGridCardPreview(
                  title: _ab(v.title, widget.isRtl),
                  iconUrl: v.iconUrl,
                  isSelected: i == idx,
                  primaryColor: widget.primaryColor,
                  width: 88.w,
                  iconSize: 18.sp,
                  fontSize: 8.sp,
                  padding: 9.r,
                  onTap: () => setState(() => _selectedIndex = i),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanelPreview(
            value: selected,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

class _MobileTopTabItemPreview extends StatefulWidget {
  final String label;
  final String svgAsset;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _MobileTopTabItemPreview({
    required this.label,
    required this.svgAsset,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_MobileTopTabItemPreview> createState() => _MobileTopTabItemPreviewState();
}

class _MobileTopTabItemPreviewState extends State<_MobileTopTabItemPreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: sel ? Colors.transparent : (_hovered ? _hoverTint(widget.primaryColor) : Colors.transparent),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44.sp,
                height: 44.sp,
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: widget.svgAsset.isNotEmpty
                      ? _netImg(
                    url: widget.svgAsset,
                    width: 24.sp,
                    height: 24.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : Icon(
                    Icons.image_outlined,
                    size: 24.sp,
                    color: sel ? Colors.white : widget.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                widget.label,
                style: StyleText.fontSize20Weight600.copyWith(
                  fontSize: 16.sp,
                  color: sel ? widget.primaryColor : AppColors.secondaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileTabDataPreview {
  final String label, iconUrl, svgUrl, fullText;
  final int tabIndex;

  const _MobileTabDataPreview({
    required this.label,
    required this.iconUrl,
    required this.svgUrl,
    required this.fullText,
    required this.tabIndex,
  });
}

class _MobileAccordionItemPreview extends StatefulWidget {
  final _MobileTabDataPreview tab;
  final List<AboutValueItem> values;
  final bool isExpanded, isRtl;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  final double fakeWidth;

  const _MobileAccordionItemPreview({
    required this.tab,
    required this.values,
    required this.isExpanded,
    required this.onTap,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fakeWidth,
  });

  @override
  State<_MobileAccordionItemPreview> createState() => _MobileAccordionItemPreviewState();
}

class _MobileAccordionItemPreviewState extends State<_MobileAccordionItemPreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final List<AboutValueItem> gridValues =
    (widget.tab.tabIndex == 2 && widget.values.length > 1)
        ? widget.values.sublist(1)
        : (widget.tab.tabIndex == 2 ? <AboutValueItem>[] : widget.values);

    final Color hoverBg = _hoverTint(widget.primaryColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.isExpanded
            ? _kSurface
            : (_hovered ? hoverBg : _kSurface),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _hovered && !widget.isExpanded
              ? widget.primaryColor.withOpacity(0.25)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? widget.primaryColor
                            : widget.secondaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: widget.tab.iconUrl.isNotEmpty
                            ? _netImg(
                          url: widget.tab.iconUrl,
                          width: 18.sp,
                          height: 18.sp,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            widget.isExpanded ? Colors.white : widget.primaryColor,
                            BlendMode.srcIn,
                          ),
                        )
                            : Icon(
                          Icons.image_outlined,
                          size: 16.sp,
                          color: widget.isExpanded ? Colors.white : AppColors.textButton,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.tab.label,
                        style: StyleText.fontSize16Weight600.copyWith(
                          fontSize: 12.sp,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? widget.primaryColor
                            : widget.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        widget.isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: widget.isExpanded ? Colors.white : widget.primaryColor,
                        size: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tab.tabIndex != 2 && widget.tab.svgUrl.isNotEmpty) ...[
                    Center(
                      child: _netImg(
                        url: widget.tab.svgUrl,
                        width: widget.fakeWidth - 16.w * 2 - 12.w * 2,
                        height: 150.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  if (widget.tab.tabIndex != 2)
                    Text(
                      widget.tab.fullText,
                      style: StyleText.fontSize13Weight400.copyWith(
                        fontSize: 10.sp,
                        height: 1.7,
                      ),
                    ),
                  if (widget.tab.tabIndex == 2)
                    _ValuesGridMobilePreview(
                      values: gridValues,
                      isRtl: widget.isRtl,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                      fakeWidth: widget.fakeWidth,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ValuesGridMobilePreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final double fakeWidth;

  const _ValuesGridMobilePreview({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fakeWidth,
  });

  @override
  State<_ValuesGridMobilePreview> createState() => _ValuesGridMobilePreviewState();
}

class _ValuesGridMobilePreviewState extends State<_ValuesGridMobilePreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    final double innerW = widget.fakeWidth - 16.w * 2 - 12.w * 2;
    final double gap = 7.w;
    final double cardW = (innerW - gap) / 2;
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(widget.values.length, (i) {
            final v = widget.values[i];
            return _ValueGridCardPreview(
              title: _ab(v.title, widget.isRtl),
              iconUrl: v.iconUrl,
              isSelected: i == idx,
              primaryColor: widget.primaryColor,
              width: cardW,
              iconSize: 16.sp,
              fontSize: 10.sp,
              padding: 9.r,
              rowLayout: true,
              onTap: () => setState(() => _selectedIndex = i),
            );
          }),
        ),
        SizedBox(height: 10.h),
        _ValueDetailPanelPreview(
          value: selected,
          isRtl: widget.isRtl,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALUE GRID CARD
// ═════════════════════════════════════════════════════════════════════════════

class _ValueGridCardPreview extends StatefulWidget {
  final String title, iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final double width, iconSize, fontSize, padding;
  final VoidCallback onTap;
  final bool rowLayout;

  const _ValueGridCardPreview({
    required this.title,
    required this.iconUrl,
    required this.isSelected,
    required this.primaryColor,
    required this.width,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    required this.onTap,
    this.rowLayout = false,
  });

  @override
  State<_ValueGridCardPreview> createState() => _ValueGridCardPreviewState();
}

class _ValueGridCardPreviewState extends State<_ValueGridCardPreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    final Widget iconWidget = widget.iconUrl.isNotEmpty
        ? _netImg(
      url: widget.iconUrl,
      width: widget.iconSize,
      height: widget.iconSize,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        sel ? Colors.white : widget.primaryColor,
        BlendMode.srcIn,
      ),
    )
        : Icon(
      Icons.star_outline,
      size: widget.iconSize,
      color: sel ? Colors.white : widget.primaryColor,
    );

    final Widget titleWidget = Text(
      widget.title,
      textAlign: widget.rowLayout ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w600,
        color: sel ? Colors.white : (_hovered ? widget.primaryColor : Colors.black87),
        height: 1.35,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.rowLayout ? null : widget.width,
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel ? widget.primaryColor : (_hovered ? hoverBg : Colors.white),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: sel
                ? [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
            border: Border.all(
              color: _hovered && !sel ? widget.primaryColor.withOpacity(0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.rowLayout
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(width: 6.w),
              Expanded(child: titleWidget),
            ],
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(height: 6.h),
              titleWidget,
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL
// ═════════════════════════════════════════════════════════════════════════════

class _ValueDetailPanelPreview extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _ValueDetailPanelPreview({
    required this.value,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _ab(value.title, isRtl);
    final String shortDesc = _ab(value.shortDescription, isRtl);
    final String fullDesc = _ab(value.description, isRtl);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: value.iconUrl.isNotEmpty
                  ? _netImg(
                url: value.iconUrl,
                width: 30.r,
                height: 30.r,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              )
                  : Icon(Icons.star_outline, size: 20.sp, color: primaryColor),
            ),
          ),
          SizedBox(height: 10.h),
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if (shortDesc.isNotEmpty) ...[
            Text(
              shortDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryBlack,
                height: 1.6,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (fullDesc.isNotEmpty)
            Text(
              fullDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryBlack,
                height: 1.65,
              ),
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