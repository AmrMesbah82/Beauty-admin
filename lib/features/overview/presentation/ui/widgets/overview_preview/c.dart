// ******************* FILE INFO *******************
// File Name: c.dart
// Description: Private constants/enums for Overview preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_preview

part of '../../pages/overview_preview.dart';
// ══════════════════════════════════════════════════════════════════════════════
// Helper — parse hex color from branding
// ══════════════════════════════════════════════════════════════════════════════

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ══════════════════════════════════════════════════════════════════════════════
// Network Image Helper (matching overview_page.dart approach)
// ══════════════════════════════════════════════════════════════════════════════

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();

  final viewId = 'svg-preview-${url.hashCode}-${width?.toInt()}-${height?.toInt()}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : fit == BoxFit.scaleDown
          ? 'scale-down'
          : 'cover';
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    inner = SizedBox(width: width, height: height, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

enum _PreviewDevice { desktop, tablet, mobile }

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;
