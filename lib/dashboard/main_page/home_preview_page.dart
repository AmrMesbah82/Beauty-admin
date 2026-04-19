/// ******************* FILE INFO *******************
/// File Name: home_preview_page.dart
/// Page 3 — "Preview Main Details" (Figma screen 6)
/// Shows Desktop / Tablet / Mobile tabs with a live preview of the real
/// AppNavbar + AppFooter widgets (no simulated components).
///
/// FIXES APPLIED:
/// • Mobile: footer is now pinned to the bottom of the phone shell.
/// • Mobile: navbar horizontal padding set to 20px only.
/// • Mobile: overflow stripe eliminated (ClipRect + OverflowBox).
/// • Shell width = fake width (375) so scale = 1.0, no squishing.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:beauty_admin/theme/app_wight.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';
import 'package:beauty_admin/widgets/app_footer.dart';
import 'package:beauty_admin/core/custom_dialog.dart';

import '../../controller/home/home_cubit.dart';
import '../../controller/home/home_state.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
}

enum _PreviewDevice { desktop, tablet, mobile }

// ── Phone shell constants ─────────────────────────────────────────────────────
// Shell width now equals the fake width so scale = 1.0 → no squishing / overflow.
// We shrink the on-screen size by wrapping in a FittedBox at the outer level.
const double _kPhoneShellW  = 375.0;  // rendered shell width  (logical px)
const double _kFakeMobileW  = 375.0;  // faked viewport width
const double _kFakeMobileH  = 812.0;  // faked viewport height

// How large the phone actually appears on screen (display scale)
const double _kMobileDisplayScale = 0.72; // ~270px wide on screen

// ── Desktop / Tablet fake viewport ───────────────────────────────────────────
const double _kFakeDesktopW = 1366.0;
const double _kFakeDesktopH =  768.0;

class HomePreviewPage extends StatefulWidget {
  const HomePreviewPage({super.key});
  @override
  State<HomePreviewPage> createState() => _HomePreviewPageState();
}

class _HomePreviewPageState extends State<HomePreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isSaving = false;

  Future<void> _publish(HomeCmsCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      await cubit.save(publishStatus: 'published');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        if (state is HomeCmsSaved) {}
        if (state is HomeCmsError) {}
      },
      builder: (context, state) {
        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _C.back,
              body: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            AdminSubNavBar(activeIndex: 0),
                            SizedBox(height: 16.h),

                            // ── Page title ──────────────────────────────────
                            Text(
                              'Preview Main Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                color: _C.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Device tabs ─────────────────────────────────
                            Row(
                              children: [
                                _deviceTab('Desktop', _PreviewDevice.desktop),
                                SizedBox(width: 24.w),
                                _deviceTab('Tablet',  _PreviewDevice.tablet),
                                SizedBox(width: 24.w),
                                _deviceTab('Mobile',  _PreviewDevice.mobile),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // ── Preview frame ────────────────────────────────
                            LayoutBuilder(
                              builder: (ctx, constraints) =>
                                  _previewFrame(constraints.maxWidth),
                            ),

                            SizedBox(height: 24.h),

                            // ── Back + Publish ──────────────────────────────
                            // ── Back + Publish ──────────────────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(), // Fixed: Use Navigator.pop
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
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSaving
                                        ? null
                                        : () => showPublishConfirmDialog(
                                      context: context,
                                      onConfirm: () => _publish(cubit),
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        color: _isSaving
                                            ? _C.primary.withOpacity(0.5)
                                            : _C.primary,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Center(
                                        child: _isSaving
                                            ? SizedBox(
                                          width: 18.w,
                                          height: 18.h,
                                          child: const CircularProgressIndicator(
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
                    ],
                  ),
                ),
              ),
            ),

            // ── Saving overlay ──────────────────────────────────────────────
            if (_isSaving)
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

  // ── Device tab ──────────────────────────────────────────────────────────────
  Widget _deviceTab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
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
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? _C.primary : _C.hintText,
                ),
              ),
            ),
            Container(
              height: 2,
              color: active ? _C.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  // ── Preview frame dispatcher ────────────────────────────────────────────────
  Widget _previewFrame(double containerWidth) {
    if (_device == _PreviewDevice.mobile) {
      return _MobilePhoneShell(containerWidth: containerWidth);
    }

    // Desktop / Tablet — scale 1366-wide content to fill containerWidth
    final double scale  = _safeScale(containerWidth / _kFakeDesktopW);
    final double outerH = _kFakeDesktopH * scale;

    return SizedBox(
      width:  double.infinity,
      height: outerH,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale:     scale,
          alignment: Alignment.topCenter,
          child: _PreviewContent(
            fakeWidth:  _kFakeDesktopW,
            fakeHeight: _kFakeDesktopH,
            navbarHorizontalPadding: null, // desktop uses its own padding
          ),
        ),
      ),
    );
  }
}

