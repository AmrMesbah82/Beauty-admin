part of '../../pages/strategy_page/strategy_preview.dart';

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final OurStrategyModel model;
  final bool isEnglish;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    final double shellH = displayH + 24 + 12 + 4;
    final double shellW = displayW + 4;

    return Center(
      child: Container(
        width: shellW,
        height: shellH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Notch ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ),
            // ── Content ────────────────────────────────────────────
            SizedBox(
              width: displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kMobileW,
                  maxHeight: _kMobileH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth: _kMobileW,
                      fakeHeight: _kMobileH,
                      model: model,
                      isEnglish: isEnglish,
                      enBytes: enBytes,
                      enUrl: enUrl,
                      arBytes: arBytes,
                      arUrl: arUrl,
                      hasEnImage: hasEnImage,
                      hasArImage: hasArImage,
                      isMobile: true,
                    ),
                  ),
                ),
              ),
            ),
            // ── Home indicator ─────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(2.r),
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

// ═════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT (renders Strategic House sections)
// ═════════════════════════════════════════════════════════════════════════════
