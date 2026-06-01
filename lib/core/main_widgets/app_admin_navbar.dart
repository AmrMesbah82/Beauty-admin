// ******************* FILE INFO *******************
// File Name: app_admin_navbar.dart
// Description: Admin navigation bar widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets

import 'package:beauty_admin/core/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../features/demos/presentation/ui/pages/demo_main_page.dart';
import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/home/presentation/controller/home_state.dart';
import '../../features/inquire/presentation/ui/pages/inquiry_main.dart';
import '../theme/app_weight.dart';
import '../theme/appcolors.dart';


class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

Color _primaryFromState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data)  => data.branding.primaryColor,
    _                          => '',
  };
  return _hexColor(hex, const Color(0xFFD16F9A));
}

Color _navbarBgFromState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.headerFooterColor,
    HomeCmsSaved(:final data)  => data.branding.headerFooterColor,
    _                          => '',
  };
  return _hexColor(hex, AppColors.white);
}

Color _hexColor(String hex, Color fallback) {
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return fallback;
}

// ─────────────────────────────────────────────────────────────────────────────
// FadeRoute — smooth fade transition between pages
// ─────────────────────────────────────────────────────────────────────────────

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  final String routeName;
  final Duration duration;

  FadeRoute({
    required this.page,
    this.routeName = '',
    this.duration = const Duration(milliseconds: 300),
  }) : super(
    settings: RouteSettings(name: routeName),
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

void _pushPage(BuildContext context, dynamic pageOrBuilder) {
  final Widget page;
  if (pageOrBuilder is Widget Function(BuildContext)) {
    page = pageOrBuilder(context);
  } else {
    page = pageOrBuilder as Widget;
  }

  Navigator.of(context).pushReplacement(
    FadeRoute(page: page),
  );
}

class _AdminNavItem {
  final String label;
  final Widget? page;
  final Widget Function(BuildContext)? pageBuilder;

  const _AdminNavItem({
    required this.label,
    this.page,
    this.pageBuilder,
  });
}

class AppAdminNavbar extends StatelessWidget {
  final String  activeLabel;
  final Widget  homePage;
  final Widget  webPage;
  final Widget  jobListingPage;
  final bool    showOnlyWebPage;

  const AppAdminNavbar({
    super.key,
    required this.activeLabel,
    required this.homePage,
    required this.webPage,
    required this.jobListingPage,
    this.showOnlyWebPage = false,
  });

  List<_AdminNavItem> get _navItems => [
    _AdminNavItem(
      label: 'Demos',
      pageBuilder: (context) => const RequestDemoMainPage(),
    ),
    _AdminNavItem(
      label: 'Inquiries',
      pageBuilder: (context) => const InquiryMainPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, cmsState) {
        final Color  primary  = _primaryFromState(cmsState);
        final Color  navbarBg = _navbarBgFromState(cmsState);
        final double w        = MediaQuery.of(context).size.width;

        if (w >= _BP.tablet) {
          return _AdminNavbarDesktop(
            activeLabel:     activeLabel,
            navItems:        _navItems,
            primary:         primary,
            navbarBg:        navbarBg,
            webPage:         webPage,
            showOnlyWebPage: showOnlyWebPage,
          );
        }
        if (w >= _BP.mobile) {
          return _AdminNavbarTablet(
            activeLabel:     activeLabel,
            navItems:        _navItems,
            primary:         primary,
            navbarBg:        navbarBg,
            webPage:         webPage,
            showOnlyWebPage: showOnlyWebPage,
          );
        }
        return _AdminNavbarMobile(
          activeLabel:     activeLabel,
          navItems:        _navItems,
          primary:         primary,
          navbarBg:        navbarBg,
          webPage:         webPage,
          showOnlyWebPage: showOnlyWebPage,
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DESKTOP
// ═════════════════════════════════════════════════════════════════════════════

class _AdminNavbarDesktop extends StatelessWidget {
  final String               activeLabel;
  final List<_AdminNavItem>  navItems;
  final Color                primary;
  final Color                navbarBg;
  final Widget               webPage;
  final bool                 showOnlyWebPage;

  const _AdminNavbarDesktop({
    required this.activeLabel,
    required this.navItems,
    required this.primary,
    required this.navbarBg,
    required this.webPage,
    required this.showOnlyWebPage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width:   1000.w,
        margin:  EdgeInsets.symmetric(vertical: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            _AdminLogo(
              onTap: () => _pushPage(context, navItems.first.pageBuilder!),
            ),
            SizedBox(width: 250.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!showOnlyWebPage)
                  ...navItems.map((item) => _AdminNavLink(
                    label:       item.label,
                    page:        item.page,
                    pageBuilder: item.pageBuilder,
                    activeLabel: activeLabel,
                    primary:     ColorPick.primary,
                  )),
                SizedBox(width: 12.w),
                _WebPageButton(
                  primary:  ColorPick.primary,
                  isActive: activeLabel == 'Web Page',
                  onTap:    () => _pushPage(context, webPage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TABLET
// ═════════════════════════════════════════════════════════════════════════════

class _AdminNavbarTablet extends StatelessWidget {
  final String               activeLabel;
  final List<_AdminNavItem>  navItems;
  final Color                primary;
  final Color                navbarBg;
  final Widget               webPage;
  final bool                 showOnlyWebPage;

  const _AdminNavbarTablet({
    required this.activeLabel,
    required this.navItems,
    required this.primary,
    required this.navbarBg,
    required this.webPage,
    required this.showOnlyWebPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:        navbarBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            _AdminLogo(
              onTap: () => _pushPage(context, navItems.first.pageBuilder!),
            ),
            SizedBox(width: 16.w),
            if (!showOnlyWebPage)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: navItems
                        .map((item) => _AdminNavLink(
                      label:       item.label,
                      page:        item.page,
                      pageBuilder: item.pageBuilder,
                      activeLabel: activeLabel,
                      primary:     primary,
                      compact:     true,
                    ))
                        .toList(),
                  ),
                ),
              )
            else
              const Spacer(),
            SizedBox(width: 12.w),
            _WebPageButton(
              primary:  primary,
              compact:  true,
              isActive: activeLabel == 'Web Page',
              onTap:    () => _pushPage(context, webPage),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  MOBILE
// ═════════════════════════════════════════════════════════════════════════════

class _AdminNavbarMobile extends StatelessWidget {
  final String               activeLabel;
  final List<_AdminNavItem>  navItems;
  final Color                primary;
  final Color                navbarBg;
  final Widget               webPage;
  final bool                 showOnlyWebPage;

  const _AdminNavbarMobile({
    required this.activeLabel,
    required this.navItems,
    required this.primary,
    required this.navbarBg,
    required this.webPage,
    required this.showOnlyWebPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:        navbarBg,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AdminLogo(
              onTap: () => _pushPage(context, navItems.first.pageBuilder!),
            ),
            if (!showOnlyWebPage)
              GestureDetector(
                onTap: () => _openDrawer(context),
                child: Container(
                  width:  36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color:        primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.menu_rounded, color: primary, size: 20.sp),
                ),
              )
            else
              _WebPageButton(
                primary:  primary,
                compact:  true,
                isActive: activeLabel == 'Web Page',
                onTap:    () => _pushPage(context, webPage),
              ),
          ],
        ),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque:             false,
        barrierDismissible: true,
        barrierColor:       Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (ctx, anim, _) => _AdminMobileDrawer(
          activeLabel: activeLabel,
          navItems:    navItems,
          primary:     primary,
          navbarBg:    navbarBg,
          webPage:     webPage,
        ),
        transitionsBuilder: (ctx, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  MOBILE DRAWER
// ═════════════════════════════════════════════════════════════════════════════

class _AdminMobileDrawer extends StatelessWidget {
  final String               activeLabel;
  final List<_AdminNavItem>  navItems;
  final Color                primary;
  final Color                navbarBg;
  final Widget               webPage;

  const _AdminMobileDrawer({
    required this.activeLabel,
    required this.navItems,
    required this.primary,
    required this.navbarBg,
    required this.webPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: navbarBg,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AdminLogo(
                    rawSize: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      _pushPage(context, navItems.first.pageBuilder!);
                    },
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width:  36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color:        primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.close_rounded, color: primary, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  ...navItems.map((item) {
                    final bool isActive  = activeLabel == item.label;
                    final bool isEnabled = item.page != null || item.pageBuilder != null;
                    return GestureDetector(
                      onTap: isEnabled
                          ? () {
                        Navigator.of(context).pop();
                        _pushPage(context, item.page ?? item.pageBuilder!);
                      }
                          : null,
                      child: Opacity(
                        opacity: isEnabled ? 1.0 : 0.45,
                        child: Container(
                          width:   double.infinity,
                          margin:  EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: isActive ? primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            item.label,
                            style: GoogleFonts.cairo(
                              fontSize:   14.sp,
                              fontWeight: isActive
                                  ? AppFontWeights.semiBold
                                  : AppFontWeights.regular,
                              color: isActive ? Colors.white : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _pushPage(context, webPage);
                    },
                    child: Container(
                      width:   double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 13.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: activeLabel == 'Web Page'
                            ? primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        border: activeLabel == 'Web Page'
                            ? null
                            : Border.all(color: primary),
                      ),
                      child: Text(
                        'Web Page',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize:   14.sp,
                          fontWeight: AppFontWeights.semiBold,
                          color: activeLabel == 'Web Page'
                              ? Colors.white
                              : primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  LOGO
// ═════════════════════════════════════════════════════════════════════════════
bool _isLikelySvg(String url) {
  final lower = Uri.decodeFull(url).toLowerCase();
  return lower.contains('.svg') ||
      lower.contains('/svg?') ||
      lower.contains('/svg/') ||
      lower.endsWith('/svg');
}

class _AdminLogo extends StatelessWidget {
  final bool         rawSize;
  final VoidCallback onTap;

  const _AdminLogo({this.rawSize = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double sz = rawSize ? 40.w : 36.w;

    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        final String logoUrl = switch (state) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _                          => '',
        };

        final Widget fallbackLogo = SvgPicture.asset(
          'assets/spa_core.svg',
          width:  sz,
          height: sz,
          fit:    BoxFit.contain,
        );

        final Widget logoWidget;
        if (logoUrl.isEmpty) {
          logoWidget = fallbackLogo;
        } else if (_isLikelySvg(logoUrl)) {
          logoWidget = SvgPicture.network(
            logoUrl,
            width:  sz,
            height: sz,
            fit:    BoxFit.contain,
            placeholderBuilder: (_) => fallbackLogo,
          );
        } else {
          logoWidget = Image.network(
            logoUrl,
            width:  sz,
            height: sz,
            fit:    BoxFit.contain,
            errorBuilder: (_, __, ___) => fallbackLogo,
          );
        }

        return GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: logoWidget,
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  NAV LINK
// ═════════════════════════════════════════════════════════════════════════════

class _AdminNavLink extends StatefulWidget {
  final String  label;
  final Widget? page;
  final Widget Function(BuildContext)? pageBuilder;
  final String  activeLabel;
  final Color   primary;
  final bool    compact;

  const _AdminNavLink({
    required this.label,
    this.page,
    this.pageBuilder,
    required this.activeLabel,
    required this.primary,
    this.compact = false,
  });

  @override
  State<_AdminNavLink> createState() => _AdminNavLinkState();
}

class _AdminNavLinkState extends State<_AdminNavLink> {
  bool _hovered = false;

  bool get _isActive  => widget.activeLabel == widget.label;
  bool get _isEnabled => widget.page != null || widget.pageBuilder != null;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:  _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: _isEnabled ? (_) => setState(() => _hovered = true)  : null,
      onExit:  _isEnabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: _isEnabled
            ? () => _pushPage(context, widget.page ?? widget.pageBuilder!)
            : null,
        child: Opacity(
          opacity: _isEnabled ? 1.0 : 0.45,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.symmetric(
                horizontal: widget.compact ? 2.w : 4.w),
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 8.w  : 14.w,
              vertical:   widget.compact ? 6.h  : 7.h,
            ),
            decoration: BoxDecoration(
              color: _isActive
                  ? widget.primary
                  : (_hovered
                  ? widget.primary.withValues(alpha: 0.08)
                  : Colors.transparent),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize:   widget.compact ? 11.sp : 13.sp,
                fontWeight: _isActive
                    ? AppFontWeights.semiBold
                    : AppFontWeights.regular,
                color: _isActive
                    ? Colors.white
                    : (_hovered ? widget.primary : AppColors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  WEB PAGE BUTTON
// ═════════════════════════════════════════════════════════════════════════════

class _WebPageButton extends StatefulWidget {
  final Color        primary;
  final bool         compact;
  final bool         isActive;
  final VoidCallback onTap;

  const _WebPageButton({
    required this.primary,
    required this.onTap,
    this.compact  = false,
    this.isActive = false,
  });

  @override
  State<_WebPageButton> createState() => _WebPageButtonState();
}

class _WebPageButtonState extends State<_WebPageButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14.w : 20.w,
            vertical:   widget.compact ? 7.h  : 9.h,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.primary
                : (_hovered
                ? widget.primary.withValues(alpha: 0.08)
                : Colors.transparent),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Web Page',
            style: GoogleFonts.cairo(
              fontSize:   widget.compact ? 11.sp : 13.sp,
              fontWeight: AppFontWeights.semiBold,
              color: widget.isActive
                  ? Colors.white
                  : (_hovered ? widget.primary : AppColors.text),
            ),
          ),
        ),
      ),
    );
  }
}