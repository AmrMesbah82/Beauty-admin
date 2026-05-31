// ******************* FILE INFO *******************
// File Name: sections.dart
// Description: Form section widgets for Owner Services edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › owner_services › presentation › ui › widget › owner_services_edit

part of '../../pages/owner_services_edit.dart';

extension _OwnerServicesEditSections on _OwnerServicesEditPageState {
  Widget _headerBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('SVG'),
            _removeButton(() {
              setState(() => _headerImage = _PickedImage.empty());
            }),
          ],
        ),
        SizedBox(height: 6.h),
        _imgBox(
          picked: _headerImage,
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => _headerImage = p);
          },
        ),
        SizedBox(height: 12.h),
        _biRow('Title', 'العنوان', _headerTitleEn, _headerTitleAr, useRow: true),
        SizedBox(height: 10.h),
        CustomValidatedTextFieldMaster(
          label: 'Description',
          hint: 'Text Here',
          controller: _headerDescEn,
          maxLines: 4,
          height: 100,
          submitted: _submitted,
          fillColor: Colors.white,
          primaryColor: _resolvedPrimary,
        ),
        SizedBox(height: 10.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف',
            hint: 'أدخل النص هنا',
            controller: _headerDescAr,
            maxLines: 4,
            height: 100,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _downloadBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _biRow('Title', 'العنوان', _dlTitleEn, _dlTitleAr, useRow: true),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Apple Store Link',
                hint: 'Insert Links',
                controller: _appStoreLink,
                height: 36,
                submitted: false,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Android Link',
                hint: 'Insert Links',
                controller: _googlePlay,
                height: 36,
                submitted: false,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _mockupsBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_mockups.length, (i) => _mockupItemRow(i)),
        SizedBox(height: 8.h),
        _addButton('Mockup', () {
          setState(
            () => _mockups.add(
              _MockupLocal(id: 'mock_${DateTime.now().millisecondsSinceEpoch}'),
            ),
          );
        }),
      ],
    ),
  );

  Widget _mockupItemRow(int i) {
    final mock = _mockups[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('SVG'),
              _removeButton(() {
                setState(() {
                  final removed = _mockups.removeAt(i);
                  removed.dispose();
                });
              }),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imgBox(
                picked: mock.image,
                onPick: () async {
                  final p = await _pickImage();
                  if (p != null) setState(() => mock.image = p);
                },
              ),
              const Spacer(),
              _alignmentPills(mock),
            ],
          ),
          SizedBox(height: 10.h),
          _biRow('Title', 'العنوان', mock.titleEn, mock.titleAr, useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Description',
            hint: 'Text Here',
            controller: mock.descEn,
            maxLines: 4,
            height: 100,
            submitted: _submitted,
            fillColor: Colors.white,
            primaryColor: _resolvedPrimary,
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف',
              hint: 'أدخل النص هنا',
              controller: mock.descAr,
              maxLines: 4,
              height: 100,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimary,
            ),
          ),
          if (i < _mockups.length - 1) Divider(height: 24.h, color: ColorPick.white),
        ],
      ),
    );
  }

  Widget _alignmentPills(_MockupLocal mock) {
    const options = ['left', 'centered', 'right'];
    return CustomSegmentedTabs(
      tabs: const ['Left', 'Centered', 'Right'],
      selectedIndex: options.indexOf(mock.alignment).clamp(0, 2),
      onTabSelected: (index) => setState(() => mock.alignment = options[index]),
      selectedColor: ColorPick.primary,
      unselectedColor: Colors.white,
      selectedTextColor: Colors.white,
      unselectedTextColor: AppColors.text,
      equalWidth: false,
      containerPadding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      containerColor: Colors.white,
    );
  }

  Widget _actionRow(OwnerServicesCmsCubit cubit) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: _navigateToPreview,
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Color(0xFF8A5C70),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Preview',
                style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 300.w),
      Expanded(
        child: GestureDetector(
          onTap: () => showPublishConfirmDialog(
            title: 'EDITING ONER SERVICES DETAILS',
            subtitle: 'Do you want to save the changes made to this ONER SERVICES?',
            context: context,
            onConfirm: () => _save(cubit, publishStatus: 'published'),
          ),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Save',
                style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _secondaryRow(OwnerServicesCmsCubit cubit) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.discard,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Discard',
                style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 300.w),
      Expanded(child: Column()),
    ],
  );
}
