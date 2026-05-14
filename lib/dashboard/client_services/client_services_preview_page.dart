/// ******************* FILE INFO *******************
/// File Name: client_services_preview_page.dart
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
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/client_services/client_services_cubit.dart';
import '../../controller/client_services/client_services_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/client_services/client_services_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color back = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFFFF0F5);
  static const Color downloadBg = Color(0xFFF5F5F5);
}

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
class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final ClientServicesPageModel model;
  final bool isEnglish;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final scale = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(
        color: _C.back,
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
  final ClientServicesPageModel model;
  final bool isEnglish;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
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
  final ClientServicesPageModel model;
  final bool isEnglish;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
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
                          isEnglish: isEnglish,
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
// PREVIEW CONTENT (renders actual client services sections)
// ═════════════════════════════════════════════════════════════════════════════
class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final ClientServicesPageModel model;
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
  Widget build(BuildContext context) {
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
                _buildHeader(),
                const SizedBox(height: 30),
                _buildDownloadBar(),
                const SizedBox(height: 30),
                ..._buildMockups(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: renders an image URL (remote SVG or base64 data-URL) ──────────
  Widget _buildImage({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final ph = placeholder ??
        Container(
          width: width,
          height: height,
          color: _C.primary.withOpacity(0.12),
          child: Icon(Icons.image_outlined,
              color: _C.primary.withOpacity(0.4), size: 36),
        );

    if (url.isEmpty) return ph;

    if (url.startsWith('data:')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => ph,
      );
    }

    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => ph,
    );
  }

  // ── Header section ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    final header = model.header;
    final title = isEnglish ? header.title.en : header.title.ar;
    final desc = isEnglish ? header.description.en : header.description.ar;
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final hasImage = header.svgUrl.isNotEmpty;

    final imageWidget = hasImage
        ? _buildImage(
      url: header.svgUrl,
      width: fakeWidth * 0.35,
      height: 200,
      fit: BoxFit.contain,
    )
        : null;

    final textWidget = Column(
      crossAxisAlignment:
      isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          title.isNotEmpty ? title : 'Our Services',
          textDirection: dir,
          style: TextStyle(
            color: _C.primary,
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          desc.isNotEmpty
              ? desc
              : 'Beauty App provides you with many salons and services to meet your needs.',
          textDirection: dir,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: _C.labelText,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      color: _C.sectionBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600 && !isMobile;
          if (isWide && hasImage) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textWidget),
                SizedBox(width: 20.w),
                Expanded(flex: 4, child: imageWidget!),
              ],
            );
          }
          return Column(
            children: [
              if (hasImage) ...[
                Center(child: imageWidget!),
                SizedBox(height: 16.h),
              ],
              textWidget,
            ],
          );
        },
      ),
    );
  }

  // ── Download bar ─────────────────────────────────────────────────────────
  Widget _buildDownloadBar() {
    final download = model.download;
    final title = isEnglish ? download.title.en : download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (isEnglish
        ? 'At Beauty, you will find luxury services.'
        : 'ستجد لدينا أفضل الخدمات.');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _C.downloadBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500 && !isMobile;
          if (isWide) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.labelText,
                    ),
                  ),
                ),
                _storeBadge(
                  label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                  image: "assets/google play.svg",
                ),
                SizedBox(width: 10.w),
                _storeBadge(
                  label: isEnglish ? 'App Store' : 'آب ستور',
                  image: "assets/app_store.svg",
                ),
              ],
            );
          }
          return Column(
            children: [
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _C.labelText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _storeBadge(
                    label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                    image: "assets/google play.svg",
                  ),
                  _storeBadge(
                    label: isEnglish ? 'App Store' : 'آب ستور',
                    image: "assets/app_store.svg",
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Mockups list ─────────────────────────────────────────────────────────
  List<Widget> _buildMockups() {
    final mockups = model.mockups.items;
    return mockups.map((item) => _buildMockupItem(item)).toList();
  }

  Widget _buildMockupItem(ClientServicesMockupItemModel item) {
    final title = isEnglish ? item.title.en : item.title.ar;
    final desc = isEnglish ? item.description.en : item.description.ar;
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;

    final imageWidget = item.svgUrl.isNotEmpty
        ? _buildImage(
      url: item.svgUrl,
      width: fakeWidth * 0.4,
      height: isMobile ? 200 : 280,
      fit: BoxFit.contain,
    )
        : Container(
      height: isMobile ? 200 : 280,
      width: double.infinity,
      color: _C.downloadBg,
      child: Center(
        child: Icon(
          Icons.phone_iphone,
          size: isMobile ? 40 : 60,
          color: _C.primary.withOpacity(0.4),
        ),
      ),
    );

    final textWidget = Column(
      crossAxisAlignment:
      isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.isNotEmpty ? title : 'Section Title',
          textDirection: dir,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: _C.labelText,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          desc.isNotEmpty ? desc : 'Description text here…',
          textDirection: dir,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: _C.labelText,
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0, vertical: 16.h),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 500 && !isMobile;

          switch (item.layout) {
            case MockupLayout.centered:
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    imageWidget,
                    SizedBox(height: 20.h),
                    textWidget,
                  ],
                ),
              );

            case MockupLayout.left:
              if (!isWide) {
                return Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      imageWidget,
                      SizedBox(height: 20.h),
                      textWidget,
                    ],
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: textWidget),
                    SizedBox(width: 20.w),
                    Expanded(flex: 4, child: imageWidget),
                  ],
                ),
              );

            case MockupLayout.right:
              if (!isWide) {
                return Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      imageWidget,
                      SizedBox(height: 20.h),
                      textWidget,
                    ],
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 4, child: imageWidget),
                    SizedBox(width: 20.w),
                    Expanded(flex: 6, child: textWidget),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _storeBadge({required String label, required String image}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvg(assetPath: image),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GET IT ON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 6.sp : 7.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 8.sp : 10.sp,
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