// ******************* FILE INFO *******************
// File Name: preview_content.dart
// Description: Preview content widget for Client Services preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › client_services › presentation › ui › widget › client_services_preview

part of '../../pages/client_services_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final ClientServicesPageModel model;
  final bool isMobile;
  final bool? isEnglish;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    this.isMobile = false,
    this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final bool resolvedIsEnglish =
        isEnglish ?? Localizations.localeOf(context).languageCode == 'en';
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
          color: ColorPick.white,
          width: fakeWidth,
          height: fakeHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(resolvedIsEnglish),
                const SizedBox(height: 30),
                _buildDownloadBar(resolvedIsEnglish),
                const SizedBox(height: 30),
                ..._buildMockups(resolvedIsEnglish),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: renders an image URL (remote SVG or base64 data-URL) ──────────
  Widget _buildImage({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final ph = placeholder ??
        Container(
          width: width,
          height: height,
          color: ColorPick.primary.withValues(alpha: 0.12),
          child: Icon(Icons.image_outlined,
              color: ColorPick.primary.withValues(alpha: 0.4), size: 36),
        );

    if (url.isEmpty) return ph;

    if (url.startsWith('data:')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => ph,
      );
    }

    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => ph,
    );
  }

  // ── Header section ───────────────────────────────────────────────────────
  Widget _buildHeader(bool isEnglish) {
    final header = model.header;
    final title = isEnglish ? header.title.en : header.title.ar;
    final desc = isEnglish ? header.description.en : header.description.ar;
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final hasImage = header.svgUrl.isNotEmpty;

    final imageWidget = hasImage
        ? _buildImage(
      url: header.svgUrl,
      width: fakeWidth * 0.35,
      height: 200,
      fit: BoxFit.contain,
    )
        : null;

    final textWidget = Column(
      crossAxisAlignment:
      isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          title.isNotEmpty ? title : 'Our Services',
          textDirection: dir,
          style: TextStyle(
            color: ColorPick.primary,
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          desc.isNotEmpty
              ? desc
              : 'Beauty App provides you with many salons and services to meet your needs.',
          textDirection: dir,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: AppColors.text,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      color: ColorPick.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600 && !isMobile;
          if (isWide && hasImage) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textWidget),
                SizedBox(width: 20.w),
                Expanded(flex: 4, child: imageWidget!),
              ],
            );
          }
          return Column(
            children: [
              if (hasImage) ...[
                Center(child: imageWidget!),
                SizedBox(height: 16.h),
              ],
              textWidget,
            ],
          );
        },
      ),
    );
  }

  // ── Download bar ─────────────────────────────────────────────────────────
  Widget _buildDownloadBar(bool isEnglish) {
    final download = model.download;
    final title = isEnglish ? download.title.en : download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (isEnglish
        ? 'At Beauty, you will find luxury services.'
        : 'ستجد لدينا أفضل الخدمات.');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500 && !isMobile;
          if (isWide) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                ),
                _storeBadge(
                  label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                  image: "assets/google play.svg",
                ),
                SizedBox(width: 10.w),
                _storeBadge(
                  label: isEnglish ? 'App Store' : 'آب ستور',
                  image: "assets/app_store.svg",
                ),
              ],
            );
          }
          return Column(
            children: [
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _storeBadge(
                    label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                    image: "assets/google play.svg",
                  ),
                  _storeBadge(
                    label: isEnglish ? 'App Store' : 'آب ستور',
                    image: "assets/app_store.svg",
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Mockups list ─────────────────────────────────────────────────────────
  List<Widget> _buildMockups(bool isEnglish) {
    final mockups = model.mockups.items;
    return mockups.map((item) => _buildMockupItem(item, isEnglish)).toList();
  }

  Widget _buildMockupItem(ClientServicesMockupItemModel item, bool isEnglish) {
    final title = isEnglish ? item.title.en : item.title.ar;
    final desc = isEnglish ? item.description.en : item.description.ar;
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;

    final imageWidget = item.svgUrl.isNotEmpty
        ? _buildImage(
      url: item.svgUrl,
      width: fakeWidth * 0.4,
      height: isMobile ? 200 : 280,
      fit: BoxFit.contain,
    )
        : Container(
      height: isMobile ? 200 : 280,
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Icon(
          Icons.phone_iphone,
          size: isMobile ? 40 : 60,
          color: ColorPick.primary.withValues(alpha: 0.4),
        ),
      ),
    );

    final textWidget = Column(
      crossAxisAlignment:
      isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.isNotEmpty ? title : 'Section Title',
          textDirection: dir,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          desc.isNotEmpty ? desc : 'Description text here…',
          textDirection: dir,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: AppColors.text,
          ),
        ),
      ],
    );

    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0, vertical: 16.h),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 500 && !isMobile;

          switch (item.layout) {
            case MockupLayout.centered:
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    imageWidget,
                    SizedBox(height: 20.h),
                    textWidget,
                  ],
                ),
              );

            case MockupLayout.left:
              if (!isWide) {
                return Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      imageWidget,
                      SizedBox(height: 20.h),
                      textWidget,
                    ],
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: textWidget),
                    SizedBox(width: 20.w),
                    Expanded(flex: 4, child: imageWidget),
                  ],
                ),
              );

            case MockupLayout.right:
              if (!isWide) {
                return Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      imageWidget,
                      SizedBox(height: 20.h),
                      textWidget,
                    ],
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 4, child: imageWidget),
                    SizedBox(width: 20.w),
                    Expanded(flex: 6, child: textWidget),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _storeBadge({required String label, required String image}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvg(assetPath: image),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GET IT ON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 6.sp : 7.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 8.sp : 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════