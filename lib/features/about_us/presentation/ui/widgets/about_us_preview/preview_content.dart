// ******************* FILE INFO *******************
// File Name: preview_content.dart
// Description: Preview content widget for About Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_preview

part of '../../pages/about_us_preview.dart';

class _PreviewContent extends StatefulWidget {
  final double fakeWidth;
  final double fakeHeight;
  final AboutPageModel model;
  final bool isRtl;
  final bool isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isRtl,
    required this.isMobile,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  late int _selectedTopTab;
  late int _selectedSubTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = 0;
    _selectedSubTab = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !widget.isMobile && widget.fakeWidth >= 900;
    final isTablet = !widget.isMobile && widget.fakeWidth >= 600 && widget.fakeWidth < 900;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(widget.fakeWidth, widget.fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Directionality(
          textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            color: AppColors.background,
            width: widget.fakeWidth,
            height: widget.fakeHeight,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildHeroSection(),
                  const SizedBox(height: 20),
                  isDesktop
                      ? _buildDesktopBody()
                      : (isTablet ? _buildTabletBody() : _buildMobileBody()),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Section ───────────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    final svgHero = widget.model.svgUrl.isNotEmpty && !widget.isMobile
        ? SizedBox(
      width: 260.w,
      height: 220.h,
      child: _netImg(
        url: widget.model.svgUrl,
        width: 260.w,
        height: 220.h,
        fit: BoxFit.contain,
      ),
    )
        : (widget.model.svgUrl.isNotEmpty && widget.isMobile
        ? SizedBox(
      width: 160.w,
      height: 160.h,
      child: _netImg(
        url: widget.model.svgUrl,
        width: 160.w,
        height: 160.h,
        fit: BoxFit.contain,
      ),
    )
        : const SizedBox.shrink());

    final titleHero = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 16.w : 24.w,
            vertical: widget.isMobile ? 20.h : 36.h),
        child: Text(
          _ab(widget.model.title, widget.isRtl).isNotEmpty
              ? _ab(widget.model.title, widget.isRtl)
              : (widget.isRtl ? 'من نحن' : 'About Us'),
          textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
          style: StyleText.fontSize45Weight600.copyWith(
            fontSize: widget.isMobile ? 28.sp : 48.sp,
            fontWeight: FontWeight.w700,
            color: ColorPick.primary,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.fakeWidth * 0.17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.isRtl
            ? [titleHero, svgHero]
            : [svgHero, titleHero],
      ),
    );
  }

  // ── Desktop Body ───────────────────────────────────────────────────────────
  Widget _buildDesktopBody() {
    final screenW = widget.fakeWidth;
    final contentW = _desktopContentWidth(context);
    final hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity);

