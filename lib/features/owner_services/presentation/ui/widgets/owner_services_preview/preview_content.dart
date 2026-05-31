// ******************* FILE INFO *******************
// File Name: preview_content.dart
// Description: Preview content widget for Owner Services preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › owner_services › presentation › ui › widget › owner_services_preview

part of '../../pages/owner_services_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final OwnerServicesPageModel model;
  final bool isMobile;
  final bool? isEnglish;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    this.isMobile = false,
    this.isEnglish,
  });

  // ── Helper: renders an SVG from URL ───────────────────────────────────────
  Widget _buildSvg({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    final placeholder = Container(
      width: width,
      height: height,
      color: ColorPick.primary.withOpacity(0.08),
      child: Icon(Icons.image_outlined,
          color: ColorPick.primary.withOpacity(0.35), size: 28),
    );

    if (url.isEmpty) return placeholder;

    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool resolvedIsEnglish =
        isEnglish ?? Localizations.localeOf(context).languageCode == 'en';
    final double hPad = isMobile ? 16 : 40;

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
                _buildHeader(hPad, resolvedIsEnglish),
                const SizedBox(height: 40),
                _buildDownload(hPad, resolvedIsEnglish),
                const SizedBox(height: 40),
                ..._buildMockups(hPad, resolvedIsEnglish),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header section ─────────────────────────────────────────────────────────
  Widget _buildHeader(double hPad, bool isEnglish) {
    final title = isEnglish
        ? model.header.title.en
        : model.header.title.ar;
    final desc = isEnglish
        ? model.header.description.en
        : model.header.description.ar;

    final isRtl = !isEnglish;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text side
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: isRtl
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      textDirection: isRtl
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      style: const TextStyle(
                        color: ColorPick.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  if (title.isNotEmpty) const SizedBox(height: 12),
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      textDirection: isRtl
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Learn More link
                  Align(
                    alignment: isRtl
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEnglish ? 'Learn More' : 'اعرف المزيد',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorPick.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorPick.primary.withOpacity(0.15),
                          ),
                          child: Icon(
                            isEnglish
                                ? Icons.arrow_forward
                                : Icons.arrow_back,
                            size: 13,
                            color: ColorPick.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // SVG image side
            if (model.header.imageUrl.isNotEmpty)
              Expanded(
                flex: 2,
                child: _buildSvg(
                  url: model.header.imageUrl,
                  width: double.infinity,
                  height: isMobile ? 140 : 180,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Download section ───────────────────────────────────────────────────────
  Widget _buildDownload(double hPad, bool isEnglish) {
    final hasLinks = model.download.appStoreLink.isNotEmpty ||
        model.download.googlePlayLink.isNotEmpty;
    if (!hasLinks) return const SizedBox.shrink();

    final title = isEnglish
        ? model.download.title.en
        : model.download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (isEnglish
        ? 'Download our app for the best experience'
        : 'قم بتنزيل تطبيقنا للحصول على أفضل تجربة');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 480;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        color: ColorPick.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (model.download.googlePlayLink.isNotEmpty)
                        _storeBadge(
                          isEnglish: isEnglish,
                          label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                          icon: Icons.play_arrow_rounded,
                        ),
                      if (model.download.googlePlayLink.isNotEmpty &&
                          model.download.appStoreLink.isNotEmpty)
                        const SizedBox(width: 12),
                      if (model.download.appStoreLink.isNotEmpty)
                        _storeBadge(
                          isEnglish: isEnglish,
                          label: isEnglish ? 'App Store' : 'آب ستور',
                          icon: Icons.apple,
                        ),
                    ],
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColorPick.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (model.download.googlePlayLink.isNotEmpty)
                      _storeBadge(
                        isEnglish: isEnglish,
                        label: isEnglish ? 'Google Play' : 'جوجل بلاي',
                        icon: Icons.play_arrow_rounded,
                      ),
                    if (model.download.appStoreLink.isNotEmpty)
                      _storeBadge(
                        isEnglish: isEnglish,
                        label: isEnglish ? 'App Store' : 'آب ستور',
                        icon: Icons.apple,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _storeBadge({
    required bool isEnglish,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? 'GET IT ON' : 'تحميل من',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mockups ────────────────────────────────────────────────────────────────
  List<Widget> _buildMockups(double hPad, bool isEnglish) {
    if (model.mockups.items.isEmpty) return [];

    return model.mockups.items.map((item) {
      return Padding(
        padding: EdgeInsets.only(left: hPad, right: hPad, bottom: 32),
        child: _buildMockupItem(item, isEnglish),
      );
    }).toList();
  }

  Widget _buildMockupItem(OwnerServicesMockupItemModel item, bool isEnglish) {
    final title = isEnglish ? item.title.en : item.title.ar;
    final desc  = isEnglish ? item.description.en : item.description.ar;
    final isRtl = !isEnglish;

    final textWidget = Expanded(
      flex: 3,
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Column(
          crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  height: 1.3,
                ),
              ),
            if (title.isNotEmpty && desc.isNotEmpty)
              const SizedBox(height: 10),
            if (desc.isNotEmpty)
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.text,
                  height: 1.7,
                ),
              ),
          ],
        ),
      ),
    );

    final imageWidget = item.imageUrl.isNotEmpty
        ? Expanded(
      flex: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildSvg(
          url: item.imageUrl,
          width: double.infinity,
          height: isMobile ? 160 : 200,
        ),
      ),
    )
        : const SizedBox.shrink();

    Widget rowContent;
    switch (item.alignment) {
      case 'right':
        rowContent = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textWidget,
            const SizedBox(width: 20),
            imageWidget,
          ],
        );
        break;
      case 'centered':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorPick.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (item.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildSvg(
                    url: item.imageUrl,
                    width: isMobile ? 160 : 200,
                    height: isMobile ? 160 : 200,
                  ),
                ),
              if (item.imageUrl.isNotEmpty) const SizedBox(height: 16),
              if (title.isNotEmpty)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              if (title.isNotEmpty && desc.isNotEmpty)
                const SizedBox(height: 8),
              if (desc.isNotEmpty)
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text,
                    height: 1.7,
                  ),
                ),
            ],
          ),
        );
      case 'left':
      default:
        rowContent = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imageWidget,
            const SizedBox(width: 20),
            textWidget,
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPick.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: rowContent,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════