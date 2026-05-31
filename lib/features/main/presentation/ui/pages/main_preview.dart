/// ******************* FILE INFO *******************
/// File Name: main_preview.dart
/// Page 3 — "Preview Main Details"
/// UPDATED: Correct viewport sizes per device:
///          Desktop  → 1366 × 768  (browser chrome frame)
///          Tablet   →  768 × 1024 (browser chrome frame)
///          Mobile   →  375 × 812  (phone shell with notch)
/// Author: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';

part '../widgets/main_preview/c.dart';
part '../widgets/main_preview/desktop_frame.dart';
part '../widgets/main_preview/tablet_frame.dart';
part '../widgets/main_preview/mobile_frame.dart';
part '../widgets/main_preview/preview_content.dart';
part '../widgets/main_preview/browser_chrome.dart';

class HomePreviewPage extends StatefulWidget {
  final bool showPublish; // ← ADD

  const HomePreviewPage({super.key, this.showPublish = true}); // ← ADD

  @override
  State<HomePreviewPage> createState() => _HomePreviewPageState();
}

class _HomePreviewPageState extends State<HomePreviewPage> {
  _PreviewDevice _device = _PreviewDevice.desktop;
  bool _isSaving = false;

  Future<void> _publish(HomeCmsCubit cubit) async {
    setState(() => _isSaving = true);
    try {
      await cubit.save(publishStatus: 'published');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: ColorPick.background,
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 0),
                        SizedBox(height: 16.h),

                        Text(
                          'Preview Main Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            color: ColorPick.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Device tabs ──────────────────────────────────
                        Row(
                          children: [
                            _tab('Desktop', _PreviewDevice.desktop),
                            SizedBox(width: 24.w),
                            _tab('Tablet',  _PreviewDevice.tablet),
                            SizedBox(width: 24.w),
                            _tab('Mobile',  _PreviewDevice.mobile),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── Preview area ─────────────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(12.r),

                          ),
                          padding: EdgeInsets.all(24.w),
                          child: LayoutBuilder(
                            builder: (ctx, box) => _buildFrame(box.maxWidth),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // ── Back + Publish ───────────────────────────────
                        // ── Back + Publish ───────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF797979),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Center(
                                    child: Text('Back',
                                        style: StyleText.fontSize14Weight600
                                            .copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 300.w),
                            if (!widget.showPublish) ...[   // ← WRAP with condition

                              Expanded(child: Container())
                            ],
                            if (widget.showPublish) ...[   // ← WRAP with condition

                              Expanded(
                                child: GestureDetector(
                                  onTap: _isSaving
                                      ? null
                                      : () => showPublishConfirmDialog(
                                    context: context,
                                    onConfirm: () => _publish(cubit),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _isSaving
                                          ? ColorPick.primary.withOpacity(0.5)
                                          : ColorPick.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? SizedBox(
                                        width: 18.w, height: 18.h,
                                        child: const CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                          : Text('Publish',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                    child: CircularProgressIndicator(color: ColorPick.primary)),
              ),
          ],
        );
      },
    );
  }

  // ── Tab widget ───────────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? ColorPick.primary : AppColors.secondaryText,
                )),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? ColorPick.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame dispatcher ──────────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(containerWidth: containerW);
      case _PreviewDevice.tablet:
        return _TabletFrame(containerWidth: containerW);
      case _PreviewDevice.mobile:
        return _MobileFrame(containerWidth: containerW);
    }
  }
}
