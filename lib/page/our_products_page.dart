/// ******************* FILE INFO *******************
/// File Name: our_products_page.dart
/// Description: "Our Products" page for the Beauty App (Bayanatz).
///              Two tabs: Client Service & Owner Service.
///              Client Service tab → ClientServicesCmsCubit (clientServicesPages collection).
///              Owner Service tab  → OwnerServicesCmsCubit  (ownerServicesPages collection).
///              Each tab renders: Header hero → Download bar → Mockups.
///              ALL data is DYNAMIC from Firebase. No static data in this file.
/// Created by: Amr Mesbah
/// Last Update: 12/04/2026
/// UPDATED: Applied identical XHR-cache loader + _SvgPulseLoader + _RevealCoordinator
///          + _Reveal animation system from about_page.dart — UI/sections unchanged.
/// UPDATED: Deep-link support — reads ?tab=client-service or ?tab=owner-service
///          from the URL on init so footer links open the correct tab directly.
///          _onTabSelected also updates the URL so the browser back-button works.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:beauty_admin/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../controller/client_services/client_services_cubit.dart';
import '../controller/client_services/client_services_state.dart';
import '../controller/owner_services/owner_services_cubit.dart';
import '../controller/owner_services/owner_services_state.dart';
import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../core/custom_segmant_tab.dart';
import '../model/client_services/client_services_model.dart';
import '../model/owner_services/owner_services_model.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TEXT FORMATTING HELPER
// ══════════════════════════════════════════════════════════════════════════════

List<String> abbreviation = [
  "it", "hr", 'utils ux', 'log', 'qa', 'pr', 'dev', 'ceo', "grc", "mena",
  "ksa", "uae", "coo", "cfo", "cdo", "cso", "cbo", "cmo", "cto", "cno",
  "cco", "chro", "cxo"
];

abstract class FormatHelper {
  static String capitalize(String input) {
    String processedInput = input.toLowerCase();
    processedInput = applyAbbreviation(processedInput);
    if (processedInput.isEmpty) return "";
    List<String> words = processedInput.split(" ");
    words = words.map((word) {
      if (word.isNotEmpty) return word[0].toUpperCase() + word.substring(1);
      return "";
    }).toList();
    return words.join(" ");
  }

  static String applyAbbreviation(String input) {
    String result = input;
    for (String abbr in abbreviation) {
      RegExp regex = RegExp(r'\b' + abbr + r'\b', caseSensitive: false);
      if (regex.hasMatch(result)) {
        result = result.replaceAllMapped(regex, (match) => abbr.toUpperCase());
      }
    }
    return result;
  }
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
// Preload helpers
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
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop    => const Offset(0, -0.18),
      _SlideDirection.fromLeft   => const Offset(-0.18, 0),
      _SlideDirection.fromRight  => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: begin, end: Offset.zero));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted && !_triggered) {
          _triggered = true;
          _ctrl.forward();
        }
      });
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
// TAB PARAM HELPERS
// ══════════════════════════════════════════════════════════════════════════════

/// Maps the ?tab= query-param value → tab index.
/// Accepts the values used in _kLabelDestinations in home_edit_page.dart.
int _tabIndexForParam(String tab) {
  switch (tab.toLowerCase().trim()) {
    case 'owner-service':
    case 'owner':
      return 1;
    case 'client-service':
    case 'client':
    default:
      return 0;
  }
}

/// Maps tab index → the canonical ?tab= query-param value.
String _tabParamForIndex(int index) =>
    index == 1 ? 'owner-service' : 'client-service';

// ══════════════════════════════════════════════════════════════════════════════
// OUR PRODUCTS PAGE ROOT
// ══════════════════════════════════════════════════════════════════════════════

class OurProductsPage extends StatefulWidget {
  const OurProductsPage({super.key});

  @override
  State<OurProductsPage> createState() => _OurProductsPageState();
}

class _OurProductsPageState extends State<OurProductsPage> {
  int _selectedTabIndex = 0;

  bool _showLoader    = true;
  bool _preloadStarted = false;
  int  _lastPreloadedTab = -1;

