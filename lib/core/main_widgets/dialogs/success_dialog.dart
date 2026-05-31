/// Module: core › main_widgets › dialogs

part of '../../custom_dialog.dart';

// ******************* FILE INFO *******************
// File Name: success_dialog.dart
// Description: Success dialog widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets › dialogs

Future<void> showSuccessDialog({
  required BuildContext context,
  String title = 'Success',
  String subtitle = 'Operation completed successfully.',
  String closeLabel = 'Close',
  VoidCallback? onClose,
  /// Optional custom SVG icon path
  String? iconAsset,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => _SuccessDialog(
      title: title,
      subtitle: subtitle,
      closeLabel: closeLabel,
      onClose: onClose,
      iconAsset: iconAsset,
    ),
  );
}

class _SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String closeLabel;
  final VoidCallback? onClose;
  final String? iconAsset;

  const _SuccessDialog({
    required this.title,
    required this.subtitle,
    required this.closeLabel,
    this.onClose,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 410.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          // Green check icon
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
          // Single close button (optional – omit if auto-dismiss is preferred)
          if (onClose != null)
            _primaryBtn(
              label: closeLabel,
              width: double.infinity,
              onTap: () {
                Navigator.of(context).pop();
                onClose!.call();
              },
            ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconAsset != null) {
      return SvgPicture.asset(iconAsset!, width: 60.r, height: 60.r);
    }
    return Container(
      width: 60.r,
      height: 60.r,
      decoration: const BoxDecoration(
        color: Color(0xFF43A047),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_rounded, color: Colors.white, size: 36.r),
    );
  }
}

// ─────────────────────────────────────────────
