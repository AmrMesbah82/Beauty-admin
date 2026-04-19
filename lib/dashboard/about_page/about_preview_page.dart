// ******************* FILE INFO *******************
// File Name: about_preview_page.dart
// Screen 3 — About Us CMS: Preview with Desktop/Tablet/Mobile + ENG/AR toggle
// UPDATED: Tab bar uses underline style (identical to job_listing_detail_page.dart)
// UPDATED: Preview body is identical to about_page.dart (_AboutBodyDesktop / Tablet / Mobile)
// UPDATED: secondaryColor wired through, hover effects, _netImg, _ValueGridCard all included
// Save button shows confirm dialog before persisting.

import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../model/about_us/about_us.dart';

// ── Shared constants (mirrors about_page.dart) ────────────────────────────────
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kDivider    = Color(0xFFDDE8DD);

// ── Preview-page-only colours ─────────────────────────────────────────────────
class _C {
  static const Color primary     = Color(0xFFD16F9A);
  static const Color secondary   = Color(0xFFE8F5EE);   // fallback secondary
  static const Color sectionBg   = Color(0xFFF5F5F5);
  static const Color cardBg      = Color(0xFFFFFFFF);
  static const Color grey        = Color(0xFF9E9E9E);
  static const Color hintText    = Color(0xFF797979);
  static const Color labelText   = Color(0xFF1A1A1A);
}

Color _hoverTint(Color primary) => primary.withOpacity(0.12);

enum _PreviewMode { desktop, tablet, mobile }
enum _PreviewLang { eng, ar }

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
  final header = String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
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
  final bool hintSvg = _isSvgUrl(url);
  Widget inner = FutureBuilder<Uint8List>(
    future: _xhrLoad(url, isSvg: hintSvg),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return placeholder ?? SizedBox(width: width, height: height);
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (hintSvg || _isSvgBytes(bytes)) {
          return SvgPicture.memory(bytes,
              width: width, height: height, fit: fit, colorFilter: colorFilter);
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      }
      return errorWidget ??
          Icon(Icons.broken_image,
              color: Colors.grey[400], size: (width ?? height ?? 24).toDouble());
    },
  );
  if (borderRadius != null) inner = ClipRRect(borderRadius: borderRadius, child: inner);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  return inner;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class AboutPreviewPageLast extends StatefulWidget {
  final AboutPageModel model;
  final Map<String, Uint8List> imageUploads;

  const AboutPreviewPageLast({
    super.key,
    required this.model,
    this.imageUploads = const {},
  });

  @override
  State<AboutPreviewPageLast> createState() => _AboutPreviewPageLastState();
}

