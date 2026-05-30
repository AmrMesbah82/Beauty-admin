part of '../../pages/overview_main.dart';

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
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final EdgeInsets? containerPadding;
  final Color? containerColor;
  final double? borderRadius;
  final double? spacing;
  final double? tabHorizontalPadding;
  final double? tabVerticalPadding;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final TextStyle? textStyle;
  final bool equalWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        color: containerColor ?? ColorPick.white,
      ),
      padding: containerPadding ?? EdgeInsets.all(8.sp),
      child: Row(
        mainAxisSize: equalWidth ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(tabs.length * 2 - 1, (index) {
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
                  ),
                )
              : _buildTab(
                  title: tabs[tabIndex],
                  isSelected: isSelected,
                  onTap: () => onTabSelected(tabIndex),
                );
        }),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: isSelected
              ? (selectedColor ?? ColorPick.primary)
              : (unselectedColor ?? AppColors.secondaryText),
        ),
        padding: EdgeInsets.symmetric(
          vertical: tabVerticalPadding ?? 6.sp,
          horizontal: tabHorizontalPadding ?? 6.sp,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              title,
              style: (textStyle ?? StyleText.fontSize14Weight500).copyWith(
                height: 1,
                color: isSelected
                    ? (selectedTextColor ?? Colors.white)
                    : (unselectedTextColor ?? AppColors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
