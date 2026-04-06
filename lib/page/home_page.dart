// ******************* FILE INFO *******************
// File Name: home_page.dart
// Description: Public-facing Home Page for the Beauty App (Bayanatz).
//              Three sections: Hero, About Us, Download App.
//              Data-driven via HomeCmsCubit + LanguageCubit.
// Created by: Claude for Amr Mesbah

import 'package:beauty_admin/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — parse hex color from branding
// ─────────────────────────────────────────────────────────────────────────────

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final data = switch (homeState) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data) => data,
          HomeCmsSaving(:final data) => data,
          HomeCmsError(:final lastData) => lastData,
          _ => null,
        };

        if (data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final primaryColor = _parseHex(
          data.branding.primaryColor,
          fallback: AppColors.primary,
        );

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isAr = langState.isArabic;

            // ── Extract section data safely ──
            String _sectionText(int index, {bool title = false}) {
              if (index >= data.sections.length) return '';
              final section = data.sections[index];
              final biText = section.description;
              return isAr ? biText.ar : biText.en;
            }

            return AppPageShell(
              currentRoute: '/',
              body: Column(
                children: [
                  // ═══════════════════════════════════════════════════════════
                  // SECTION 1 — HERO
                  // ═══════════════════════════════════════════════════════════
                  _HeroSection(
                    primaryColor: primaryColor,
                    title: isAr ? data.title.ar : data.title.en,
                    subtitle: isAr
                        ? data.shortDescription.ar
                        : data.shortDescription.en,
                  ),

                  SizedBox(height: 40.h),

                  // ═══════════════════════════════════════════════════════════
                  // SECTION 2 — ABOUT US
                  // ═══════════════════════════════════════════════════════════
                  _AboutUsSection(
                    primaryColor: primaryColor,
                    heading: isAr ? 'من نحن' : 'About Us',
                    body: _sectionText(0),
                    readMoreLabel: isAr ? 'اقرأ المزيد' : 'Read More',
                    onReadMore: () {
                      // TODO: navigate to about page
                    },
                  ),

                  SizedBox(height: 40.h),

                  // ═══════════════════════════════════════════════════════════
                  // SECTION 3 — DOWNLOAD APP
                  // ═══════════════════════════════════════════════════════════
                  _DownloadAppSection(
                    primaryColor: primaryColor,
                    heading: isAr
                        ? 'حمّل تطبيق Beauty الآن'
                        : 'Download Beauty App Now',
                    body: _sectionText(1),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — HERO
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String subtitle;

  const _HeroSection({
    required this.primaryColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            // ── Desktop / Tablet — Row layout ──
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Phone mockups
                Expanded(
                  flex: 5,
                  child: _HeroPhones(),
                ),
                SizedBox(width: 30.w),
                // Text
                Expanded(
                  flex: 5,
                  child: _HeroText(
                    title: title,
                    subtitle: subtitle,
                    primaryColor: primaryColor,
                  ),
                ),
              ],
            );
          }

          // ── Mobile — Column layout ──
          return Column(
            children: [
              _HeroPhones(),
              SizedBox(height: 24.h),
              _HeroText(
                title: title,
                subtitle: subtitle,
                primaryColor: primaryColor,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroPhones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Back phone (slightly left & tilted) ──
          Positioned(
            left: 10.w,
            top: 20.h,
            child: Transform.rotate(
              angle: -0.08,
              child: SvgPicture.asset(
                'assets/beauty/home/second_phone.svg',
                height: 280.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // ── Front phone (center, slightly overlapping) ──
          Positioned(
            left: 60.w,
            top: 0,
            child: SvgPicture.asset(
              'assets/beauty/home/phone_home.svg',
              height: 300.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
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
          title,
          style: AppTextStyles.font23BlackSemiBoldCairo,
        ),
        SizedBox(height: 12.h),
        Text(
          subtitle,
          style: AppTextStyles.font20BlackCairoMedium.copyWith(
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — ABOUT US
// ─────────────────────────────────────────────────────────────────────────────

class _AboutUsSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String readMoreLabel;
  final VoidCallback? onReadMore;

  const _AboutUsSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    required this.readMoreLabel,
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
            heading,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Body text ──
          Text(
            body,
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
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      readMoreLabel,
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
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14.sp,
                        color: primaryColor,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — DOWNLOAD APP
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadAppSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;

  const _DownloadAppSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            // ── Desktop / Tablet — Row layout ──
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Phone mockup with border
                Expanded(
                  flex: 4,
                  child: _DownloadPhoneMockup(primaryColor: primaryColor),
                ),
                SizedBox(width: 30.w),
                // Text + store badges
                Expanded(
                  flex: 6,
                  child: _DownloadTextContent(
                    primaryColor: primaryColor,
                    heading: heading,
                    body: body,
                  ),
                ),
              ],
            );
          }

          // ── Mobile — Column layout ──
          return Column(
            children: [
              _DownloadPhoneMockup(primaryColor: primaryColor),
              SizedBox(height: 24.h),
              _DownloadTextContent(
                primaryColor: primaryColor,
                heading: heading,
                body: body,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DownloadPhoneMockup extends StatelessWidget {
  final Color primaryColor;

  const _DownloadPhoneMockup({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
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
      child: SvgPicture.asset(
        'assets/beauty/home/phone_home.svg',
        height: 280.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _DownloadTextContent extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;

  const _DownloadTextContent({
    required this.primaryColor,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Heading ──
        Text(
          heading,
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
              body,
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          ),

        // ── Store Badges ──
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Google Play
            _StoreBadge(
              onTap: () {
                // TODO: launch Google Play URL
              },
              imageAsset: 'assets/beauty/home/google_play_badge.png',
            ),
            SizedBox(width: 12.w),
            // App Store
            _StoreBadge(
              onTap: () {
                // TODO: launch App Store URL
              },
              imageAsset: 'assets/beauty/home/app_store_badge.png',
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE BADGE BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _StoreBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final String imageAsset;

  const _StoreBadge({
    this.onTap,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.asset(
          imageAsset,
          height: 42.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}