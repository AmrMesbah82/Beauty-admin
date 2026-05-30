part of '../../pages/main_edit.dart';

extension _HomeEditSections on _HomeEditPageState {
  Widget _logoAndBrandingSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      _sectionLabel('Logo'),
      SizedBox(height: 6.h),
      _imgBox(
        picked: _logoPicked,
        placeholderAsset: 'assets/home_control/image.svg',
        pickIconAsset: 'assets/control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _logoPicked = p);
        },
      ),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _primaryColor,
            label: 'Female Primary Color',
            hintText: '#008037',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _malePrimaryColor,
            label: 'Male Primary Color',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _secondaryColor,
            label: 'Secondary Color',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _bgColor,
            label: 'Background',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _headerFooterColor,
            label: 'Header and Footer',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _mainWidgetColor,
            label: 'Main Widget Color',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'English Font',
          primaryColor: _resolvedPrimaryColor,
          hint: Text('Select font',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText)),
          selectedValue: _engFont,
          dropdownColor: Colors.white,
          borderRadius: 4.r,
          items: _kFonts,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _engFont = val),
        )),
        SizedBox(width: 16.w),
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'Arabic Font',
          primaryColor: _resolvedPrimaryColor,
          hint: Text('Select font',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText)),
          selectedValue: _arFont,
          dropdownColor: Colors.white,
          items: _kFonts,
          borderRadius: 4.r,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _arFont = val),
        )),
      ]),
    ],
  );

  Widget _navSection() {
    final isOpen = _open['navBtn'] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['navBtn'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Header',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CustomSvg(
                  assetPath: 'assets/arrowdown.svg',
                  width: 20.w, height: 20.h,
                  fit: BoxFit.scaleDown,
                  color: Colors.white,
                ),
              ),
            ]),
          ),
        ),
        if (isOpen)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _navBtns.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final btn    = _navBtns.removeAt(oldIndex);
                final route  = _navRoutes.removeAt(oldIndex);
                final status = _navStatus.removeAt(oldIndex);
                final icon   = _navIcons.removeAt(oldIndex);
                _navBtns.insert(newIndex, btn);
                _navRoutes.insert(newIndex, route);
                _navStatus.insert(newIndex, status);
                _navIcons.insert(newIndex, icon);
                _hasChanges = true;
              });
            },
            itemBuilder: (context, i) =>
                _buildNavItemRow(key: ValueKey('nav_$i'), index: i),
          ),
      ]),
    );
  }

  Widget _buildNavItemRow({required Key key, required int index}) {
    final nameEnCtrl = _navBtns[index]['nameEn']!;
    final nameArCtrl = _navBtns[index]['nameAr']!;

    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: index == 0 ? 15.h : 0.h),
          _sectionLabel('Icon'),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _navIcons[index],
            placeholderAsset: 'assets/control/edit_icon_pick.svg',
            pickIconAsset: 'assets/control/camera.svg',
            onPick: () async {
              final p = await _pickImage();
              if (p != null) {
                setState(() => _navIcons[index] = p);
                _hasChanges = true;
              }
            },
          ),
          SizedBox(height: 10.h),
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h, right: 0.w),
                      child: Icon(Icons.menu_rounded,
                          size: 20.sp, color: AppColors.secondaryText),
                    ),
                  ),
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      label: 'Title',
                      fillColor: Colors.white,
                      labelTrailing: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Status ',
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: AppColors.text)),
                          FlutterSwitch(
                            width: 38.sp, height: 22.sp,
                            padding: 3.sp, borderRadius: 20.sp,
                            toggleSize: 16.sp,
                            activeColor: ColorPick.primary,
                            inactiveColor: Colors.grey.withOpacity(.16),
                            value: _navStatus[index],
                            onToggle: (val) {
                              setState(() => _navStatus[index] = val);
                              _hasChanges = true;
                            },
                          ),
                        ],
                      ),
                      hint: 'Home',
                      controller: nameEnCtrl,
                      height: 36, submitted: _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      primaryColor: _resolvedPrimaryColor,
                      onChanged: (value) => _hasChanges = true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomValidatedTextFieldMaster(
                        label: 'العنوان',
                        fillColor: Colors.white,
                        hint: 'الرئيسية',
                        controller: nameArCtrl,
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
        ],
      ),
    );
  }

  Widget _headerSection() {
    final isOpen = _open['header'] ?? true;
    return Container(
      decoration: BoxDecoration(
          color: ColorPick.white,
          borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['header'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Header Titles',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _headerItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _headerItems.removeAt(oldIndex);
                  _headerItems.insert(newIndex, item);
                  _hasChanges = true;
                });
              },
              itemBuilder: (context, i) => _buildHeaderRow(
                  key: ValueKey(_headerItems[i]),
                  index: i,
                  item: _headerItems[i]),
            ),
          ),
      ]),
    );
  }

  Widget _buildHeaderRow({
    required Key key,
    required int index,
    required _HeaderItem item,
  }) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Status: ',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text)),
              FlutterSwitch(
                width: 38.sp, height: 22.sp,
                padding: 3.sp, borderRadius: 20.sp,
                toggleSize: 16.sp,
                activeColor: ColorPick.primary,
                inactiveColor: Colors.grey.withOpacity(.16),
                value: item.status,
                onToggle: (val) {
                  setState(() => item.status = val);
                  _hasChanges = true;
                },
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 20.sp, color: AppColors.secondaryText),
                ),
              ),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Title', hint: 'None',
                  fillColor: Colors.white,
                  controller: item.en,
                  height: 36, submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  primaryColor: _resolvedPrimaryColor,
                  onChanged: (value) => _hasChanges = true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'العنوان',
                    fillColor: Colors.white,
                    hint: 'اكتب هنا',
                    controller: item.ar,
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
