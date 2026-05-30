part of '../../pages/main_edit.dart';

extension _HomeEditSectionsFooter on _HomeEditPageState {
  Widget _footerSection(HomeCmsCubit cubit) => _accordion(
    key: 'footer',
    title: 'Footer',
    children: [
      ...List.generate(_footerColumns.length, (i) => _buildFooterColumn(i)),
      SizedBox(height: 4.h),
      if (_footerColumns.length < 6)
        GestureDetector(
          onTap: () {
            print('🟢 [Footer] addColumn tapped: '
                'currentColumns=${_footerColumns.length}  max=6');
            setState(() {
              _footerColumns.add(_newFooterColumn());
              _hasChanges = true;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
                color: const Color(0xFF797979),
                borderRadius: BorderRadius.circular(4.r)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 14.sp, color: Colors.white),
              SizedBox(width: 4.w),
              Text('Column',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: Colors.white)),
            ]),
          ),
        )
      else
        Builder(builder: (_) {
          print('🔴 [Footer] addColumn HIDDEN: '
              'columns=${_footerColumns.length} >= 6');
          return const SizedBox();
        }),
    ],
  );

  Widget _buildFooterColumn(int colIndex) {
    final col              = _footerColumns[colIndex];
    final labels           = col['labels'] as List<Map<String, dynamic>>;
    final navDropdownItems = _buildNavDropdownItems();

    print('🟡 [Footer] buildFooterColumn: colIndex=$colIndex  '
        'totalColumns=${_footerColumns.length}  '
        'labelsCount=${labels.length}');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${colIndex + 1}${_ord(colIndex + 1)} Column',
              style: StyleText.fontSize15Weight600.copyWith(color: AppColors.text)),
          _removeBtn(
              label: 'Remove',
              onTap: () => setState(() {
                final removed = _footerColumns.removeAt(colIndex);
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _disposeColumn(removed));
                _hasChanges = true;
              })),
        ],
      ),
      SizedBox(height: 8.h),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: CustomDropdownFormFieldInvMaster(
              label: 'Group Title',
              primaryColor: _resolvedPrimaryColor,
              hint: Text('Select navigation item',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText)),
              selectedValue: col['route'] as String?,
              items: navDropdownItems,
              widthIcon: 18, heightIcon: 18,
              dropdownColor: Colors.white,
              height: 36,
              onChanged: (val) {
                setState(() {
                  col['route'] = val;
                  if (val != null && val.isNotEmpty) {
                    final idx = _navRoutes.indexOf(val);
                    if (idx != -1) {
                      (col['titleEn'] as TextEditingController).text =
                          _navBtns[idx]['nameEn']!.text;
                      (col['titleAr'] as TextEditingController).text =
                          _navBtns[idx]['nameAr']!.text;
                    }
                  } else {
                    (col['titleEn'] as TextEditingController).clear();
                    (col['titleAr'] as TextEditingController).clear();
                  }
                  _hasChanges = true;
                });
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 1,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('عنوان المجموعة',
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 36.h,
                    child: TextFormField(
                      controller: col['titleAr'] as TextEditingController,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'الاسم بالعربي',
                        hintStyle: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                                const BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 1)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                                const BorderSide(color: Colors.transparent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),
      ...List.generate(labels.length, (li) => _buildLabelRow(colIndex, li)),
      SizedBox(height: 4.h),
      if (labels.length < 4)
        _addLabelBtn(onTap: () {
          print('🟢 [Footer] addLabel tapped: colIndex=$colIndex  '
              'currentLabels=${labels.length}  max=4');
          setState(() {
            labels.add(_newLabelRow());
            _hasChanges = true;
          });
        })
      else
        Builder(builder: (_) {
          print('🔴 [Footer] addLabel HIDDEN: colIndex=$colIndex  '
              'labelsCount=${labels.length} >= 4');
          return const SizedBox();
        }),
      SizedBox(height: 12.h),
    ]);
  }

  Widget _buildLabelRow(int colIndex, int labelIndex) {
    final labels =
        _footerColumns[colIndex]['labels'] as List<Map<String, dynamic>>;
    final label = labels[labelIndex];

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDropdownFormFieldInvMaster(
                        label: 'Navigate To',
                        primaryColor: _resolvedPrimaryColor,
                        hint: Text('Select destination',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.secondaryText)),
                        selectedValue: label['route'] as String?,
                        items: _kLabelDestinations,
                        dropdownColor: Colors.white,
                        widthIcon: 18,
                        labelTrailing: GestureDetector(
                          onTap: () => setState(() {
                            final removed = labels.removeAt(labelIndex);
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _disposeLabel(removed));
                            _hasChanges = true;
                          }),
                          child: Container(
                            width: 16.w, height: 16.h,
                            decoration: const BoxDecoration(
                                color: ColorPick.red, shape: BoxShape.circle),
                            child: Icon(Icons.remove,
                                color: Colors.white, size: 16.sp),
                          ),
                        ),
                        heightIcon: 18,
                        borderRadius: 4.r,
                        height: 36,
                        onChanged: (val) {
                          setState(() => label['route'] = val);
                          _hasChanges = true;
                        },
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
              ),
              SizedBox(width: 0.sp),
              Expanded(child: Container()),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Label', hint: 'Text Here',
                  controller: label['en'] as TextEditingController,
                  height: 36, submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  fillColor: Colors.white,
                  primaryColor: _resolvedPrimaryColor,
                  onChanged: (value) => _hasChanges = true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'التسمية',
                    fillColor: Colors.white,
                    hint: 'أدخل النص هنا',
                    controller: label['ar'] as TextEditingController,
                    height: 36, submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    primaryColor: _resolvedPrimaryColor,
                    onChanged: (value) => _hasChanges = true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
