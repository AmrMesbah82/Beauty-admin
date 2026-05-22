part of '../../pages/contact_us_preview.dart';

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 13,
          fontWeight: FontWeight.w700, color: _kPink));
}
