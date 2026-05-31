// ******************* FILE INFO *******************
// File Name: preview_header_section.dart
// Description: Header section widget for Master preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_preview

part of '../../pages/master_preview.dart';

class _PreviewHeaderSection extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;

  const _PreviewHeaderSection({required this.model, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final header     = model.sectionByKey('header');
    final isVisible  = header?.visibility ?? true;
    if (!isVisible) return const SizedBox.shrink();

    final titleText = isEnglish
        ? (header?.title.en.isNotEmpty == true
        ? header!.title.en
        : (model.title.en.isNotEmpty ? model.title.en : 'Beauty App'))
        : (header?.title.ar.isNotEmpty == true
        ? header!.title.ar
        : (model.title.ar.isNotEmpty ? model.title.ar : 'تطبيق بيوتي'));

    final shortDescText = isEnglish
        ? (header?.shortDescription.en.isNotEmpty == true
        ? header!.shortDescription.en
        : (model.shortDescription.en.isNotEmpty
        ? model.shortDescription.en
        : 'Style & Simple Bright'))
        : (header?.shortDescription.ar.isNotEmpty == true
        ? header!.shortDescription.ar
        : (model.shortDescription.ar.isNotEmpty
        ? model.shortDescription.ar
        : 'أناقة وبساطة مشرقة'));

    final imageUrl = header?.imageUrl ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _previewImageBox(imageUrl, 200, 200),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text),
                ),
                const SizedBox(height: 8),
                Text(
                  shortDescText,
                  textDirection:
                  isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ColorPick.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
