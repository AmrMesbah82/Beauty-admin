/// Shared viewport dimensions and device enum for all preview pages.
///
/// Import this instead of redeclaring _kDesktopW / _kTabletW / _kMobileW
/// in every feature's c.dart file.
class AppPreviewSizes {
  AppPreviewSizes._();

  static const double desktopW = 1366.0;
  static const double desktopH =  768.0;

  static const double tabletW  =  768.0;
  static const double tabletH  = 1024.0;

  static const double mobileW  =  375.0;
  static const double mobileH  =  812.0;

  /// Returns [v] if finite and positive, otherwise 1.0.
  static double safeScale(double v) =>
      (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;
}

/// Shared device-type enum used by all preview pages.
enum PreviewDevice { desktop, tablet, mobile }
