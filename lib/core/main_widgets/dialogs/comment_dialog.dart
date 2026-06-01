part of '../../custom_dialog.dart';

// ******************* FILE INFO *******************
// File Name: comment_dialog.dart
// Description: Comment/justification dialog widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets › dialogs


/// Module: core › main_widgets › dialogs


Future<void> showCommentDialog({
  required BuildContext context,
  String title = 'Comment',
  String fieldLabel = 'Justifications',
  String hint = 'Text here',
  String submitLabel = 'Submit',
  int maxLength = 500,
  TextDirection textDirection = TextDirection.ltr,
  /// Pass SVG asset for the title icon, or leave null for default X icon
  String? titleIconAsset,
  void Function(String comment)? onSubmit,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _CommentDialog(
      title: title,
      fieldLabel: fieldLabel,
      hint: hint,
      submitLabel: submitLabel,
      maxLength: maxLength,
      textDirection: textDirection,
      titleIconAsset: titleIconAsset,
      onSubmit: onSubmit,
    ),
  );
}

class _CommentDialog extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String hint;
  final String submitLabel;
  final int maxLength;
  final TextDirection textDirection;
  final String? titleIconAsset;
  final void Function(String)? onSubmit;

  const _CommentDialog({
    required this.title,
    required this.fieldLabel,
    required this.hint,
    required this.submitLabel,
    required this.maxLength,
    required this.textDirection,
    this.titleIconAsset,
    this.onSubmit,
  });

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_controller.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit?.call(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 539.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              _TitleIcon(assetPath: widget.titleIconAsset),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.title,
                  style:
                  StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.text),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 18.r, color: AppColors.text),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Text field ──
          CustomValidatedTextFieldMaster(
            label: widget.fieldLabel,
            hint: widget.hint,
            controller: _controller,
            height: 100,
            maxLines: 5,
            maxLength: widget.maxLength,
            showCharCount: true,
            submitted: _submitted,
            textDirection: widget.textDirection,
            onChanged: (_) => setState(() {}),
          ),

          SizedBox(height: 16.h),

          // ── Submit button ──
          Align(
            alignment: Alignment.centerRight,
            child: _primaryBtn(
              label: widget.submitLabel,
              onTap: _handleSubmit,
              width: 120.w,
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
