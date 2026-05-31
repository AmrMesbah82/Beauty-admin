// ******************* FILE INFO *******************
// File Name: ui_helpers.dart
// Description: UI helper widgets for Overview edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_edit

part of '../../pages/overview_edit.dart';

extension _OverviewEditUiHelpers on _OverviewEditPageState {
  Widget _accordionWrap(String key, String title, List<Widget> children) {
    final isOpen = _open[key] ?? true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _open[key] = !isOpen),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary, borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(children: [
              Expanded(child: Text(title,
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              Icon(
                isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 20.sp,
              ),
            ]),
          ),
        ]),
      ),
      if (isOpen)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    ]);
  }

  Widget _sectionLabel(String t) =>
      Text(t, style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text));

  Widget _biRow(
      String enLbl, String arLbl,
      TextEditingController enC, TextEditingController arC, {
        int maxLines = 1, bool useRow = false,
      }) {
    final h = maxLines > 1 ? 100.0 : 36.0;
    final en = CustomValidatedTextFieldMaster(
      label: enLbl, hint: 'Text Here', fillColor: Colors.white, controller: enC,
      maxLines: maxLines, height: h, submitted: _submitted,
      textDirection: ui.TextDirection.ltr, textAlign: TextAlign.left, primaryColor: _resolvedPrimary,
    );
    final ar = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLbl, fillColor: Colors.white, hint: 'أدخل النص هنا', controller: arC,
        maxLines: maxLines, height: h, submitted: _submitted,
        textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right, primaryColor: _resolvedPrimary,
      ),
    );
    if (useRow) {
      return Row(children: [Expanded(child: en), SizedBox(width: 16.w), Expanded(child: ar)]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [en, SizedBox(height: 10.h), ar]);
  }

  Widget _addButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(color: Color(0xFF797979), borderRadius: BorderRadius.circular(4.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text(label, style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _imgBox({required _PickedImage picked, VoidCallback? onPick}) {
    Widget content;

    if (picked.bytes != null) {
      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-preview-${picked.bytes!.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl..style.width = '100%'..style.height = '100%'..style.objectFit = 'contain';
        return img;
      });
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(child: SizedBox(width: 70.w, height: 70.h, child: HtmlElementView(viewType: viewId))),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      final viewId = 'svg-url-preview-${picked.url!.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = picked.url!..style.width = '100%'..style.height = '100%'..style.objectFit = 'contain';
        return img;
      });
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(child: SizedBox(width: 70.w, height: 70.h, child: HtmlElementView(viewType: viewId))),
      );
    } else {
      content = _placeholderCircle();
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 24.w, height: 24.h,
            decoration: BoxDecoration(color: ColorPick.primary, shape: BoxShape.circle),
            child: Center(child: CustomSvg(assetPath: 'assets/control/camera.svg', width: 12.w, height: 12.h, fit: BoxFit.fill)),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle() => Container(
    width: 70.w, height: 70.h,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Center(child: CustomSvg(assetPath: 'assets/control/camera.svg', width: 30.w, color: Colors.grey, height: 30.h, fit: BoxFit.fill)),
  );
}
