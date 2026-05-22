part of '../../pages/about_us_preview.dart';

class _DesktopRightPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _DesktopRightPanel({
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
      return _ValuesGridDesktopPreview(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 13.sp,
                height: 1.75,
              ),
            ),
          ),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            _netImg(
              url: section.svgUrl,
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TABLET COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════
