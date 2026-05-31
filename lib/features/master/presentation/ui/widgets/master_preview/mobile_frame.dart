// ******************* FILE INFO *******************
// File Name: mobile_frame.dart
// Description: Mobile device frame for Master preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_preview

part of '../../pages/master_preview.dart';

class _MobileFrame extends StatelessWidget {
  final double           containerWidth;
  final MasterPageModel? model;
  final bool             isEnglish;
  final bool             homeViewOpen;
  final VoidCallback     onToggleHome;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    final double shellH = displayH + 24 + 12 + 4;
    final double shellW = displayW + 4;

    return Center(
      child: Container(
        width: shellW,
        height: shellH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Notch ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ColorPick.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────
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
                    child: SizedBox(
                      width: _kMobileW,
                      height: _kMobileH,
                      child: _PreviewContent(
                        fakeWidth:    _kMobileW,
                        fakeHeight:   _kMobileH,
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

            // ── Home indicator ─────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Container(
                  width: displayW * 0.3,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorPick.white,
                    borderRadius: BorderRadius.circular(2),
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
// Preview content — the actual page content rendered inside the frame
// ─────────────────────────────────────────────────────────────────────────────