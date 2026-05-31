// ******************* FILE INFO *******************
// File Name: desktop_frame.dart
// Description: Desktop device frame for Main preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › main › presentation › ui › widget › main_preview

part of '../../pages/main_preview.dart';

class _DesktopFrame extends StatelessWidget {
  final double containerWidth;
  const _DesktopFrame({required this.containerWidth});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return SizedBox(
      width: containerWidth,
      height: frameH + 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            _BrowserChrome(),
            SizedBox(
              width: containerWidth,
              height: frameH,
              child: ClipRect(                          // ← ADD THIS
                child: OverflowBox(                     // ← ADD THIS
                  alignment: Alignment.topLeft,
                  maxWidth: _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _PreviewContent(
                        fakeWidth:  _kDesktopW,
                        fakeHeight: _kDesktopH,
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
// Tablet frame  (768 × 1024 — centered, aspect-ratio preserved)
// ─────────────────────────────────────────────────────────────────────────────
