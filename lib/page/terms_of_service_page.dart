// ******************* FILE INFO *******************
// File Name: terms_of_service_page.dart
// Contains: Tab 0 (Terms and Conditions) and Tab 1 (Privacy Policy)
// UPDATED: Split from original about_page.dart — UI unchanged

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:beauty_admin/controller/home/home_cubit.dart';
import 'package:beauty_admin/controller/home/home_state.dart';
import 'package:beauty_admin/controller/home/lang_state.dart';
import 'package:beauty_admin/model/about_us/about_us.dart';
import 'package:beauty_admin/model/home/home_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import '../theme/appcolors.dart';
import '../theme/text.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../controller/about_us/about_us_cubit.dart';
import '../controller/about_us/about_us_state.dart';

const Color _kDefaultGreen = Color(0xFFD16F9A);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Hover tint matching navbar: primary.withOpacity(0.12)
Color _hoverTint(Color primary) => primary.withOpacity(0.12);

double _desktopContentWidth(BuildContext context) {
  final double screen = MediaQuery.of(context).size.width;
  final double natural = (248.w * 4) + (8.w * 3);
  return natural.clamp(0.0, screen - 64.0);
}

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

({int topTab, int subTab}) _resolveTabParam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'terms-and-conditions':
      return (topTab: 0, subTab: 0);
    case 'privacy-policy':
      return (topTab: 1, subTab: 0);
    default:
      return (topTab: 0, subTab: 0);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR Image Cache
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
          Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: (width ?? height ?? 24).toDouble(),
          );
    },
  );
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  return inner;
}

// ══════════════════════════════════════════════════════════════════════════════
// Preload helpers
// ══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadImages(List<String> urls) async {
  final valid = urls
      .where(
        (u) =>
    u.isNotEmpty &&
        (u.startsWith('http://') || u.startsWith('https://')),
  )
      .toSet();
  await Future.wait(
    valid.map(
          (url) =>
          _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
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
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop => const Offset(0, -0.18),
      _SlideDirection.fromLeft => const Offset(-0.18, 0),
      _SlideDirection.fromRight => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () => _checkAndTrigger());
      Future.delayed(
        widget.delay + const Duration(milliseconds: 120),
            () => _checkAndTrigger(),
      );
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
// SVG Pulse Loader
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
    _opacity = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
// PAGE ROOT
// ══════════════════════════════════════════════════════════════════════════════

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TermsCubit()..load()),
      ],
      child: const _TermsOfServicePageView(),
    );
  }
}

class _TermsOfServicePageView extends StatefulWidget {
  const _TermsOfServicePageView();
  @override
  State<_TermsOfServicePageView> createState() => _TermsOfServicePageViewState();
}

