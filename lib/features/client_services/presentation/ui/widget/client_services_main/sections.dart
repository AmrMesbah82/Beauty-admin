part of '../../pages/client_services_main.dart';

extension _ClientServicesMainSections on _ClientServicesMainPageState {
  // ── Last Updated Row ────────────────────────────────────────────────────────
  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: ColorPick.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style:
                StyleText.fontSize13Weight500.copyWith(color: ColorPick.primary),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: ColorPick.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Details',
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  CustomSvg(
                    assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.scaleDown,
                    color: ColorPick.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion ───────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(6.r),
                bottomRight: Radius.circular(6.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  // ── Header section ──────────────────────────────────────────────────────────
  Widget _headerSection(ClientServicesPageModel m) => _accordion(
        key: 'header',
        title: 'Header',
        children: [
          _readOnlyLabel('SVG'),
          SizedBox(height: 6.h),
          _readOnlyImageCircle(m.header.svgUrl),
          SizedBox(height: 14.h),
          _readOnlyBiRow(
              'Title', 'العنوان', m.header.title.en, m.header.title.ar),
          SizedBox(height: 10.h),
          _readOnlyLabel('Description'),
          SizedBox(height: 6.h),
          _readOnlyBox(m.header.description.en, maxLines: 4),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الوصف',
              style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text),
            ),
          ),
          SizedBox(height: 6.h),
          _readOnlyBox(
            m.header.description.ar,
            maxLines: 4,
            textDirection: ui.TextDirection.rtl,
          ),
        ],
      );

  // ── Download section ────────────────────────────────────────────────────────
  Widget _downloadSection(ClientServicesPageModel m) => _accordion(
        key: 'download',
        title: 'Download Applications',
        children: [
          _readOnlyBiRow(
            'Title',
            'العنوان',
            m.download.title.en,
            m.download.title.ar,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apple Store Link',
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _readOnlyBox(m.download.appStoreLink),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Android Link',
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _readOnlyBox(m.download.googlePlayLink),
                  ],
                ),
              ),
            ],
          ),
        ],
      );

  // ── Mockups section ─────────────────────────────────────────────────────────
  Widget _mockupsSection(ClientServicesPageModel m) => _accordion(
        key: 'mockups',
        title: 'Mockups',
        children: [
          ...m.mockups.items.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _readOnlyLabel('SVG'),
                      const Spacer(),
                      _layoutChips(entry.value.layout),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  _readOnlyImageCircle(entry.value.svgUrl),
                  SizedBox(height: 10.h),
                  _readOnlyBiRow(
                    'Title',
                    'العنوان',
                    entry.value.title.en,
                    entry.value.title.ar,
                  ),
                  SizedBox(height: 8.h),
                  _readOnlyLabel('Description'),
                  SizedBox(height: 6.h),
                  _readOnlyBox(entry.value.description.en, maxLines: 4),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الوصف',
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _readOnlyBox(
                    entry.value.description.ar,
                    maxLines: 4,
                    textDirection: ui.TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h),
                  Divider(color: ColorPick.white),
                ],
              ),
            ),
          ),
        ],
      );

  // ── Layout chips (read-only) ────────────────────────────────────────────────
  Widget _layoutChips(MockupLayout layout) {
    const options = ['left', 'centered', 'right'];
    final currentLayout = layout.name.toLowerCase();
    final selectedIndex = options.indexOf(currentLayout).clamp(0, 2);

    return CustomSegmentedTabs(
      tabs: const ['Left', 'Centered', 'Right'],
      selectedIndex: selectedIndex,
      onTabSelected: (_) {},
      selectedColor: ColorPick.primary,
      unselectedColor: Colors.white,
      selectedTextColor: Colors.white,
      unselectedTextColor: AppColors.text,
      equalWidth: false,
      containerPadding:
          EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      containerColor: Colors.white,
    );
  }

  // ── Shared read-only helpers ────────────────────────────────────────────────
  Widget _readOnlyLabel(String t) => Text(
        t,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
      );

  Widget _readOnlyBiRow(
          String enL, String arL, String enV, String arV) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enL,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 6.h),
                _readOnlyBox(enV),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  arL,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 6.h),
                _readOnlyBox(arV, textDirection: ui.TextDirection.rtl),
              ],
            ),
          ),
        ],
      );

  Widget _readOnlyBox(
    String text, {
    int maxLines = 1,
    ui.TextDirection textDirection = ui.TextDirection.ltr,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text.isEmpty ? 'Text Here' : text,
        textDirection: textDirection,
        style: StyleText.fontSize12Weight400.copyWith(
          color: text.isEmpty ? AppColors.secondaryText : AppColors.text,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _readOnlyImageCircle(String url) {
    if (url.isNotEmpty) {
      final viewId = 'svg-client-svc-main-${url.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: SizedBox(
            width: 70.w,
            height: 70.h,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      );
    }
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomSvg(
          assetPath: 'assets/home_control/image.svg',
          width: 20.w,
          height: 20.h,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
