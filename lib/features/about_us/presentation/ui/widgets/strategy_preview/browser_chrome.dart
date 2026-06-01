// ******************* FILE INFO *******************
// File Name: browser_chrome.dart
// Description: Browser chrome frame for Strategy preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › strategy_preview

part of '../../pages/strategy_page/strategy_preview.dart';

class _BrowserChrome extends StatelessWidget {
  final bool compact;
  const _BrowserChrome({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double h = compact ? 22 : 28;
    return Container(
      height: h,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 4),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 4),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: compact ? 10 : 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ── Confirm Dialog ────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r)),
    contentPadding: EdgeInsets.all(24.r),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EE),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Icon(Icons.edit_note,
              size: 40.sp, color: ColorPick.activeColor),
        ),
        SizedBox(height: 16.h),
        Text(
          'EDITING OUR STRATEGY DETAILS',
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight600
              .copyWith(color: const Color(0xFF1A1A1A)),
        ),
        SizedBox(height: 8.h),
        Text(
          'Do you want to save the changes made to this Our Strategy?',
          textAlign: TextAlign.center,
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryBlack),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Back',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPick.activeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Confirm',
                      style: StyleText.fontSize13Weight500
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