class _TermsOfServicePageViewState extends State<_TermsOfServicePageView> {
  bool _showLoader = true, _preloadStarted = false;
  int? _initialTopTab;
  bool _tabParamApplied = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
      _readTabParam();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readTabParam();
  }

  void _readTabParam() {
    if (!mounted) return;
    try {
      final uri = GoRouterState.of(context).uri;
      final tabParam = uri.queryParameters['tab'];
      if (tabParam != null && tabParam.isNotEmpty) {
        final resolved = _resolveTabParam(tabParam);
        if (_initialTopTab != resolved.topTab) {
          setState(() {
            _initialTopTab = resolved.topTab;
            _tabParamApplied = false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _preloadAndReveal({required String logoUrl}) async {
    if (_preloadStarted) return;
    _preloadStarted = true;
    final urls = [
      if (logoUrl.isNotEmpty) logoUrl,
    ];
    await _preloadImages(urls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLoader = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final String logoUrl = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data) => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };
        final Color primaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.primaryColor,
            fallback: _kDefaultGreen,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.primaryColor,
            fallback: _kDefaultGreen,
          ),
          _ => _kDefaultGreen,
        };
        final Color secondaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.secondaryColor,
            fallback: _kGreenLight,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.secondaryColor,
            fallback: _kGreenLight,
          ),
          _ => _kGreenLight,
        };
        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          _ => AppColors.background,
        };
        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        if (homeState is HomeCmsError &&
            homeState.lastData == null &&
            _showLoader) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showLoader = false);
          });
        }

        return BlocBuilder<TermsCubit, TermsState>(
          builder: (context, termsState) {
            final TermsOfServiceModel? termsModel = switch (termsState) {
              TermsLoaded() => termsState.data,
              TermsSaved() => termsState.data,
              _ => null,
            };
            final bool termsReady = termsModel != null,
                isError = termsState is TermsError,
                allReady = homeReady && termsReady;
            if (allReady && !_preloadStarted)
              _preloadAndReveal(logoUrl: logoUrl);
            if (isError && !termsReady)
              return Scaffold(
                backgroundColor: backgroundColor,
                body: Center(
                  child: Text(
                    'Failed to load: ${(termsState as TermsError).message}',
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            final Color loaderBg = switch (homeState) {
              HomeCmsLoaded(:final data) => _parseColor(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              HomeCmsSaved(:final data) => _parseColor(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              _ => _kLoaderNeutral,
            };
            if (_showLoader || !allReady)
              return _SvgPulseLoader(
                logoUrl: logoUrl.isEmpty ? null : logoUrl,
                backgroundColor: loaderBg,
              );

            return BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, langState) {
                final bool isRtl = langState.isArabic;
                final double w = MediaQuery.of(context).size.width;
                return Directionality(
                  textDirection: isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Scaffold(
                    backgroundColor: backgroundColor,
                    body: _RevealCoordinatorWidget(
                      child: Column(
                        children: [
                          // ✅ Navbar — always visible at top
                          Material(
                            color: backgroundColor,
                            elevation: 0,
                            child: AppNavbar(currentRoute: '/terms'),
                          ),

                          // ✅ Middle content — scrolls, takes all remaining space
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _Reveal(
                                    delay: const Duration(milliseconds: 80),
                                    direction: _SlideDirection.fromLeft,
                                    duration: const Duration(milliseconds: 650),
                                    child: w < _BP.mobile
                                        ? _TermsHeaderMobile(
                                      isRtl: isRtl,
                                      primaryColor: primaryColor,
                                    )
                                        : _TermsHeaderDesktop(
                                      isRtl: isRtl,
                                      primaryColor: primaryColor,
                                    ),
                                  ),
                                  w < _BP.mobile
                                      ? _TermsBodyMobile(
                                    termsModel: termsModel!,
                                    isRtl: isRtl,
                                    primaryColor: primaryColor,
                                    secondaryColor: secondaryColor,
                                    logoUrl: logoUrl,
                                    initialTopTab: _tabParamApplied ? null : _initialTopTab,
                                    onTabApplied: () => _tabParamApplied = true,
                                  )
                                      : _TermsBodyDesktop(
                                    termsModel: termsModel!,
                                    isRtl: isRtl,
                                    primaryColor: primaryColor,
                                    secondaryColor: secondaryColor,
                                    logoUrl: logoUrl,
                                    initialTopTab: _tabParamApplied ? null : _initialTopTab,
                                    onTabApplied: () => _tabParamApplied = true,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ✅ Footer — always visible at bottom
                          _Reveal(
                            delay: const Duration(milliseconds: 100),
                            direction: _SlideDirection.fromBottom,
                            duration: const Duration(milliseconds: 600),
                            child: const AppFooter(),
                          ),
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
// Headers
// ══════════════════════════════════════════════════════════════════════════════

class _TermsHeaderDesktop extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  const _TermsHeaderDesktop({
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity);
    final String title = isRtl ? 'الشروط والخدمة' : 'Terms of Service';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36.h),
      child: Text(
        title,
        style: StyleText.fontSize45Weight600.copyWith(
          fontSize: 48.sp,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      ),
    );
  }
}

class _TermsHeaderMobile extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  const _TermsHeaderMobile({
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final String title = isRtl ? 'الشروط والخدمة' : 'Terms of Service';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Text(
        title,
        style: StyleText.fontSize45Weight600.copyWith(
          fontSize: 28.sp,
          fontWeight: FontWeight.w900,
          color: primaryColor,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY — Tab 0 (Terms and Conditions) and Tab 1 (Privacy Policy)
// ══════════════════════════════════════════════════════════════════════════════

class _TermsBodyDesktop extends StatefulWidget {
  final TermsOfServiceModel termsModel;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final String logoUrl;
  final int? initialTopTab;
  final VoidCallback? onTabApplied;
  const _TermsBodyDesktop({
    required this.termsModel,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoUrl,
    this.initialTopTab,
    this.onTabApplied,
  });
  @override
  State<_TermsBodyDesktop> createState() => _TermsBodyDesktopState();
}

class _TermsBodyDesktopState extends State<_TermsBodyDesktop> {
  late int _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  Widget _downloadButton(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvg(
              assetPath: "assets/download.svg",
              width: 12.h,
              height: 16.h,
              fit: BoxFit.scaleDown,
              color: widget.primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: widget.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop doc panel — matches Figma layout:
  /// Row: [White card (logo+date header + text)] | [SVG image]
  /// Download buttons below
  Widget _docPanel({
    required String description,
    required String svgUrl,
    required String attachEnUrl,
    required String attachArUrl,
    required String labelEn,
    required String labelAr,
    required String lastUpdate,
  }) {
    final String logoUrl = widget.logoUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: full column (white card + download buttons) ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── White card ──
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo (left) + Date (right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (logoUrl.isNotEmpty)
                          _netImg(
                            url: logoUrl,
                            width: 80.w,
                            height: 40.h,
                            fit: BoxFit.contain,
                          )
                        else
                          const SizedBox.shrink(),
                        if (lastUpdate.isNotEmpty)
                          Text(
                            lastUpdate,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryBlack.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      description,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 13.sp,
                        height: 1.75,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Download buttons below the card ──
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _downloadButton(labelEn, attachEnUrl),
                  _downloadButton(labelAr, attachArUrl),
                ],
              ),
            ],
          ),
        ),

        // // ── Right: SVG beside the ENTIRE left column (card + buttons) ──
        // if (svgUrl.isNotEmpty) ...[
        //   SizedBox(width: 16.w),
        //   Padding(
        //     padding: EdgeInsets.only(top: 0),
        //     child: _netImg(
        //       url: svgUrl,
        //       width: 200.w,
        //       height: 200.h,
        //       fit: BoxFit.contain,
        //       borderRadius: BorderRadius.circular(10.r),
        //     ),
        //   ),
        // ],
      ],
    );
  }

  // Only 2 top tabs: Terms and Conditions & Privacy Policy
  final List<BiText> _topTabs = [
    BiText(ar: 'الشروط والأحكام', en: 'Terms and Conditions'),
    BiText(ar: 'سياسة الخصوصية', en: 'Privacy Policy'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity);
    final TermsSection terms = widget.termsModel.termsAndConditions,
        privacy = widget.termsModel.privacyPolicy;

    // Last update label — use model field if available, else fallback
    final String termsLastUpdate = widget.isRtl
        ? 'آخر تحديث: ${terms.lastUpdate ?? ''}'
        : 'Last Update: ${terms.lastUpdate ?? ''}';
    final String privacyLastUpdate = widget.isRtl
        ? 'آخر تحديث: ${privacy.lastUpdate ?? ''}'
        : 'Last Update: ${privacy.lastUpdate ?? ''}';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Tab Bar ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_topTabs.length, (i) {
                final bool isRtl = context.read<LanguageCubit>().state.isArabic;
                final String label = isRtl
                    ? (_topTabs[i].ar.isNotEmpty
                    ? _topTabs[i].ar
                    : _topTabs[i].en)
                    : _topTabs[i].en;
                final String svgAsset = switch (i) {
                  0 => terms.svgUrl,
                  _ => privacy.svgUrl,
                };
                return _DesktopTopTabItem(
                  index: i,
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: i == _selectedTopTab,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Tab 0: Terms and Conditions ──
          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _docPanel(
                description: _ab(terms.description, widget.isRtl),
                svgUrl: terms.svgUrl,
                attachEnUrl: terms.attachEnUrl,
                attachArUrl: terms.attachArUrl,
                labelEn: 'Download PDF of Terms and Conditions (ENG)',
                labelAr: 'Download PDF of Terms and Conditions (ARB)',
                lastUpdate: termsLastUpdate,
              ),
            ),

          // ── Tab 1: Privacy Policy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _docPanel(
                description: _ab(privacy.description, widget.isRtl),
                svgUrl: privacy.svgUrl,
                attachEnUrl: privacy.attachEnUrl,
                attachArUrl: privacy.attachArUrl,
                labelEn: 'Download PDF of Privacy Policy (ENG)',
                labelAr: 'Download PDF of Privacy Policy (ARB)',
                lastUpdate: privacyLastUpdate,
              ),
            ),

          SizedBox(height: 36.h),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Top Tab Item (with hover) ✅
// ══════════════════════════════════════════════════════════════════════════════

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
    final Color hoverBg = _hoverTint(widget.primaryColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 8.h,
          ),
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
                  color: sel
                      ? widget.primaryColor
                      : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: _netImg(
                    url: widget.svgAsset,
                    width: 24.sp,
                    height: 24.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel
                      ? widget.primaryColor
                      : (_hovered
                      ? AppColors.secondaryBlack
                      : AppColors.secondaryBlack
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

// ══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY — Tab 0 (Terms and Conditions) and Tab 1 (Privacy Policy)
// ══════════════════════════════════════════════════════════════════════════════

class _TermsBodyMobile extends StatefulWidget {
  final TermsOfServiceModel termsModel;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final String logoUrl;
  final int? initialTopTab;
  final VoidCallback? onTabApplied;
  const _TermsBodyMobile({
    required this.termsModel,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoUrl,
    this.initialTopTab,
    this.onTabApplied,
  });
  @override
  State<_TermsBodyMobile> createState() => _TermsBodyMobileState();
}

class _TermsBodyMobileState extends State<_TermsBodyMobile> {
  late int _selectedTopTab;
  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  // Only 2 top tabs: Terms and Conditions & Privacy Policy
  final List<BiText> _topTabs = [
    BiText(ar: 'الشروط والأحكام', en: 'Terms and Conditions'),
    BiText(ar: 'سياسة الخصوصية', en: 'Privacy Policy'),
  ];
  final List<String> _svgAssets = [
    'assets/images/about_us/Terms and Conditions.svg',
    'assets/images/about_us/Privacy Policy.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final TermsSection terms = widget.termsModel.termsAndConditions,
        privacy = widget.termsModel.privacyPolicy;

    final String termsLastUpdate = widget.isRtl
        ? 'آخر تحديث: ${terms.lastUpdate ?? ''}'
        : 'Last Update: ${terms.lastUpdate ?? ''}';
    final String privacyLastUpdate = widget.isRtl
        ? 'آخر تحديث: ${privacy.lastUpdate ?? ''}'
        : 'Last Update: ${privacy.lastUpdate ?? ''}';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_topTabs.length, (i) {
                return _MobileTopTabItem(
                  label: widget.isRtl
                      ? (_topTabs[i].ar.isNotEmpty
                      ? _topTabs[i].ar
                      : _topTabs[i].en)
                      : _topTabs[i].en,
                  svgAsset: _svgAssets[i],
                  isSelected: i == _selectedTopTab,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Tab 0: Terms and Conditions ──
          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('mob_top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileDocPanel(
                description: _ab(terms.description, widget.isRtl),
                svgUrl: terms.svgUrl,
                attachEnUrl: terms.attachEnUrl,
                attachArUrl: terms.attachArUrl,
                labelEn: 'Download PDF of Terms and Conditions (ENG)',
                labelAr: 'Download PDF of Terms and Conditions (ARB)',
                primaryColor: widget.primaryColor,
                logoUrl: widget.logoUrl,
                lastUpdate: termsLastUpdate,
              ),
            ),

          // ── Tab 1: Privacy Policy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('mob_top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileDocPanel(
                description: _ab(privacy.description, widget.isRtl),
                svgUrl: privacy.svgUrl,
                attachEnUrl: privacy.attachEnUrl,
                attachArUrl: privacy.attachArUrl,
                labelEn: 'Download PDF of Privacy Policy (ENG)',
                labelAr: 'Download PDF of Privacy Policy (ARB)',
                primaryColor: widget.primaryColor,
                logoUrl: widget.logoUrl,
                lastUpdate: privacyLastUpdate,
              ),
            ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mobile Top Tab Item (with hover) ✅
// ══════════════════════════════════════════════════════════════════════════════

class _MobileTopTabItem extends StatefulWidget {
  final String label;
  final String svgAsset;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _MobileTopTabItem({
    required this.label,
    required this.svgAsset,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });
  @override
  State<_MobileTopTabItem> createState() => _MobileTopTabItemState();
}

class _MobileTopTabItemState extends State<_MobileTopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: sel
                ? Colors.transparent
                : (_hovered ? hoverBg : Colors.transparent),
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
                width: 48.sp,
                height: 48.sp,
                decoration: BoxDecoration(
                  color: sel
                      ? widget.primaryColor
                      : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    widget.svgAsset,
                    width: 26.sp,
                    height: 26.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                widget.label,
                style: StyleText.fontSize20Weight600.copyWith(
                  color: sel
                      ? widget.primaryColor
                      : (_hovered
                      ? widget.primaryColor
                      : AppColors.secondaryBlack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mobile Doc Panel — Figma layout:
//   • SVG image on top (full width)
//   • White card: logo (left) + date (right) header, then text only
//   • Download buttons below
// ══════════════════════════════════════════════════════════════════════════════

class _MobileDocPanel extends StatelessWidget {
  final String description, svgUrl, attachEnUrl, attachArUrl, labelEn, labelAr;
  final Color primaryColor;
  final String logoUrl;
  final String lastUpdate;

  const _MobileDocPanel({
    required this.description,
    required this.svgUrl,
    required this.attachEnUrl,
    required this.attachArUrl,
    required this.labelEn,
    required this.labelAr,
    required this.primaryColor,
    required this.logoUrl,
    required this.lastUpdate,
  });

  Widget _downloadBtn(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSvg(
                assetPath: "assets/download.svg",
                width: 18.w,
                height: 18.h,
                fit: BoxFit.scaleDown,
                color: primaryColor,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SVG image on top (full width) ──
        if (svgUrl.isNotEmpty) ...[
          Center(
            child: _netImg(
              url: svgUrl,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 14.h),
        ],

        // ── White card: logo+date header + text only ──
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo (left) + Date (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (logoUrl.isNotEmpty)
                      _netImg(
                        url: logoUrl,
                        width: 70.w,
                        height: 34.h,
                        fit: BoxFit.contain,
                      )
                    else
                      const SizedBox.shrink(),
                    if (lastUpdate.isNotEmpty)
                      Flexible(
                        child: Text(
                          lastUpdate,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryBlack.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Description text only
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryBlack,
                    height: 1.75,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Download buttons ──
        _downloadBtn(labelEn, attachEnUrl),
        _downloadBtn(labelAr, attachArUrl),
        SizedBox(height: 8.h),
      ],
    );
  }
}