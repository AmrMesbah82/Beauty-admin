// ******************* FILE INFO *******************
// File Name: sections.dart
// Description: Form section widgets for Request edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › presentation › ui › widget › request_edit

part of '../../pages/request_edit.dart';

extension _RequestEditSections on _RequestDemoEditPageState {
  Widget _headerBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl('SVG'),
        SizedBox(height: 6.h),
        _imgBox(_hSvg, () async {
          final p = await _pick();
          if (p != null) setState(() => _hSvg = p);
        }),
        if (_sub && _hSvg.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text('SVG image is required',
                style: StyleText.fontSize10Weight400.copyWith(color: ColorPick.red)),
          ),
        SizedBox(height: 14.h),
        _biFields('Title', 'العنوان', _hTitleEn, _hTitleAr),
      ],
    ),
  );

  Widget _questionsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_qs.length, (i) => _qRow(i)),
        Row(
          children: [
            _addBtn('Value', () {
              if (_qs.isNotEmpty) {
                final lastQ = _qs.last;
                if (lastQ.type != QuestionType.dropdown) {
                  _showErrorDialog(
                    'Not a Dropdown',
                    'Values can only be added to dropdown-type questions. Please change the question type to Dropdown first.',
                  );
                  return;
                }
                if (lastQ.values.isNotEmpty) {
                  final lastVal = lastQ.values.last;
                  if (lastVal.en.text.trim().isEmpty || lastVal.ar.text.trim().isEmpty) {
                    _showErrorDialog(
                      'Incomplete Value',
                      'Please fill in the current value fields (English & Arabic) before adding a new one.',
                    );
                    return;
                  }
                }
                setState(() => lastQ.values.add(
                  _VLocal(id: 'v_${DateTime.now().millisecondsSinceEpoch}'),
                ));
              }
            }),
            SizedBox(width: 8.w),
            _addBtn('Question', () => setState(
              () => _qs.add(_QLocal(id: 'q_${DateTime.now().millisecondsSinceEpoch}')),
            )),
          ],
        ),
        if (_sub && _qs.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text('At least one question is required',
                style: StyleText.fontSize10Weight400.copyWith(color: ColorPick.red)),
          ),
      ],
    ),
  );

  Widget _qRow(int i) {
    final q = _qs[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CustomValidatedTextFieldMaster(
                      label: 'Question', hint: 'Text Here', controller: q.qEn,
                      height: 36, submitted: _sub, fillColor: Colors.white, primaryColor: _p,
                    ),
                    _removeDot(() => setState(() {
                      final r = _qs.removeAt(i);
                      WidgetsBinding.instance.addPostFrameCallback((_) => r.dispose());
                    })),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'سؤال', hint: 'أدخل النص هنا', controller: q.qAr,
                    height: 36, submitted: _sub, fillColor: Colors.white,
                    textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right, primaryColor: _p,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Type Of Question',
                  primaryColor: _resolvedPrimaryColor,
                  hint: Text('Text',
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                  selectedValue: q.type.toValue(),
                  items: _kTypes,
                  widthIcon: 18, heightIcon: 18, height: 36,
                  dropdownColor: Colors.white,
                  onChanged: (val) => setState(() => q.type = QuestionType.fromValue(val)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Row(
                  children: [
                    Text('Required',
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    Spacer(),
                    FlutterSwitch(
                      width: 38.sp, height: 22.sp, padding: 3.sp,
                      borderRadius: 20.sp, toggleSize: 16.sp,
                      activeColor: ColorPick.primary,
                      inactiveColor: Colors.grey.withOpacity(.16),
                      value: q.required,
                      onToggle: (v) => setState(() => q.required = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (q.type == QuestionType.dropdown) ...[
            ...List.generate(q.values.length, (vi) {
              final v = q.values[vi];
              final isDupEn = q.values.where((other) => other.id != v.id).any(
                  (other) => other.en.text.trim().toLowerCase() ==
                      v.en.text.trim().toLowerCase() && v.en.text.trim().isNotEmpty);
              final isDupAr = q.values.where((other) => other.id != v.id).any(
                  (other) => other.ar.text.trim() == v.ar.text.trim() && v.ar.text.trim().isNotEmpty);
              final isDuplicate = isDupEn || isDupAr;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomValidatedTextFieldMaster(
                          hint: 'Text Here', label: 'Values', controller: v.en,
                          labelTrailing: _removeDot(() => setState(() {
                            final r = q.values.removeAt(vi);
                            WidgetsBinding.instance.addPostFrameCallback((_) => r.dispose());
                          })),
                          height: 36, submitted: _sub, fillColor: Colors.white,
                          primaryColor: isDuplicate ? ColorPick.red : _p,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: CustomValidatedTextFieldMaster(
                            hint: 'أدخل النص هنا', controller: v.ar, label: "القيم",
                            height: 36, submitted: _sub, fillColor: Colors.white,
                            textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right,
                            primaryColor: isDuplicate ? ColorPick.red : _p,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isDuplicate)
                    Text('Duplicate value — each option must be unique',
                        style: StyleText.fontSize10Weight400.copyWith(color: ColorPick.red)),
                ],
              );
            }),
            if (_sub && q.type == QuestionType.dropdown && q.values.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text('At least one value is required for dropdown questions',
                    style: StyleText.fontSize10Weight400.copyWith(color: ColorPick.red)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _confirmBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl('SVG'),
        SizedBox(height: 6.h),
        _imgBox(_cSvg, () async {
          final p = await _pick();
          if (p != null) setState(() => _cSvg = p);
        }),
        if (_sub && _cSvg.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text('SVG image is required',
                style: StyleText.fontSize10Weight400.copyWith(color: ColorPick.red)),
          ),
        SizedBox(height: 14.h),
        _biFields('Title', 'العنوان', _cTitleEn, _cTitleAr),
        SizedBox(height: 10.h),
        CustomValidatedTextFieldMaster(
          label: 'Description', hint: 'Text Here', controller: _cDescEn,
          maxLines: 4, height: 100, submitted: _sub, fillColor: Colors.white,
          showCharCount: true, primaryColor: _p,
        ),
        SizedBox(height: 10.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف', hint: 'أدخل النص هنا', controller: _cDescAr,
            maxLines: 4, height: 100, submitted: _sub, fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right,
            showCharCount: true, primaryColor: _p,
          ),
        ),
      ],
    ),
  );
}
