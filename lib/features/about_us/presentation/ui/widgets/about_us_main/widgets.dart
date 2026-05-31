// ******************* FILE INFO *******************
// File Name: widgets.dart
// Description: Sub-widgets for About Us main page
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_main

part of '../../pages/about_us_main.dart';

extension _AboutMainWidgets on _AboutMainPageMasterDashboardState {
  Widget _renderBytes(
    Uint8List b, {
    bool isSvg = false,
    BoxFit fit = BoxFit.cover,
  }) {
    if (isSvg || _isSvgBytes(b)) {
      return SvgPicture.memory(b, fit: fit);
    }
    return Image.memory(b, fit: fit);
  }

  Widget _networkImage({
    required String url,
    bool isSvg = false,
    BoxFit fit = BoxFit.cover,
    double iconSize = 24,
  }) {
    if (url.isEmpty) {
      return Icon(
        isSvg ? Icons.description_outlined : Icons.image_outlined,
        color: Colors.grey[500],
        size: iconSize.sp,
      );
    }

    final viewId = 'svg-about-main-${url.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      return img;
    });

    return HtmlElementView(viewType: viewId);
  }

  Widget _iconPreviewCircle({
    required String label,
    required String url,
    bool isSvg = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.h),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: url.isNotEmpty
              ? ClipOval(
                  child: SizedBox(
                    width: 56.w,
                    height: 56.w,
                    child: _networkImage(
                      url: url,
                      isSvg: isSvg,
                      fit: BoxFit.contain,
                      iconSize: 24,
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    isSvg ? Icons.description_outlined : Icons.image_outlined,
                    color: Colors.grey[500],
                    size: 24.sp,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _sectionReadView({
    required String iconUrl,
    required String svgUrl,
    required String subDescEn,
    required String subDescAr,
    required String descEn,
    required String descAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconPreviewCircle(label: 'Icon', url: iconUrl),
            SizedBox(width: 24.w),
            _iconPreviewCircle(label: 'SVG', url: svgUrl, isSvg: true),
          ],
        ),
        SizedBox(height: 16.h),
        _readField(
          'Sub Description',
          subDescEn.isEmpty ? 'Text Here' : subDescEn,
          height: 80,
        ),
        SizedBox(height: 15.h),
        _readFieldRtl('وصف فرعي', subDescAr, height: 80),
        SizedBox(height: 10.h),
        _readField(
          'Description',
          descEn.isEmpty ? 'Text Here' : descEn,
          height: 80,
        ),
        SizedBox(height: 15.h),
        _readFieldRtl('الوصف', descAr, height: 80),
      ],
    );
  }

  Widget _valuesGrid(List<AboutValueItem> items) {
    final rows = <List<AboutValueItem>>[];
    for (int i = 0; i < items.length; i += 4) {
      rows.add(items.skip(i).take(4).toList());
    }
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...row.map(
                    (item) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _valueMiniCard(item),
                      ),
                    ),
                  ),
                  ...List.generate(
                    4 - row.length,
                    (_) => const Expanded(child: SizedBox()),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _valueMiniCard(AboutValueItem item) {
    return Container(
      height: 140.h,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: _networkImage(
                url: item.iconUrl,
                isSvg: false,
                fit: BoxFit.contain,
                iconSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: StyleText.fontSize12Weight600.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: Text(
              item.shortDescription.en.isNotEmpty
                  ? item.shortDescription.en
                  : 'Short Description',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryBlack,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: ColorPick.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: ColorPick.primary),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.card,
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

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _readField(String label, String value, {double height = 36}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            height: height.h,
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: height > 36 ? 8.h : 0,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              value,
              style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText),
              maxLines: height > 36 ? 5 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _readFieldRtl(
    String label,
    String value, {
    double height = 36,
  }) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
                  StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: height.h,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: height > 36 ? 8.h : 0,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r),
              ),
              alignment:
                  height > 36 ? Alignment.topRight : Alignment.centerRight,
              child: Text(
                value.isEmpty ? 'أكتب هنا' : value,
                style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText),
                textDirection: TextDirection.rtl,
                maxLines: height > 36 ? 5 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
