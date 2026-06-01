// ******************* FILE INFO *******************
// File Name: tablet_content_panel.dart
// Description: Tablet content panel for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _TabletContentPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _TabletContentPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridTabletPreview(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ColorPick.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.svgUrl.isNotEmpty) ...[
            Center(
              child: _netImg(
                url: section.svgUrl,
                width: 160.w,
                height: 160.h,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Text(
            _ab(section.description, isRtl),
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: 11.sp,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALUES GRIDS
// ═════════════════════════════════════════════════════════════════════════════
