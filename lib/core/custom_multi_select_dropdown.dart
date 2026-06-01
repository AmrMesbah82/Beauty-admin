// ******************* FILE INFO *******************
// File Name: custom_multi_select_dropdown.dart
// Created by: Amr Mesbah
// Matches visual style of CustomDropdownFormFieldInvMaster
// Supports checkbox multi-select with List<String> output

import 'package:beauty_admin/core/theme/app_colors.dart';
import 'package:beauty_admin/core/theme/app_font_style.dart';


import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_svg.dart';


class CustomMultiSelectDropdown extends StatefulWidget {
  final List<String>               selectedValues;
  final List<Map<String, String>>  items;
  final Function(List<String>)     onChanged;
  final double?                    widthIcon;
  final double?                    heightIcon;
  final Color?                     primaryColor;
  final Color?                     dropdownColor;
  final double?                    width;
  final double?                    height;
  final double?                    spaceHeight;
  final double?                    dropdownWidth;
  final Widget?                    hint;
  final String?                    label;
  final String?                    iconPath;
  final double                     borderRadius;
  final TextDirection               textDirection;
  final String?                    labelPrefixSvg;
  final double?                    labelPrefixSvgSize;
  final Color?                     labelPrefixColor;

  const CustomMultiSelectDropdown({
    Key? key,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.primaryColor,
    this.dropdownColor,
    this.width,
    this.height,
    this.spaceHeight,
    this.dropdownWidth,
    this.hint,
    this.label,
    this.iconPath,
    this.borderRadius  = 8.0,
    this.textDirection = TextDirection.ltr,
    this.labelPrefixSvg,
    this.labelPrefixSvgSize,
    this.labelPrefixColor,
  }) : super(key: key);

  @override
  State<CustomMultiSelectDropdown> createState() =>
      _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState
    extends State<CustomMultiSelectDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  // Local copy so checkbox state updates instantly without waiting for parent
  late List<String> _selected;

