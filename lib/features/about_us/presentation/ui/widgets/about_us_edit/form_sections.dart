// ******************* FILE INFO *******************
// File Name: form_sections.dart
// Description: Form section widgets for About Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_edit

part of '../../pages/about_us_edit.dart';

extension _AboutEditFormSections on _AboutEditPageMasterState {
  // ── Headings section ────────────────────────────────────────────────────────
  Widget _headingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageUploadCircle(
          label: 'Icon',
          bytes: _headingsSvgBytes,
          url: _headingsSvgUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) {
              setState(() => _headingsSvgBytes = b);
              _hasChanges = true;
            }
          },
        ),
        SizedBox(height: 20.h),

        _fieldLabel('Title'),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _titleEnCtrl,
          arCtrl: _titleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ── Navigation Label section ────────────────────────────────────────────────
  Widget _navigationLabelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageUploadCircle(
          label: 'Icon',
          bytes: _navLabelIconBytes,
          url: _navLabelIconUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) {
              setState(() => _navLabelIconBytes = b);
              _hasChanges = true;
            }
          },
        ),
        SizedBox(height: 20.h),

        _fieldLabel('Title'),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _navLabelTitleEnCtrl,
          arCtrl: _navLabelTitleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ── Vision / Mission section editor ────────────────────────────────────────
  Widget _sectionEditor({
    required Uint8List? iconBytes,
    required Uint8List? svgBytes,
    required String iconUrl,
    required String svgUrl,
    required VoidCallback onPickIcon,
    required VoidCallback onPickSvg,
    required TextEditingController subEnCtrl,
    required TextEditingController subArCtrl,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _imageUploadCircle(
              label: 'Icon',
              bytes: iconBytes,
              url: iconUrl,
              onTap: onPickIcon,
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'Icon',
              bytes: svgBytes,
              url: svgUrl,
              onTap: onPickSvg,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: subEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
        SizedBox(height: 10.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          fillColor: Colors.white,
          controller: subArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
        SizedBox(height: 10.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: descEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
        SizedBox(height: 10.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 100,
          fillColor: Colors.white,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
      ],
    );
  }

  // ── Values section ──────────────────────────────────────────────────────────
  Widget _valuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_valueItems.length, (index) {
          final v = _valueItems[index];
          final bool isMain = index == 0;
          return _valueItemWidget(v, isMain: isMain);
        }),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addValueItem,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Value',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueItemWidget(_ValueItem v, {required bool isMain}) {
    final String itemLabel = isMain ? 'Main Icon' : 'Icon';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: itemLabel,
                bytes: v.iconBytes,
                url: v.iconUrl,
                onTap: () async {
                  final b = await _pickSvgFile();
                  if (b != null) {
                    setState(() => v.iconBytes = b);
                    _hasChanges = true;
                  }
                },
              ),
              GestureDetector(
                onTap: () => _removeValueItem(v.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _bilingualRow(
            enCtrl: v.titleEnCtrl,
            arCtrl: v.titleArCtrl,
            enHint: 'Text Here',
            arHint: 'أدخل النص هنا',
          ),

          _fieldLabel('Short Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: v.shortDescEnCtrl,
            height: 100,
            fillColor: Colors.white,
            maxLines: 4,
            maxLength: 500,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
          SizedBox(height: 8.h),
          _fieldLabelAr('وصف مختصر'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: v.shortDescArCtrl,
            fillColor: Colors.white,
            height: 100,
            maxLines: 4,
            maxLength: 500,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
        ],
      ),
    );
  }
}
