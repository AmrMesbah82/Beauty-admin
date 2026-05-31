// ******************* FILE INFO *******************
// File Name: sections.dart
// Description: Section widgets for Main main
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › main › presentation › ui › widget › main_main

part of '../../pages/main_main.dart';


extension _HomeMainSections on _HomeMainPageState {
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
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomSvg(
                      assetPath: 'assets/arrowdown.svg',
                      width: 20.w, height: 20.h,
                      fit: BoxFit.scaleDown,
                      color: Colors.white,
                    ),
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
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _readOnlyLogoSection(HomePageModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logo',
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 8.h),
        Container(
          width: 70.w, height: 70.h,
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: data.branding.logoUrl.isNotEmpty
              ? () {
                  final viewId =
                      'svg-home-logo-${data.branding.logoUrl.hashCode}';
                  ui_web.platformViewRegistry.registerViewFactory(viewId,
                      (int id) {
                    final img = html.ImageElement()
                      ..src = data.branding.logoUrl
                      ..style.width = '100%'
                      ..style.height = '100%'
                      ..style.objectFit = 'contain';
                    return img;
                  });
                  return ClipOval(
                    child: SizedBox(
                      width: 70.w, height: 70.h,
                      child: HtmlElementView(viewType: viewId),
                    ),
                  );
                }()
              : const Icon(Icons.image_outlined, color: Colors.grey),
        ),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(
              child: _colorReadField('Primary Color', data.branding.primaryColor)),
          SizedBox(width: 16.w),
          Expanded(
              child: _colorReadField('Secondary', data.branding.secondaryColor)),
        ]),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(child: _colorReadField(
              'Male Primary Color', data.branding.malePrimaryColor)),
          SizedBox(width: 16.w),
          Expanded(child: _colorReadField(
              'Main Widget Color', data.branding.mainWidgetColor)),
        ]),
        SizedBox(height: 12.h),
        Row(children: [
          Expanded(child: _colorReadField('Background',
              data.branding.backgroundColor.isNotEmpty
                  ? data.branding.backgroundColor : '#D9D9D9')),
          SizedBox(width: 16.w),
          Expanded(child: _colorReadField('Header and Footer',
              data.branding.headerFooterColor.isNotEmpty
                  ? data.branding.headerFooterColor : '#D9D9D9')),
        ]),
        SizedBox(height: 12.h),
        Row(children: [
          Expanded(child: _readField('English Font',
              data.branding.englishFont.isEmpty
                  ? 'Select Font' : data.branding.englishFont)),
          SizedBox(width: 16.w),
          Expanded(child: _readField('Arabic Font',
              data.branding.arabicFont.isEmpty
                  ? 'Select Font' : data.branding.arabicFont)),
        ]),
      ],
    );
  }

  Widget _readOnlyHeaderSection(HomePageModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...data.navButtons.asMap().entries.map((entry) {
          final i = entry.key;
          final btn = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i > 0) ...[
                  Divider(color: const Color(0xFFE8E8E8), height: 1),
                  SizedBox(height: 12.h),
                ],
                Text('Icon',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.text)),
                SizedBox(height: 6.h),
                _readOnlyIconCircle(btn.iconUrl),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.menu_rounded,
                        size: 18.sp, color: AppColors.secondaryText),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _readFieldWithStatus('Title',
                          btn.name.en.isEmpty ? 'Text Here' : btn.name.en,
                          btn.status),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(child: _readFieldRtl('العنوان', btn.name.ar)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _readOnlyFooterSection(HomePageModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.footerColumns.asMap().entries.map((entry) {
        final i = entry.key;
        final col = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i > 0) ...[
              Divider(color: const Color(0xFFE8E8E8), height: 1),
              SizedBox(height: 12.h),
            ],
            Text('${i + 1}${_ord(i + 1)} Column',
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.text)),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(child: _readField('Group Title',
                  col.title.en.isEmpty ? 'Read Us' : col.title.en)),
              SizedBox(width: 16.w),
              Expanded(child: _readFieldRtl('عنوان المجموعة', col.title.ar)),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(child: _readField('Navigation', _displayRoute(col.route))),
              SizedBox(width: 10.w),
              const Expanded(child: SizedBox()),
            ]),
            SizedBox(height: 8.h),
            ...col.labels.map((lbl) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: _readField(
                        'Navigate To', _displayRoute(lbl.route))),
                    SizedBox(width: 8.w),
                    const Expanded(child: SizedBox()),
                  ]),
                  SizedBox(height: 6.h),
                  Row(children: [
                    Expanded(child: _readField('Label',
                        lbl.label.en.isEmpty ? 'Text Here' : lbl.label.en)),
                    SizedBox(width: 8.w),
                    Expanded(
                        child: _readFieldRtl('التسمية', lbl.label.ar)),
                  ]),
                ],
              ),
            )),
            SizedBox(height: 8.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _readOnlyAppLinkSection(HomePageModel data) {
    final appLinks = data.appDownloadLinks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _readField('Navigation Label',
                appLinks.labelEn.isEmpty ? 'Text Here' : appLinks.labelEn)),
            SizedBox(width: 16.w),
            Expanded(child: _readFieldRtl('تسمية التنقل', appLinks.labelAr)),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Icon',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.text)),
                  SizedBox(height: 6.h),
                  _readOnlyIconCircle(appLinks.iosIconUrl),
                  SizedBox(height: 10.h),
                  _readField('Insert Apple Link',
                      appLinks.iosUrl.isEmpty
                          ? 'Insert Apple Link' : appLinks.iosUrl),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Icon',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.text)),
                  SizedBox(height: 6.h),
                  _readOnlyIconCircle(appLinks.androidIconUrl),
                  SizedBox(height: 10.h),
                  _readField('Insert Android Link',
                      appLinks.androidUrl.isEmpty
                          ? 'Insert Android Link' : appLinks.androidUrl),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _readOnlyLinksSection(HomePageModel data) {
    final rows = (data.socialLinks.length / 2).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final left  = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _readLinkItem(data.socialLinks[left], left)),
              SizedBox(width: 16.w),
              right < data.socialLinks.length
                  ? Expanded(
                      child: _readLinkItem(data.socialLinks[right], right))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _readLinkItem(dynamic link, int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Icon',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.text)),
                SizedBox(width: 6.w),
                Container(
                  width: 32.w, height: 18.h,
                  decoration: BoxDecoration(
                    color: link.visibility
                        ? ColorPick.primary
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Align(
                    alignment: link.visibility
                        ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 14.w, height: 14.h,
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _readOnlyIconCircle(link.iconUrl),
        SizedBox(height: 6.h),
        _readField('Insert Link',
            link.url.isEmpty ? 'Insert Links' : link.url),
      ],
    );
  }

  Widget _readOnlyIconCircle(String url) {
    if (url.isNotEmpty) {
      final viewId = 'svg-home-main-${url.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      return Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: SizedBox(
            width: 60.w, height: 60.h,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      );
    }
    return Container(
      width: 60.w, height: 60.h,
      decoration: const BoxDecoration(
          color: Color(0xFFD9D9D9), shape: BoxShape.circle),
      child: const Icon(Icons.add, color: Colors.grey, size: 20),
    );
  }

  Widget _readField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity, height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.centerLeft,
        child: Text(value,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
            overflow: TextOverflow.ellipsis),
      ),
    ],
  );

  Widget _readFieldRtl(String label, String value) => Directionality(
    textDirection: ui.TextDirection.rtl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity, height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.centerRight,
          child: Text(value.isEmpty ? 'أدخل النص هنا' : value,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
              overflow: TextOverflow.ellipsis,
              textDirection: ui.TextDirection.rtl),
        ),
      ],
    ),
  );

  Widget _readFieldWithStatus(
      String label, String value, bool status) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Status: ',
                      style: StyleText.fontSize11Weight400
                          .copyWith(color: AppColors.text)),
                  Container(
                    width: 32.w, height: 18.h,
                    decoration: BoxDecoration(
                      color: status
                          ? ColorPick.primary
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Align(
                      alignment: status
                          ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 14.w, height: 14.h,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity, height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment: Alignment.centerLeft,
            child: Text(value.isEmpty ? 'Text Here' : value,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  Widget _colorReadField(String label, String hex) {
    Color color;
    try {
      final clean = hex.replaceAll('#', '');
      color = clean.length == 6
          ? Color(int.parse('FF$clean', radix: 16))
          : Colors.grey.shade300;
    } catch (_) {
      color = Colors.grey.shade300;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 4.h),
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(children: [
            Container(
              width: 14.w, height: 14.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Text(hex.isEmpty ? '#D9D9D9' : hex,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText)),
          ]),
        ),
      ],
    );
  }

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}
