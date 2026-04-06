// ******************* FILE INFO *******************
// File Name: app_page_shell.dart
// Description: Reusable page shell with AppNavbar (top) + AppFooter (bottom)
//              and a scrollable body slot in between.
//              Body content is constrained to 1000.w max width, centered.
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../theme/appcolors.dart';
import 'app_footer.dart';
import 'app_navbar.dart';

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

class AppPageShell extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final bool scrollable;
  final void Function(String route)? onNavItemTap;
  final Color? backgroundColor;

  /// Max width for the body content area. Defaults to 1000.w.
  /// Navbar and footer remain full-width.
  final double? maxBodyWidth;

  const AppPageShell({
    super.key,
    required this.currentRoute,
    required this.body,
    this.scrollable = true,
    this.onNavItemTap,
    this.backgroundColor,
    this.maxBodyWidth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final Color bgColor = backgroundColor ??
            switch (homeState) {
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

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;
            final double screenW = MediaQuery.of(context).size.width;
            final double contentMaxW = maxBodyWidth ?? 1000.w;

            // Clamp so on small screens it doesn't exceed screen width
            final double effectiveMaxW = contentMaxW.clamp(0, screenW);

            Widget bodyContent = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: effectiveMaxW),
                child: SizedBox(
                  width: effectiveMaxW,
                  child: body,
                ),
              ),
            );

            if (scrollable) {
              bodyContent = SingleChildScrollView(child: bodyContent);
            }

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: bgColor,
                body: Column(
                  children: [
                    // ── Navbar — full width ──
                    Material(
                      color: bgColor,
                      elevation: 0,
                      child: AppNavbar(
                        currentRoute: currentRoute,
                        onItemTap: onNavItemTap,
                      ),
                    ),

                    // ── Body — centered, max 1000.w ──
                    Expanded(child: bodyContent),

                    // ── Footer — full width ──
                    const AppFooter(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}