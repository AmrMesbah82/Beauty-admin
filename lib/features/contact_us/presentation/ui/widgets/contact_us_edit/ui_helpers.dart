// ******************* FILE INFO *******************
// File Name: ui_helpers.dart
// Description: UI helper widgets for Contact Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_edit

part of '../../pages/contact_us_edit.dart';

extension _ContactUsEditUiHelpers on _ContactUsCmsEditPageState {
  // ── Accordion ───────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width:   double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color:        ColorPick.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size:  22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width:      double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            child: child,
          ),
      ],
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────────
  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: ColorPick.preview,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ContactUsCmsPreviewPage()),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child:
                  _btn(label: 'Save', color: ColorPick.primary, onTap: _onSaveTap),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: ColorPick.back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 300.sp),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ── Image upload circle ─────────────────────────────────────────────────────
  Widget _imageUploadCircle({
    required String     label,
    required Uint8List? bytes,
    required String     url,
    required VoidCallback onTap,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   13.sp,
              fontWeight: FontWeight.w600,
              color:      Colors.black87,
            )),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:  64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url))
                    : Icon(Icons.description_outlined,
                        color: Colors.grey[600], size: 28.sp),
              ),
              Positioned(
                bottom: 0,
                right:  0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width:  25.w,
                    height: 25.h,
                    decoration: const BoxDecoration(
                        color: ColorPick.primary, shape: BoxShape.circle),
                    child: Center(
                      child: CustomSvg(
                        assetPath: 'assets/control/camera.svg',
                        width:     10.w,
                        height:    10.h,
                        fit:       BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(Uint8List? bytes, String url) {
    if (bytes != null) {
      final dataUrl = _svgBytesToDataUrl(bytes);
      final viewId  = 'svg-about-bytes-${bytes.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src             = dataUrl
          ..style.width     = '100%'
          ..style.height    = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      return SizedBox(
          width: 64.w, height: 64.h, child: HtmlElementView(viewType: viewId));
    }
    if (url.isNotEmpty) {
      final viewId = 'svg-about-url-${url.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src             = url
          ..style.width     = '100%'
          ..style.height    = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      return SizedBox(
          width: 64.w, height: 64.h, child: HtmlElementView(viewType: viewId));
    }
    return Icon(Icons.image_outlined, color: Colors.grey[500], size: 28.sp);
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
      );

  Widget _fieldLabelAr(String text) => Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style:
              StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
        ),
      );

  Widget _btn({
    required String       label,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(8.r),
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
  }
}
