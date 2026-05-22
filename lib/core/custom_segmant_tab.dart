import 'package:beauty_admin/core/theme/appcolors.dart';
import 'package:beauty_admin/core/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';




/// A customizable segmented tabs widget that can be reused throughout the app
///
/// Example usage:
/// ```dart
/// CustomSegmentedTabs(
///   tabs: ['المخطط', 'الجدول'],
///   selectedIndex: controller.selectedTabIndex,
///   onTabSelected: (index) {
///     controller.updateTabIndex(index);
///   },
/// )
/// ```
class CustomSegmentedTabs extends StatelessWidget {
  const CustomSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.containerPadding,
    this.containerColor,
    this.borderRadius,
    this.spacing,
    this.tabHorizontalPadding,
    this.tabVerticalPadding,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.textStyle,
    this.equalWidth = false,
    this.tabIcons,
    this.iconSize,
    this.iconSpacing,
  });

  /// List of tab titles
  final List<String> tabs;

  /// Currently selected tab index (0-based)
  final int selectedIndex;

  /// Callback when a tab is tapped, returns the index
  final ValueChanged<int> onTabSelected;

  /// Padding around the entire container
  final EdgeInsets? containerPadding;

  /// Background color of the container
  final Color? containerColor;

  /// Border radius of the container
  final double? borderRadius;

  /// Spacing between tabs
  final double? spacing;

  /// Horizontal padding for each tab
  final double? tabHorizontalPadding;

  /// Vertical padding for each tab
  final double? tabVerticalPadding;

  /// Background color for selected tab
  final Color? selectedColor;

  /// Background color for unselected tabs
  final Color? unselectedColor;

  /// Text color for selected tab
  final Color? selectedTextColor;

  /// Text color for unselected tabs
  final Color? unselectedTextColor;

  /// Custom text style (will be merged with color changes)
  final TextStyle? textStyle;

  /// If true, all tabs will have equal width
  final bool equalWidth;

  /// Optional list of SVG asset paths for each tab
  final List<String>? tabIcons;

  /// Size of the icon
  final double? iconSize;

  /// Spacing between icon and text
  final double? iconSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        color: containerColor ?? AppColors.field,
      ),
      padding: containerPadding ?? EdgeInsets.all(8.sp),
      child: Row(
        mainAxisSize: equalWidth ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(tabs.length * 2 - 1, (index) {
          // Even indices are tabs, odd indices are spacers
          if (index.isOdd) {
            return SizedBox(width: spacing ?? 10.sp);
          }

          final tabIndex = index ~/ 2;
          final isSelected = tabIndex == selectedIndex;

          return equalWidth
              ? Expanded(
            child: _buildTab(
              title: tabs[tabIndex],
              isSelected: isSelected,
              onTap: () => onTabSelected(tabIndex),
              iconPath: tabIcons != null && tabIndex < tabIcons!.length
                  ? tabIcons![tabIndex]
                  : null,
            ),
          )
              : _buildTab(
            title: tabs[tabIndex],
            isSelected: isSelected,
            onTap: () => onTabSelected(tabIndex),
            iconPath: tabIcons != null && tabIndex < tabIcons!.length
                ? tabIcons![tabIndex]
                : null,
          );
        }),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    String? iconPath,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelected
                ? (selectedColor ?? AppColors.primary)
                : (unselectedColor ?? AppColors.field),
          ),
          padding: EdgeInsets.symmetric(
            vertical: tabVerticalPadding ?? 6.sp,
            horizontal: tabHorizontalPadding ?? 6.sp,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconPath != null) ...[
                  SvgPicture.asset(
                    iconPath,
                    width:  32.sp,
                    height: 23.sp,
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? (selectedTextColor ?? AppColors.textButton)
                          : (unselectedTextColor ?? AppColors.secondaryBlack),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: iconSpacing ?? 6.w),
                ],
                FittedBox(
                  child: Text(
                    title.tr,
                    style: (textStyle ?? AppTextStyles.font14BlackSemiBoldCairo)
                        .copyWith(
                      height: 1,
                      color: isSelected
                          ? (selectedTextColor ?? AppColors.textButton)
                          : (unselectedTextColor ?? AppColors.secondaryBlack),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example Usage:
// Container(
//   width: 200,
//   height: 40,
//   child: CustomSegmentedTabs(
//     tabs: ['Client', 'Owner'],
//     tabIcons: [
//       'assets/beauty/contact_us/client.svg',
//       'assets/beauty/contact_us/owner.svg',
//     ],
//     selectedIndex: selectedIndex,
//     onTabSelected: (index) => setState(() => selectedIndex = index),
//     selectedColor: AppColors.secondaryPrimary,
//     unselectedColor: AppColors.background,
//     equalWidth: true,
//     spacing: 8,
//     iconSize: 16,
//     iconSpacing: 6,
//   ),
// ),