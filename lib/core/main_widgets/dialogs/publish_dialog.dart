part of '../../custom_dialog.dart';

// ******************* FILE INFO *******************
// File Name: publish_dialog.dart
// Description: Publish confirmation dialog widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets › dialogs

Future<void> showPublishConfirmDialog({
  required BuildContext context,
  String title = 'EDITING MAIN DETAILS',
  String subtitle = 'Do you want to save the changes made to this Main?',
  String confirmLabel = 'Confirm',
  String backLabel = 'Back',
  // ── CHANGED: was VoidCallback? — now Future<void> Function()? ──
  Future<void> Function()? onConfirm,
  VoidCallback? onBack,
  /// Optional custom illustration asset path (SVG or PNG)
  String? illustrationAsset,
})
{
  return showDialog(
    context: context,
    barrierDismissible: false, // prevent accidental dismiss while saving
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _PublishConfirmDialog(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      backLabel: backLabel,
      onConfirm: onConfirm,
      onBack: onBack,
      illustrationAsset: illustrationAsset,
    ),
  );
}

class _PublishConfirmDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String confirmLabel;
  final String backLabel;
  // ── CHANGED: was VoidCallback? — now Future<void> Function()? ──
  final Future<void> Function()? onConfirm;
  final VoidCallback? onBack;
  final String? illustrationAsset;

  const _PublishConfirmDialog({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.backLabel,
    this.onConfirm,
    this.onBack,
    this.illustrationAsset,
  });

  @override
  State<_PublishConfirmDialog> createState() => _PublishConfirmDialogState();
}

class _PublishConfirmDialogState extends State<_PublishConfirmDialog> {
  bool _loading = false;

  /// Called when the user taps Confirm.
  /// Shows CircularProgressIndicator inside the dialog while _save() runs.
  /// Closes the dialog automatically when done.
  Future<void> _handleConfirm() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      // Directly await the async _save() — no microtask wrapper
      await widget.onConfirm?.call();
    } catch (e) {
      // _save() handles its own error logging; we just ensure loading resets
      debugPrint('[PublishConfirmDialog] onConfirm error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back-swipe / back button while saving
      canPop: !_loading,
      child: _DialogShell(
        width: 600.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),

            // ── Illustration ──────────────────────────────────────
            _buildIllustration(),
            SizedBox(height: 24.h),

            // ── Title ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // ── Subtitle ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.subtitle,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // ── Buttons / Loader ──────────────────────────────────
            // When _loading is true  → show CircularProgressIndicator
            //                          centered where the buttons were.
            // When _loading is false → show Back + Confirm buttons.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: SizedBox(
                height: 48.h,
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD16F9A),
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  children: [
                    // ── Back button ──────────────────────────
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onBack?.call();
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9E9E9E),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              widget.backLabel,
                              style: StyleText.fontSize14Weight600
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // ── Confirm button ───────────────────────
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleConfirm,
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD16F9A),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              widget.confirmLabel,
                              style: StyleText.fontSize14Weight600
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    if (widget.illustrationAsset != null) {
      return widget.illustrationAsset!.endsWith('.svg')
          ? SvgPicture.asset(widget.illustrationAsset!,
          width: 180.w, height: 160.h, fit: BoxFit.contain)
          : Image.asset(widget.illustrationAsset!,
          width: 180.w, height: 160.h, fit: BoxFit.contain);
    }
    return SizedBox(
      width: 180.w,
      height: 160.h,
      child: CustomSvg(
          assetPath: "assets/confirm_dialog.svg"),
    );
  }
}

// ── Back button (grey, matches Figma) ────────────────────────────────────────
class _BackBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BackBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFF9E9E9E),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ── Confirm button (green, matches Figma) ────────────────────────────────────
class _ConfirmGreenBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ConfirmGreenBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFFD16F9A),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ── Simple CustomPainter fallback illustration ────────────────────────────────
class _PersonIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()
      ..color = const Color(0xFF008037);
    final skin = Paint()
      ..color = const Color(0xFFFFCC99);
    final dark = Paint()
      ..color = const Color(0xFF3E2723);
    final white = Paint()
      ..color = Colors.white;
    final screen = Paint()
      ..color = const Color(0xFF4CAF50);
    final grey = Paint()
      ..color = const Color(0xFFBDBDBD);

    final cx = size.width * 0.55;
    final cy = size.height * 0.30;

    // Monitor frame
    final monRect = Rect.fromLTWH(
        size.width * 0.28, size.height * 0.05,
        size.width * 0.55, size.height * 0.50);
    canvas.drawRRect(
        RRect.fromRectAndRadius(monRect, const Radius.circular(10)),
        Paint()
          ..color = const Color(0xFF424242));
    // Screen
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            monRect.deflate(6), const Radius.circular(6)),
        screen);
    // Monitor stand
    canvas.drawRect(
        Rect.fromLTWH(cx - 6, monRect.bottom, 12, size.height * 0.08),
        grey);
    canvas.drawRect(
        Rect.fromLTWH(cx - 20, monRect.bottom + size.height * 0.08,
            40, 6),
        grey);

    // Body (green sweater)
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.08,
                size.height * 0.52, size.width * 0.38, size.height * 0.40),
            const Radius.circular(12)),
        green);

    // Head
    canvas.drawCircle(
        Offset(size.width * 0.27, size.height * 0.36), size.width * 0.13,
        skin);

    // Hair
    final hairPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width * 0.27, size.height * 0.27),
          radius: size.width * 0.11))
      ..close();
    canvas.drawPath(hairPath, dark);

    // Paper in hand
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.38, size.height * 0.55,
                size.width * 0.16, size.height * 0.20),
            const Radius.circular(3)),
        white);
    // Lines on paper
    final linePaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.5;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * 0.55 + i * size.height * 0.04;
      canvas.drawLine(
          Offset(size.width * 0.41, y),
          Offset(size.width * 0.51, y),
          linePaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
