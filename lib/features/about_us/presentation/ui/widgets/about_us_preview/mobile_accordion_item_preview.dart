// ******************* FILE INFO *******************
// File Name: mobile_accordion_item_preview.dart
// Description: Mobile accordion item for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _MobileAccordionItemPreview extends StatefulWidget {
  final _MobileTabDataPreview tab;
  final List<AboutValueItem> values;
  final bool isExpanded, isRtl;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  final double fakeWidth;

  const _MobileAccordionItemPreview({
    required this.tab,
    required this.values,
    required this.isExpanded,
    required this.onTap,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fakeWidth,
  });

  @override
  State<_MobileAccordionItemPreview> createState() => _MobileAccordionItemPreviewState();
}

class _MobileAccordionItemPreviewState extends State<_MobileAccordionItemPreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final List<AboutValueItem> gridValues =
    (widget.tab.tabIndex == 2 && widget.values.length > 1)
        ? widget.values.sublist(1)
        : (widget.tab.tabIndex == 2 ? <AboutValueItem>[] : widget.values);

    final Color hoverBg = _hoverTint(widget.primaryColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.isExpanded
            ? ColorPick.white
            : (_hovered ? hoverBg : ColorPick.white),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _hovered && !widget.isExpanded
              ? widget.primaryColor.withValues(alpha: 0.25)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? widget.primaryColor
                            : widget.secondaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: widget.tab.iconUrl.isNotEmpty
                            ? _netImg(
                          url: widget.tab.iconUrl,
                          width: 18.sp,
                          height: 18.sp,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            widget.isExpanded ? Colors.white : widget.primaryColor,
                            BlendMode.srcIn,
                          ),
                        )
                            : Icon(
                          Icons.image_outlined,
                          size: 16.sp,
                          color: widget.isExpanded ? Colors.white : AppColors.textButton,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.tab.label,
                        style: StyleText.fontSize16Weight600.copyWith(
                          fontSize: 12.sp,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? widget.primaryColor
                            : widget.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        widget.isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: widget.isExpanded ? Colors.white : widget.primaryColor,
                        size: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tab.tabIndex != 2 && widget.tab.svgUrl.isNotEmpty) ...[
                    Center(
                      child: _netImg(
                        url: widget.tab.svgUrl,
                        width: widget.fakeWidth - 16.w * 2 - 12.w * 2,
                        height: 150.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  if (widget.tab.tabIndex != 2)
                    Text(
                      widget.tab.fullText,
                      style: StyleText.fontSize13Weight400.copyWith(
                        fontSize: 10.sp,
                        height: 1.7,
                      ),
                    ),
                  if (widget.tab.tabIndex == 2)
                    _ValuesGridMobilePreview(
                      values: gridValues,
                      isRtl: widget.isRtl,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                      fakeWidth: widget.fakeWidth,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
