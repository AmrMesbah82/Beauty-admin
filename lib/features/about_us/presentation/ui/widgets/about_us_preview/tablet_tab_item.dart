// ******************* FILE INFO *******************
// File Name: tablet_tab_item.dart
// Description: Tablet tab item for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _TabletTabItem extends StatefulWidget {
  final String label, iconUrl;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;

  const _TabletTabItem({
    required this.label,
    required this.iconUrl,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  State<_TabletTabItem> createState() => _TabletTabItemState();
}

class _TabletTabItemState extends State<_TabletTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverBg = _hoverTint(widget.primaryColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.primaryColor
                : (_hovered ? hoverBg : _kSurface),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: widget.isSelected
                  ? widget.primaryColor
                  : (_hovered ? widget.primaryColor.withOpacity(0.3) : _kDivider),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.iconUrl.isNotEmpty)
                _netImg(
                  url: widget.iconUrl,
                  width: 16.sp,
                  height: 16.sp,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    widget.isSelected ? Colors.white : widget.primaryColor,
                    BlendMode.srcIn,
                  ),
                )
              else
                Icon(Icons.image_outlined,
                    size: 16.sp,
                    color: widget.isSelected ? Colors.white : widget.primaryColor),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected
                        ? Colors.white
                        : (_hovered ? widget.primaryColor : widget.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
