// ******************* FILE INFO *******************
// File Name: values_grid_desktop_preview.dart
// Description: Values grid desktop layout for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _ValuesGridDesktopPreview extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _ValuesGridDesktopPreview({
    required this.values,
    required this.primaryColor,
    required this.secondaryColor,
    this.isRtl = false,
  });

  @override
  State<_ValuesGridDesktopPreview> createState() => _ValuesGridDesktopPreviewState();
}

class _ValuesGridDesktopPreviewState extends State<_ValuesGridDesktopPreview> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
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
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: List.generate(widget.values.length, (i) {
              final v = widget.values[i];
              return _ValueGridCardPreview(
                title: _ab(v.title, widget.isRtl),
                iconUrl: v.iconUrl,
                isSelected: i == idx,
                primaryColor: widget.primaryColor,
                width: 100.w,
                iconSize: 22.sp,
                fontSize: 9.sp,
                padding: 10.r,
                onTap: () => setState(() => _selectedIndex = i),
              );
            }),
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
