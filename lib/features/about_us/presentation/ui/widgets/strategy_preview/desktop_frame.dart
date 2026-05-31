// ******************* FILE INFO *******************
// File Name: desktop_frame.dart
// Description: Desktop device frame for Strategy preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › strategy_preview

part of '../../pages/strategy_page/strategy_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final OurStrategyModel model;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
  });

  @override
  Widget build(BuildContext context) {
    final scale = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(
        color: ColorPick.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
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
                      child: _PreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        model: model,
                        enBytes: enBytes,
                        enUrl: enUrl,
                        arBytes: arBytes,
                        arUrl: arUrl,
                        hasEnImage: hasEnImage,
                        hasArImage: hasArImage,
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
// TABLET FRAME (768 × 1024)
// ═════════════════════════════════════════════════════════════════════════════
