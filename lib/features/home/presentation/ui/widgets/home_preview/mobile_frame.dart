// ******************* FILE INFO *******************
// File Name: mobile_frame.dart
// Description: Mobile device frame for Home preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_preview

part of '../../pages/home_preview.dart';

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  const _MobileFrame({required this.containerWidth});

  @override
  Widget build(BuildContext context) {
    // Target display width = 35% of container, max 280
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    // Shell adds notch bar (24) + bottom bar (12) + border (4)
    final double shellH = displayH + 24 + 12 + 4;
    final double shellW = displayW + 4;

    return Column(
      children: [

        Center(
          child: Container(
            width: shellW,
            height: shellH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),


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
                        color: ColorPick.white,
                        borderRadius: BorderRadius.circular(6),
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
                          fakeWidth:  _kMobileW,
                          fakeHeight: _kMobileH,
                          mobileNavbarPadding: 16,
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
                        color: ColorPick.white,
                        borderRadius: BorderRadius.circular(2),
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
// Shared preview content (real widgets, faked MediaQuery)
// ─────────────────────────────────────────────────────────────────────────────
