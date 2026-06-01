// ******************* FILE INFO *******************
// File Name: tablet_frame.dart
// Description: Tablet device frame for Overview preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_preview

part of '../../pages/overview_preview.dart';

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  final OverviewPageModel model;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Column(
      children: [
        Center(
          child: Container(
            width: displayW + 4,
            height: displayH + 28 + 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorPick.white, width: 2),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
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
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE FRAME (375 × 812)
// ═════════════════════════════════════════════════════════════════════════════
