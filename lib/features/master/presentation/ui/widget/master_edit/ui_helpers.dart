part of '../../pages/master_edit.dart';

extension _MasterEditUiHelpers on _MasterEditPageState {
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
                borderRadius: isOpen
                    ? BorderRadius.only(
                        topLeft:  Radius.circular(6.r),
                        topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ]),
            ),
          ),
          if (isOpen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  Widget _biRow(
      String enLabel,
      String arLabel,
      TextEditingController enCtrl,
      TextEditingController arCtrl, {
        int maxLines = 1,
        bool useRow = false,
      }) {
    final double fieldH = maxLines > 1 ? 120 : 36;
    final enField = CustomValidatedTextFieldMaster(
      label: enLabel,
      hint: 'Text Here',
      fillColor: Colors.white,
      controller: enCtrl,
      maxLines: maxLines,
      height: fieldH,
      submitted: _submitted,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      primaryColor: _resolvedPrimaryColor,
    );
    final arField = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLabel,
        fillColor: Colors.white,
        hint: 'أدخل النص هنا',
        controller: arCtrl,
        maxLines: maxLines,
        height: fieldH,
        submitted: _submitted,
        textDirection: ui.TextDirection.rtl,
        textAlign: TextAlign.right,
        primaryColor: _resolvedPrimaryColor,
      ),
    );
    if (useRow) {
      return Row(children: [
        Expanded(child: enField),
        SizedBox(width: 16.w),
        Expanded(child: arField),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [enField, SizedBox(height: 10.h), arField],
    );
  }

  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-preview-${picked.bytes!.hashCode}';

      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      content = Container(
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
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      final viewId = 'svg-url-preview-${picked.url!.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = picked.url!
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      content = Container(
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
    } else {
      content = _placeholderCircle();
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: ColorPick.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvg(
                assetPath: 'assets/control/camera.svg',
                width: 12.w,
                height: 12.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle() => Container(
    width: 70.w,
    height: 70.h,
    decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), shape: BoxShape.circle),
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
