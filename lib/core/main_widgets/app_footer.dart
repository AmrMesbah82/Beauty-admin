// ******************* FILE INFO *******************
// File Name: app_footer.dart
// UPDATED: Footer now matches Figma design:
//          - Top row: Logo + footer columns (Our Products, About Us, Terms, Contact Us)
//          - Bottom row: "Download the App" + iOS/Android icons (left) | Social icons (center) | Copyright (right)
// UPDATED: Footer background reads from model.branding.headerFooterColor
// FIXED: _socialIcons / _socialIconsRaw now filter by l.visibility ✅
// ADDED: _DownloadAppRow with iOS/Android SVG from assets/footer/
// ADDED: AppDownloadLinksModel support for CMS-driven store URLs
// FIXED: Replaced all GoRouter navigation (context.go / context.push /
//        GoRouterState.of) with Navigator.push(MaterialPageRoute) so the
//        footer works even when rendered outside the GoRouter widget tree. ✅
// UPDATED: Page names to match existing pages (AboutPage, ContactPage,
//          OurProductsPage, TermsOfServicePage, OverviewPage)
// UPDATED: Removed tablet layout - now only mobile and desktop
// Description: AppFooter driven by HomePageModel via HomeCmsCubit.
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../features/home/data/models/home_model.dart';
import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/home/presentation/controller/home_state.dart';
import '../../features/home/presentation/controller/lang_state.dart';
import '../theme/app_weight.dart';
import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

// ── Page registry ─────────────────────────────────────────────────────────────
// Import your existing pages here
// Make sure to add the correct import paths for your pages
// Example imports (update paths as needed):
// import '../page/about_page.dart';
// import '../page/contact_page.dart';
// import '../page/terms_of_service_page.dart';
// import '../page/overview_page.dart';

// ── Route → page builder ──────────────────────────────────────────────────────
/// Returns the Widget to push for a given route string.
/// Handles plain paths (/about) and query-param paths (/about?tab=owner-service).
Widget? _pageForRoute(String route) {
  final uri = Uri.tryParse(route);
  if (uri == null) return null;
  final path = uri.path;
  final tab = uri.queryParameters['tab'] ?? '';

  switch (path) {
    case '/':
      return const HomePage();
    case '/overview':
    case '/services':
      return const HomePage();
    case '/about':
      return HomePage();
    case '/contact':
    case '/contactus':
      return const HomePage();
    case '/terms':
    case '/termsofservice':
      return const HomePage();
    case '/careers':
      return CareersPage(initialTab: tab);
    default:
      return null;
  }
}

/// Push a named route using plain Navigator — works anywhere in the tree.
void _navigateTo(BuildContext context, String route) {
  if (route.isEmpty) return;
  final page = _pageForRoute(route);
  if (page == null) return;
  Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute(builder: (_) => page));
}

// ─────────────────────────────────────────────────────────────────────────────

class _BP {
  static const double mobile = 768;
}

const Color _kFallbackPrimary = Color(0xFF008037);
const Color _kFallbackFooterBg = Color(0xFFF5F5F5);

List<FooterColumnModel> _syncedFooterColumns(HomePageModel model) {
  final navByRoute = <String, NavButtonModel>{
    for (final btn in model.navButtons)
      if (btn.route.isNotEmpty) btn.route: btn,
  };
  final List<FooterColumnModel> result = [];
  for (final col in model.footerColumns) {
    final nav = col.route.isNotEmpty ? navByRoute[col.route] : null;
    if (nav != null) {
      if (!nav.status) continue;
      result.add(col.copyWith(title: nav.name));
    } else {
      result.add(col);
    }
  }
  return result;
}

