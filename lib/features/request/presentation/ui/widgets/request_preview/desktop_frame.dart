// ******************* FILE INFO *******************
// File Name: desktop_frame.dart
// Description: Desktop device frame for Request preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › presentation › ui › widget › request_preview

part of '../../pages/request_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  final RequestDemoPageModel model;

  const _DesktopFrame({
    required this.containerWidth,
    required this.model,
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
