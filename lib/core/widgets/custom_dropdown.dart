/// ******************* FILE INFO *******************
/// File Name: custom_dropdown.dart
/// UPDATED: primaryColor is now REQUIRED (not optional).
///          All hover, focus, selected, and border colors
///          are driven by the required primaryColor parameter.
/// Author: Amr Mesbah

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../theme/app_colors.dart';
import '../theme/app_font_style.dart';


class CustomDropdownFormFieldInvMaster extends StatefulWidget {
  final String? selectedValue;
  final double? widthIcon;
  final Color primaryColor;          // ← REQUIRED, no longer optional
  final Color? dropdownColor;
  final double? heightIcon;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  final String Function(String?)? validator;
  final double? width;
  final double? height;
  final double? spaceHeight;
  final double? dropdownWidth;
  final Widget? hint;
  final String? label;

  /// Optional widget placed at the trailing end of the label row.
  final Widget? labelTrailing;

  final String? iconPath;
  final Map<String, Color>? itemColors;
  final bool showColorDots;
  final double borderRadius;

  const CustomDropdownFormFieldInvMaster({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    required this.primaryColor,       // ← REQUIRED
    this.validator,
    this.width,
    this.height,
    this.spaceHeight,
    this.dropdownWidth,
    this.hint,
    this.dropdownColor,
    this.label,
    this.labelTrailing,
    this.iconPath,
    this.itemColors,
    this.showColorDots = false,
    this.borderRadius = 4,
  }) : super(key: key);

  @override
  State<CustomDropdownFormFieldInvMaster> createState() =>
      _CustomDropdownFormFieldInvMasterState();
}

class _CustomDropdownFormFieldInvMasterState
    extends State<CustomDropdownFormFieldInvMaster> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  @override
  void initState() {
    super.initState();
    internalSelectedValue = widget.selectedValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _dropdownKey.currentContext;
      if (ctx != null && mounted) {
        final box = ctx.findRenderObject() as RenderBox;
        setState(() => _popupWidth = box.size.width);
      }
    });
  }

  @override
  void didUpdateWidget(CustomDropdownFormFieldInvMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      internalSelectedValue = widget.selectedValue;
    }
  }

  // ── Color helper ──────────────────────────────────────────────────────────
  Color? _getItemColor(Map<String, String> item) {
    if (widget.itemColors == null) return null;
    final key   = item['key']   ?? '';
    final value = item['value'] ?? '';
    return widget.itemColors![key] ?? widget.itemColors![value];
  }

  // ── Dropdown item builder ─────────────────────────────────────────────────
  Widget _buildDropdownItem(Map<String, String> item) {
    final Color? itemColor = _getItemColor(item);

    if (widget.showColorDots && itemColor != null) {
      return Row(
        children: [
          Container(
            width: 8.sp,
            height: 8.sp,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item['value'] ?? '',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      item['value'] ?? '',
      style: StyleText.fontSize12Weight400.copyWith(
        color: itemColor ?? AppColors.text,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Arrow icon ────────────────────────────────────────────────────────────
  Widget _arrowIcon() => CustomSvg(
    assetPath: "assets/arrowdown.svg",
    width: 20.w,
    height: 20.h,
    fit: BoxFit.fill,
  );

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = widget.height ?? 36;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row ──────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.label!,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text),
                ),
              ),
              if (widget.labelTrailing != null) ...[
                SizedBox(width: 8.w),
                widget.labelTrailing!,
              ],
            ],
          ),
          SizedBox(height: widget.spaceHeight ?? 6.h),
        ],

        // ── Dropdown container ─────────────────────────────────────────────
        Container(
          key: _dropdownKey,
          width: widget.width,
          height: fieldHeight.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            validator: widget.validator,
            builder: (FormFieldState<String> field) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: widget.hint,
                  value: widget.items.any(
                          (e) => e['key'] == internalSelectedValue)
                      ? internalSelectedValue
                      : null,
                  onChanged: (value) {
                    setState(() {
                      internalSelectedValue = value;
                      field.didChange(value);
                    });
                    widget.onChanged(value);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: fieldHeight.h,
                    width: widget.width?.w,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: widget.dropdownColor ?? const Color(0xFFF1F2ED),
                      borderRadius:
                      BorderRadius.circular(widget.borderRadius.r),
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: widget.dropdownWidth ??
                        _popupWidth ??
                        widget.width ??
                        100.w,
                    maxHeight: 225.h,
                    offset: const Offset(0, 0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                      BorderRadius.circular(4.r),
                      border: Border.all(
                        color: widget.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility:
                      MaterialStateProperty.all(false),
                      trackVisibility:
                      MaterialStateProperty.all(false),
                      thickness: MaterialStateProperty.all(0),
                      radius: Radius.zero,
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: fieldHeight.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    overlayColor:
                    MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                          if (states.contains(MaterialState.hovered)) {
                            return widget.primaryColor.withValues(alpha: 0.12);
                          }
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.selected)) {
                            return widget.primaryColor.withValues(alpha: 0.08);
                          }
                          return null;
                        }),
                  ),
                  iconStyleData: IconStyleData(icon: _arrowIcon()),
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                  items: widget.items.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit['key'],
                      child: _buildDropdownItem(unit),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}