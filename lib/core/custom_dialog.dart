/// ******************* FILE INFO *******************
/// File Name: custom_dialog.dart
/// Description: Reusable dialog widgets (entry point + shared helpers).
///   - showConfirmDialog   → confirm_dialog.dart
///   - showSuccessDialog   → success_dialog.dart
///   - showCommentDialog   → comment_dialog.dart
///   - showUploadDialog    → upload_dialog.dart
///   - showPublishConfirmDialog → publish_dialog.dart
/// Created by: Amr Mesbah
/// Last Update: 31/05/2026

/// Module: core › dialogs

import 'package:beauty_admin/core/theme/app_colors.dart';
import 'package:beauty_admin/core/theme/app_font_style.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widgets/textfield.dart';
import 'package:beauty_admin/core/constants/color.dart';

part 'main_widgets/dialogs/confirm_dialog.dart';
part 'main_widgets/dialogs/success_dialog.dart';
part 'main_widgets/dialogs/comment_dialog.dart';
part 'main_widgets/dialogs/upload_dialog.dart';
part 'main_widgets/dialogs/publish_dialog.dart';

// ─────────────────────────────────────────────
//  SHARED HELPERS
// ─────────────────────────────────────────────

/// Rounded dialog shell used by every dialog.
class _DialogShell extends StatelessWidget {
  final Widget child;
  final double? width;

  const _DialogShell({required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: width ?? 420.w,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(-3, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.r),
        child: child,
      ),
    );
  }
}

/// Yellow primary button (matches your customButton style).
Widget _primaryBtn({
  required String label,
  required VoidCallback onTap,
  double? width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: Colors.black),
        ),
      ),
    ),
  );
}

/// Grey/neutral secondary button.
Widget _secondaryBtn({
  required String label,
  required VoidCallback onTap,
  double? width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      height: 38.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: Colors.black87),
        ),
      ),
    ),
  );
}

/// Icon shown in dialog headers. Renders [assetPath] as SVG if provided,
/// falls back to [fallback], or to a default yellow circle icon.
class _TitleIcon extends StatelessWidget {
  final String? assetPath;
  final Widget? fallback;

  const _TitleIcon({this.assetPath, this.fallback});

  @override
  Widget build(BuildContext context) {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return SvgPicture.asset(assetPath!, width: 20.r, height: 20.r);
    }
    if (fallback != null) return fallback!;
    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.info_outline, size: 12.r, color: Colors.white),
    );
  }
}

