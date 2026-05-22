part of '../../pages/main_main.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color back = Color(0xFFF1F2ED);
}

/// Strip leading slash for display
String _displayRoute(String route) {
  if (route.isEmpty) return 'None';
  return route.startsWith('/') ? route.substring(1) : route;
}
