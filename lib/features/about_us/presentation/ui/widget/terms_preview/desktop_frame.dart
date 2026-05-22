part of '../../pages/terms_page/terms_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double         containerWidth;
  final TermsOfServiceModel model;
  final Uint8List?     termsSvgBytes;
  final Uint8List?     privacySvgBytes;
  final bool           isEnglish;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    this.termsSvgBytes,
    this.privacySvgBytes,
  });

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width:  containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(color: _C.back),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width:  containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth:  _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale:     scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _PreviewContent(
                        fakeWidth:       _kDesktopW,
                        fakeHeight:      _kDesktopH,
                        model:           model,
                        termsSvgBytes:   termsSvgBytes,
                        privacySvgBytes: privacySvgBytes,
                        isEnglish:       isEnglish,
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

// ═════════════════════════════════════════════════════════════════════════════
// TABLET FRAME  (768 × 1024)
// ═════════════════════════════════════════════════════════════════════════════
