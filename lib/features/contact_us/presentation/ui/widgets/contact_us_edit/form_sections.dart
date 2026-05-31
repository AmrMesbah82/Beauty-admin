// ******************* FILE INFO *******************
// File Name: form_sections.dart
// Description: Form section widgets for Contact Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_edit

part of '../../pages/contact_us_edit.dart';

extension _ContactUsEditFormSections on _ContactUsCmsEditPageState {
  // ── Headings section ────────────────────────────────────────────────────────
  Widget _headingsSection() {
    final svgMissing =
        _submitted && _headingSvgBytes == null && _headingSvgUrl.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _imageUploadCircle(
          label: 'SVG',
          bytes: _headingSvgBytes,
          url:   _headingSvgUrl,
          onTap: () async {
            final b = await _pickSvgOnly();
            if (b != null) setState(() => _headingSvgBytes = b);
          },
        ),
        if (svgMissing)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'SVG is required',
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11.sp, color: _kRed),
            ),
          ),
        SizedBox(height: 16.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'Text Here',
                    fillColor:     Colors.white,
                    controller:    _titleEnCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign:     TextAlign.start,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _fieldLabelAr('العنوان'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'أدخل النص هنا',
                    fillColor:     Colors.white,
                    controller:    _titleArCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign:     TextAlign.right,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _fieldLabel('Short Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'Text Here',
          fillColor:     Colors.white,
          controller:    _shortDescEnCtrl,
          height:        42,
          maxLines:      1,
          maxLength:     300,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.start,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 12.h),

        _fieldLabelAr('وصف مختصر'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'أدخل النص هنا',
          fillColor:     Colors.white,
          controller:    _shortDescArCtrl,
          height:        42,
          maxLines:      1,
          maxLength:     300,
          submitted:     _submitted,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ── Description section (Client / Owner) ────────────────────────────────────
  Widget _descriptionSection({
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required List<_ReasonItem>     reasons,
    required bool                  isRequired,
    required ValueChanged<bool>    onToggleRequired,
    required VoidCallback          onAddReason,
    required void Function(String) onRemoveReason,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'Text Here',
          fillColor:     Colors.white,
          controller:    descEnCtrl,
          height:        100,
          maxLines:      4,
          maxLength:     500,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.start,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 12.h),

        _fieldLabelAr('الوصف'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'أدخل النص هنا',
          fillColor:     Colors.white,
          controller:    descArCtrl,
          height:        100,
          maxLines:      4,
          maxLength:     500,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        ...reasons.asMap().entries.map(
          (e) => _reasonEditItem(
            e.value,
            e.key,
            onRemoveReason,
            sectionIsRequired: isRequired,
            onToggleRequired:  e.key == 0 ? onToggleRequired : null,
          ),
        ),

        GestureDetector(
          onTap: onAddReason,
          child: Container(
            width:  110.w,
            height: 30.h,
            decoration: BoxDecoration(
              color:        const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Reason',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ── Reason edit item ────────────────────────────────────────────────────────
  Widget _reasonEditItem(
    _ReasonItem r,
    int index,
    void Function(String) onRemove, {
    required bool sectionIsRequired,
    ValueChanged<bool>? onToggleRequired,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  hint:  'Text Here',
                  label: 'Reason',
                  labelTrailing: Row(
                    children: [
                      if (onToggleRequired != null) ...[
                        Text(
                          'Required',
                          style: TextStyle(
                            fontFamily:  'Cairo',
                            fontSize:    12.sp,
                            fontWeight:  FontWeight.w500,
                            color:       Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => onToggleRequired(!sectionIsRequired),
                          child: _toggleSwitch(sectionIsRequired),
                        ),
                      ],
                      if (index > 0) ...[
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => onRemove(r.id),
                          child: Container(
                            width:  18.w,
                            height: 18.h,
                            decoration: const BoxDecoration(
                              color: _kRed,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.remove,
                                color: Colors.white, size: 12.sp),
                          ),
                        ),
                      ],
                    ],
                  ),
                  fillColor:     Colors.white,
                  controller:    r.labelEnCtrl,
                  height:        42,
                  maxLines:      1,
                  maxLength:     200,
                  submitted:     _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign:     TextAlign.start,
                  onChanged:     (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_fieldLabelAr('السبب')],
                    ),
                    SizedBox(height: 4.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'أدخل النص هنا',
                      fillColor:     Colors.white,
                      controller:    r.labelArCtrl,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign:     TextAlign.right,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleSwitch(bool isOn) {
    return Container(
      width:  40.w,
      height: 22.h,
      decoration: BoxDecoration(
        color:        isOn ? ColorPick.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: AnimatedAlign(
        duration:  const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width:  18.w,
          height: 18.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  // ── Social Links section ────────────────────────────────────────────────────
  Widget _socialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        if (_socialLinkItems.isNotEmpty) ..._buildSocialLinksGrid(),

        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addSocialLink,
          child: Container(
            width:  90.w,
            height: 30.h,
            decoration: BoxDecoration(
              color:        const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Link',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  List<Widget> _buildSocialLinksGrid() {
    final rows = <Widget>[];
    for (var i = 0; i < _socialLinkItems.length; i += 2) {
      final left  = _socialLinkItems[i];
      final right = (i + 1) < _socialLinkItems.length
          ? _socialLinkItems[i + 1]
          : null;

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SizedBox(
            height: 38.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _socialLinkDropdownWidget(left)),
                SizedBox(width: 16.w),
                right != null
                    ? Expanded(child: _socialLinkDropdownWidget(right))
                    : const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _socialLinkDropdownWidget(_SocialLinkItem s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _SocialLinkDropdown(
            key:           ValueKey(s.id),
            footerLinks:   _footerSocialLinks,
            selectedIndex: s.selectedIndex,
            onChanged: (idx) {
              setState(() => s.selectedIndex = idx);
            },
            submitted: _submitted,
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => _removeSocialLink(s.id),
          child: Container(
            width:  20.w,
            height: 20.w,
            decoration:
                const BoxDecoration(color: _kRed, shape: BoxShape.circle),
            child: Icon(Icons.remove, color: Colors.white, size: 12.sp),
          ),
        ),
      ],
    );
  }
}
