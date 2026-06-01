// ******************* FILE INFO *******************
// File Name: ui_helpers.dart
// Description: UI helper widgets for Client Services edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › client_services › presentation › ui › widget › client_services_edit

part of '../../pages/client_services_edit.dart';

extension _ClientServicesEditUiHelpers on _ClientServicesEditPageState {
  Widget _btn(String label, Color bg, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              label,
              style:
                  StyleText.fontSize14Weight600.copyWith(color: Colors.white),
            ),
          ),
        ),
      );

  Widget _accordionWrap(String key, String title, List<Widget> children) {
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  Widget _label(String t) => Text(
        t,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
      );

  Widget _removeChip(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: ColorPick.red,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Remove',
            style: StyleText.fontSize11Weight400.copyWith(color: Colors.white),
          ),
        ),
      );

  Widget _descFields(
          TextEditingController en, TextEditingController ar) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomValidatedTextFieldMaster(
            label: 'Description',
            hint: 'Text Here',
            controller: en,
            maxLines: 4,
            showCharCount: false,
            maxLength: 10000,
            height: 100,
            submitted: _submitted,
            fillColor: Colors.white,
            primaryColor: _prim,
          ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف',
              hint: 'أدخل النص هنا',
              controller: ar,
              showCharCount: false,
              maxLength: 10000,
              maxLines: 4,
              height: 100,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _prim,
            ),
          ),
        ],
      );

  Widget _biRow(
    String enL,
    String arL,
    TextEditingController enC,
    TextEditingController arC, {
    bool useRow = false,
  }) {
    final en = CustomValidatedTextFieldMaster(
      label: enL,
      hint: 'Text Here',
      fillColor: Colors.white,
      controller: enC,
      height: 36,
      submitted: _submitted,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      primaryColor: _prim,
    );
    final ar = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arL,
        fillColor: Colors.white,
        hint: 'أدخل النص هنا',
        controller: arC,
        height: 36,
        submitted: _submitted,
        textDirection: ui.TextDirection.rtl,
        textAlign: TextAlign.right,
        primaryColor: _prim,
      ),
    );
    if (useRow)
      return Row(
        children: [
          Expanded(child: en),
          SizedBox(width: 16.w),
          Expanded(child: ar),
        ],
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        en,
        SizedBox(height: 10.h),
        ar,
      ],
    );
  }

  Widget _addButton(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: ColorPick.back,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14.sp, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                label,
                style:
                    StyleText.fontSize12Weight500.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-preview-${picked.bytes!.hashCode}';

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

  Widget _placeholder() => Container(
        width: 50.w,
        height: 50.h,
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

  Widget _placeholderCircle() => Container(
        width: 70.w,
        height: 70.h,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: CustomSvg(
            assetPath: 'assets/control/camera.svg',
            width: 30.w,
            height: 30.h,
            color: Colors.grey,
            fit: BoxFit.fill,
          ),
        ),
      );
}
