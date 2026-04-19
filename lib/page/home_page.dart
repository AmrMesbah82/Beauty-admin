/// ******************* FILE INFO *******************
/// File Name: home_page.dart
/// Description: Public-facing Home Page for the Beauty App (Bayanatz).
///              ALL sections are CMS-driven via Firebase.
///              Hero → MasterCmsCubit root title/shortDescription + header section image/visibility.
///              About Us & Download App → MasterCmsCubit sections by key.
/// Created by: Claude for Amr Mesbah
/// Last Update: 12/04/2026
/// UPDATED: Applied identical XHR-cache loader + _RevealCoordinator + _Reveal animation
///          system from about_page.dart — UI/sections unchanged.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:beauty_admin/core/widget/format.dart';
import 'package:beauty_admin/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../controller/master/master_cubit.dart';
import '../controller/master/master_state.dart';
import '../model/master/master_model.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';

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
// XHR Image Cache  ← identical to about_page.dart
// ══════════════════════════════════════════════════════════════════════════════

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
  final header =
  String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

/// Identical network-image helper from about_page.dart
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
      if (snapshot.connectionState == ConnectionState.waiting) {
        return placeholder ?? SizedBox(width: width, height: height);
      }
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (hintSvg || _isSvgBytes(bytes)) {
          return SvgPicture.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            colorFilter: colorFilter,
          );
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      }
      return errorWidget ??
          Icon(Icons.broken_image,
              color: Colors.grey[400],
              size: (width ?? height ?? 24).toDouble());
    },
  );
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  return inner;
}

// ══════════════════════════════════════════════════════════════════════════════
// Preload helpers  ← identical to about_page.dart
// ══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadImages(List<String> urls) async {
  final valid = urls
      .where((u) =>
  u.isNotEmpty &&
      (u.startsWith('http://') || u.startsWith('https://')))
      .toSet();
  await Future.wait(
    valid.map((url) =>
        _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0))),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system  ← identical to about_page.dart
// ══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class _RevealCoordinator extends InheritedWidget {
  final _RevealCoordinatorState state;
  const _RevealCoordinator({required this.state, required super.child});
  static _RevealCoordinatorState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RevealCoordinator>()?.state;
  @override
  bool updateShouldNotify(_RevealCoordinator old) => false;
}

class _RevealCoordinatorWidget extends StatefulWidget {
  final Widget child;
  const _RevealCoordinatorWidget({required this.child});
  @override
  State<_RevealCoordinatorWidget> createState() => _RevealCoordinatorState();
}

class _RevealCoordinatorState extends State<_RevealCoordinatorWidget> {
  final List<_RevealState> _items = [];

  void register(_RevealState item) {
    _items.add(item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) item.onScroll();
      });
    });
  }

  void unregister(_RevealState item) => _items.remove(item);

  void notifyScroll() {
    for (final item in List.of(_items)) item.onScroll();
  }

  @override
  Widget build(BuildContext context) => _RevealCoordinator(
    state: this,
    child: NotificationListener<ScrollNotification>(
      onNotification: (_) {
        notifyScroll();
        return false;
      },
      child: widget.child,
    ),
  );
}

