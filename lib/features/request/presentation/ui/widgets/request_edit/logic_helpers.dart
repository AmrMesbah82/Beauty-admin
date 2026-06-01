// ******************* FILE INFO *******************
// File Name: logic_helpers.dart
// Description: Business-logic helpers for Request edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › presentation › ui › widget › request_edit

part of '../../pages/request_edit.dart';

extension _RequestEditLogic on _RequestDemoEditPageState {
  void _seed(RequestDemoPageModel d) {
    final h = Object.hashAll([
      d.headerSvgUrl,
      d.demoQuestions.length,
      d.confirmSvgUrl,
    ]);
    if (_hash == h) return;
    _hash = h;

    _hTitleEn.text = d.headerTitle.en;
    _hTitleAr.text = d.headerTitle.ar;
    _hSvg = d.headerSvgUrl.isNotEmpty
        ? _Img(url: d.headerSvgUrl)
        : const _Img();

    for (final q in _qs) q.dispose();
    _qs.clear();
    for (final q in d.demoQuestions) {
      final local = _QLocal(id: q.id);
      local.qEn.text = q.question.en;
      local.qAr.text = q.question.ar;
      local.type = q.type;
      local.required = q.required;
      for (final v in q.values) {
        final vl = _VLocal(id: v.id);
        vl.en.text = v.label.en;
        vl.ar.text = v.label.ar;
        local.values.add(vl);
      }
      _qs.add(local);
    }

    _cTitleEn.text = d.confirmTitle.en;
    _cTitleAr.text = d.confirmTitle.ar;
    _cDescEn.text = d.confirmDescription.en;
    _cDescAr.text = d.confirmDescription.ar;
    _cSvg = d.confirmSvgUrl.isNotEmpty
        ? _Img(url: d.confirmSvgUrl)
        : const _Img();
  }

