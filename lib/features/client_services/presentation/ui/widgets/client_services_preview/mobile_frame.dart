// ******************* FILE INFO *******************
// File Name: mobile_frame.dart
// Description: Mobile device frame for Client Services preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › client_services › presentation › ui › widget › client_services_preview

part of '../../pages/client_services_preview.dart';

class _MobileFrame extends StatelessWidget {
  final double containerWidth;
  final ClientServicesPageModel model;

  const _MobileFrame({
    required this.containerWidth,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

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
                          fakeWidth: _kMobileW,
                          fakeHeight: _kMobileH,
                          model: model,
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

// ═════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT (renders actual client services sections)
// ═════════════════════════════════════════════════════════════════════════════
