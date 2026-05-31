// ******************* FILE INFO *******************
// File Name: mobile_top_tab_item_preview.dart
// Description: Mobile top tab item for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _MobileTopTabItemPreview extends StatefulWidget {
  final String label;
  final String svgAsset;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _MobileTopTabItemPreview({
    required this.label,
    required this.svgAsset,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_MobileTopTabItemPreview> createState() => _MobileTopTabItemPreviewState();
}

class _MobileTopTabItemPreviewState extends State<_MobileTopTabItemPreview> {
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
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: sel ? Colors.transparent : (_hovered ? _hoverTint(widget.primaryColor) : Colors.transparent),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44.sp,
                height: 44.sp,
                decoration: BoxDecoration(
                  color: sel ? widget.primaryColor : widget.secondaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: widget.svgAsset.isNotEmpty
                      ? _netImg(
                    url: widget.svgAsset,
                    width: 24.sp,
                    height: 24.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      sel ? Colors.white : widget.primaryColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : Icon(
                    Icons.image_outlined,
                    size: 24.sp,
                    color: sel ? Colors.white : widget.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                widget.label,
                style: StyleText.fontSize20Weight600.copyWith(
                  fontSize: 16.sp,
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