class _AboutPreviewPageLastState extends State<AboutPreviewPageLast>
    with SingleTickerProviderStateMixin {
  // ── Mode / lang state ──────────────────────────────────────────────────────
  _PreviewMode _mode = _PreviewMode.desktop;
  _PreviewLang _lang = _PreviewLang.eng;
  bool _previewOpen  = true;

  // ── Job-listing style tab controller for Desktop/Tablet/Mobile ────────────
  late TabController _tabController;

  bool get _isRtl => _lang == _PreviewLang.ar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final confirmed = await _showConfirmDialog(context);
    if (confirmed == true && mounted) {
      context.read<AboutCubit>().save(
        model: widget.model,
        imageUploads: widget.imageUploads.isEmpty ? null : widget.imageUploads,
      );
    }
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.sectionBg,
      body: BlocListener<AboutCubit, AboutState>(
        listener: (context, state) {
          if (state is AboutSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About Us saved successfully!')));
            Navigator.popUntil(context, (r) => r.isFirst);
          }
          if (state is AboutError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                AdminSubNavBar(activeIndex: 5),
                SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // ── Page title ─────────────────────────────────────────
                      Text(
                        'Preview About Us Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                            color: _C.primary, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 16.h),

                      // ── Job-listing style tab bar ──────────────────────────
                      _buildModeTabBar(),
                      SizedBox(height: 15.h),



                      // ── Single accordion wrapping the full about-page body ─
                      _previewAccordion(
                        title: 'About Us Section',
                        isOpen: _previewOpen,
                        onToggle: () => setState(() => _previewOpen = !_previewOpen),
                        child: _aboutBodyByMode(),
                      ),
                      SizedBox(height: 24.h),

                      // ── Back | Save ────────────────────────────────────────
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 44.h,
                            child: ElevatedButton(
                              onPressed: _onBack,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r))),
                              child: Text('Back',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox(
                            height: 44.h,
                            child: ElevatedButton(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r))),
                              child: Text('Save',
                                  style: StyleText.fontSize14Weight600
                                      .copyWith(color: Colors.white)),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Job-listing style underline tab bar ────────────────────────────────────
  Widget _buildModeTabBar() {
    final tabs = [
      (_PreviewMode.desktop, 'Desktop'),
      (_PreviewMode.tablet,  'Tablet'),
      (_PreviewMode.mobile,  'Mobile'),
    ];
    return Row(
      children: tabs.map((entry) {
        final mode  = entry.$1;
        final label = entry.$2;
        final isActive = _mode == mode;
        return Padding(
          padding: EdgeInsets.only(right: 28.w),
          child: GestureDetector(
            onTap: () => setState(() => _mode = mode),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? _C.primary : _C.hintText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: isActive ? _C.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── ENG / AR toggle ────────────────────────────────────────────────────────
  Widget _buildLangToggle() {
    return Container(
      height: 34.h,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _kDivider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_PreviewLang.eng, _PreviewLang.ar].map((lang) {
          final selected = _lang == lang;
          final label    = lang == _PreviewLang.eng ? 'ENG' : 'AR';
          return GestureDetector(
            onTap: () => setState(() => _lang = lang),
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
        }).toList(),
      ),
    );
  }

  // ── Accordion wrapper ──────────────────────────────────────────────────────
  Widget _previewAccordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: _C.cardBg, borderRadius: BorderRadius.circular(6.r)),
      child: Column(children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ]),
          ),
        ),
        if (isOpen)
          Padding(padding: EdgeInsets.all(16.w), child: child),
      ]),
    );
  }

  // ── Route to the correct body by mode ─────────────────────────────────────
  Widget _aboutBodyByMode() {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: switch (_mode) {
        _PreviewMode.desktop => _PreviewDesktopBody(
            model: widget.model,
            isRtl: _isRtl,
            primaryColor: _C.primary,
            secondaryColor: _C.secondary),
        _PreviewMode.tablet  => _PreviewTabletBody(
            model: widget.model,
            isRtl: _isRtl,
            primaryColor: _C.primary,
            secondaryColor: _C.secondary),
        _PreviewMode.mobile  => _PreviewMobileBody(
            model: widget.model,
            isRtl: _isRtl,
            primaryColor: _C.primary,
            secondaryColor: _C.secondary),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY  — mirrors about_page.dart _AboutBodyDesktop exactly
// ═══════════════════════════════════════════════════════════════════════════════

class _PreviewDesktopBody extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _PreviewDesktopBody({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_PreviewDesktopBody> createState() => _PreviewDesktopBodyState();
}

class _PreviewDesktopBodyState extends State<_PreviewDesktopBody> {
  int _selectedTab = 0;

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية'  : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم'   : 'Values',
  };

  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ => widget.model.values.isNotEmpty
        ? widget.model.values.first.iconUrl
        : '',
  };

  String _tabDesc(int i) {
    final desc = switch (i) {
      0 => _ab(widget.model.vision.subDescription, widget.isRtl),
      1 => _ab(widget.model.mission.subDescription, widget.isRtl),
      _ => widget.model.values.isNotEmpty
          ? _ab(widget.model.values.first.shortDescription, widget.isRtl)
          : '',
    };
    if (desc.length > 160) return '${desc.substring(0, 157)}…';
    return desc;
  }

  @override
  Widget build(BuildContext context) {
    const double gap   = 16.0;
    const double leftW = 280.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: tab list ────────────────────────────────────────────
              SizedBox(
                width: leftW.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (i) {
                    final bool isLast = i == 2;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                      child: _DesktopTabItem(
                        label:        _tabLabel(i),
                        iconUrl:      _tabIconUrl(i),
                        selectedDesc: _selectedTab == i ? _tabDesc(i) : '',
                        isSelected:   _selectedTab == i,
                        primaryColor:   widget.primaryColor,
                        secondaryColor: widget.secondaryColor,
                        onTap: () => setState(() => _selectedTab = i),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(width: gap.w),

              // ── Right: detail panel ───────────────────────────────────────
              Expanded(
                child: _DesktopRightPanel(
                  model:          widget.model,
                  tabIndex:       _selectedTab,
                  isRtl:          widget.isRtl,
                  primaryColor:   widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 36.h),
      ],
    );
  }
}

// ─── Desktop Tab Item ──────────────────────────────────────────────────────

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
      onExit:  (_) => setState(() => _hovered = false),
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
              Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42.w,
                  height: 42.h,
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
                      colorFilter:
                      ColorFilter.mode(iconColor, BlendMode.srcIn),
                    )
                        : Icon(Icons.image_outlined,
                        size: 20.sp, color: iconColor),
                  ),
                ),
                SizedBox(width: 12.w),
                Flexible(
                  child: Text(
                    widget.label,
                    style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor),
                  ),
                ),
              ]),
              if (widget.isSelected && widget.selectedDesc.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  widget.selectedDesc,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight400.copyWith(
                      fontSize: 11.sp,
                      height: 1.65,
                      color: AppColors.secondaryBlack),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Desktop Right Panel ───────────────────────────────────────────────────

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
      return _ValuesGridDesktop(
        values:         otherValues,
        isRtl:          isRtl,
        primaryColor:   primaryColor,
        secondaryColor: secondaryColor,
      );
    }
    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400
                  .copyWith(fontSize: 13.sp, height: 1.75),
            ),
          ),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            _netImg(
              url:          section.svgUrl,
              width:        180.w,
              height:       180.h,
              fit:          BoxFit.contain,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — DESKTOP  (mirrors about_page.dart _ValuesGridDesktop)
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridDesktop extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridDesktop({
    required this.values,
    required this.primaryColor,
    required this.secondaryColor,
    this.isRtl = false,
  });
  @override
  State<_ValuesGridDesktop> createState() => _ValuesGridDesktopState();
}

