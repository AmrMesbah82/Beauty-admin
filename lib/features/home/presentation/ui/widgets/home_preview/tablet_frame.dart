// ******************* FILE INFO *******************
// File Name: tablet_frame.dart
// Description: Tablet device frame for Home preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_preview

part of '../../pages/home_preview.dart';

class _TabletFrame extends StatelessWidget {
  final double containerWidth;
  const _TabletFrame({required this.containerWidth});

  @override
  Widget build(BuildContext context) {
    // Target display width = 55% of container, max 500
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Column(
      children: [

        Center(
          child: Container(
            width: displayW + 4,   // +4 for border
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
                _BrowserChrome(compact: true),
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
                          fakeWidth:  _kTabletW,
                          fakeHeight: _kTabletH,
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

// ─────────────────────────────────────────────────────────────────────────────
// Mobile frame  (375 × 812 — phone shell with notch)
// ─────────────────────────────────────────────────────────────────────────────
