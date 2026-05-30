part of '../../pages/request_edit.dart';

extension _RequestEditUiHelpers on _RequestDemoEditPageState {
  Widget _btn(String l, Color bg, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      height: 44.h,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6.r)),
      child: Center(
        child: Text(l, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
      ),
    ),
  );

  Widget _acc(String key, String title, List<Widget> ch) {
    final o = _open[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !o),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                ),
                Icon(
                  o ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (o) Column(crossAxisAlignment: CrossAxisAlignment.start, children: ch),
      ],
    );
  }

  Widget _lbl(String t) =>
      Text(t, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  Widget _biFields(
      String enL, String arL,
      TextEditingController enC, TextEditingController arC) =>
      Row(
        children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: enL, hint: 'Text Here', controller: enC, height: 36,
              submitted: _sub, fillColor: Colors.white,
              textDirection: ui.TextDirection.ltr, textAlign: TextAlign.left, primaryColor: _p,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: arL, hint: 'أدخل النص هنا', controller: arC, height: 36,
                submitted: _sub, fillColor: Colors.white,
                textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right, primaryColor: _p,
              ),
            ),
          ),
        ],
      );

  Widget _removeDot(VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      width: 16.w, height: 16.h,
      decoration: const BoxDecoration(color: ColorPick.red, shape: BoxShape.circle),
      child: Icon(Icons.remove, color: Colors.white, size: 10.sp),
    ),
  );

  Widget _addBtn(String l, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Color(0xFF797979), borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(l, style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
        ],
      ),
    ),
  );

  Widget _imgBox(_Img picked, VoidCallback onPick) {
    Widget content;

    if (picked.bytes != null) {
      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-req-bytes-${picked.bytes!.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: SizedBox(width: 70.w, height: 70.h, child: HtmlElementView(viewType: viewId)),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      final viewId = 'svg-req-url-${picked.url!.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = picked.url!
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: SizedBox(width: 70.w, height: 70.h, child: HtmlElementView(viewType: viewId)),
        ),
      );
    } else {
      content = Container(
        width: 50.w, height: 50.h,
        decoration: BoxDecoration(
          color: _sub && picked.isEmpty ? ColorPick.red.withOpacity(0.1) : const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            size: 24.sp,
            color: _sub && picked.isEmpty ? ColorPick.red : AppColors.secondaryText,
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(onTap: onPick, child: content),
        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 24.w, height: 24.h,
              decoration: BoxDecoration(color: ColorPick.primary, shape: BoxShape.circle),
              child: Center(
                child: CustomSvg(
                  assetPath: 'assets/control/camera.svg',
                  width: 12.w, height: 12.h, fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