  bool get _isRtl => widget.textDirection == TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedValues);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _dropdownKey.currentContext;
      if (ctx != null && mounted) {
        final box = ctx.findRenderObject() as RenderBox;
        setState(() => _popupWidth = box.size.width);
      }
    });
  }

  @override
  void didUpdateWidget(CustomMultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selected = List<String>.from(widget.selectedValues);
    }
  }

  void _toggleItem(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
    widget.onChanged(List<String>.from(_selected));
  }

  // ── Display text for the button ───────────────────────────────────────────
  String _buildDisplayText() {
    if (_selected.isEmpty) return '';

    // Map keys → display values
    final labels = _selected.map((key) {
      final match = widget.items.firstWhere(
            (e) => e['key'] == key,
        orElse: () => {'key': key, 'value': key},
      );
      return match['value'] ?? key;
    }).toList();

    if (labels.length <= 2) return labels.join(', ');
    return '${labels.take(2).join(', ')} +${labels.length - 2}';
  }

  Widget _arrowIcon() => CustomSvg(
    assetPath: 'assets/arrowdown.svg',
    width:     20.w,
    height:    20.h,
  );

  // ── Custom button (closed state) ──────────────────────────────────────────
  Widget _buildCustomButton(double fieldHeight) {
    final hasValue   = _selected.isNotEmpty;
    final displayText = _buildDisplayText();

    return Container(
      height:  fieldHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color:        widget.dropdownColor ?? const Color(0xFFF1F2ED),
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
      ),
      child: Row(children: [
        if (widget.iconPath != null) ...[
          SvgPicture.asset(
            widget.iconPath!,
            width:  (widget.widthIcon  ?? 16).w,
            height: (widget.heightIcon ?? 16).w,
            colorFilter: widget.primaryColor != null
                ? ColorFilter.mode(widget.primaryColor!, BlendMode.srcIn)
                : null,
          ),
          SizedBox(width: 6.w),
        ],
        Expanded(
          child: hasValue
              ? Text(
            displayText,
            textDirection: widget.textDirection,
            textAlign: _isRtl ? TextAlign.right : TextAlign.left,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          )
              : DefaultTextStyle.merge(
            child: Directionality(
              textDirection: widget.textDirection,
              child: widget.hint ?? const SizedBox.shrink(),
            ),
          ),
        ),
        _arrowIcon(),
      ]),
    );
  }

  // ── Label row ─────────────────────────────────────────────────────────────
  Widget _buildLabelRow() {
    final double prefixSize = widget.labelPrefixSvgSize ?? 14;

    final Widget? prefixIcon = widget.labelPrefixSvg != null
        ? SvgPicture.asset(
      widget.labelPrefixSvg!,
      width:  prefixSize.w,
      height: prefixSize.h,
      colorFilter: widget.labelPrefixColor != null
          ? ColorFilter.mode(
          widget.labelPrefixColor!, BlendMode.srcIn)
          : null,
    )
        : null;

    final Widget labelText = Text(
      widget.label!,
      textDirection: widget.textDirection,
      style:
      StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
    );

    final List<Widget> innerChildren = [];

    if (_isRtl) {
      innerChildren.add(labelText);
      if (prefixIcon != null) {
        innerChildren.add(SizedBox(width: 5.w));
        innerChildren.add(prefixIcon);
      }
    } else {
      if (prefixIcon != null) {
        innerChildren.add(prefixIcon);
        innerChildren.add(SizedBox(width: 5.w));
      }
      innerChildren.add(labelText);
    }

    return Row(
      mainAxisSize:       MainAxisSize.max,
      mainAxisAlignment:  MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: innerChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = widget.height ?? 36;
    final Color  checkColor  =
        widget.primaryColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          _buildLabelRow(),
          SizedBox(height: widget.spaceHeight ?? 6.h),
        ],

        Directionality(
          textDirection: widget.textDirection,
          child: Container(
            key:    _dropdownKey,
            width:  widget.width,
            height: fieldHeight.h,
            decoration: BoxDecoration(
              color:        widget.dropdownColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded:   true,
                // We never set a single "value" — multi-select has no concept
                value:        null,
                // Suppress the default hint when items are selected
                hint:         _selected.isEmpty
                    ? Directionality(
                    textDirection: widget.textDirection,
                    child: widget.hint ?? const SizedBox.shrink())
                    : null,
                customButton: _buildCustomButton(fieldHeight),
                onChanged:    (_) {}, // handled inside item onTap
                buttonStyleData: ButtonStyleData(
                  height:  fieldHeight.h,
                  width:   widget.width?.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: widget.dropdownColor ??
                        const Color(0xFFF1F2ED),
                    borderRadius:
                    BorderRadius.circular(widget.borderRadius.r),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  width: widget.dropdownWidth ??
                      _popupWidth ??
                      widget.width ??
                      100.w,
                  maxHeight: 225.h,
                  offset:    const Offset(0, 0),
                  decoration: BoxDecoration(
                    color:        AppColors.background,
                    borderRadius:
                    BorderRadius.circular(widget.borderRadius.r),
                    border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset:     const Offset(0, 2),
                      ),
                    ],
                  ),
                  scrollbarTheme: ScrollbarThemeData(
                    thumbVisibility:
                    MaterialStateProperty.all(false),
                    trackVisibility:
                    MaterialStateProperty.all(false),
                    thickness: MaterialStateProperty.all(0),
                    radius:    Radius.zero,
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height:  fieldHeight.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  overlayColor:
                  MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return checkColor.withValues(alpha: 0.08);
                    }
                    return null;
                  }),
                ),
                iconStyleData: const IconStyleData(
                  icon: SizedBox.shrink(), // hidden — customButton has arrow
                ),
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.text),
                // ── Items with checkboxes ──────────────────────────────
                items: widget.items.map((item) {
                  final key     = item['key']   ?? '';
                  final label   = item['value'] ?? '';
                  final checked = _selected.contains(key);

                  return DropdownMenuItem<String>(
                    value:   key,
                    enabled: false, // we handle tap ourselves
                    child: InkWell(
                      onTap: () => _toggleItem(key),
                      child: Directionality(
                        textDirection: widget.textDirection,
                        child: Row(
                          children: [
                            // ── Checkbox ──────────────────────────
                            Container(
                              width:  18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                color: checked
                                    ? checkColor
                                    : Colors.transparent,
                                borderRadius:
                                BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: checked
                                      ? checkColor
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              child: checked
                                  ? Icon(Icons.check,
                                  size:  12.sp,
                                  color: Colors.white)
                                  : null,
                            ),
                            SizedBox(width: 10.w),
                            // ── Label ─────────────────────────────
                            Expanded(
                              child: Text(
                                label,
                                textDirection: widget.textDirection,
                                textAlign: _isRtl
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: StyleText.fontSize12Weight400
                                    .copyWith(
                                  color: AppColors.text,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}