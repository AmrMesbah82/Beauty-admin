/// ******************* FILE INFO *******************
/// File Name: custom_textformfield.dart
/// Description: this is custom Text field can reuse
/// Created by: Amr Mesbah
/// Last Update: 09/05/2026
/// Changed: Added optional labelTrailing widget rendered at the end of the label row

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';


import '../theme/app_colors.dart';
import '../theme/app_font_style.dart';


class CustomValidatedTextFieldMaster extends StatefulWidget {
  final String? label;
  final String hint;
  final TextEditingController controller;
  final double height;
  final double? width;
  final int maxLines;
  final bool enabled;
  final bool showCharCount;
  final ValueChanged<String>? onChanged;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool onlyDigits;
  final bool submitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;

  /// Optional widget placed at the trailing end of the label row.
  /// Only rendered when [label] is not null.
  /// Example: a status toggle, an icon button, a badge, etc.
  final Widget? labelTrailing;

  /// Dynamic primary color from CMS branding (used for focused border,
  /// cursor, and text selection highlight).
  /// Falls back to AppColors.primary if not provided.
  final Color? primaryColor;

  /// Hard character cap (default 500)
  final int maxLength;

  /// Minimum character requirement (default 0 = no minimum)
  final int minLength;

  const CustomValidatedTextFieldMaster({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.height = 36,
    this.width,
    this.maxLines = 1,
    this.enabled = true,
    this.showCharCount = false,
    this.onChanged,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.labelTrailing,
    this.primaryColor,
    this.maxLength = 500,
    this.minLength = 0,
  });

  @override
  State<CustomValidatedTextFieldMaster> createState() =>
      _CustomValidatedTextFieldMasterState();
}

class _CustomValidatedTextFieldMasterState
    extends State<CustomValidatedTextFieldMaster> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomValidatedTextFieldMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String _toArabicNum(int number) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicNums[int.parse(e)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final Color resolvedPrimary = widget.primaryColor ?? Color(0xFFD16F9A);

    final String text = widget.controller.text;

    final bool isNotDigits =
        widget.onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);
    final bool isEmpty    = text.trim().isEmpty;
    final bool isTooShort =
        !isEmpty && widget.minLength > 0 && text.trim().length < widget.minLength;

    final bool showError = (widget.submitted && isEmpty) ||
        (widget.submitted && isTooShort) ||
        (!isEmpty && isNotDigits);

    String errorText = '';
    if (isEmpty) {
      errorText = widget.textDirection == TextDirection.rtl
          ? "هذا الحقل مطلوب"
          : "This field is required.";
    } else if (isTooShort) {
      errorText = widget.textDirection == TextDirection.rtl
          ? "الحد الأدنى ${widget.minLength} حرف"
          : "Minimum ${widget.minLength} characters required.";
    } else if (isNotDigits) {
      errorText = "Only numbers are allowed.";
    }

    final bool lightMode   = Theme.of(context).brightness == Brightness.light;
    final bool showCounter = widget.showCharCount && !showError;

    final Color resolvedFill = widget.fillColor ??
        (lightMode ? const Color(0xFFF1F2ED) : AppColors.background);

    final List<TextInputFormatter> formatters = [
      if (widget.onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ];

    final int currentLen = widget.controller.text.characters.length;
    final borderRadius   = BorderRadius.circular(4.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row ─────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.label!,
                  textDirection: widget.textDirection,
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
          SizedBox(height: 6.h),
        ],

        // ── Input field ───────────────────────────────────────────────────
        SizedBox(
          height: widget.height.h,
          width:  widget.width,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary:   resolvedPrimary,
                onSurface: AppColors.text,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor:       resolvedPrimary.withValues(alpha: 0.3),
                selectionHandleColor: resolvedPrimary,
                cursorColor:          resolvedPrimary,
              ),
            ),
            child: TextFormField(
              controller:        widget.controller,
              maxLines:          widget.maxLines,
              enabled:           widget.enabled,
              textDirection:     widget.textDirection,
              textAlign:         widget.textAlign,
              cursorColor:       resolvedPrimary,
              autovalidateMode:  AutovalidateMode.always,
              validator:         (_) => showError ? '' : null,
              keyboardType:
              widget.onlyDigits ? TextInputType.number : TextInputType.text,
              style: widget.textStyle ??
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onChanged:            widget.onChanged,
              inputFormatters:      formatters,
              maxLength:            widget.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofillHints:        const [],
              decoration: InputDecoration(
                errorStyle:  const TextStyle(height: 0, fontSize: 0),
                hoverColor:  Colors.transparent,
                hintText:    widget.hint,
                hintStyle: widget.hintStyle ??
                    StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                filled:      true,
                fillColor:   resolvedFill,
                isDense:     true,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                    vertical: 13.h, horizontal: 8.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  const BorderSide(color: Colors.transparent, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  const BorderSide(color: Colors.transparent, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: resolvedPrimary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide:
                  BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        // ── Fixed-height lane: error OR counter OR nothing ─────────────────
        SizedBox(
          height: 18.h,
          child: showError
              ? Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText,
              style: AppTextStyles.font10BlackCairoRegular.copyWith(
                fontWeight: FontWeight.w700,
                height:     1.1,
                color:      Colors.red,
              ),
            ),
          )
              : (showCounter
              ? Align(
            alignment: widget.textDirection == TextDirection.rtl
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              widget.textDirection == TextDirection.rtl
                  ? "${_toArabicNum(currentLen)}/${_toArabicNum(widget.maxLength)}"
                  : "$currentLen/${widget.maxLength}",
              style: AppTextStyles.font12MediumGreyRegularCairo,
            ),
          )
              : const SizedBox.shrink()),
        ),
      ],
    );
  }
}