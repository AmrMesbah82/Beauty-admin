// ******************* FILE INFO *******************
// File Name: desktop_frame.dart
// Description: Desktop device frame for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double           containerWidth;
  final ContactUsCmsModel data;
  final bool             isEnglish;
  const _DesktopFrame({required this.containerWidth, required this.data, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(color: ColorPick.white),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
                        isEnglish: isEnglish,  // ← add this
                        data: data,
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

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET FRAME
// ═══════════════════════════════════════════════════════════════════════════════
