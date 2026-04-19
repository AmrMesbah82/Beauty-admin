// ******************* FILE INFO *******************
// File Name: about_page.dart
// Contains: Tab 0 (About Us) and Tab 1 (Our Strategy)
// UPDATED: Split from original about_page.dart — UI unchanged
// UPDATED: Added headings SVG hero banner display from model.svgUrl
// UPDATED: Fixed Row layout — SVG + title now render side by side correctly

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
    case 'our-strategy':
      return (topTab: 1, subTab: 0);
    case 'vision':
      return (topTab: 0, subTab: 0);
    case 'mission':
      return (topTab: 0, subTab: 1);
    case 'values':
      return (topTab: 0, subTab: 2);
    case 'our-team':
    case 'why-join-our-team':
    case 'about-us':
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
})
{
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

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AboutCubit()..load()),
        BlocProvider(create: (_) => StrategyCubit()..load()),
      ],
      child: const _AboutPageView(),
    );
  }
}

class _AboutPageView extends StatefulWidget {
  const _AboutPageView();
  @override
  State<_AboutPageView> createState() => _AboutPageViewState();
}

class _AboutPageViewState extends State<_AboutPageView> {
  bool _showLoader = true, _preloadStarted = false;
  int? _initialTopTab, _initialSubTab;
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
        if (_initialTopTab != resolved.topTab ||
            _initialSubTab != resolved.subTab) {
          setState(() {
            _initialTopTab = resolved.topTab;
            _initialSubTab = resolved.subTab;
            _tabParamApplied = false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required AboutPageModel model,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;
    final urls = [
      if (logoUrl.isNotEmpty) logoUrl,
      if (model.svgUrl.isNotEmpty) model.svgUrl,
      if (model.vision.iconUrl.isNotEmpty) model.vision.iconUrl,
      if (model.vision.svgUrl.isNotEmpty) model.vision.svgUrl,
      if (model.mission.iconUrl.isNotEmpty) model.mission.iconUrl,
      if (model.mission.svgUrl.isNotEmpty) model.mission.svgUrl,
      for (final v in model.values)
        if (v.iconUrl.isNotEmpty) v.iconUrl,
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

        return BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            final AboutPageModel? model = switch (state) {
              AboutLoaded() => state.data,
              AboutSaved() => state.data,
              _ => null,
            };
            final bool aboutReady = model != null,
                isError = state is AboutError,
                allReady = homeReady && aboutReady;
            if (allReady && !_preloadStarted)
              _preloadAndReveal(logoUrl: logoUrl, model: model!);
            if (isError && !aboutReady)
              return Scaffold(
                backgroundColor: backgroundColor,
                body: Center(
                  child: Text(
                    'Failed to load: ${(state as AboutError).message}',
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
                  textDirection:
                  isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Scaffold(
                    backgroundColor: backgroundColor,
                    body: _RevealCoordinatorWidget(
                      child: Column(
                        children: [
                          // ✅ Navbar — always visible at top
                          Material(
                            color: backgroundColor,
                            elevation: 0,
                            child: AppNavbar(currentRoute: '/contact'),
                          ),

                          // ✅ Middle content — scrolls, takes all remaining space
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ✅ FIXED: SVG illustration + Title in same Row
                                  // SVG gets a fixed width; title takes remaining space via Expanded
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [

                                      SizedBox(width: 220.w),


                                      // Left: illustration SVG
                                      if (model!.svgUrl.isNotEmpty)
                                        _Reveal(
                                          delay: const Duration(
                                              milliseconds: 60),
                                          direction: _SlideDirection.fromTop,
                                          duration: const Duration(
                                              milliseconds: 600),
                                          child: w < _BP.mobile
                                              ? _HeadingsSvgMobile(
                                              svgUrl: model.svgUrl)
                                              : _HeadingsSvgDesktop(
                                              svgUrl: model.svgUrl),
                                        ),

                                      // Right: page title — must be Expanded to avoid overflow
                                      Expanded(
                                        child: _Reveal(
                                          delay: const Duration(
                                              milliseconds: 80),
                                          direction:
                                          _SlideDirection.fromLeft,
                                          duration: const Duration(
                                              milliseconds: 650),
                                          child: w < _BP.mobile
                                              ? _AboutHeaderMobile(
                                            model: model,
                                            isRtl: isRtl,
                                            primaryColor: primaryColor,
                                          )
                                              : _AboutHeaderDesktop(
                                            model: model,
                                            isRtl: isRtl,
                                            primaryColor: primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  w < _BP.mobile
                                      ? _AboutBodyMobile(
                                    model: model,
                                    isRtl: isRtl,
                                    primaryColor: primaryColor,
                                    secondaryColor: secondaryColor,
                                    initialTopTab: _tabParamApplied
                                        ? null
                                        : _initialTopTab,
                                    initialSubTab: _tabParamApplied
                                        ? null
                                        : _initialSubTab,
                                    onTabApplied: () =>
                                    _tabParamApplied = true,
                                  )
                                      : _AboutBodyDesktop(
                                    model: model,
                                    isRtl: isRtl,
                                    primaryColor: primaryColor,
                                    secondaryColor: secondaryColor,
                                    initialTopTab: _tabParamApplied
                                        ? null
                                        : _initialTopTab,
                                    initialSubTab: _tabParamApplied
                                        ? null
                                        : _initialSubTab,
                                    onTabApplied: () =>
                                    _tabParamApplied = true,
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
// ✅ FIXED: Headings SVG Hero Banner — Desktop
// Uses a fixed width so it behaves correctly inside a Row
// ══════════════════════════════════════════════════════════════════════════════

class _HeadingsSvgDesktop extends StatelessWidget {
  final String svgUrl;
  const _HeadingsSvgDesktop({required this.svgUrl});

  @override
  Widget build(BuildContext context) {
    return _netImg(
      url: svgUrl,
      width: 340.w,  // fixed width — mirrors the Figma ~344px illustration
      height: 280.h,
      fit: BoxFit.contain,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ✅ FIXED: Headings SVG Hero Banner — Mobile
// Uses a fixed width so it behaves correctly inside a Row
// ══════════════════════════════════════════════════════════════════════════════

class _HeadingsSvgMobile extends StatelessWidget {
  final String svgUrl;
  const _HeadingsSvgMobile({required this.svgUrl});

  @override
  Widget build(BuildContext context) {
    return _netImg(
      url: svgUrl,
      width: 160.w,  // fixed width for mobile
      height: 160.h,
      fit: BoxFit.contain,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Headers
// ══════════════════════════════════════════════════════════════════════════════

class _AboutHeaderDesktop extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderDesktop({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
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

class _AboutHeaderMobile extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderMobile({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
// DESKTOP BODY — Only Tab 0 (About Us) and Tab 1 (Our Strategy)
// ══════════════════════════════════════════════════════════════════════════════

class _AboutBodyDesktop extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialTopTab, initialSubTab;
  final VoidCallback? onTabApplied;
  const _AboutBodyDesktop({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialTopTab,
    this.initialSubTab,
    this.onTabApplied,
  });
  @override
  State<_AboutBodyDesktop> createState() => _AboutBodyDesktopState();
}

class _AboutBodyDesktopState extends State<_AboutBodyDesktop> {
  late int _selectedTab, _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    _selectedTab = widget.initialSubTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية' : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم' : 'Values',
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

  // Only 2 top tabs: About Us & Our Strategy
  final List<BiText> _topTabs = [
    BiText(ar: 'من نحن', en: 'About Us'),
    BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity),
        gap = 16.w,
        leftW = 280.w;

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
                  0 => widget.model.navigationLabel.iconUrl,
                  _ => switch (context.read<StrategyCubit>().state) {
                    StrategyLoaded(:final data) => data.navigationLabel.iconUrl,
                    StrategySaved(:final data) => data.navigationLabel.iconUrl,
                    _ => '',
                  },
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

          // ── Tab 0: About Us ──
          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: leftW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (i) {
                          final bool isLast = i == 2;
                          return _Reveal(
                            key: ValueKey('top_0_tab_$i'),
                            delay: Duration(milliseconds: 120 + i * 80),
                            direction: _SlideDirection.fromLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: isLast ? 0 : 8.h,
                              ),
                              child: _DesktopTabItem(
                                label: _tabLabel(i),
                                iconUrl: _tabIconUrl(i),
                                selectedDesc: _selectedTab == i
                                    ? _tabDesc(i)
                                    : '',
                                isSelected: _selectedTab == i,
                                primaryColor: widget.primaryColor,
                                secondaryColor: widget.secondaryColor,
                                onTap: () => setState(() => _selectedTab = i),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _Reveal(
                        key: const ValueKey('top_0_right'),
                        delay: const Duration(milliseconds: 180),
                        direction: _SlideDirection.fromRight,
                        child: _DesktopRightPanel(
                          model: widget.model,
                          tabIndex: _selectedTab,
                          isRtl: widget.isRtl,
                          primaryColor: widget.primaryColor,
                          secondaryColor: widget.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Tab 1: Our Strategy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: BlocBuilder<StrategyCubit, StrategyState>(
                builder: (context, strategyState) {
                  final String svgUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.vision.svgUrl,
                    StrategySaved(:final data) => data.vision.svgUrl,
                    _ => '',
                  };
                  final String strategicHouseEnUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.strategicHouseEnUrl,
                    StrategySaved(:final data) => data.strategicHouseEnUrl,
                    _ => '',
                  };
                  final String strategicHouseArUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.strategicHouseArUrl,
                    StrategySaved(:final data) => data.strategicHouseArUrl,
                    _ => '',
                  };

                  return BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, langState) {
                      final bool isRtl = langState.isArabic;
                      final String strategicHouseUrl =
                      isRtl ? strategicHouseArUrl : strategicHouseEnUrl;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (svgUrl.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: _netImg(
                                  url: svgUrl,
                                  width: 300.w,
                                  height: 300.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                          SizedBox(height: 24.h),

                          if (strategicHouseUrl.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRtl
                                      ? 'البيت الاستراتيجي'
                                      : 'Strategic House',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: widget.primaryColor,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(0.r),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(
                                    child: _netImg(
                                      url: strategicHouseUrl,
                                      width: double.infinity,
                                      height: 640.h,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (svgUrl.isEmpty && strategicHouseUrl.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Text(
                                  isRtl ? 'لا يوجد محتوى بعد' : 'No content yet',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
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
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel
                      ? widget.primaryColor
                      : AppColors.secondaryBlack,
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
// Desktop Tab Item (with hover) ✅
// ══════════════════════════════════════════════════════════════════════════════

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
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
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

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Right Panel
// ══════════════════════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL
// ══════════════════════════════════════════════════════════════════════════════

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
    final String title = _ab(value.title, isRtl),
        shortDesc = _ab(value.shortDescription, isRtl),
        fullDesc = _ab(value.description, isRtl);
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
                colorFilter: ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
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

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — DESKTOP (with hover) ✅
// ══════════════════════════════════════════════════════════════════════════════

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
    if (widget.values.isEmpty)
      return Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10.r),
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
              final sel = i == idx;
              return _ValueGridCard(
                title: _ab(v.title, widget.isRtl),
                iconUrl: v.iconUrl,
                isSelected: sel,
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
          _ValueDetailPanel(
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

// ══════════════════════════════════════════════════════════════════════════════
// Value Grid Card — shared hover widget ✅
// ══════════════════════════════════════════════════════════════════════════════

class _ValueGridCard extends StatefulWidget {
  final String title;
  final String iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final double width;
  final double iconSize;
  final double fontSize;
  final double padding;
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
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.rowLayout ? null : widget.width,
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel
                ? widget.primaryColor
                : (_hovered ? hoverBg : Colors.white),
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
              color: _hovered && !sel
                  ? widget.primaryColor.withOpacity(0.3)
                  : Colors.transparent,
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

// ══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY — Only Tab 0 (About Us) and Tab 1 (Our Strategy)
// ══════════════════════════════════════════════════════════════════════════════

class _AboutBodyMobile extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialTopTab, initialSubTab;
  final VoidCallback? onTabApplied;
  const _AboutBodyMobile({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialTopTab,
    this.initialSubTab,
    this.onTabApplied,
  });
  @override
  State<_AboutBodyMobile> createState() => _AboutBodyMobileState();
}

class _AboutBodyMobileState extends State<_AboutBodyMobile> {
  late int _selectedTopTab;
  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  // Only 2 top tabs: About Us & Our Strategy
  final List<BiText> _topTabs = [
    BiText(ar: 'من نحن', en: 'About Us'),
    BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
  ];
  @override
  Widget build(BuildContext context) {

    final String aboutIconUrl = widget.model.navigationLabel.iconUrl;
    final String strategyIconUrl = switch (context.read<StrategyCubit>().state) {
      StrategyLoaded(:final data) => data.navigationLabel.iconUrl,
      StrategySaved(:final data) => data.navigationLabel.iconUrl,
      _ => '',
    };
    final List<String> svgAssets = [aboutIconUrl, strategyIconUrl];

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
                  svgAsset: svgAssets[i],
                  isSelected: i == _selectedTopTab,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('mob_top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileAboutUsContent(
                model: widget.model,
                isRtl: widget.isRtl,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
                initialExpanded: widget.initialSubTab,
              ),
            ),

          // ── Tab 1: Our Strategy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('mob_top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: BlocBuilder<StrategyCubit, StrategyState>(
                builder: (context, strategyState) {
                  final String svgUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.vision.svgUrl,
                    StrategySaved(:final data) => data.vision.svgUrl,
                    _ => '',
                  };
                  final String strategicHouseEnUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.strategicHouseEnUrl,
                    StrategySaved(:final data) => data.strategicHouseEnUrl,
                    _ => '',
                  };
                  final String strategicHouseArUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.strategicHouseArUrl,
                    StrategySaved(:final data) => data.strategicHouseArUrl,
                    _ => '',
                  };

                  return BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, langState) {
                      final bool isRtl = langState.isArabic;
                      final String strategicHouseUrl =
                      isRtl ? strategicHouseArUrl : strategicHouseEnUrl;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (svgUrl.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: _netImg(
                                  url: svgUrl,
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                          SizedBox(height: 16.h),

                          if (strategicHouseUrl.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRtl
                                      ? 'البيت الاستراتيجي'
                                      : 'Strategic House',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: widget.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: _kSurface,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(
                                    child: _netImg(
                                      url: strategicHouseUrl,
                                      width: double.infinity,
                                      height: 180.h,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (svgUrl.isEmpty && strategicHouseUrl.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Text(
                                  isRtl
                                      ? 'لا يوجد محتوى بعد'
                                      : 'No content yet',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
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
                  color: sel ? widget.primaryColor : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: widget.svgAsset.isNotEmpty
                      ? _netImg(
                    url: widget.svgAsset,
                    width: 26.sp,
                    height: 26.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : Icon(
                    Icons.image_outlined,
                    size: 26.sp,
                    color: sel ? Colors.white : widget.primaryColor,
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

// ── Mobile About Us Content ──

class _MobileAboutUsContent extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialExpanded;
  const _MobileAboutUsContent({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialExpanded,
  });
  @override
  State<_MobileAboutUsContent> createState() => _MobileAboutUsContentState();
}

class _MobileAboutUsContentState extends State<_MobileAboutUsContent> {
  late int _expanded;
  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded ?? 0;
  }

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية' : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم' : 'Values',
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
    final tabs = [
      _MobileTabData(
        label: _tabLabel(0),
        iconUrl: _tabIconUrl(0),
        svgUrl: widget.model.vision.svgUrl,
        fullText: _ab(widget.model.vision.description, widget.isRtl),
        tabIndex: 0,
      ),
      _MobileTabData(
        label: _tabLabel(1),
        iconUrl: _tabIconUrl(1),
        svgUrl: widget.model.mission.svgUrl,
        fullText: _ab(widget.model.mission.description, widget.isRtl),
        tabIndex: 1,
      ),
      _MobileTabData(
        label: _tabLabel(2),
        iconUrl: _tabIconUrl(2),
        svgUrl: '',
        fullText: '',
        tabIndex: 2,
      ),
    ];
    return Column(
      children: tabs.map((tab) {
        final bool isOpen = _expanded == tab.tabIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _MobileAccordionItem(
            tab: tab,
            values: widget.model.values,
            isExpanded: isOpen,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            onTap: () =>
                setState(() => _expanded = isOpen ? -1 : tab.tabIndex),
          ),
        );
      }).toList(),
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

// ══════════════════════════════════════════════════════════════════════════════
// Mobile Accordion Item (with hover) ✅
// ══════════════════════════════════════════════════════════════════════════════

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
        : (widget.tab.tabIndex == 2
        ? <AboutValueItem>[]
        : widget.values);

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
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                            widget.isExpanded
                                ? Colors.white
                                : widget.primaryColor,
                            BlendMode.srcIn,
                          ),
                        )
                            : Icon(
                          Icons.image_outlined,
                          size: 16.sp,
                          color: widget.isExpanded
                              ? Colors.white
                              : AppColors.textButton,
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
                    if (widget.isExpanded)
                      Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white,
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
                  if (widget.tab.tabIndex != 2 &&
                      widget.tab.svgUrl.isNotEmpty) ...[
                    Center(
                      child: _netImg(
                        url: widget.tab.svgUrl,
                        width: MediaQuery.of(context).size.width -
                            16.w * 2 -
                            12.w * 2,
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
                    _ValuesGridMobile(
                      values: gridValues,
                      isRtl: widget.isRtl,
                      primaryColor: widget.primaryColor,
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

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — MOBILE (with hover) ✅
// ══════════════════════════════════════════════════════════════════════════════

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
    if (widget.values.isEmpty)
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
    final double innerW =
        MediaQuery.of(context).size.width - 16.w * 2 - 12.w * 2,
        gap = 7.w,
        cardW = (innerW - gap) / 2;
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
            final sel = i == idx;
            return _ValueGridCard(
              title: _ab(v.title, widget.isRtl),
              iconUrl: v.iconUrl,
              isSelected: sel,
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
        _ValueDetailPanel(
          value: selected,
          isRtl: widget.isRtl,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
      ],
    );
  }
}