class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay, duration;
  final _SlideDirection direction;
  const _Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });
  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop => const Offset(0, -0.18),
      _SlideDirection.fromLeft => const Offset(-0.18, 0),
      _SlideDirection.fromRight => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () => _checkAndTrigger());
      Future.delayed(
          widget.delay + const Duration(milliseconds: 120),
              () => _checkAndTrigger());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _RevealCoordinator.of(context)?.register(this);
  }

  @override
  void dispose() {
    _RevealCoordinator.of(context)?.unregister(this);
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH - 40) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SVG Pulse Loader  ← identical to about_page.dart
// ══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color backgroundColor;
  const _SvgPulseLoader({this.logoUrl, required this.backgroundColor});
  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null)
      setState(() => _resolvedUrl = widget.logoUrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null)
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: _netImg(
            url: _resolvedUrl!,
            width: 88.w,
            height: 88.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOME PAGE ROOT
// ══════════════════════════════════════════════════════════════════════════════

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomePageView();
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();
  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  bool _showLoader = true;
  bool _preloadStarted = false;

  @override
  void initState() {
    super.initState();
    // Hard-cap the loader at 12 s — identical to about_page.dart
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required String headerImageUrl,
    required String aboutImageUrl,
    required String downloadImageUrl,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    final urls = [
      if (logoUrl.isNotEmpty) logoUrl,
      if (headerImageUrl.isNotEmpty) headerImageUrl,
      if (aboutImageUrl.isNotEmpty) aboutImageUrl,
      if (downloadImageUrl.isNotEmpty) downloadImageUrl,
    ];

    await _preloadImages(urls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLoader = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final homeData = switch (homeState) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data) => data,
          HomeCmsSaving(:final data) => data,
          HomeCmsError(:final lastData) => lastData,
          _ => null,
        };

        // ── Resolve branding colors (with fallbacks before data loads) ──
        final Color primaryColor = homeData != null
            ? _parseHex(homeData.branding.primaryColor,
            fallback: AppColors.primary)
            : AppColors.primary;

        final Color backgroundColor = homeData != null
            ? _parseHex(homeData.branding.backgroundColor,
            fallback: AppColors.background)
            : AppColors.background;

        final String logoUrl = homeData?.branding.logoUrl ?? '';

        // ── Show pulse loader until home data arrives ──
        if (homeData == null) {
          return _SvgPulseLoader(
            logoUrl: logoUrl.isEmpty ? null : logoUrl,
            backgroundColor: backgroundColor,
          );
        }

        return BlocBuilder<MasterCmsCubit, MasterCmsState>(
          builder: (context, masterState) {
            MasterPageModel? masterData;
            if (masterState is MasterCmsLoaded) {
              masterData = masterState.data;
            } else if (masterState is MasterCmsSaved) {
              masterData = masterState.data;
            }

            final bool masterReady =
                masterState is MasterCmsLoaded || masterState is MasterCmsError;

            // ── Still waiting for master — keep pulsing ──
            if (!masterReady && masterData == null) {
              return _SvgPulseLoader(
                logoUrl: logoUrl.isEmpty ? null : logoUrl,
                backgroundColor: backgroundColor,
              );
            }

            // ── Extract section URLs for preloading ──
            final headerSection = masterData?.sectionByKey('header');
            final aboutSection = masterData?.sectionByKey('aboutUs');
            final downloadSection = masterData?.sectionByKey('footer');

            final String headerImageUrl = headerSection?.imageUrl ?? '';
            final String aboutImageUrl = aboutSection?.imageUrl ?? '';
            final String downloadImageUrl = downloadSection?.imageUrl ?? '';

            // ── Kick off preload once we have all data ──
            if (!_preloadStarted) {
              _preloadAndReveal(
                logoUrl: logoUrl,
                headerImageUrl: headerImageUrl,
                aboutImageUrl: aboutImageUrl,
                downloadImageUrl: downloadImageUrl,
              );
            }

            // ── Keep showing pulse loader until preload finishes ──
            if (_showLoader) {
              return _SvgPulseLoader(
                logoUrl: logoUrl.isEmpty ? null : logoUrl,
                backgroundColor: backgroundColor,
              );
            }

            // ══════════════════════════════════════════════════════════
            // FULL PAGE — loader hidden, reveal animations take over
            // ══════════════════════════════════════════════════════════
            return BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, langState) {
                final bool isAr = langState.isArabic;

                // ── HERO: title/shortDescription from masterData ROOT ──
                final heroTitle = isAr
                    ? (masterData?.title.ar.isNotEmpty == true
                    ? masterData!.title.ar
                    : homeData.title.ar)
                    : (masterData?.title.en.isNotEmpty == true
                    ? masterData!.title.en
                    : homeData.title.en);

                final heroSubtitle = isAr
                    ? (masterData?.shortDescription.ar.isNotEmpty == true
                    ? masterData!.shortDescription.ar
                    : homeData.shortDescription.ar)
                    : (masterData?.shortDescription.en.isNotEmpty == true
                    ? masterData!.shortDescription.en
                    : homeData.shortDescription.en);

                // ── ABOUT US ──
                final aboutHeading = isAr
                    ? (aboutSection?.title.ar.isNotEmpty == true
                    ? aboutSection!.title.ar
                    : 'من نحن')
                    : (aboutSection?.title.en.isNotEmpty == true
                    ? aboutSection!.title.en
                    : 'About Us');

                final aboutBody = isAr
                    ? (aboutSection?.description.ar ?? '')
                    : (aboutSection?.description.en ?? '');

                // ── DOWNLOAD APP ──
                final downloadHeading = isAr
                    ? (downloadSection?.title.ar.isNotEmpty == true
                    ? downloadSection!.title.ar
                    : 'حمّل تطبيق Beauty الآن')
                    : (downloadSection?.title.en.isNotEmpty == true
                    ? downloadSection!.title.en
                    : 'Download Beauty App Now');

                final downloadBody = isAr
                    ? (downloadSection?.description.ar ?? '')
                    : (downloadSection?.description.en ?? '');

                return Directionality(
                  textDirection:
                  isAr ? TextDirection.rtl : TextDirection.ltr,
                  child: AppPageShell(
                    currentRoute: '/',
                    body: _RevealCoordinatorWidget(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ═══════════════════════════════════════════
                          // SECTION 1 — HERO
                          // ═══════════════════════════════════════════
                          if (headerSection?.visibility ?? true) ...[
                            _Reveal(
                              delay: const Duration(milliseconds: 60),
                              direction: _SlideDirection.fromBottom,
                              duration: const Duration(milliseconds: 650),
                              child: _HeroSection(
                                primaryColor: primaryColor,
                                title: heroTitle,
                                subtitle: heroSubtitle,
                                imageUrl: headerImageUrl,
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],

                          // ═══════════════════════════════════════════
                          // SECTION 2 — ABOUT US
                          // ═══════════════════════════════════════════
                          if (aboutSection?.visibility ?? true) ...[
                            _Reveal(
                              delay: const Duration(milliseconds: 120),
                              direction: _SlideDirection.fromLeft,
                              duration: const Duration(milliseconds: 650),
                              child: _AboutUsSection(
                                primaryColor: primaryColor,
                                heading: aboutHeading,
                                body: aboutBody,
                                readMoreLabel: isAr ? 'اقرأ المزيد' : 'Read More',
                                imageUrl: aboutImageUrl,
                                onReadMore: () {
                                  // TODO: navigate to about page
                                },
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],

                          // ═══════════════════════════════════════════
                          // SECTION 3 — DOWNLOAD APP
                          // ═══════════════════════════════════════════
                          if (downloadSection?.visibility ?? true) ...[
                            _Reveal(
                              delay: const Duration(milliseconds: 180),
                              direction: _SlideDirection.fromRight,
                              duration: const Duration(milliseconds: 650),
                              child: _DownloadAppSection(
                                primaryColor: primaryColor,
                                heading: downloadHeading,
                                body: downloadBody,
                                imageUrl: downloadImageUrl,
                                appStoreLink:
                                masterData?.appLinks.appStoreLink ?? '',
                                googlePlayLink:
                                masterData?.appLinks.googlePlayLink ?? '',
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — HERO
// ══════════════════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String subtitle;
  final String imageUrl;

  const _HeroSection({
    required this.primaryColor,
    required this.title,
    required this.subtitle,
    this.imageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildImage(320.h)),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 5,
                  child: _Reveal(
                    delay: const Duration(milliseconds: 100),
                    direction: _SlideDirection.fromRight,
                    child: _HeroText(
                      title: FormatHelper.capitalize(title),
                      subtitle: subtitle,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildImage(280.h),
              SizedBox(height: 24.h),
              _HeroText(
                title: FormatHelper.capitalize(title),
                subtitle: subtitle,
                primaryColor: primaryColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(double height) {
    if (imageUrl.isEmpty) {
      return _EmptyImagePlaceholder(
        height: height,
        color: primaryColor,
        label: 'Hero Image',
      );
    }
    return _netImg(
      url: imageUrl,
      height: height,
      fit: BoxFit.contain,
      errorWidget: _EmptyImagePlaceholder(
        height: height,
        color: primaryColor,
        label: 'Hero Image',
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color primaryColor;

  const _HeroText({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: AppTextStyles.font23BlackSemiBoldCairo,
        ),
        SizedBox(height: 12.h),
        Text(
          FormatHelper.capitalize(subtitle),
          style: AppTextStyles.font20BlackCairoMedium.copyWith(
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — ABOUT US
// ══════════════════════════════════════════════════════════════════════════════

class _AboutUsSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String readMoreLabel;
  final String imageUrl;
  final VoidCallback? onReadMore;

  const _AboutUsSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    required this.readMoreLabel,
    this.imageUrl = '',
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ──
          Text(
            FormatHelper.capitalize(heading),
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          // ── CMS Image ──
          if (imageUrl.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _netImg(
                url: imageUrl,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),

          // ── Body text ──
          if (body.isNotEmpty)
            Text(
              FormatHelper.capitalize(body),
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          SizedBox(height: 16.h),

          // ── Read More ──
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              onTap: onReadMore,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FormatHelper.capitalize(readMoreLabel),
                      style: AppTextStyles.font14BlackCairoMedium.copyWith(
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.15),
                      ),
                      child: Icon(Icons.arrow_forward,
                          size: 14.sp, color: primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — DOWNLOAD APP
// ══════════════════════════════════════════════════════════════════════════════

class _DownloadAppSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String imageUrl;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadAppSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    this.imageUrl = '',
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 4, child: _buildImage(320.h)),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 6,
                  child: _DownloadTextContent(
                    primaryColor: primaryColor,
                    heading: heading,
                    body: body,
                    appStoreLink: appStoreLink,
                    googlePlayLink: googlePlayLink,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildImage(280.h),
              SizedBox(height: 24.h),
              _DownloadTextContent(
                primaryColor: primaryColor,
                heading: heading,
                body: body,
                appStoreLink: appStoreLink,
                googlePlayLink: googlePlayLink,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(double height) {
    if (imageUrl.isEmpty) {
      return _EmptyImagePlaceholder(
        height: height,
        color: primaryColor,
        label: 'App Image',
      );
    }
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2.w,
        ),
        color: primaryColor.withOpacity(0.04),
      ),
      child: _netImg(
        url: imageUrl,
        height: height - 32.w,
        fit: BoxFit.contain,
        errorWidget: _EmptyImagePlaceholder(
          height: height - 32.w,
          color: primaryColor,
          label: 'App Image',
        ),
      ),
    );
  }
}

class _DownloadTextContent extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadTextContent({
    required this.primaryColor,
    required this.heading,
    required this.body,
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  void _launchUrl(String url) {
    if (url.isEmpty) return;
    // TODO: use url_launcher — launchUrl(Uri.parse(url))
    print('🟡 [DownloadSection] launch: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Heading ──
        Text(
          FormatHelper.capitalize(heading),
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 16.h),

        // ── Body text ──
        if (body.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              FormatHelper.capitalize(body),
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          ),

        // ── Store Badges ──
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            _StoreBadge(
              onTap: () => _launchUrl(googlePlayLink),
              svgAsset: 'assets/beauty/home/google_play.svg',
            ),
            _StoreBadge(
              onTap: () => _launchUrl(appStoreLink),
              svgAsset: 'assets/beauty/home/app_store.svg',
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Helper — empty image placeholder  (unchanged from original)
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyImagePlaceholder extends StatelessWidget {
  final double? width;
  final double height;
  final Color color;
  final String label;

  const _EmptyImagePlaceholder({
    this.width,
    required this.height,
    required this.color,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined,
                size: 40.sp, color: color.withOpacity(0.3)),
            if (label.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                label,
                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                  color: color.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STORE BADGE BUTTON  (unchanged from original)
// ══════════════════════════════════════════════════════════════════════════════

class _StoreBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final String svgAsset;

  const _StoreBadge({this.onTap, required this.svgAsset});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SvgPicture.asset(
          svgAsset,
          height: 42.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}