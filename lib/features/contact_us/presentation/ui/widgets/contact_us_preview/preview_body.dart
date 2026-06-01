// ******************* FILE INFO *******************
// File Name: preview_body.dart
// Description: Preview body widget for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _PreviewBody extends StatefulWidget {
  final ContactUsCmsModel data;
  const _PreviewBody({required this.data});

  @override
  State<_PreviewBody> createState() => _PreviewBodyState();
}

class _PreviewBodyState extends State<_PreviewBody> {
  _PreviewDevice _device      = _PreviewDevice.desktop;
  bool           _isEnglish   = true;
  bool           _isPublishing = false;

// In _PreviewBodyState class, update the _publish method:

  Future<void> _publish() async {
    setState(() => _isPublishing = true);
    try {
      await context.read<ContactUsCmsCubit>().save(model: widget.data);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
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
                    AdminSubNavBar(activeIndex: 6),
                    SizedBox(height: 16.h),

                    Text(
                      'Preview Contact Us Details',
                      style: StyleText.fontSize45Weight600.copyWith(
                        color: ColorPick.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Device tabs + Language toggle ──────────────────
                    Row(
                      children: [
                        _tab('Desktop', _PreviewDevice.desktop),
                        SizedBox(width: 24.w),
                        _tab('Tablet',  _PreviewDevice.tablet),
                        SizedBox(width: 24.w),
                        _tab('Mobile',  _PreviewDevice.mobile),
                        const Spacer(),
                        SizedBox(
                          width: 95.w,
                          height: 36.h,
                          child: CustomSegmentedTabs(
                            tabs: const ['ENG', 'AR'],
                            selectedIndex: _isEnglish ? 0 : 1,
                            onTabSelected: (i) =>
                                setState(() => _isEnglish = i == 0),
                            selectedColor:      ColorPick.primary,
                            unselectedColor:    Colors.white,
                            selectedTextColor:  Colors.white,
                            unselectedTextColor: AppColors.text,
                            equalWidth: false,
                            containerPadding: EdgeInsets.symmetric(
                                horizontal: 8.sp, vertical: 4.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ── Preview frame ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: LayoutBuilder(
                        builder: (ctx, box) => _buildFrame(box.maxWidth),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Back + Publish ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: ColorPick.back,
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
                        Expanded(
                          child: GestureDetector(
                            onTap: _isPublishing
                                ? null
                                : () => showPublishConfirmDialog(
                              title:    'PUBLISHING CONTACT US',
                              subtitle: 'Do you want to publish this Contact Us page?',
                              context:  context,
                              onConfirm: _publish,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _isPublishing
                                    ? ColorPick.primary.withValues(alpha: 0.5)
                                    : ColorPick.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: _isPublishing
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
                    ),
                    SizedBox(height: 40.h),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isPublishing)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
          ),
      ],
    );
  }

  // ── Tab widget ─────────────────────────────────────────────────────────────
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

  // ── Frame dispatcher ───────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW,
            data: widget.data,
            isEnglish: _isEnglish);
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW,
            data: widget.data,
            isEnglish: _isEnglish);
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW,
            data: widget.data,
            isEnglish: _isEnglish);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME
// ═══════════════════════════════════════════════════════════════════════════════
