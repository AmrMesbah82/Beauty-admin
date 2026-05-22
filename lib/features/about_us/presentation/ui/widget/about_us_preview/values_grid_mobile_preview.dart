part of '../../pages/about_us_preview.dart';

class _ValuesGridMobilePreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final double fakeWidth;

  const _ValuesGridMobilePreview({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fakeWidth,
  });

  @override
  State<_ValuesGridMobilePreview> createState() => _ValuesGridMobilePreviewState();
}

class _ValuesGridMobilePreviewState extends State<_ValuesGridMobilePreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    final double innerW = widget.fakeWidth - 16.w * 2 - 12.w * 2;
    final double gap = 7.w;
    final double cardW = (innerW - gap) / 2;
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(widget.values.length, (i) {
            final v = widget.values[i];
            return _ValueGridCardPreview(
              title: _ab(v.title, widget.isRtl),
              iconUrl: v.iconUrl,
              isSelected: i == idx,
              primaryColor: widget.primaryColor,
              width: cardW,
              iconSize: 16.sp,
              fontSize: 10.sp,
              padding: 9.r,
              rowLayout: true,
              onTap: () => setState(() => _selectedIndex = i),
            );
          }),
        ),
        SizedBox(height: 10.h),
        _ValueDetailPanelPreview(
          value: selected,
          isRtl: widget.isRtl,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALUE GRID CARD
// ═════════════════════════════════════════════════════════════════════════════
