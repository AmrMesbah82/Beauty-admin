part of '../../pages/overview_preview.dart';

class _PreviewContent extends StatefulWidget {
  final double fakeWidth;
  final double fakeHeight;
  final OverviewPageModel model;
  final bool isEnglish;
  final bool isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  int _galleryActiveIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get background color from HomePage branding if available
    final homeState = context.watch<HomeCmsCubit>().state;
    final homeData = switch (homeState) {
      HomeCmsLoaded(:final data) => data,
      HomeCmsSaved(:final data) => data,
      HomeCmsSaving(:final data) => data,
      HomeCmsError(:final lastData) => lastData,
      _ => null,
    };

    final Color mainWidgetColor = homeData != null
        ? _parseHex(homeData.branding.mainWidgetColor, fallback: Colors.white)
        : Colors.white;

    final Color backgroundColor = homeData != null
        ? _parseHex(homeData.branding.backgroundColor, fallback: ColorPick.white)
        : ColorPick.white;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(widget.fakeWidth, widget.fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color: backgroundColor,
          width: widget.fakeWidth,
          height: widget.fakeHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildOverview(mainWidgetColor),
                const SizedBox(height: 50),
                _buildServices(),
                const SizedBox(height: 50),
                _buildGallery(mainWidgetColor),
                const SizedBox(height: 50),
                _buildComments(mainWidgetColor),
                const SizedBox(height: 50),
                _buildDownload(mainWidgetColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Overview section ───────────────────────────────────────────────────────
  Widget _buildOverview(Color mainWidgetColor) {
    final m = widget.model;
    final title = widget.isEnglish ? m.headings.title.en : m.headings.title.ar;
    final desc = widget.isEnglish
        ? m.headings.description.en
        : m.headings.description.ar;

    return Container(
      decoration: BoxDecoration(
        color: mainWidgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 32,
          horizontal: widget.isMobile ? 16 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.isNotEmpty ? title : 'Overview',
              style: TextStyle(
                color: ColorPick.primary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              desc.isNotEmpty
                  ? desc
                  : 'Welcome to Beauty App, where beauty meets tranquility.',
              textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
              style: TextStyle(
                height: 1.7,
                color: AppColors.text,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isEnglish ? 'Read More' : 'اقرأ المزيد',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPick.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorPick.primary.withOpacity(0.15),
                        ),
                        child: Icon(
                          widget.isEnglish ? Icons.arrow_forward : Icons.arrow_back,
                          size: 14,
                          color: ColorPick.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Services section ───────────────────────────────────────────────────────
  Widget _buildServices() {
    final m = widget.model;
    if (m.services.items.isEmpty) return const SizedBox.shrink();

    final svcTitle = widget.isEnglish ? m.services.title.en : m.services.title.ar;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: widget.isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            svcTitle.isNotEmpty ? svcTitle : 'Top Services',
            textDirection: widget.isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: const TextStyle(
              color: ColorPick.primary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: m.services.items.map((item) {
                final name = widget.isEnglish ? item.name.en : item.name.ar;
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPick.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Center(
                            child: item.imageUrl.isNotEmpty
                                ? _netImg(
                              url: item.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.scaleDown,
                              placeholder: Icon(
                                Icons.spa_outlined,
                                color: ColorPick.primary.withOpacity(0.4),
                                size: 28,
                              ),
                              errorWidget: Icon(
                                Icons.spa_outlined,
                                color: ColorPick.primary.withOpacity(0.4),
                                size: 28,
                              ),
                            )
                                : Icon(
                              Icons.spa_outlined,
                              color: ColorPick.primary.withOpacity(0.4),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name.isNotEmpty ? name : 'Service',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gallery section ────────────────────────────────────────────────────────
  Widget _buildGallery(Color mainWidgetColor) {
    final m = widget.model;
    if (m.gallery.images.isEmpty) return const SizedBox.shrink();

    final visibleImages = m.gallery.images
        .where((img) => img.imageUrl.isNotEmpty)
        .toList();
    if (visibleImages.isEmpty) return const SizedBox.shrink();

    if (_galleryActiveIndex >= visibleImages.length) {
      _galleryActiveIndex = visibleImages.length - 1;
    }

    final isMobileView = widget.fakeWidth < 600;
    final double inactiveSize = isMobileView ? 110 : 200;
    final double activeSize   = isMobileView ? 160 : 284;

    return Container(
      decoration: BoxDecoration(
        color: mainWidgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 16 : 40,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEnglish ? 'Gallery' : 'المعرض',
              style: const TextStyle(
                color: ColorPick.primary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: activeSize + 16,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(visibleImages.length, (i) {
                    final bool isActive = _galleryActiveIndex == i;
                    final double size = isActive ? activeSize : inactiveSize;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _galleryActiveIndex = i),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          width: size,
                          height: size,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _netImg(
                              url: visibleImages[i].imageUrl,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: ColorPick.primary.withOpacity(0.12),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: ColorPick.primary.withOpacity(0.4),
                                  size: 36,
                                ),
                              ),
                              errorWidget: Container(
                                color: ColorPick.primary.withOpacity(0.08),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: ColorPick.primary.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(visibleImages.length, (i) {
                final bool active = _galleryActiveIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _galleryActiveIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active ? ColorPick.primary : ColorPick.primary.withOpacity(0.3),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Comments section ───────────────────────────────────────────────────────
  Widget _buildComments(Color mainWidgetColor) {
    final m = widget.model;
    if (m.clientComments.comments.isEmpty) return const SizedBox.shrink();

    final cmtTitle = widget.isEnglish
        ? m.clientComments.title.en
        : m.clientComments.title.ar;
    final highlightWord = widget.isEnglish ? 'Clients' : 'عملائنا';
    final titleText = cmtTitle.isNotEmpty
        ? cmtTitle
        : (widget.isEnglish
        ? 'What Our Clients Say About Us'
        : 'ماذا يقول عملاؤنا عنّا');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: widget.isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          _buildHighlightedTitle(titleText, highlightWord),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: m.clientComments.comments.map((cmt) {
                final firstName = widget.isEnglish
                    ? cmt.firstName.en
                    : cmt.firstName.ar;
                final lastName = widget.isEnglish
                    ? cmt.lastName.en
                    : cmt.lastName.ar;
                final feedback = widget.isEnglish
                    ? cmt.feedback.en
                    : cmt.feedback.ar;
                final fullName = '$firstName $lastName'.trim();

                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: mainWidgetColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: cmt.imageUrl.isNotEmpty
                                ? _netImg(
                              url: cmt.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                ColorPick.primary.withOpacity(0.15),
                                child: Icon(
                                  Icons.person_outline,
                                  color: ColorPick.primary,
                                  size: 22,
                                ),
                              ),
                              errorWidget: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                ColorPick.primary.withOpacity(0.15),
                                child: Icon(
                                  Icons.person_outline,
                                  color: ColorPick.primary,
                                  size: 22,
                                ),
                              ),
                            )
                                : CircleAvatar(
                              radius: 24,
                              backgroundColor:
                              ColorPick.primary.withOpacity(0.15),
                              child: Icon(
                                Icons.person_outline,
                                color: ColorPick.primary,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fullName.isNotEmpty ? fullName : 'Client Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        feedback.isNotEmpty
                            ? feedback
                            : 'Great service! Highly recommended.',
                        textDirection: widget.isEnglish
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: AppColors.text.withOpacity(0.75),
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedTitle(String title, String highlightWord) {
    final idx = title.toLowerCase().indexOf(highlightWord.toLowerCase());
    if (idx == -1) {
      return Text(
        title,
        style: TextStyle(
          color: AppColors.text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      );
    }

    final before = title.substring(0, idx);
    final keyword = title.substring(idx, idx + highlightWord.length);
    final after = title.substring(idx + highlightWord.length);

    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: AppColors.text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(text: keyword, style: const TextStyle(color: ColorPick.primary)),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }

  // ── Download section ───────────────────────────────────────────────────────
  Widget _buildDownload(Color mainWidgetColor) {
    final m = widget.model;
    final title = widget.isEnglish ? m.download.title.en : m.download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (widget.isEnglish
        ? 'Download our app for the best experience'
        : 'قم بتنزيل تطبيقنا للحصول على أفضل تجربة');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        decoration: BoxDecoration(
          color: mainWidgetColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
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
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _storeBadge(
                        label: widget.isEnglish ? 'Google Play' : 'جوجل بلاي',
                        icon: Icons.play_arrow_rounded,
                      ),
                      const SizedBox(width: 12),
                      _storeBadge(
                        label: widget.isEnglish ? 'App Store' : 'آب ستور',
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
                  style: const TextStyle(
                    color: ColorPick.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _storeBadge(
                      label: widget.isEnglish ? 'Google Play' : 'جوجل بلاي',
                      icon: Icons.play_arrow_rounded,
                    ),
                    _storeBadge(
                      label: widget.isEnglish ? 'App Store' : 'آب ستور',
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

  Widget _storeBadge({required String label, required IconData icon}) {
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
                widget.isEnglish ? 'GET IT ON' : 'تحميل من',
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
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════