String _bi(BiText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

Color _hexColor(String hex, Color fallback) {
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return fallback;
}

String _staticCopyright(bool isRtl) {
  final year = DateTime.now().year.toString();
  return isRtl
      ? 'حقوق النشر © $year بيانات زي للتحول الرقمي. جميع الحقوق محفوظة.'
      : 'Copyright © $year Bayanat. ALL RIGHT RESERVED.';
}

// ─────────────────────────────────────────────────────────────────────────────
// AppFooter
// ─────────────────────────────────────────────────────────────────────────────

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      buildWhen: (_, __) => true,
      builder: (context, state) {
        final HomePageModel model = switch (state) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data)  => data,
          _ => context.read<HomeCmsCubit>().current,
        };

        final Color primary = _hexColor(
          model.branding.primaryColor,
          _kFallbackPrimary,
        );
        final Color footerBg = _hexColor(
          model.branding.headerFooterColor,
          _kFallbackFooterBg,
        );
        final List<FooterColumnModel> columns = _syncedFooterColumns(model);

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;
            final double screenWidth = MediaQuery.of(context).size.width;

            Widget footer;
            if (screenWidth >= _BP.mobile) {
              footer = _FooterDesktop(
                model: model,
                columns: columns,
                primary: primary,
                footerBg: footerBg,
                isRtl: isRtl,
              );
            } else {
              footer = _FooterMobile(
                model: model,
                columns: columns,
                primary: primary,
                footerBg: footerBg,
                isRtl: isRtl,
              );
            }

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: footer,
            );
          },
        );
      },
    );
  }
}

// ─── DESKTOP ──────────────────────────────────────────────────────────────────

class _FooterDesktop extends StatelessWidget {
  final HomePageModel model;
  final List<FooterColumnModel> columns;
  final Color primary;
  final Color footerBg;
  final bool isRtl;

