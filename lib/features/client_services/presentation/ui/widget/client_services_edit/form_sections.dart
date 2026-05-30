part of '../../pages/client_services_edit.dart';

extension _ClientServicesEditFormSections on _ClientServicesEditPageState {
  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _headerBody() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('SVG'),
              if (!_hdrSvg.isEmpty)
                _removeChip(() => setState(() => _hdrSvg = _PickedImage.empty())),
            ],
          ),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _hdrSvg,
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => _hdrSvg = p);
            },
          ),
          SizedBox(height: 14.h),
          _biRow('Title', 'العنوان', _hdrTitleEn, _hdrTitleAr, useRow: true),
          _descFields(_hdrDescEn, _hdrDescAr),
        ],
      );

  // ── Download ────────────────────────────────────────────────────────────────
  Widget _downloadBody() => Column(
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
                  submitted: _submitted,
                  fillColor: Colors.white,
                  primaryColor: _prim,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Android Link',
                  hint: 'Insert Links',
                  controller: _googlePlay,
                  height: 36,
                  submitted: _submitted,
                  fillColor: Colors.white,
                  primaryColor: _prim,
                ),
              ),
            ],
          ),
        ],
      );

  // ── Mockups ─────────────────────────────────────────────────────────────────
  Widget _mockupsBody() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(_mockups.length, (i) => _mockupRow(i)),
          SizedBox(height: 8.h),
          _addButton('Mockup', () {
            setState(
              () => _mockups.add(
                _MockupLocal(
                    id: 'mock_${DateTime.now().millisecondsSinceEpoch}'),
              ),
            );
          }),
        ],
      );

  Widget _mockupRow(int i) {
    final m = _mockups[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('SVG'),
              _removeChip(
                () => setState(() {
                  final removed = _mockups.removeAt(i);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => removed.dispose(),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              _imgBox(
                picked: m.svg,
                onPick: () async {
                  final p = await _pickImage();
                  if (p != null) setState(() => m.svg = p);
                },
              ),
              const Spacer(),
              _layoutChipsEdit(m),
            ],
          ),
          SizedBox(height: 10.h),
          _biRow('Title', 'العنوان', m.titleEn, m.titleAr, useRow: true),
          _descFields(m.descEn, m.descAr),
          SizedBox(height: 8.h),
          Divider(color: ColorPick.white),
        ],
      ),
    );
  }

  Widget _layoutChipsEdit(_MockupLocal m) {
    const options = ['left', 'centered', 'right'];
    final currentLayout = m.layout.name.toLowerCase();

    return CustomSegmentedTabs(
      tabs: const ['Left', 'Centered', 'Right'],
      selectedIndex: options.indexOf(currentLayout).clamp(0, 2),
      onTabSelected: (index) =>
          setState(() => m.layout = MockupLayout.values[index]),
      selectedColor: ColorPick.primary,
      unselectedColor: Colors.white,
      selectedTextColor: Colors.white,
      unselectedTextColor: AppColors.text,
      equalWidth: false,
      containerPadding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      containerColor: Colors.white,
    );
  }
}
