/// Module: core › main_widgets › dialogs

part of '../../custom_dialog.dart';

// ******************* FILE INFO *******************
// File Name: confirm_dialog.dart
// Description: Confirm dialog widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets › dialogs

Future<void> showConfirmDialog({
  required BuildContext context,
  String title = 'Confirm',
  String subtitle = 'Are you sure you want to proceed?',
  String confirmLabel = 'Yes',
  String cancelLabel = 'No',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  /// Pass a custom SVG asset path for the icon, e.g. 'assets/icons/cancel.svg'
  String? iconAsset,
  /// Fallback icon widget if no SVG asset is given
  Widget? iconWidget,
})
{
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => _ConfirmDialog(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      iconAsset: iconAsset,
      iconWidget: iconWidget,
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? iconAsset;
  final Widget? iconWidget;

  const _ConfirmDialog({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.iconAsset,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 411.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          // Icon
          _buildIcon(),
          SizedBox(height: 16.h),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24.h),
          // Buttons row
          Row(
            children: [
              Expanded(
                child: _secondaryBtn(
                  label: cancelLabel,
                  onTap: () {
                    Navigator.of(context).pop();
                    onCancel?.call();
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _primaryBtn(
                  label: confirmLabel,
                  onTap: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconWidget != null) return iconWidget!;
    if (iconAsset != null) {
      return SvgPicture.asset(iconAsset!, width: 60.r, height: 60.r);
    }
    // Default: red X circle (matches Figma design)
    return Container(
      width: 60.r,
      height: 60.r,
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.close_rounded, color: Colors.white, size: 36.r),
    );
  }
}

// ─────────────────────────────────────────────
