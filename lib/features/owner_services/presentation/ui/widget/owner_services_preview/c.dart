part of '../../pages/owner_services_preview.dart';

class _C {
  static const Color primary    = Color(0xFFD16F9A);
  static const Color back       = Color(0xFFF1F2ED);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color sectionBg  = Color(0xFFFDF5F8);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color addBtn     = Color(0xFF797979);
}

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

enum _PreviewDevice { desktop, tablet, mobile }

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

// ═════════════════════════════════════════════════════════════════════════════
// PAGE
// ═════════════════════════════════════════════════════════════════════════════