  @override
  void initState() {
    super.initState();

    // ── Default load for tab 0 so the page never sits blank ────────────────
    context.read<ClientServicesCmsCubit>().load(gender: 'female');

    // ── Read ?tab=... query param AFTER the first frame ─────────────────────
    // GoRouterState.of(context) requires the widget to be mounted first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uri   = GoRouterState.of(context).uri;
      final tab   = uri.queryParameters['tab'] ?? '';
      final index = _tabIndexForParam(tab);

      if (index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex  = index;
          _showLoader        = true;
          _preloadStarted    = false;
        });
        // Load the cubit for the resolved tab
        if (index == 1) {
          context.read<OwnerServicesCmsCubit>().load(gender: 'female');
        }
        // Re-arm hard-cap for new tab
        Future.delayed(const Duration(seconds: 12), () {
          if (mounted && _showLoader) setState(() => _showLoader = false);
        });
      }
    });

    // Hard-cap the initial loader at 12 s
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
  }

  // ── Tab switch: updates content AND URL ──────────────────────────────────
  void _onTabSelected(int index) {
    if (_selectedTabIndex == index) return;

    // Update URL so the browser back-button and footer links both work
    context.go('/about?tab=${_tabParamForIndex(index)}');

    setState(() {
      _selectedTabIndex  = index;
      _showLoader        = true;
      _preloadStarted    = false;
    });

    if (index == 0) {
      context.read<ClientServicesCmsCubit>().load(gender: 'female');
    } else {
      context.read<OwnerServicesCmsCubit>().load(gender: 'female');
    }

    // Re-arm the 12-second hard cap for the new tab
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
  }

  bool _isActiveTabReady(
      ClientServicesCmsState clientState,
      OwnerServicesCmsState ownerState,
      ) {
    if (_selectedTabIndex == 0) {
      return clientState is ClientServicesCmsLoaded ||
          clientState is ClientServicesCmsSaved;
    } else {
      return ownerState is OwnerServicesCmsLoaded ||
          ownerState is OwnerServicesCmsSaved;
    }
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required ClientServicesPageModel? clientData,
    required OwnerServicesPageModel? ownerData,
  }) async {
    if (_preloadStarted && _lastPreloadedTab == _selectedTabIndex) return;
    _preloadStarted    = true;
    _lastPreloadedTab  = _selectedTabIndex;

    final List<String> urls = [if (logoUrl.isNotEmpty) logoUrl];

    if (_selectedTabIndex == 0 && clientData != null) {
      if (clientData.header.svgUrl.isNotEmpty) urls.add(clientData.header.svgUrl);
      for (final m in clientData.mockups.items) {
        if (m.svgUrl.isNotEmpty) urls.add(m.svgUrl);
      }
    } else if (_selectedTabIndex == 1 && ownerData != null) {
      if (ownerData.header.imageUrl.isNotEmpty) urls.add(ownerData.header.imageUrl);
      for (final m in ownerData.mockups.items) {
        if (m.imageUrl.isNotEmpty) urls.add(m.imageUrl);
      }
    }

    await _preloadImages(urls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLoader = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        return BlocBuilder<ClientServicesCmsCubit, ClientServicesCmsState>(
          builder: (context, clientState) {
            return BlocBuilder<OwnerServicesCmsCubit, OwnerServicesCmsState>(
              builder: (context, ownerState) {

                // ── Extract home data ────────────────────────────────────
                final homeData = switch (homeState) {
                  HomeCmsLoaded(:final data)  => data,
                  HomeCmsSaved(:final data)   => data,
                  HomeCmsSaving(:final data)  => data,
                  HomeCmsError(:final lastData) => lastData,
                  _ => null,
                };

                // ── Resolve branding ─────────────────────────────────────
                final Color primaryColor = homeData != null
                    ? _parseHex(homeData.branding.primaryColor,
                    fallback: AppColors.primary)
                    : AppColors.primary;

                final Color backgroundColor = homeData != null
                    ? _parseHex(homeData.branding.backgroundColor,
                    fallback: AppColors.background)
                    : AppColors.background;

                final String logoUrl = homeData?.branding.logoUrl ?? '';

                // ── Phase 1: No home data ────────────────────────────────
                if (homeData == null) {
                  return _SvgPulseLoader(
                    logoUrl: logoUrl.isEmpty ? null : logoUrl,
                    backgroundColor: AppColors.background,
                  );
                }

                // ── Phase 2: Active tab still loading ────────────────────
                if (!_isActiveTabReady(clientState, ownerState)) {
                  return _SvgPulseLoader(
                    logoUrl: logoUrl.isEmpty ? null : logoUrl,
                    backgroundColor: backgroundColor,
                  );
                }

                // ── Extract model data for preload ───────────────────────
                final ClientServicesPageModel? clientData = switch (clientState) {
                  ClientServicesCmsLoaded(:final data) => data,
                  ClientServicesCmsSaved(:final data)  => data,
                  _ => null,
                };
                final OwnerServicesPageModel? ownerData = switch (ownerState) {
                  OwnerServicesCmsLoaded(:final data) => data,
                  OwnerServicesCmsSaved(:final data)  => data,
                  _ => null,
                };

                // ── Kick off preload once active tab data is ready ───────
                if (!_preloadStarted || _lastPreloadedTab != _selectedTabIndex) {
                  _preloadAndReveal(
                    logoUrl: logoUrl,
                    clientData: clientData,
                    ownerData: ownerData,
                  );
                }

                // ── Keep pulsing until preload finishes ──────────────────
                if (_showLoader) {
                  return _SvgPulseLoader(
                    logoUrl: logoUrl.isEmpty ? null : logoUrl,
                    backgroundColor: backgroundColor,
                  );
                }

                // ════════════════════════════════════════════════════════
                // ✅ EVERYTHING READY — reveal animations take over
                // ════════════════════════════════════════════════════════
                return BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, langState) {
                    final bool isAr = langState.isArabic;

                    return Directionality(
                      textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                      child: AppPageShell(
                        currentRoute: '/about',
                        body: _RevealCoordinatorWidget(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 24.h),

                              // ── SEGMENTED TABS ──────────────────────────
                              _Reveal(
                                delay: const Duration(milliseconds: 60),
                                direction: _SlideDirection.fromTop,
                                duration: const Duration(milliseconds: 600),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                                  child: Center(
                                    child: SizedBox(
                                      width: 400.w,
                                      child: CustomSegmentedTabs(
                                        tabs: isAr
                                            ? ['خدمة العميل', 'خدمة المالك']
                                            : ['Client Service', 'Owner Service'],
                                        selectedIndex: _selectedTabIndex,
                                        onTabSelected: _onTabSelected,
                                        selectedColor: primaryColor,
                                        equalWidth: true,
                                        spacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 30.h),

                              // ── CONTENT ─────────────────────────────────
                              if (_selectedTabIndex == 0)
                                _ClientServiceTab(
                                  key: const ValueKey('client_tab'),
                                  primaryColor: primaryColor,
                                  isAr: isAr,
                                )
                              else
                                _OwnerServiceTab(
                                  key: const ValueKey('owner_tab'),
                                  primaryColor: primaryColor,
                                  isAr: isAr,
                                ),

                              SizedBox(height: 20.h),
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
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT SERVICE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ClientServiceTab extends StatelessWidget {
  final Color primaryColor;
  final bool isAr;

  const _ClientServiceTab({
    super.key,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientServicesCmsCubit, ClientServicesCmsState>(
      builder: (context, state) {
        if (state is ClientServicesCmsError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 40.w),
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.font14BlackCairoRegular
                    .copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = switch (state) {
          ClientServicesCmsLoaded(:final data) => data,
          ClientServicesCmsSaved(:final data)  => data,
          _ => context.read<ClientServicesCmsCubit>().current,
        };

        final mockups = data.mockups.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header hero
            _Reveal(
              delay: const Duration(milliseconds: 80),
              direction: _SlideDirection.fromBottom,
              duration: const Duration(milliseconds: 650),
              child: _ClientHeaderHero(
                header: data.header,
                primaryColor: primaryColor,
                isAr: isAr,
              ),
            ),

            SizedBox(height: 20.h),

            // Download bar
            _Reveal(
              delay: const Duration(milliseconds: 140),
              direction: _SlideDirection.fromLeft,
              duration: const Duration(milliseconds: 650),
              child: _DownloadNowBar(
                primaryColor: primaryColor,
                label: isAr
                    ? (data.download.title.ar.isNotEmpty
                    ? data.download.title.ar
                    : 'حمّل الآن')
                    : (data.download.title.en.isNotEmpty
                    ? data.download.title.en
                    : 'Download Now'),
                appStoreLink: data.download.appStoreLink,
                googlePlayLink: data.download.googlePlayLink,
              ),
            ),

            SizedBox(height: 30.h),

            // Mockup sections — staggered Reveal per item
            ...List.generate(mockups.length, (i) {
              final direction = i.isEven
                  ? _SlideDirection.fromLeft
                  : _SlideDirection.fromRight;
              return _Reveal(
                key: ValueKey('client_mockup_$i'),
                delay: Duration(milliseconds: 200 + i * 80),
                direction: direction,
                duration: const Duration(milliseconds: 650),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: _ClientMockupSectionWidget(
                    item: mockups[i],
                    primaryColor: primaryColor,
                    isAr: isAr,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OWNER SERVICE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _OwnerServiceTab extends StatelessWidget {
  final Color primaryColor;
  final bool isAr;

  const _OwnerServiceTab({
    super.key,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      builder: (context, state) {
        if (state is OwnerServicesCmsError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 40.w),
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.font14BlackCairoRegular
                    .copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = switch (state) {
          OwnerServicesCmsLoaded(:final data) => data,
          OwnerServicesCmsSaved(:final data)  => data,
          _ => context.read<OwnerServicesCmsCubit>().current,
        };

        final mockups = data.mockups.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header hero
            _Reveal(
              delay: const Duration(milliseconds: 80),
              direction: _SlideDirection.fromBottom,
              duration: const Duration(milliseconds: 650),
              child: _OwnerHeaderHero(
                header: data.header,
                primaryColor: primaryColor,
                isAr: isAr,
              ),
            ),

            SizedBox(height: 20.h),

            // Download bar
            _Reveal(
              delay: const Duration(milliseconds: 140),
              direction: _SlideDirection.fromRight,
              duration: const Duration(milliseconds: 650),
              child: _DownloadNowBar(
                primaryColor: primaryColor,
                label: isAr
                    ? (data.download.title.ar.isNotEmpty
                    ? data.download.title.ar
                    : 'حمّل الآن')
                    : (data.download.title.en.isNotEmpty
                    ? data.download.title.en
                    : 'Download Now'),
                appStoreLink: data.download.appStoreLink,
                googlePlayLink: data.download.googlePlayLink,
              ),
            ),

            SizedBox(height: 30.h),

            // Mockup sections — staggered Reveal per item
            ...List.generate(mockups.length, (i) {
              final direction = i.isEven
                  ? _SlideDirection.fromRight
                  : _SlideDirection.fromLeft;
              return _Reveal(
                key: ValueKey('owner_mockup_$i'),
                delay: Duration(milliseconds: 200 + i * 80),
                direction: direction,
                duration: const Duration(milliseconds: 650),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: _OwnerMockupSectionWidget(
                    item: mockups[i],
                    primaryColor: primaryColor,
                    isAr: isAr,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT HEADER HERO
// ══════════════════════════════════════════════════════════════════════════════

class _ClientHeaderHero extends StatelessWidget {
  final ClientServicesHeaderModel header;
  final Color primaryColor;
  final bool isAr;

  const _ClientHeaderHero({
    required this.header,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final rawTitle = isAr
        ? (header.title.ar.isNotEmpty ? header.title.ar : header.title.en)
        : (header.title.en.isNotEmpty ? header.title.en : header.title.ar);
    final title = FormatHelper.capitalize(rawTitle);
    final desc = isAr
        ? (header.description.ar.isNotEmpty
        ? header.description.ar
        : header.description.en)
        : (header.description.en.isNotEmpty
        ? header.description.en
        : header.description.ar);
    final hasImage = header.svgUrl.isNotEmpty;

    if (title.isEmpty && desc.isEmpty && !hasImage) return const SizedBox.shrink();

    final imageWidget = hasImage
        ? _netImg(
      url: header.svgUrl,
      height: 220.h,
      fit: BoxFit.contain,
      placeholder: SizedBox(height: 220.h),
      errorWidget: SizedBox(height: 220.h),
    )
        : null;

    final textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Text(title,
              style: AppTextStyles.font20BlackCairoSemiBold
                  .copyWith(color: primaryColor, fontSize: 28.sp)),
        if (desc.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Text(desc,
              style: AppTextStyles.font14BlackCairoRegular
                  .copyWith(height: 1.7, color: AppColors.secondaryBlack)),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          if (isWide && imageWidget != null) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textWidget),
                SizedBox(width: 30.w),
                Expanded(flex: 4, child: imageWidget),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageWidget != null) ...[
                Center(child: imageWidget),
                SizedBox(height: 16.h),
              ],
              textWidget,
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OWNER HEADER HERO
// ══════════════════════════════════════════════════════════════════════════════

class _OwnerHeaderHero extends StatelessWidget {
  final OwnerServicesHeaderModel header;
  final Color primaryColor;
  final bool isAr;

  const _OwnerHeaderHero({
    required this.header,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final rawTitle = isAr
        ? (header.title.ar.isNotEmpty ? header.title.ar : header.title.en)
        : (header.title.en.isNotEmpty ? header.title.en : header.title.ar);
    final title = FormatHelper.capitalize(rawTitle);
    final desc = isAr
        ? (header.description.ar.isNotEmpty
        ? header.description.ar
        : header.description.en)
        : (header.description.en.isNotEmpty
        ? header.description.en
        : header.description.ar);
    final hasImage = header.imageUrl.isNotEmpty;

    if (title.isEmpty && desc.isEmpty && !hasImage) return const SizedBox.shrink();

    final imageWidget = hasImage
        ? _netImg(
      url: header.imageUrl,
      height: 220.h,
      fit: BoxFit.contain,
      placeholder: SizedBox(height: 220.h),
      errorWidget: SizedBox(height: 220.h),
    )
        : null;

    final textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Text(title,
              style: AppTextStyles.font20BlackCairoSemiBold
                  .copyWith(color: primaryColor, fontSize: 28.sp)),
        if (desc.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Text(desc,
              style: AppTextStyles.font14BlackCairoRegular
                  .copyWith(height: 1.7, color: AppColors.secondaryBlack)),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          if (isWide && imageWidget != null) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textWidget),
                SizedBox(width: 30.w),
                Expanded(flex: 4, child: imageWidget),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageWidget != null) ...[
                Center(child: imageWidget),
                SizedBox(height: 16.h),
              ],
              textWidget,
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT MOCKUP SECTION WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class _ClientMockupSectionWidget extends StatelessWidget {
  final ClientServicesMockupItemModel item;
  final Color primaryColor;
  final bool isAr;

  const _ClientMockupSectionWidget({
    required this.item,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final rawTitle = isAr
        ? (item.title.ar.isNotEmpty ? item.title.ar : item.title.en)
        : (item.title.en.isNotEmpty ? item.title.en : item.title.ar);
    final title = FormatHelper.capitalize(rawTitle);
    final body = isAr
        ? (item.description.ar.isNotEmpty
        ? item.description.ar
        : item.description.en)
        : (item.description.en.isNotEmpty
        ? item.description.en
        : item.description.ar);

    final imageWidget = item.svgUrl.isNotEmpty
        ? _netImg(
      url: item.svgUrl,
      height: 280.h,
      fit: BoxFit.contain,
      placeholder: SizedBox(height: 280.h),
      errorWidget: SizedBox(
        height: 280.h,
        child: Center(
          child: Icon(Icons.image_outlined,
              size: 60.r,
              color: AppColors.secondaryBlack.withOpacity(0.3)),
        ),
      ),
    )
        : SizedBox(
      height: 280.h,
      child: Center(
        child: Icon(Icons.image_outlined,
            size: 60.r,
            color: AppColors.secondaryBlack.withOpacity(0.3)),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          switch (item.layout) {
            case MockupLayout.centered:
              return _CenterLayout(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor);
            case MockupLayout.right:
              return isWide
                  ? _SideBySideLayout(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor, imageOnLeft: false)
                  : _StackedFallback(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor);
            case MockupLayout.left:
              return isWide
                  ? _SideBySideLayout(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor, imageOnLeft: true)
                  : _StackedFallback(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor);
          }
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OWNER MOCKUP SECTION WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class _OwnerMockupSectionWidget extends StatelessWidget {
  final OwnerServicesMockupItemModel item;
  final Color primaryColor;
  final bool isAr;

  const _OwnerMockupSectionWidget({
    required this.item,
    required this.primaryColor,
    required this.isAr,
  });

  _MockupAlign get _align {
    switch (item.alignment) {
      case 'centered': return _MockupAlign.centered;
      case 'right':    return _MockupAlign.right;
      case 'left':
      default:         return _MockupAlign.left;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawTitle = isAr
        ? (item.title.ar.isNotEmpty ? item.title.ar : item.title.en)
        : (item.title.en.isNotEmpty ? item.title.en : item.title.ar);
    final title = FormatHelper.capitalize(rawTitle);
    final body = isAr
        ? (item.description.ar.isNotEmpty
        ? item.description.ar
        : item.description.en)
        : (item.description.en.isNotEmpty
        ? item.description.en
        : item.description.ar);

    final imageWidget = item.imageUrl.isNotEmpty
        ? _netImg(
      url: item.imageUrl,
      height: 280.h,
      fit: BoxFit.contain,
      placeholder: SizedBox(height: 280.h),
      errorWidget: SizedBox(
        height: 280.h,
        child: Center(
          child: Icon(Icons.image_outlined,
              size: 60.r,
              color: AppColors.secondaryBlack.withOpacity(0.3)),
        ),
      ),
    )
        : SizedBox(
      height: 280.h,
      child: Center(
        child: Icon(Icons.image_outlined,
            size: 60.r,
            color: AppColors.secondaryBlack.withOpacity(0.3)),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          switch (_align) {
            case _MockupAlign.centered:
              return _CenterLayout(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor);
            case _MockupAlign.right:
              return isWide
                  ? _SideBySideLayout(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor, imageOnLeft: false)
                  : _StackedFallback(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor);
            case _MockupAlign.left:
              return isWide
                  ? _SideBySideLayout(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor, imageOnLeft: true)
                  : _StackedFallback(
                  title: title, body: body, imageWidget: imageWidget,
                  primaryColor: primaryColor);
          }
        },
      ),
    );
  }
}

enum _MockupAlign { left, centered, right }

// ══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD NOW BAR
// ══════════════════════════════════════════════════════════════════════════════

class _DownloadNowBar extends StatelessWidget {
  final Color primaryColor;
  final String label;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadNowBar({
    required this.primaryColor,
    required this.label,
    required this.appStoreLink,
    required this.googlePlayLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(color: primaryColor)),
          const Spacer(),
          Wrap(
            spacing: 10.w,
            children: [
              _MiniStoreBadge(
                svgAsset: 'assets/beauty/home/google_play.svg',
                onTap: googlePlayLink.isNotEmpty ? () {} : null,
              ),
              _MiniStoreBadge(
                svgAsset: 'assets/beauty/home/app_store.svg',
                onTap: appStoreLink.isNotEmpty ? () {} : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStoreBadge extends StatelessWidget {
  final String svgAsset;
  final VoidCallback? onTap;

  const _MiniStoreBadge({required this.svgAsset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: SvgPicture.asset(svgAsset, height: 36.h, fit: BoxFit.contain),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LAYOUT WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _CenterLayout extends StatelessWidget {
  final String title;
  final String body;
  final Widget imageWidget;
  final Color primaryColor;

  const _CenterLayout({
    required this.title,
    required this.body,
    required this.imageWidget,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        imageWidget,
        SizedBox(height: 20.h),
        Text(title,
            style: AppTextStyles.font20BlackCairoSemiBold,
            textAlign: TextAlign.center),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(body,
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                  height: 1.7, color: AppColors.secondaryBlack),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _SideBySideLayout extends StatelessWidget {
  final String title;
  final String body;
  final Widget imageWidget;
  final Color primaryColor;
  final bool imageOnLeft;

  const _SideBySideLayout({
    required this.title,
    required this.body,
    required this.imageWidget,
    required this.primaryColor,
    required this.imageOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: AppTextStyles.font20BlackCairoSemiBold
                .copyWith(color: primaryColor)),
        SizedBox(height: 12.h),
        Text(body,
            style: AppTextStyles.font14BlackCairoRegular
                .copyWith(height: 1.7, color: AppColors.secondaryBlack)),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: imageOnLeft
          ? [
        Expanded(flex: 4, child: imageWidget),
        SizedBox(width: 30.w),
        Expanded(flex: 6, child: textWidget),
      ]
          : [
        Expanded(flex: 6, child: textWidget),
        SizedBox(width: 30.w),
        Expanded(flex: 4, child: imageWidget),
      ],
    );
  }
}

class _StackedFallback extends StatelessWidget {
  final String title;
  final String body;
  final Widget imageWidget;
  final Color primaryColor;

  const _StackedFallback({
    required this.title,
    required this.body,
    required this.imageWidget,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: imageWidget),
        SizedBox(height: 16.h),
        Text(title,
            style: AppTextStyles.font20BlackCairoSemiBold
                .copyWith(color: primaryColor)),
        SizedBox(height: 12.h),
        Text(body,
            style: AppTextStyles.font14BlackCairoRegular
                .copyWith(height: 1.7, color: AppColors.secondaryBlack)),
      ],
    );
  }
}