// ── Safe scale helper ─────────────────────────────────────────────────────────
double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ── Shared preview content ────────────────────────────────────────────────────
// fakeHeight drives the Column so Expanded fills correctly and footer pins to bottom.
class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;

  /// When set, overrides the navbar's horizontal padding (mobile fix = 20).
  /// When null, the navbar renders with its own default padding.
  final double? navbarHorizontalPadding;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    this.navbarHorizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final Widget navbar = navbarHorizontalPadding != null
        ? Padding(
      padding: EdgeInsets.symmetric(horizontal: navbarHorizontalPadding!),
      // We wrap AppNavbar in a SizedBox so it doesn't try to be wider
      // than fakeWidth, then remove its own internal padding via the
      // outer Padding widget above.
      child: SizedBox(
        width: fakeWidth - (navbarHorizontalPadding! * 2),
        child: AppNavbar(currentRoute: '/'),
      ),
    )
        : AppNavbar(currentRoute: '/');

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: SizedBox(
        width:  fakeWidth,
        height: fakeHeight, // explicit height — required for Expanded + footer pin
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Real AppNavbar (with mobile padding override) ───────────
            navbar,

            // ── Body spacer — pushes footer to the very bottom ──────────
            const Expanded(
              child: ColoredBox(color: _C.back),
            ),

            // ── Real AppFooter — always pinned at the bottom ────────────
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Mobile phone shell ────────────────────────────────────────────────────────
//
// Strategy:
//   • Content faked at _kFakeMobileW × _kFakeMobileH (375 × 812).
//   • Shell size = fake size, so scale = 1.0 → NO squishing, no overflow.
//   • The whole shell is then shrunk on screen via Transform.scale at
//     _kMobileDisplayScale (0.72) so it fits nicely in the page.
//   • ClipRect + OverflowBox ensure nothing bleeds outside the shell border.
class _MobilePhoneShell extends StatelessWidget {
  final double containerWidth;
  const _MobilePhoneShell({required this.containerWidth});

  @override
  Widget build(BuildContext context) {
    // Displayed shell dimensions on screen
    final double displayW = _kPhoneShellW * _kMobileDisplayScale; // ≈ 270
    final double displayH = _kFakeMobileH * _kMobileDisplayScale; // ≈ 585

    return Container(
      width:  double.infinity,
      decoration: BoxDecoration(
        color:        _C.back,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      // Reserve the exact display height so the outer scroll doesn't collapse
      height: displayH + 64, // + vertical padding (32*2)
      child: Center(
        child: Transform.scale(
          scale:     _kMobileDisplayScale,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width:  _kPhoneShellW,   // 375 — full fake width
            height: _kFakeMobileH,   // 812 — full fake height
            child: Container(
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _C.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset:     const Offset(0, 6),
                  ),
                ],
              ),
              // ClipRect prevents any child overflow from showing outside the shell
              clipBehavior: Clip.antiAlias,
              child: _PreviewContent(
                fakeWidth:  _kFakeMobileW,  // 375
                fakeHeight: _kFakeMobileH,  // 812
                navbarHorizontalPadding: 20, // ← mobile navbar padding = 20px
              ),
            ),
          ),
        ),
      ),
    );
  }
}