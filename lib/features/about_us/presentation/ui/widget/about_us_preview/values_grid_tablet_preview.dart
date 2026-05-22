part of '../../pages/about_us_preview.dart';

class _ValuesGridTabletPreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _ValuesGridTabletPreview({
    required this.values,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_ValuesGridTabletPreview> createState() => _ValuesGridTabletPreviewState();
}

class _ValuesGridTabletPreviewState extends State<_ValuesGridTabletPreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: widget.secondaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(widget.values.length, (i) {
                final v = widget.values[i];
                return _ValueGridCardPreview(
                  title: _ab(v.title, widget.isRtl),
                  iconUrl: v.iconUrl,
                  isSelected: i == idx,
                  primaryColor: widget.primaryColor,
                  width: 88.w,
                  iconSize: 18.sp,
                  fontSize: 8.sp,
                  padding: 9.r,
                  onTap: () => setState(() => _selectedIndex = i),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          _ValueDetailPanelPreview(
            value: selected,
            isRtl: widget.isRtl,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════