class _ValuesGridDesktopState extends State<_ValuesGridDesktop> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
            color: _kSurface, borderRadius: BorderRadius.circular(10.r)),
        child: Center(
          child: Text('No values added yet.',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  color: Colors.grey[500])),
        ),
      );
    }
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            widget.primaryColor.withOpacity(.06),
            widget.primaryColor.withOpacity(.25),
            widget.primaryColor.withOpacity(.06),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(10.r),
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
              return _ValueGridCard(
                title:        _ab(v.title, widget.isRtl),
                iconUrl:      v.iconUrl,
                isSelected:   i == idx,
                primaryColor: widget.primaryColor,
                width:        100.w,
                iconSize:     22.sp,
                fontSize:     9.sp,
                padding:      10.r,
                onTap: () => setState(() => _selectedIndex = i),
              );
            }),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanel(
            value:          selected,
            isRtl:          widget.isRtl,
            primaryColor:   widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET BODY  — mirrors about_page.dart _AboutBodyTablet exactly
// ═══════════════════════════════════════════════════════════════════════════════

class _PreviewTabletBody extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _PreviewTabletBody({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_PreviewTabletBody> createState() => _PreviewTabletBodyState();
}

class _PreviewTabletBodyState extends State<_PreviewTabletBody> {
  int _selectedTab = 0;

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية'  : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم'   : 'Values',
  };

  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ => widget.model.values.isNotEmpty
        ? widget.model.values.first.iconUrl
        : '',
  };

  @override
  Widget build(BuildContext context) {
    const double gap = 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final bool isLast = i == 2;
            return Expanded(
              child: Padding(
                padding:
                EdgeInsetsDirectional.only(end: isLast ? 0 : gap.w),
                child: _TabletTabItem(
                  label:          _tabLabel(i),
                  iconUrl:        _tabIconUrl(i),
                  isSelected:     _selectedTab == i,
                  primaryColor:   widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  onTap: () => setState(() => _selectedTab = i),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 14.h),
        _TabletContentPanel(
          model:          widget.model,
          tabIndex:       _selectedTab,
          isRtl:          widget.isRtl,
          primaryColor:   widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}

// ─── Tablet Tab Item ───────────────────────────────────────────────────────

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
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.primaryColor
                : (_hovered ? hoverBg : _kSurface),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: widget.isSelected
                  ? widget.primaryColor
                  : (_hovered
                  ? widget.primaryColor.withOpacity(0.3)
                  : _kDivider),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.iconUrl.isNotEmpty)
                _netImg(
                  url:         widget.iconUrl,
                  width:       16.sp,
                  height:      16.sp,
                  fit:         BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    widget.isSelected ? Colors.white : widget.primaryColor,
                    BlendMode.srcIn,
                  ),
                )
              else
                Icon(Icons.image_outlined,
                    size: 16.sp,
                    color: widget.isSelected
                        ? Colors.white
                        : widget.primaryColor),
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
                        : (_hovered
                        ? widget.primaryColor
                        : widget.primaryColor),
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

// ─── Tablet Content Panel ──────────────────────────────────────────────────

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
      return _ValuesGridTablet(
        values:         otherValues,
        isRtl:          isRtl,
        primaryColor:   primaryColor,
        secondaryColor: secondaryColor,
      );
    }
    final AboutSection section =
    tabIndex == 0 ? model.vision : model.mission;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
          color: _kSurface, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.svgUrl.isNotEmpty) ...[
            Center(
              child: _netImg(
                url:          section.svgUrl,
                width:        160.w,
                height:       160.h,
                fit:          BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Text(_ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400
                  .copyWith(fontSize: 11.sp, height: 1.75)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — TABLET  (mirrors about_page.dart _ValuesGridTablet)
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridTablet extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridTablet({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_ValuesGridTablet> createState() => _ValuesGridTabletState();
}

class _ValuesGridTabletState extends State<_ValuesGridTablet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
        child: Center(
          child: Text('No values added yet.',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: Colors.grey[500])),
        ),
      );
    }
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
                color: widget.secondaryColor,
                borderRadius: BorderRadius.circular(10.r)),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(widget.values.length, (i) {
                final v = widget.values[i];
                return _ValueGridCard(
                  title:        _ab(v.title, widget.isRtl),
                  iconUrl:      v.iconUrl,
                  isSelected:   i == idx,
                  primaryColor: widget.primaryColor,
                  width:        88.w,
                  iconSize:     18.sp,
                  fontSize:     8.sp,
                  padding:      9.r,
                  onTap: () => setState(() => _selectedIndex = i),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanel(
            value:          selected,
            isRtl:          widget.isRtl,
            primaryColor:   widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY  — mirrors about_page.dart _AboutBodyMobile exactly
// ═══════════════════════════════════════════════════════════════════════════════

class _PreviewMobileBody extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _PreviewMobileBody({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_PreviewMobileBody> createState() => _PreviewMobileBodyState();
}

class _PreviewMobileBodyState extends State<_PreviewMobileBody> {
  int _expanded = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _MobileTabData(
        label:    widget.isRtl ? 'الرؤية'  : 'Vision',
        iconUrl:  widget.model.vision.iconUrl,
        svgUrl:   widget.model.vision.svgUrl,
        fullText: _ab(widget.model.vision.description, widget.isRtl),
        tabIndex: 0,
      ),
      _MobileTabData(
        label:    widget.isRtl ? 'الرسالة' : 'Mission',
        iconUrl:  widget.model.mission.iconUrl,
        svgUrl:   widget.model.mission.svgUrl,
        fullText: _ab(widget.model.mission.description, widget.isRtl),
        tabIndex: 1,
      ),
      _MobileTabData(
        label: widget.isRtl ? 'القيم' : 'Values',
        iconUrl: widget.model.values.isNotEmpty
            ? widget.model.values.first.iconUrl
            : '',
        svgUrl:   '',
        fullText: '',
        tabIndex: 2,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14.h),
        ...tabs.map((tab) {
          final isOpen = _expanded == tab.tabIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _MobileAccordionItem(
              tab:          tab,
              values:       widget.model.values,
              isExpanded:   isOpen,
              isRtl:        widget.isRtl,
              primaryColor:   widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              onTap: () =>
                  setState(() => _expanded = isOpen ? -1 : tab.tabIndex),
            ),
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _MobileTabData {
  final String label, iconUrl, svgUrl, fullText;
  final int tabIndex;
  const _MobileTabData({
    required this.label,
    required this.iconUrl,
    required this.svgUrl,
    required this.fullText,
    required this.tabIndex,
  });
}

// ─── Mobile Accordion Item ─────────────────────────────────────────────────

class _MobileAccordionItem extends StatefulWidget {
  final _MobileTabData tab;
  final List<AboutValueItem> values;
  final bool isExpanded, isRtl;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _MobileAccordionItem({
    required this.tab,
    required this.values,
    required this.isExpanded,
    required this.onTap,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_MobileAccordionItem> createState() => _MobileAccordionItemState();
}

class _MobileAccordionItemState extends State<_MobileAccordionItem> {
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
            onExit:  (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:  38.w,
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
                        url:         widget.tab.iconUrl,
                        width:       18.sp,
                        height:      18.sp,
                        fit:         BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          widget.isExpanded
                              ? Colors.white
                              : widget.primaryColor,
                          BlendMode.srcIn,
                        ),
                      )
                          : Icon(Icons.image_outlined,
                          size: 16.sp,
                          color: widget.isExpanded
                              ? Colors.white
                              : AppColors.textButton),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.tab.label,
                      style: StyleText.fontSize16Weight600.copyWith(
                          fontSize: 12.sp, color: widget.primaryColor),
                    ),
                  ),
                  if (widget.isExpanded)
                    Container(
                      width:  26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: widget.primaryColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(Icons.keyboard_arrow_up_rounded,
                          color: Colors.white, size: 16.sp),
                    ),
                ]),
              ),
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tab.tabIndex != 2 &&
                      widget.tab.svgUrl.isNotEmpty) ...[
                    Center(
                      child: _netImg(
                        url:    widget.tab.svgUrl,
                        width:  MediaQuery.of(context).size.width -
                            16.w * 2 - 12.w * 2,
                        height: 150.h,
                        fit:    BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  if (widget.tab.tabIndex != 2)
                    Text(widget.tab.fullText,
                        style: StyleText.fontSize13Weight400
                            .copyWith(fontSize: 10.sp, height: 1.7)),
                  if (widget.tab.tabIndex == 2)
                    _ValuesGridMobile(
                      values:         gridValues,
                      isRtl:          widget.isRtl,
                      primaryColor:   widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — MOBILE  (mirrors about_page.dart _ValuesGridMobile)
// ═══════════════════════════════════════════════════════════════════════════════

class _ValuesGridMobile extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridMobile({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_ValuesGridMobile> createState() => _ValuesGridMobileState();
}

class _ValuesGridMobileState extends State<_ValuesGridMobile> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text('No values added yet.',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: Colors.grey[500])),
        ),
      );
    }
    final double innerW =
        MediaQuery.of(context).size.width - 16.w * 2 - 12.w * 2;
    final double gap   = 7.w;
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
            return _ValueGridCard(
              title:        _ab(v.title, widget.isRtl),
              iconUrl:      v.iconUrl,
              isSelected:   i == idx,
              primaryColor: widget.primaryColor,
              width:        cardW,
              iconSize:     16.sp,
              fontSize:     10.sp,
              padding:      9.r,
              rowLayout:    true,
              onTap: () => setState(() => _selectedIndex = i),
            );
          }),
        ),
        SizedBox(height: 10.h),
        _ValueDetailPanel(
          value:          selected,
          isRtl:          widget.isRtl,
          primaryColor:   widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUE GRID CARD — shared hover widget (mirrors about_page.dart)
// ═══════════════════════════════════════════════════════════════════════════════

class _ValueGridCard extends StatefulWidget {
  final String title, iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final double width, iconSize, fontSize, padding;
  final VoidCallback onTap;
  final bool rowLayout;
  const _ValueGridCard({
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
  State<_ValueGridCard> createState() => _ValueGridCardState();
}

class _ValueGridCardState extends State<_ValueGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    final Widget iconWidget = widget.iconUrl.isNotEmpty
        ? _netImg(
      url:         widget.iconUrl,
      width:       widget.iconSize,
      height:      widget.iconSize,
      fit:         BoxFit.contain,
      colorFilter: ColorFilter.mode(
        sel ? Colors.white : widget.primaryColor,
        BlendMode.srcIn,
      ),
    )
        : Icon(Icons.star_outline,
        size: widget.iconSize,
        color: sel ? Colors.white : widget.primaryColor);

    final Widget titleWidget = Text(
      widget.title,
      textAlign: widget.rowLayout ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w600,
        color: sel
            ? Colors.white
            : (_hovered ? widget.primaryColor : Colors.black87),
        height: 1.35,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:   widget.rowLayout ? null : widget.width,
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel ? widget.primaryColor : (_hovered ? hoverBg : Colors.white),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: sel
                ? [BoxShadow(
                color: widget.primaryColor.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4))]
                : [],
            border: Border.all(
              color: _hovered && !sel
                  ? widget.primaryColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.rowLayout
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            iconWidget,
            SizedBox(width: 6.w),
            Expanded(child: titleWidget),
          ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
            iconWidget,
            SizedBox(height: 6.h),
            titleWidget,
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL — mirrors about_page.dart _ValueDetailPanel
// ═══════════════════════════════════════════════════════════════════════════════

class _ValueDetailPanel extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValueDetailPanel({
    required this.value,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String title     = _ab(value.title, isRtl);
    final String shortDesc = _ab(value.shortDescription, isRtl);
    final String fullDesc  = _ab(value.description, isRtl);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: value.iconUrl.isNotEmpty
                  ? _netImg(
                url:         value.iconUrl,
                width:       30.r,
                height:      30.r,
                fit:         BoxFit.contain,
                colorFilter: ColorFilter.mode(
                    primaryColor, BlendMode.srcIn),
              )
                  : Icon(Icons.star_outline,
                  size: 20.sp, color: primaryColor),
            ),
          ),
          SizedBox(height: 10.h),
          if (title.isNotEmpty) ...[
            Text(title,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            SizedBox(height: 8.h),
          ],
          if (shortDesc.isNotEmpty) ...[
            Text(shortDesc,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryBlack,
                    height: 1.6)),
            SizedBox(height: 10.h),
          ],
          if (fullDesc.isNotEmpty)
            Text(fullDesc,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryBlack,
                    height: 1.65)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRM DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.r),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  80.w,
            height: 80.w,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(40.r)),
            child: Icon(Icons.edit_note,
                size: 40.sp, color: const Color(0xFFD16F9A)),
          ),
          SizedBox(height: 16.h),
          Text('EDITING ABOUT US DETAILS',
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight600
                  .copyWith(color: const Color(0xFF1A1A1A))),
          SizedBox(height: 8.h),
          Text(
            'Do you want to save the changes made to this About Us?',
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack),
          ),
          SizedBox(height: 20.h),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E9E9E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r))),
                  child: Text('Back',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD16F9A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r))),
                  child: Text('Confirm',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
          ]),
        ],
      ),
    ),
  );
}