part of '../../pages/master_preview.dart';

class _PreviewAboutUsSection extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;

  const _PreviewAboutUsSection({required this.model, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final about     = model.sectionByKey('aboutUs');
    final isVisible = about?.visibility ?? true;
    if (!isVisible) return const SizedBox.shrink();

    final titleText = isEnglish
        ? (about?.title.en.isNotEmpty == true ? about!.title.en : 'About Us')
        : (about?.title.ar.isNotEmpty == true
        ? about!.title.ar
        : 'معلومات عنا');

    final descText = isEnglish
        ? (about?.description.en.isNotEmpty == true
        ? about!.description.en
        : 'Welcome to Beauty App, where beauty meets tranquility.')
        : (about?.description.ar.isNotEmpty == true
        ? about!.description.ar
        : 'مرحباً بكم في تطبيق بيوتي، حيث يلتقي الجمال بالهدوء.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment:
        isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            titleText,
            textDirection:
            isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD16F9A)),
          ),
          const SizedBox(height: 12),
          Text(
            descText,
            textDirection:
            isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400,
                color: AppColors.text, height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: isEnglish
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                isEnglish ? 'Read More' : 'اقرأ المزيد',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorPick.primary),
              ),
              const SizedBox(width: 4),
              Icon(
                isEnglish
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: ColorPick.primary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
