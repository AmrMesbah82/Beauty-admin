// ******************* FILE INFO *******************
// File Name: preview_footer_section.dart
// Description: Footer section widget for Master preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_preview

part of '../../pages/master_preview.dart';

class _PreviewFooterSection extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;

  const _PreviewFooterSection({required this.model, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final footer    = model.sectionByKey('footer');
    final isVisible = footer?.visibility ?? true;
    if (!isVisible) return const SizedBox.shrink();

    final titleText = isEnglish
        ? (footer?.title.en.isNotEmpty == true
        ? footer!.title.en
        : 'Download Beauty App Now')
        : (footer?.title.ar.isNotEmpty == true
        ? footer!.title.ar
        : 'حمل تطبيق بيوتي الآن');

    final descText = isEnglish
        ? (footer?.description.en.isNotEmpty == true
        ? footer!.description.en
        : 'At Beauty, you will find luxury services.')
        : (footer?.description.ar.isNotEmpty == true
        ? footer!.description.ar
        : 'ستجد لدينا أفضل الخدمات الفاخرة.');

    final imageUrl = footer?.imageUrl ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _previewImageBox(imageUrl, 200, 220,
              fallbackIcon: Icons.phone_iphone,
              fallbackBg: _C.downloadBg),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text),
                ),
                const SizedBox(height: 10),
                Text(
                  descText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400,
                      color: AppColors.text, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Define button dimensions based on screen width
                        double buttonWidth;
                        double buttonHeight;
                        double spacing;

                        if (constraints.maxWidth >= 1024) {
                          // Desktop
                          buttonWidth = 200;
                          buttonHeight = 60;
                          spacing = 16;
                        } else if (constraints.maxWidth >= 600) {
                          // Tablet
                          buttonWidth = 180;
                          buttonHeight = 55;
                          spacing = 12;
                        } else {
                          // Mobile
                          buttonWidth = 150;
                          buttonHeight = 50;
                          spacing = 10;
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSvg(
                              assetPath: "assets/google play.svg",
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                            SizedBox(width: spacing),
                            CustomSvg(
                              assetPath: "assets/app_store.svg",
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers (top-level functions — accessible by all section widgets)
// ─────────────────────────────────────────────────────────────────────────────

Widget _previewImageBox(
    String imageUrl,
    double width,
    double height, {
      IconData fallbackIcon = Icons.image,
      Color    fallbackBg   = ColorPick.white,
    }) {
  if (imageUrl.isNotEmpty) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.network(
        imageUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const CircleProgressMaster(),
      ),
    );
  }
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: fallbackBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Icon(fallbackIcon, size: 48, color: AppColors.secondaryText),
    ),
  );
}

Widget _storeBadge({required String label, required IconData icon}) {
  return Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(6),
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
              label.contains('جوجل') || label.contains('آب')
                  ? 'تحميل من'
                  : 'GET IT ON',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w400),
            ),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Browser chrome bar (dots + URL bar)
// ─────────────────────────────────────────────────────────────────────────────
