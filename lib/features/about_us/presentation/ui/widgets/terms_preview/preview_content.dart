// ******************* FILE INFO *******************
// File Name: preview_content.dart
// Description: Preview content widget for Terms preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › terms_preview

part of '../../pages/terms_page/terms_preview.dart';

class _PreviewContent extends StatefulWidget {
  final double              fakeWidth;
  final double              fakeHeight;
  final TermsOfServiceModel model;
  final Uint8List?          termsSvgBytes;
  final Uint8List?          privacySvgBytes;
  final bool                isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    this.termsSvgBytes,
    this.privacySvgBytes,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  bool _termsOpen   = true;
  bool _privacyOpen = true;

  bool get _isMobileView => widget.fakeWidth < 600;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:        Size(widget.fakeWidth, widget.fakeHeight),
        padding:     EdgeInsets.zero,
        viewInsets:  EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color:  ColorPick.white,
          width:  widget.fakeWidth,
          height: widget.fakeHeight,
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: isEnglish
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const SizedBox(height: 24),
                  // _buildHero(),
                  const SizedBox(height: 32),
                  _buildAccordion(
                    title:    isEnglish ? 'Terms and Conditions' : 'الشروط والأحكام',
                    isOpen:   _termsOpen,
                    onToggle: () => setState(() => _termsOpen = !_termsOpen),
                    child:    _buildSection(
                      isEnglish: isEnglish,
                      section:  widget.model.termsAndConditions,
                      svgBytes: widget.termsSvgBytes,
                      labelEn:  'Download PDF of Terms and Conditions (ENG)',
                      labelAr:  'تحميل PDF للشروط والأحكام (عربي)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAccordion(
                    title:    isEnglish ? 'Privacy Policy' : 'سياسة الخصوصية',
                    isOpen:   _privacyOpen,
                    onToggle: () => setState(() => _privacyOpen = !_privacyOpen),
                    child:    _buildSection(
                      isEnglish: isEnglish,
                      section:  widget.model.privacyPolicy,
                      svgBytes: widget.privacySvgBytes,
                      labelEn:  'Download PDF of Privacy Policy (ENG)',
                      labelAr:  'تحميل PDF لسياسة الخصوصية (عربي)',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────────
  Widget _buildHero(bool isEnglish) {
    final h = _isMobileView ? 100.0 : 140.0;
    return Container(
      width:  double.infinity,
      height: h,
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      decoration: BoxDecoration(
        color:        ColorPick.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEnglish ? 'Legal' : 'قانوني',
              style: TextStyle(
                color:      Colors.white.withValues(alpha: 0.65),
                fontSize:   _isMobileView ? 11 : 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEnglish
                  ? 'Terms & Privacy'
                  : 'الشروط والخصوصية',
              style: TextStyle(
                color:      Colors.white,
                fontSize:   _isMobileView ? 20 : 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _buildAccordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    final hPad = widget.isMobile ? 16.0 : 40.0;
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset:     const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width:   double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color:        ColorPick.primary,
                borderRadius: isOpen
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size:  20,
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
        ],
      ),
    );
  }

  // ── Section body ───────────────────────────────────────────────────────────
  Widget _buildSection({
    required bool         isEnglish,
    required TermsSection section,
    required Uint8List?   svgBytes,
    required String       labelEn,
    required String       labelAr,
  }) {
    final desc   = isEnglish
        ? section.description.en
        : section.description.ar;
    final svgUrl = section.svgUrl;
    final hasSvg = svgBytes != null || svgUrl.isNotEmpty;

    if (_isMobileView) {
      // ── Mobile / narrow layout: stacked ──────────────────────────────
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSvg) ...[
            Center(
              child: _svgWidget(
                  bytes: svgBytes, url: svgUrl,
                  width: 100, height: 100),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            desc.isEmpty ? 'Description text here…' : desc,
            textDirection: isEnglish
                ? TextDirection.ltr
                : TextDirection.rtl,
            style: TextStyle(
                fontSize: 12, height: 1.75, color: AppColors.text),
          ),
          const SizedBox(height: 16),
          _downloadLinks(
            section:  section,
            labelEn:  labelEn,
            labelAr:  labelAr,
            stacked:  true,
          ),
        ],
      );
    }

    // ── Desktop / tablet layout: side-by-side ──────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                desc.isEmpty ? 'Description text here…' : desc,
                textDirection: isEnglish
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                style: TextStyle(
                    fontSize: 13, height: 1.75, color: AppColors.text),
              ),
            ),
            if (hasSvg) ...[
              const SizedBox(width: 28),
              _svgWidget(
                  bytes: svgBytes, url: svgUrl,
                  width: 160, height: 160),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _downloadLinks(
          section: section,
          labelEn: labelEn,
          labelAr: labelAr,
          stacked: false,
        ),
      ],
    );
  }

  // ── Download links row/column ───────────────────────────────────────────────
  Widget _downloadLinks({
    required TermsSection section,
    required String       labelEn,
    required String       labelAr,
    required bool         stacked,
  }) {
    Widget _btn(String label, String url) {
      if (url.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvg(
              assetPath: 'assets/images/export.svg',
              color:     ColorPick.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize:        11,
                  fontWeight:      FontWeight.w500,
                  color:           ColorPick.primary,
                  decoration:      TextDecoration.underline,
                  decorationColor: ColorPick.primary),
            ),
          ),
        ],
      );
    }

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _btn(labelEn, section.attachEnUrl),
          if (section.attachArUrl.isNotEmpty) const SizedBox(height: 6),
          _btn(labelAr, section.attachArUrl),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn(labelEn, section.attachEnUrl),
        _btn(labelAr, section.attachArUrl),
      ],
    );
  }
}

// ── Shared SVG renderer ───────────────────────────────────────────────────────
Widget _svgWidget({
  required Uint8List? bytes,
  required String     url,
  required double     width,
  required double     height,
}) {
  if (bytes != null && bytes.isNotEmpty) {
    return SvgPicture.memory(bytes,
        width: width, height: height, fit: BoxFit.contain);
  }
  if (url.isNotEmpty) {
    return SvgPicture.network(
      url,
      width: width, height: height, fit: BoxFit.contain,
      placeholderBuilder: (_) => SizedBox(
        width: width, height: height,
        child: const Center(child: CircularProgressIndicator(
            color: Color(0xFF008037), strokeWidth: 2)),
      ),
    );
  }
  return SizedBox(
    width: width, height: height,
    child: Icon(Icons.image_outlined,
        color: Colors.grey[400], size: width * 0.4),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════
