part of '../../pages/strategy_page/strategy_preview.dart';

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final OurStrategyModel model;
  final bool isEnglish;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;

  const _TabletFrame({
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
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Center(
      child: Container(
        width: displayW + 4,
        height: displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _C.border, width: 2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const _BrowserChrome(compact: true),
            SizedBox(
              width: displayW,
              height: displayH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kTabletW,
                  maxHeight: _kTabletH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: _PreviewContent(
                      fakeWidth: _kTabletW,
                      fakeHeight: _kTabletH,
                      model: model,
                      isEnglish: isEnglish,
                      enBytes: enBytes,
                      enUrl: enUrl,
                      arBytes: arBytes,
                      arUrl: arUrl,
                      hasEnImage: hasEnImage,
                      hasArImage: hasArImage,
                      isTablet: true,
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

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE FRAME (375 × 812)
// ═════════════════════════════════════════════════════════════════════════════