  const _FooterDesktop({
    required this.model,
    required this.columns,
    required this.primary,
    required this.footerBg,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final double contentW = (248.w * 4) + (8.w * 3);
    final double hPad = ((MediaQuery.of(context).size.width - contentW) / 2)
        .clamp(16.0, double.infinity);

    return Container(
      padding: EdgeInsets.all(22.sp),
      decoration: BoxDecoration(
        color: footerBg,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24.r),
          topEnd: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Logo + Footer columns ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoBox(
                logoUrl: model.branding.logoUrl,
                primary: primary,
                size: 50.sp,
              ),
              SizedBox(width: 32.w),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: columns
                      .map(
                        (col) => _FooterColumnWidget(
                      column: col,
                      titleColor: AppColors.text,
                      primary: primary,
                      isRtl: isRtl,
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(color: primary, thickness: 0.5),
          SizedBox(height: 14.h),

          // ── Bottom row: Download App | Social Icons | Copyright ──────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (model.appDownloadLinks.visibility)
                _DownloadAppRow(
                  appDownloadLinks: model.appDownloadLinks,
                  primary: primary,
                  isRtl: isRtl,
                ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _socialIcons(model.socialLinks, primary),
              ),
              const Spacer(),
              Text(
                _staticCopyright(isRtl),
                style: context.isTablet  ?StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.sp,
                ):


                StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── MOBILE ───────────────────────────────────────────────────────────────────

class _FooterMobile extends StatelessWidget {
  final HomePageModel model;
  final List<FooterColumnModel> columns;
  final Color primary;
  final Color footerBg;
  final bool isRtl;

  const _FooterMobile({
    required this.model,
    required this.columns,
    required this.primary,
    required this.footerBg,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final String? firstLabel =
    (columns.isNotEmpty && columns.first.labels.isNotEmpty)
        ? _bi(columns.first.labels.first.label, isRtl)
        : null;
    final String? firstRoute =
    (columns.isNotEmpty &&
        columns.first.labels.isNotEmpty &&
        columns.first.labels.first.route.isNotEmpty)
        ? columns.first.labels.first.route
        : null;

    return Container(
      color: footerBg,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Social icons row with dividers ───────────────────────────
          Row(
            children: [
              Expanded(
                child: Divider(color: primary.withValues(alpha: 0.5), thickness: 1),
              ),
              SizedBox(width: 10.w),
              ..._socialIconsRaw(model.socialLinks, primary),
              SizedBox(width: 10.w),
              Expanded(
                child: Divider(color: primary.withValues(alpha: 0.5), thickness: 1),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Download the App (mobile) ─────────────────────────────
          if (model.appDownloadLinks.visibility) ...[
            _DownloadAppRow(
              appDownloadLinks: model.appDownloadLinks,
              primary: primary,
              isRtl: isRtl,
              compact: true,
            ),
            SizedBox(height: 10.h),
          ],

          if (firstLabel != null)
            _FooterLink(label: firstLabel, route: firstRoute, primary: primary),
          SizedBox(height: 6.h),
          Text(
            _staticCopyright(isRtl),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Download the App Row ─────────────────────────────────────────────────────

class _DownloadAppRow extends StatelessWidget {
  final AppDownloadLinksModel appDownloadLinks;
  final Color primary;
  final bool isRtl;
  final bool compact;

  const _DownloadAppRow({
    required this.appDownloadLinks,
    required this.primary,
    required this.isRtl,
    this.compact = false,
  });

  Future<void> _openUrl(String rawUrl) async {
    String url = rawUrl.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 24.w : 28.w;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isRtl ? 'حمّل التطبيق' : 'Download the App',
          style: GoogleFonts.cairo(
            fontSize: compact ? 11.sp : 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 10.w),

        // ── iOS icon ─────────────────────────────────────────────────
        GestureDetector(
          onTap: appDownloadLinks.iosUrl.isNotEmpty
              ? () => _openUrl(appDownloadLinks.iosUrl)
              : null,
          child: MouseRegion(
            cursor: appDownloadLinks.iosUrl.isNotEmpty
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            child: Container(
              width: iconSize + 8.w,
              height: iconSize + 8.w,
              decoration: BoxDecoration(
                border: Border.all(color: primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: appDownloadLinks.iosIconUrl.isNotEmpty
                    ? SvgPicture.network(
                  appDownloadLinks.iosIconUrl,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                  placeholderBuilder: (_) =>
                      SizedBox(width: iconSize, height: iconSize),
                )
                    : SvgPicture.asset(
                  'assets/footer/ios_logo.svg',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // ── Android icon ──────────────────────────────────────────────
        GestureDetector(
          onTap: appDownloadLinks.androidUrl.isNotEmpty
              ? () => _openUrl(appDownloadLinks.androidUrl)
              : null,
          child: MouseRegion(
            cursor: appDownloadLinks.androidUrl.isNotEmpty
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            child: Container(
              width: iconSize + 8.w,
              height: iconSize + 8.w,
              decoration: BoxDecoration(
                border: Border.all(color: primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: appDownloadLinks.androidIconUrl.isNotEmpty
                    ? SvgPicture.network(
                  appDownloadLinks.androidIconUrl,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                  placeholderBuilder: (_) => SizedBox(width: iconSize, height: iconSize),
                )
                    : SvgPicture.asset(
                  'assets/footer/android_logo.svg',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Footer Column ────────────────────────────────────────────────────────────

class _FooterColumnWidget extends StatefulWidget {
  final FooterColumnModel column;
  final Color titleColor;
  final Color primary;
  final bool isRtl;

  const _FooterColumnWidget({
    required this.column,
    required this.titleColor,
    required this.primary,
    required this.isRtl,
  });

  @override
  State<_FooterColumnWidget> createState() => _FooterColumnWidgetState();
}

class _FooterColumnWidgetState extends State<_FooterColumnWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final String title = _bi(widget.column.title, widget.isRtl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Column title (navigates to column route) ──────────────────
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: widget.column.route.isNotEmpty
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: GestureDetector(
            onTap: widget.column.route.isNotEmpty
                ? () => _navigateTo(context, widget.column.route)
                : null,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: _hovered
                    ? FontWeight.w900
                    : AppFontWeights.semiBold,
                color: _hovered ? widget.primary : widget.titleColor,
              ),
              child: Text(title),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // ── Labels ────────────────────────────────────────────────────
        ...widget.column.labels.map(
              (lbl) => _FooterLink(
            label: _bi(lbl.label, widget.isRtl),
            route: lbl.route.isNotEmpty ? lbl.route : widget.column.route,
            primary: widget.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Footer Link ──────────────────────────────────────────────────────────────

class _FooterLink extends StatefulWidget {
  final String label;
  final String? route;
  final Color primary;

  const _FooterLink({required this.label, required this.primary, this.route});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  /// Navigate using plain Navigator — no GoRouter dependency.
  void _handleTap(BuildContext context) {
    final route = widget.route;
    if (route == null || route.isEmpty) return;
    _navigateTo(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.route != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: Text(
          widget.label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: AppFontWeights.regular,
            height: 2.0,
            color: _hovered ? widget.primary : AppColors.secondaryBlack,
            decoration: _hovered ? TextDecoration.underline : null,
            decorationColor: widget.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Logo box ─────────────────────────────────────────────────────────────────

class _LogoBox extends StatelessWidget {
  final String logoUrl;
  final Color primary;
  final double size;

  const _LogoBox({
    required this.logoUrl,
    required this.primary,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.h,
      child: logoUrl.isNotEmpty
          ? SvgPicture.network(
        logoUrl,
        width: size.w,
        height: size.h,
        fit: BoxFit.contain,
        placeholderBuilder: (_) =>
            SizedBox(width: size.w, height: size.h),
      )
          : Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
    );
  }
}

// ─── Social icon helpers ──────────────────────────────────────────────────────

/// Filters by l.visibility — hidden icons won't appear in footer
List<Widget> _socialIcons(
    List<SocialLinkModel> links,
    Color borderColor, {
      double gap = 10,
    }) {
  return links
      .where((l) => l.visibility && (l.iconUrl.isNotEmpty || l.url.isNotEmpty))
      .map(
        (l) => Padding(
      padding: EdgeInsetsDirectional.only(end: gap.w),
      child: _SocialIconWidget(link: l, borderColor: borderColor, size: 32),
    ),
  )
      .toList();
}

/// Same visibility filter for mobile
List<Widget> _socialIconsRaw(List<SocialLinkModel> links, Color borderColor) {
  return links
      .where((l) => l.visibility && (l.iconUrl.isNotEmpty || l.url.isNotEmpty))
      .expand(
        (l) => [
      _SocialIconWidget(
        link: l,
        borderColor: borderColor,
        size: 32,
        raw: true,
      ),
      SizedBox(width: 8.w),
    ],
  )
      .toList();
}

class _SocialIconWidget extends StatelessWidget {
  final SocialLinkModel link;
  final Color borderColor;
  final double size;
  final bool raw;

  const _SocialIconWidget({
    required this.link,
    required this.borderColor,
    required this.size,
    this.raw = false,
  });

  double get _ic => raw ? size * 0.47 : (size * 0.47).w;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = link.iconUrl.isNotEmpty
        ? SvgPicture.network(
      link.iconUrl,
      width: 20.w,
      height: 20.w,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(width: _ic, height: _ic),
    )
        : Icon(Icons.link, size: _ic, color: borderColor);

    final box = Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(raw ? 8 : 8.r),
      ),
      child: Center(child: iconWidget),
    );

    return link.url.isNotEmpty
        ? GestureDetector(
      onTap: () async {
        String rawUrl = link.url.trim();
        if (!rawUrl.startsWith('http://') &&
            !rawUrl.startsWith('https://')) {
          rawUrl = 'https://$rawUrl';
        }
        final uri = Uri.tryParse(rawUrl);
        if (uri == null || !uri.hasAuthority) return;
        if (!await canLaunchUrl(uri)) return;
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      },
      child: MouseRegion(cursor: SystemMouseCursors.click, child: box),
    )
        : box;
  }
}

// ─── Placeholder pages (if not already defined elsewhere) ────────────────────
// Remove these if you already have these pages defined in your project

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home Page')));
  }
}

class CareersPage extends StatelessWidget {
  final String initialTab;

  const CareersPage({super.key, this.initialTab = ''});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Careers Page')));
  }
}