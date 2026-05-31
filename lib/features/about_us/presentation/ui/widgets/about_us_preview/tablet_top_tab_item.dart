// ******************* FILE INFO *******************
// File Name: tablet_top_tab_item.dart
// Description: Tablet top tab item for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _TabletTopTabItem extends StatefulWidget {
  final String label;
  final String svgAsset;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _TabletTopTabItem({
    required this.label,
    required this.svgAsset,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_TabletTopTabItem> createState() => _TabletTopTabItemState();
}

class _TabletTopTabItemState extends State<_TabletTopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border(
              bottom: BorderSide(
                color: sel ? widget.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: widget.svgAsset.isNotEmpty
                      ? _netImg(
                    url: widget.svgAsset,
                    width: 22.sp,
                    height: 22.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : Icon(
                    Icons.image_outlined,
                    size: 22.sp,
                    color: sel ? Colors.white : widget.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.label,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: sel ? widget.primaryColor : AppColors.secondaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
