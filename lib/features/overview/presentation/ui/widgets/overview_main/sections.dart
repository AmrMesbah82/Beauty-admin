// ******************* FILE INFO *******************
// File Name: sections.dart
// Description: Section widgets for Overview main
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_main

part of '../../pages/overview_main.dart';

extension _OverviewMainSections on _OverviewMainPageState {
  String _fmtDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

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
              color: ColorPick.white, borderRadius: BorderRadius.circular(4.r)),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: ColorPick.primary),
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
                  Text('Edit Details',
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: Colors.black)),
                  SizedBox(width: 6.w),
                  CustomSvg(
                      assetPath: "assets/control/edit_icon_pick.svg",
                      width: 20.w,
                      height: 20.h,
                      fit: BoxFit.scaleDown,
                      color: ColorPick.primary),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _open[key] = !isOpen),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: ColorPick.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(children: [
            Expanded(
                child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white))),
            Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 20.sp),
          ]),
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
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
    ]);
  }

  Widget _headingsSection(OverviewPageModel m) => _accordion(
    key: 'headings',
    title: 'Headings',
    children: [
      _readOnlyBiRow('Title', 'العنوان', m.headings.title.en, m.headings.title.ar),
      SizedBox(height: 10.h),
      _readOnlyLabel('Description'),
      SizedBox(height: 6.h),
      _readOnlyBox(m.headings.description.en, maxLines: 4),
      SizedBox(height: 8.h),
      Align(
          alignment: Alignment.centerRight,
          child: Text('الوصف',
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text))),
      SizedBox(height: 6.h),
      _readOnlyBox(m.headings.description.ar,
          maxLines: 4, textDirection: ui.TextDirection.rtl),
    ],
  );

  Widget _servicesSection(OverviewPageModel m) => _accordion(
    key: 'services',
    title: 'Services',
    children: [
      _readOnlyBiRow('Title', 'العنوان', m.services.title.en, m.services.title.ar),
      SizedBox(height: 10.h),
      ...m.services.items.map((item) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 6.h),
          _readOnlyLabel('Image'),
          SizedBox(height: 6.h),
          _readOnlyImageCircle(item.imageUrl),
          SizedBox(height: 10.h),
          _readOnlyBiRow('Service Name', 'اسم الخدمة', item.name.en, item.name.ar),
        ]),
      )),
    ],
  );

  Widget _gallerySection(OverviewPageModel m) => _accordion(
    key: 'gallery',
    title: 'Gallery',
    children: [
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: m.gallery.images.map((img) {
          return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _readOnlyLabel('Image'),
            SizedBox(height: 4.h),
            _readOnlyImageCircle(img.imageUrl),
          ]);
        }).toList(),
      ),
    ],
  );

  Widget _clientCommentsSection(OverviewPageModel m) => _accordion(
    key: 'comments',
    title: 'Client Comments',
    children: [
      _readOnlyBiRow('Title', 'العنوان', m.clientComments.title.en,
          m.clientComments.title.ar),
      SizedBox(height: 10.h),
      ...m.clientComments.comments.map((c) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _readOnlyImageCircle(c.imageUrl),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('First Name',
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
              SizedBox(height: 6.h),
              _readOnlyBox(c.firstName.en),
            ])),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Last Name',
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
              SizedBox(height: 6.h),
              _readOnlyBox(c.lastName.en),
            ])),
          ]),
          SizedBox(height: 8.h),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('اسم العائلة',
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
              SizedBox(height: 6.h),
              _readOnlyBox(c.lastName.ar, textDirection: ui.TextDirection.rtl),
            ])),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('الاسم الأول',
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
              SizedBox(height: 6.h),
              _readOnlyBox(c.firstName.ar, textDirection: ui.TextDirection.rtl),
            ])),
          ]),
          SizedBox(height: 8.h),
          _readOnlyLabel('Feedback'),
          SizedBox(height: 6.h),
          _readOnlyBox(c.feedback.en, maxLines: 4),
          SizedBox(height: 8.h),
          Align(
              alignment: Alignment.centerRight,
              child: Text('ملاحظات',
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text))),
          SizedBox(height: 6.h),
          _readOnlyBox(c.feedback.ar,
              maxLines: 4, textDirection: ui.TextDirection.rtl),
        ]),
      )),
    ],
  );

  Widget _downloadSection(OverviewPageModel m) => _accordion(
    key: 'download',
    title: 'Download Applications',
    children: [
      _readOnlyBiRow('Title', 'العنوان', m.download.title.en, m.download.title.ar),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Apple Store Link',
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          _readOnlyBox(m.download.appStoreLink),
        ])),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Android Link',
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          _readOnlyBox(m.download.googlePlayLink),
        ])),
      ]),
    ],
  );

  Widget _readOnlyLabel(String text) =>
      Text(text, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  Widget _readOnlyBiRow(String enLabel, String arLabel, String enVal, String arVal) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(enLabel,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
        SizedBox(height: 6.h),
        _readOnlyBox(enVal),
      ])),
      SizedBox(width: 16.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(arLabel,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
        SizedBox(height: 6.h),
        _readOnlyBox(arVal, textDirection: ui.TextDirection.rtl),
      ])),
    ]);
  }

  Widget _readOnlyBox(String text,
      {int maxLines = 1, ui.TextDirection textDirection = ui.TextDirection.ltr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
      child: Text(
        text.isEmpty ? 'Text Here' : text,
        textDirection: textDirection,
        style: StyleText.fontSize12Weight400.copyWith(
            color: text.isEmpty ? AppColors.secondaryText : AppColors.text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _readOnlyImageCircle(String url) {
    if (url.isNotEmpty) {
      final viewId = 'svg-overview-main-${url.hashCode}';
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
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
      decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
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
