// ******************* FILE INFO *******************
// File Name: tablet_frame.dart
// Description: Tablet device frame for Master preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_preview

part of '../../pages/master_preview.dart';

class _TabletFrame extends StatelessWidget {
  final double           containerWidth;
  final MasterPageModel? model;
  final bool             isEnglish;
  final bool             homeViewOpen;
  final VoidCallback     onToggleHome;

  const _TabletFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Center(
      child: Container(
        width: displayW + 4,
        height: displayH + 28 + 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4)),
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
                    child: SizedBox(
                      width: _kTabletW,
                      height: _kTabletH,
                      child: _PreviewContent(
                        fakeWidth:    _kTabletW,
                        fakeHeight:   _kTabletH,
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
// Mobile frame  (375 × 812 — phone shell with notch)
// ─────────────────────────────────────────────────────────────────────────────