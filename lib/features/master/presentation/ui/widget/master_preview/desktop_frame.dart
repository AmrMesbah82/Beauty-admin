part of '../../pages/master_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double          containerWidth;
  final MasterPageModel? model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return SizedBox(
      width: containerWidth,
      height: frameH + 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width: containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      height: _kDesktopH,
                      child: _PreviewContent(
                        fakeWidth:    _kDesktopW,
                        fakeHeight:   _kDesktopH,
                        model:        model,
                        isEnglish:    isEnglish,
                        homeViewOpen: homeViewOpen,
                        onToggleHome: onToggleHome,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet frame  (768 × 1024 — centered, aspect-ratio preserved)
// ─────────────────────────────────────────────────────────────────────────────
