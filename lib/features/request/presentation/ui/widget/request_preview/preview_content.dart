part of '../../pages/request_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final RequestDemoPageModel model;
  final bool isEnglish;
  final bool isMobile;
  final bool isTablet;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTabletOrMobile = isMobile || isTablet;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final verticalPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

    final title = isEnglish ? model.confirmTitle.en : model.confirmTitle.ar;
    final desc =
    isEnglish ? model.confirmDescription.en : model.confirmDescription.ar;
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final svgUrl = model.confirmSvgUrl;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          width: fakeWidth,
          height: fakeHeight,
          color: _C.back,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 500.w,
                  ),
                  padding: EdgeInsets.all(isMobile ? 20.r : 32.r),
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── SVG Image ────────────────────────────────────────
                      if (svgUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: SvgPicture.network(
                            svgUrl,
                            height: isMobile ? 120.h : 160.h,
                            width: isMobile ? 120.w : 160.w,
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) => SizedBox(
                              height: isMobile ? 120.h : 160.h,
                              width: isMobile ? 120.w : 160.w,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: _C.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorBuilder: (_, __, ___) => Container(
                              height: isMobile ? 120.h : 160.h,
                              width: isMobile ? 120.w : 160.w,
                              decoration: BoxDecoration(
                                color: _C.sectionBg,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                size: isMobile ? 40.sp : 60.sp,
                                color: _C.hintText,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: isMobile ? 120.h : 160.h,
                          width: isMobile ? 120.w : 160.w,
                          decoration: BoxDecoration(
                            color: _C.sectionBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: isMobile ? 40.sp : 60.sp,
                            color: _C.hintText,
                          ),
                        ),

                      SizedBox(height: isMobile ? 20.h : 24.h),

                      // ── Title ────────────────────────────────────────────
                      Text(
                        title.isNotEmpty
                            ? title
                            : 'Waiting till Customer Services Call You',
                        textDirection: dir,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 16.sp : 18.sp,
                          fontWeight: FontWeight.w700,
                          color: _C.primary,
                        ),
                      ),

                      SizedBox(height: isMobile ? 12.h : 16.h),

                      // ── Description ──────────────────────────────────────
                      Text(
                        desc.isNotEmpty
                            ? desc
                            : 'Your demo request has been successfully submitted, thank you! We\'ll be in touch soon to confirm the details.',
                        textDirection: dir,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13.sp : 14.sp,
                          fontWeight: FontWeight.w400,
                          color: _C.labelText,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════
