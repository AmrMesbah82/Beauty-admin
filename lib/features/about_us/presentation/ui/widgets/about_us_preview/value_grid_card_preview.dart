// ******************* FILE INFO *******************
// File Name: value_grid_card_preview.dart
// Description: Value grid card for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _ValueGridCardPreview extends StatefulWidget {
  final String title, iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final double width, iconSize, fontSize, padding;
  final VoidCallback onTap;
  final bool rowLayout;

  const _ValueGridCardPreview({
    required this.title,
    required this.iconUrl,
    required this.isSelected,
    required this.primaryColor,
    required this.width,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    required this.onTap,
    this.rowLayout = false,
  });

  @override
  State<_ValueGridCardPreview> createState() => _ValueGridCardPreviewState();
}

class _ValueGridCardPreviewState extends State<_ValueGridCardPreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    final Widget iconWidget = widget.iconUrl.isNotEmpty
        ? _netImg(
      url: widget.iconUrl,
      width: widget.iconSize,
      height: widget.iconSize,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        sel ? Colors.white : widget.primaryColor,
        BlendMode.srcIn,
      ),
    )
        : Icon(
      Icons.star_outline,
      size: widget.iconSize,
      color: sel ? Colors.white : widget.primaryColor,
    );

    final Widget titleWidget = Text(
      widget.title,
      textAlign: widget.rowLayout ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w600,
        color: sel ? Colors.white : (_hovered ? widget.primaryColor : Colors.black87),
        height: 1.35,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.rowLayout ? null : widget.width,
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel ? widget.primaryColor : (_hovered ? hoverBg : Colors.white),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: sel
                ? [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
            border: Border.all(
              color: _hovered && !sel ? widget.primaryColor.withValues(alpha: 0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.rowLayout
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(width: 6.w),
              Expanded(child: titleWidget),
            ],
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(height: 6.h),
              titleWidget,
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL
// ═════════════════════════════════════════════════════════════════════════════