    final topTabs = [
      BiText(ar: 'من نحن', en: 'About Us'),
      BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Tab Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(topTabs.length, (i) {
                final label = widget.isRtl
                    ? (topTabs[i].ar.isNotEmpty ? topTabs[i].ar : topTabs[i].en)
                    : topTabs[i].en;
                final svgAsset = i == 0
                    ? widget.model.navigationLabel.iconUrl
                    : '';
                return _DesktopTopTabItem(
                  index: i,
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: _selectedTopTab == i,
                  primaryColor: ColorPick.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 10.h),

          // Tab 0: About Us
          if (_selectedTopTab == 0) _buildDesktopAboutUsContent(),

          // Tab 1: Our Strategy
          if (_selectedTopTab == 1) _buildDesktopStrategyContent(),

          SizedBox(height: 36.h),
        ],
      ),
    );
  }

  Widget _buildDesktopAboutUsContent() {
    var gap = 16.w;
    var leftW = 280.w;

    final tabLabels = [
      widget.isRtl ? 'الرؤية' : 'Vision',
      widget.isRtl ? 'الرسالة' : 'Mission',
      widget.isRtl ? 'القيم' : 'Values',
    ];
    final tabIconUrls = [
      widget.model.vision.iconUrl,
      widget.model.mission.iconUrl,
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
    ];
    final tabDescs = [
      _ab(widget.model.vision.subDescription, widget.isRtl),
      _ab(widget.model.mission.subDescription, widget.isRtl),
      widget.model.values.isNotEmpty
          ? _ab(widget.model.values.first.shortDescription, widget.isRtl)
          : '',
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (i) {
                final isLast = i == 2;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                  child: _DesktopTabItem(
                    label: tabLabels[i],
                    iconUrl: tabIconUrls[i],
                    selectedDesc: _selectedSubTab == i ? tabDescs[i] : '',
                    isSelected: _selectedSubTab == i,
                    primaryColor: ColorPick.primary,
                    secondaryColor: _C.secondary,
                    onTap: () => setState(() => _selectedSubTab = i),
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _DesktopRightPanel(
              model: widget.model,
              tabIndex: _selectedSubTab,
              isRtl: widget.isRtl,
              primaryColor: ColorPick.primary,
              secondaryColor: _C.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStrategyContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          widget.isRtl ? 'استراتيجيتنا قيد التطوير' : 'Our Strategy content goes here',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  // ── Tablet Body ────────────────────────────────────────────────────────────
  Widget _buildTabletBody() {
    final topTabs = [
      BiText(ar: 'من نحن', en: 'About Us'),
      BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(topTabs.length, (i) {
                final label = widget.isRtl
                    ? (topTabs[i].ar.isNotEmpty ? topTabs[i].ar : topTabs[i].en)
                    : topTabs[i].en;
                final svgAsset = i == 0
                    ? widget.model.navigationLabel.iconUrl
                    : '';
                return _TabletTopTabItem(
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: _selectedTopTab == i,
                  primaryColor: ColorPick.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),
          if (_selectedTopTab == 0) _buildTabletAboutUsContent(),
          if (_selectedTopTab == 1) _buildTabletStrategyContent(),
        ],
      ),
    );
  }

  Widget _buildTabletAboutUsContent() {
    final tabLabels = [
      widget.isRtl ? 'الرؤية' : 'Vision',
      widget.isRtl ? 'الرسالة' : 'Mission',
      widget.isRtl ? 'القيم' : 'Values',
    ];
    final tabIconUrls = [
      widget.model.vision.iconUrl,
      widget.model.mission.iconUrl,
      widget.model.values.isNotEmpty ? widget.model.values.first.iconUrl : '',
    ];

    return Column(
      children: [
        Row(
          children: List.generate(3, (i) {
            final isLast = i == 2;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: isLast ? 0 : 10.w),
                child: _TabletTabItem(
                  label: tabLabels[i],
                  iconUrl: tabIconUrls[i],
                  isSelected: _selectedSubTab == i,
                  primaryColor: ColorPick.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedSubTab = i),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 14.h),
        _TabletContentPanel(
          model: widget.model,
          tabIndex: _selectedSubTab,
          isRtl: widget.isRtl,
          primaryColor: ColorPick.primary,
          secondaryColor: _C.secondary,
        ),
      ],
    );
  }

  Widget _buildTabletStrategyContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          widget.isRtl ? 'استراتيجيتنا قيد التطوير' : 'Our Strategy content goes here',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  // ── Mobile Body ────────────────────────────────────────────────────────────
  Widget _buildMobileBody() {
    final topTabs = [
      BiText(ar: 'من نحن', en: 'About Us'),
      BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(topTabs.length, (i) {
                final label = widget.isRtl
                    ? (topTabs[i].ar.isNotEmpty ? topTabs[i].ar : topTabs[i].en)
                    : topTabs[i].en;
                final svgAsset = i == 0
                    ? widget.model.navigationLabel.iconUrl
                    : '';
                return _MobileTopTabItemPreview(
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: _selectedTopTab == i,
                  primaryColor: ColorPick.primary,
                  secondaryColor: _C.secondary,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),
          if (_selectedTopTab == 0) _buildMobileAboutUsContent(),
          if (_selectedTopTab == 1) _buildMobileStrategyContent(),
        ],
      ),
    );
  }

  Widget _buildMobileAboutUsContent() {
    final tabs = [
      _MobileTabDataPreview(
        label: widget.isRtl ? 'الرؤية' : 'Vision',
        iconUrl: widget.model.vision.iconUrl,
        svgUrl: widget.model.vision.svgUrl,
        fullText: _ab(widget.model.vision.description, widget.isRtl),
        tabIndex: 0,
      ),
      _MobileTabDataPreview(
        label: widget.isRtl ? 'الرسالة' : 'Mission',
        iconUrl: widget.model.mission.iconUrl,
        svgUrl: widget.model.mission.svgUrl,
        fullText: _ab(widget.model.mission.description, widget.isRtl),
        tabIndex: 1,
      ),
      _MobileTabDataPreview(
        label: widget.isRtl ? 'القيم' : 'Values',
        iconUrl: widget.model.values.isNotEmpty
            ? widget.model.values.first.iconUrl
            : '',
        svgUrl: '',
        fullText: '',
        tabIndex: 2,
      ),
    ];

    return Column(
      children: tabs.map((tab) {
        final isOpen = _selectedSubTab == tab.tabIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _MobileAccordionItemPreview(
            tab: tab,
            values: widget.model.values,
            isExpanded: isOpen,
            isRtl: widget.isRtl,
            primaryColor: ColorPick.primary,
            secondaryColor: _C.secondary,
            fakeWidth: widget.fakeWidth,
            onTap: () => setState(() => _selectedSubTab = isOpen ? -1 : tab.tabIndex),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileStrategyContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          widget.isRtl ? 'استراتيجيتنا قيد التطوير' : 'Our Strategy content goes here',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESKTOP COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════
