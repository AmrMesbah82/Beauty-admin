// ******************* FILE INFO *******************
// File Name: ui_helpers.dart
// Description: UI helper widgets for About Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_edit

part of '../../pages/about_us_edit.dart';

extension _AboutEditUiHelpers on _AboutEditPageMasterState {
  // ── Action buttons ──────────────────────────────────────────────────────────
  Widget _actionButtons(bool canPublish) {
    return Column(
      children: [
        Row(
          children: [
            // ── Preview ────────────────────────────────────────────────────
            Expanded(
              child: _btn(
                label: 'Preview',
                color: ColorPick.preview,
                onTap: _onPreview,
              ),
            ),
            SizedBox(width: 300.w),

            // ── Publish ────────────────────────────────────────────────────
            Expanded(
              child: AbsorbPointer(
                absorbing: !canPublish,
                child: Opacity(
                  opacity: canPublish ? 1.0 : 0.5,
                  child: _btn(
                    label: 'Publish',
                    color: const Color(0xFFD16F9A),
                    onTap: () {
                      if (!canPublish) {
                        setState(() => _submitted = true);
                        _showValidationError();
                        return;
                      }
                      showPublishConfirmDialog(
                        title: 'EDITING ABOUT US DETAILS',
                        subtitle:
                            'Do you want to save the changes made to this ABOUT US?',
                        context: context,
                        onConfirm: () => _save('published'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── Discard ────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: ColorPick.back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ── Saving overlay ──────────────────────────────────────────────────────────
  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 180.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: const Color(0xFFD16F9A)),
              SizedBox(height: 12.h),
              Text(
                'Saving...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image upload circle ─────────────────────────────────────────────────────
  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize16Weight400.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url))
                    : Icon(
                        Icons.add,
                        color: Colors.grey[600],
                        size: 28.sp,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 25.w,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD16F9A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: CustomSvg(
                        assetPath: "assets/control/camera.svg",
                        width: 10.w,
                        height: 10.h,
                        fit: BoxFit.scaleDown,
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
      final viewId = 'svg-about-bytes-${bytes.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return SizedBox(
        width: 64.w,
        height: 64.h,
        child: HtmlElementView(viewType: viewId),
      );
    }

    if (url.isNotEmpty) {
      final viewId = 'svg-about-url-${url.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return SizedBox(
        width: 64.w,
        height: 64.h,
        child: HtmlElementView(viewType: viewId),
      );
    }

    return Icon(Icons.image_outlined, color: Colors.grey[500], size: 28.sp);
  }

  // ── Shared form helpers ─────────────────────────────────────────────────────
  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
    int maxLength = 500,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint,
            controller: enCtrl,
            fillColor: Colors.white,
            height: 42,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint,
            controller: arCtrl,
            height: 42,
            fillColor: Colors.white,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
      );

  Widget _fieldLabelAr(String text) => Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
        ),
      );

  Widget _btn({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
