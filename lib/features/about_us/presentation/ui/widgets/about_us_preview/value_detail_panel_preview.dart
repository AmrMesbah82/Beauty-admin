// ******************* FILE INFO *******************
// File Name: value_detail_panel_preview.dart
// Description: Value detail panel for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _ValueDetailPanelPreview extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _ValueDetailPanelPreview({
    required this.value,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _ab(value.title, isRtl);
    final String shortDesc = _ab(value.shortDescription, isRtl);
    final String fullDesc = _ab(value.description, isRtl);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: value.iconUrl.isNotEmpty
                  ? _netImg(
                url: value.iconUrl,
                width: 30.r,
                height: 30.r,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              )
                  : Icon(Icons.star_outline, size: 20.sp, color: primaryColor),
            ),
          ),
          SizedBox(height: 10.h),
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if (shortDesc.isNotEmpty) ...[
            Text(
              shortDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryBlack,
                height: 1.6,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (fullDesc.isNotEmpty)
            Text(
              fullDesc,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryBlack,
                height: 1.65,
              ),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════
