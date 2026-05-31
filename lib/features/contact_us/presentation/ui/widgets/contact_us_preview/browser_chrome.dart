// ******************* FILE INFO *******************
// File Name: browser_chrome.dart
// Description: Browser chrome frame for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _BrowserChrome extends StatelessWidget {
  final bool compact;
  const _BrowserChrome({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double h = compact ? 22 : 28;
    return Container(
      height: h,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 4),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 4),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: compact ? 10 : 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
