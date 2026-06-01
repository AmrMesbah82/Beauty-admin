// ******************* FILE INFO *******************
// File Name: ui_helpers.dart
// Description: UI helper widgets for Home edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_edit

part of '../../pages/home_edit.dart';

extension _HomeEditUiHelpers on _HomeEditPageState {
  Widget _gap() => SizedBox(height: 10.h);

  Widget _accordion({
    required String       key,
    required String       title,
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
                  borderRadius: BorderRadius.circular(8.r)),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomSvg(
                    assetPath: 'assets/arrowdown.svg',
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.scaleDown,
                    color: Colors.white,
                  ),
                ),
              ]),
            ),
          ),
          if (isOpen)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ],
      ),
    );
  }

  Widget _removeBtn({required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
              color: ColorPick.red, borderRadius: BorderRadius.circular(4.r)),
          child: Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: Colors.white)),
        ),
      );

  Widget _addLabelBtn({required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
          color: ColorPick.back,
          borderRadius: BorderRadius.circular(4.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text('Label',
            style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _sectionLabel(String text) => Text(text,
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text));

  Widget _imgBox({
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/control/camera.svg',
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w, height: 30.h,
                fit: BoxFit.scaleDown,
                placeholderBuilder: (_) => _placeholderCircle(placeholderAsset),
              ),
            ),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                picked.url!,
                width: 20.w, height: 20.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    } else {
      content = _placeholderCircle(placeholderAsset);
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 24.w, height: 24.h,
            decoration: BoxDecoration(
              color: ColorPick.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvg(
                assetPath: pickIconAsset,
                width: 12.w, height: 12.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle(String assetPath) => Container(
    width: 70.w, height: 70.h,
    decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Center(
        child: CustomSvg(
            assetPath: assetPath,
            width: 20.w, height: 20.h,
            fit: BoxFit.fill)),
  );

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}
