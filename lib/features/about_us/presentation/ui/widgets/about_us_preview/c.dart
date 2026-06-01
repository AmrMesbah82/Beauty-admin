// ******************* FILE INFO *******************
// File Name: c.dart
// Description: Private constants/enums for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';
Color _hoverTint(Color primary) => primary.withValues(alpha: 0.12);

enum _PreviewDevice { desktop, tablet, mobile }

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH = 768.0;

const double _kTabletW = 768.0;
const double _kTabletH = 1024.0;

const double _kMobileW = 375.0;
const double _kMobileH = 812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ═══════════════════════════════════════════════════════════════════════════════
// XHR IMAGE CACHE — identical to about_page.dart
// ═══════════════════════════════════════════════════════════════════════════════

final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: isSvg ? 'image/svg+xml' : null,
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header = String.fromCharCodes(
    b.sublist(0, b.length.clamp(0, 100)),
  ).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();

  final fitStr = fit == BoxFit.contain
      ? 'contain'
      : fit == BoxFit.scaleDown
      ? 'scale-down'
      : fit == BoxFit.fill
      ? 'fill'
      : 'cover';

  String _safeSize(double? v) {
    if (v == null) return 'null';
    if (v.isInfinite || v.isNaN) return 'fill';
    return v.toInt().toString();
  }

  final viewId =
      'svg-about-preview-${url.hashCode}-${_safeSize(width)}-${_safeSize(height)}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fitStr;
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    final safeW = (width != null && !width.isNaN && !width.isInfinite)
        ? width
        : double.infinity;
    final safeH = (height != null && !height.isNaN && !height.isInfinite)
        ? height
        : null;
    inner = SizedBox(width: safeW, height: safeH, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

double _desktopContentWidth(BuildContext context) {
  final double screen = MediaQuery.of(context).size.width;
  final double natural = (248.w * 4) + (8.w * 3);
  return natural.clamp(0.0, screen - 64.0);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW PAGE
// ═══════════════════════════════════════════════════════════════════════════════