  Future<_Img?> _pick() async {
    final c = Completer<_Img?>();
    bool d = false;
    final inp = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';
    inp.onChange.listen((_) {
      final f = inp.files;
      if (f == null || f.isEmpty) {
        if (!d) { d = true; c.complete(null); }
        return;
      }
      final file = f.first;
      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        if (!d) {
          d = true;
          _showErrorDialog('Invalid File Type', 'Please select an SVG file only.');
          c.complete(null);
        }
        return;
      }
      final r = html.FileReader();
      r.onLoadEnd.listen((_) {
        if (!d) {
          d = true;
          final x = r.result;
          if (x is ByteBuffer) {
            c.complete(_Img(bytes: Uint8List.view(x)));
          } else if (x is List<int>) {
            c.complete(_Img(bytes: Uint8List.fromList(x)));
          } else {
            c.complete(null);
          }
        }
      });
      r.onError.listen((_) {
        if (!d) { d = true; c.complete(null); }
      });
      r.readAsArrayBuffer(file);
    });
    inp.click();
    Future.delayed(const Duration(minutes: 5), () {
      if (!d) { d = true; c.complete(null); }
    });
    return c.future;
  }

  bool _validateAllFields() {
    if (_hTitleEn.text.trim().isEmpty) return false;
    if (_hTitleAr.text.trim().isEmpty) return false;
    if (_hSvg.isEmpty) return false;
    if (_qs.isEmpty) return false;
    for (final q in _qs) {
      if (q.qEn.text.trim().isEmpty) return false;
      if (q.qAr.text.trim().isEmpty) return false;
      if (q.type == QuestionType.dropdown) {
        if (q.values.isEmpty) return false;
        for (final v in q.values) {
          if (v.en.text.trim().isEmpty) return false;
          if (v.ar.text.trim().isEmpty) return false;
        }
        if (_hasDuplicateValues(q)) return false;
      }
    }
    if (_cTitleEn.text.trim().isEmpty) return false;
    if (_cTitleAr.text.trim().isEmpty) return false;
    if (_cDescEn.text.trim().isEmpty) return false;
    if (_cDescAr.text.trim().isEmpty) return false;
    if (_cSvg.isEmpty) return false;
    return true;
  }

  bool _hasDuplicateValues(_QLocal q) {
    final enSeen = <String>{};
    final arSeen = <String>{};
    for (final v in q.values) {
      final en = v.en.text.trim().toLowerCase();
      final ar = v.ar.text.trim();
      if (en.isNotEmpty && !enSeen.add(en)) return true;
      if (ar.isNotEmpty && !arSeen.add(ar)) return true;
    }
    return false;
  }

  bool _isDuplicateValue(_QLocal q, String newEn, String newAr, {String? excludeId}) {
    final newEnLow = newEn.trim().toLowerCase();
    final newArTrim = newAr.trim();
    for (final v in q.values) {
      if (excludeId != null && v.id == excludeId) continue;
      if (newEnLow.isNotEmpty && v.en.text.trim().toLowerCase() == newEnLow) return true;
      if (newArTrim.isNotEmpty && v.ar.text.trim() == newArTrim) return true;
    }
    return false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.r, height: 60.r,
                decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 36.r),
              ),
              SizedBox(height: 16.h),
              Text(title, textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              Text(message, textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text.withValues(alpha: 0.6))),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity, height: 38.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text('OK', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationErrorDialog() {
    String errorMessage = 'Please fill all required fields:\n\n';
    if (_hTitleEn.text.trim().isEmpty || _hTitleAr.text.trim().isEmpty) {
      errorMessage += '• Header Title (English & Arabic)\n';
    }
    if (_hSvg.isEmpty) errorMessage += '• Header SVG Image\n';
    if (_qs.isEmpty) {
      errorMessage += '• At least one Question\n';
    } else {
      for (var i = 0; i < _qs.length; i++) {
        final q = _qs[i];
        if (q.qEn.text.trim().isEmpty || q.qAr.text.trim().isEmpty) {
          errorMessage += '• Question ${i + 1} (English & Arabic)\n';
        }
        if (q.type == QuestionType.dropdown) {
          if (q.values.isEmpty) {
            errorMessage += '• Question ${i + 1} - Add at least one value\n';
          } else {
            for (var vi = 0; vi < q.values.length; vi++) {
              final v = q.values[vi];
              if (v.en.text.trim().isEmpty || v.ar.text.trim().isEmpty) {
                errorMessage += '• Question ${i + 1} - Value ${vi + 1}\n';
              }
            }
            if (_hasDuplicateValues(q)) {
              errorMessage += '• Question ${i + 1} - Duplicate values found. Each value must be unique\n';
            }
          }
        }
      }
    }
    if (_cTitleEn.text.trim().isEmpty || _cTitleAr.text.trim().isEmpty) {
      errorMessage += '• Confirm Title (English & Arabic)\n';
    }
    if (_cDescEn.text.trim().isEmpty || _cDescAr.text.trim().isEmpty) {
      errorMessage += '• Confirm Description (English & Arabic)\n';
    }
    if (_cSvg.isEmpty) errorMessage += '• Confirm SVG Image\n';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450.w,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.r, height: 60.r,
                decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                child: Icon(Icons.error_outline, color: Colors.white, size: 36.r),
              ),
              SizedBox(height: 16.h),
              Text('Validation Error', textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight600.copyWith(color: AppColors.secondaryText)),
              SizedBox(height: 8.h),
              Container(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: SingleChildScrollView(
                  child: Text(errorMessage, textAlign: TextAlign.left,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text.withValues(alpha: 0.8))),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity, height: 38.h,
                  decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
                  child: Center(
                    child: Text('OK', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(RequestDemoCmsCubit cubit, {String status = 'published'}) async {
    try {
      String headerSvgUrl = cubit.current.headerSvgUrl;
      if (_hSvg.bytes != null) {
        headerSvgUrl = await cubit.uploadHeaderSvg(_hSvg.bytes!);
      }

      String confirmSvgUrl = cubit.current.confirmSvgUrl;
      if (_cSvg.bytes != null) {
        confirmSvgUrl = await cubit.uploadConfirmSvg(_cSvg.bytes!);
      }

      final questions = <DemoQuestionModel>[];
      for (var i = 0; i < _qs.length; i++) {
        final q = _qs[i];
        final values = <QuestionValueModel>[];
        for (var vi = 0; vi < q.values.length; vi++) {
          final v = q.values[vi];
          values.add(QuestionValueModel(id: v.id, label: BiText(en: v.en.text, ar: v.ar.text)));
        }
        questions.add(DemoQuestionModel(
          id: q.id,
          question: BiText(en: q.qEn.text, ar: q.qAr.text),
          type: q.type,
          required: q.required,
          values: values,
          order: i,
        ));
      }

      final updated = cubit.current.copyWith(
        headerSvgUrl: headerSvgUrl,
        headerTitle: BiText(en: _hTitleEn.text, ar: _hTitleAr.text),
        demoQuestions: questions,
        confirmSvgUrl: confirmSvgUrl,
        confirmTitle: BiText(en: _cTitleEn.text, ar: _cTitleAr.text),
        confirmDescription: BiText(en: _cDescEn.text, ar: _cDescAr.text),
        status: status,
      );

      await cubit.saveModel(updated);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.r, height: 60.r,
                    decoration: const BoxDecoration(color: Color(0xFF43A047), shape: BoxShape.circle),
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 36.r),
                  ),
                  SizedBox(height: 16.h),
                  Text('Published Successfully', textAlign: TextAlign.center,
                      style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
                  SizedBox(height: 8.h),
                  Text('Your changes have been published successfully', textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text.withValues(alpha: 0.6))),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Get.forceAppUpdate();
                      html.window.location.reload();
                    },
                    child: Container(
                      width: double.infinity, height: 38.h,
                      decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
                      child: Center(child: Text('OK', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.r, height: 60.r,
                    decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                    child: Icon(Icons.error_outline, color: Colors.white, size: 36.r),
                  ),
                  SizedBox(height: 16.h),
                  Text('Error', textAlign: TextAlign.center,
                      style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
                  SizedBox(height: 8.h),
                  Text('An error occurred: ${e.toString()}', textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text.withValues(alpha: 0.6))),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: double.infinity, height: 38.h,
                      decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
                      child: Center(child: Text('OK', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }
}
