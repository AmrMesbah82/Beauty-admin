part of '../../pages/home_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final double? mobileNavbarPadding;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    this.mobileNavbarPadding,
  });

  @override
  Widget build(BuildContext context) {
    final Widget navbar = mobileNavbarPadding != null
        ? Padding(
      padding: EdgeInsets.symmetric(horizontal: mobileNavbarPadding!),
      child: AppNavbar(currentRoute: '/'),
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
        width: fakeWidth,
        height: fakeHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            navbar,
            const Expanded(child: ColoredBox(color: _C.back)),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Browser chrome bar (dots + URL bar)
// ─────────────────────────────────────────────────────────────────────────────
