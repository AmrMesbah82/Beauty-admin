/// File Name: request_edit.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/custom_dropdwon.dart';
import 'package:beauty_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../data/model/request_model.dart';
import '../../controller/request_cubit.dart';
import '../../controller/request_state.dart';
import 'request_preview.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;

part '../widget/request_edit/img.dart';
part '../widget/request_edit/q_local.dart';
part '../widget/request_edit/v_local.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

class RequestDemoEditPage extends StatefulWidget {
  const RequestDemoEditPage({super.key});
  @override
  State<RequestDemoEditPage> createState() => _RequestDemoEditPageState();
}

class _RequestDemoEditPageState extends State<RequestDemoEditPage> {
  bool _sub = false;
  int? _hash;

  final _hTitleEn = TextEditingController();
  final _hTitleAr = TextEditingController();
  _Img _hSvg = const _Img();

  final List<_QLocal> _qs = [];

  final _cTitleEn = TextEditingController();
  final _cTitleAr = TextEditingController();
  final _cDescEn = TextEditingController();
  final _cDescAr = TextEditingController();
  _Img _cSvg = const _Img();

  final Map<String, bool> _open = {
    'header': true,
    'questions': true,
    'confirm': true,
  };
  Color get _p => ColorPick.primary;

  @override
  void dispose() {
    _hTitleEn.dispose();
    _hTitleAr.dispose();
    for (final q in _qs) q.dispose();
    _cTitleEn.dispose();
    _cTitleAr.dispose();
    _cDescEn.dispose();
    _cDescAr.dispose();
    super.dispose();
  }

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

  /// Pick SVG file only
  Future<_Img?> _pick() async {
    final c = Completer<_Img?>();
    bool d = false;
    final inp = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';
    inp.onChange.listen((_) {
      final f = inp.files;
      if (f == null || f.isEmpty) {
        if (!d) {
          d = true;
          c.complete(null);
        }
        return;
      }

      final file = f.first;
      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        if (!d) {
          d = true;
          _showErrorDialog('Invalid File Type',
              'Please select an SVG file only.');
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
        if (!d) {
          d = true;
          c.complete(null);
        }
      });
      r.readAsArrayBuffer(file);
    });
    inp.click();
    Future.delayed(const Duration(minutes: 5), () {
      if (!d) {
        d = true;
        c.complete(null);
      }
    });
    return c.future;
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
                width: 60.r,
                height: 60.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 36.r),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.text),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.text.withOpacity(0.6)),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        // Check for duplicates in dropdown values
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

  /// Returns true if a question has duplicate values (case-insensitive on EN or AR)
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

  /// Check if adding a new value would duplicate an existing one in the given question
  bool _isDuplicateValue(_QLocal q, String newEn, String newAr,
      {String? excludeId}) {
    final newEnLow = newEn.trim().toLowerCase();
    final newArTrim = newAr.trim();
    for (final v in q.values) {
      if (excludeId != null && v.id == excludeId) continue;
      if (newEnLow.isNotEmpty &&
          v.en.text.trim().toLowerCase() == newEnLow) return true;
      if (newArTrim.isNotEmpty && v.ar.text.trim() == newArTrim) return true;
    }
    return false;
  }

  void _showValidationErrorDialog() {
    String errorMessage = 'Please fill all required fields:\n\n';

    if (_hTitleEn.text.trim().isEmpty || _hTitleAr.text.trim().isEmpty) {
      errorMessage += '• Header Title (English & Arabic)\n';
    }
    if (_hSvg.isEmpty) {
      errorMessage += '• Header SVG Image\n';
    }
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
              errorMessage +=
              '• Question ${i + 1} - Duplicate values found. Each value must be unique\n';
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
    if (_cSvg.isEmpty) {
      errorMessage += '• Confirm SVG Image\n';
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.r,
                height: 60.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline,
                    color: Colors.white, size: 36.r),
              ),
              SizedBox(height: 16.h),
              Text(
                'Validation Error',
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.secondaryText),
              ),
              SizedBox(height: 8.h),
              Container(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: SingleChildScrollView(
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.left,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text.withOpacity(0.8)),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the model from local controllers and save
  Future<void> _save(
      RequestDemoCmsCubit cubit, {
        String status = 'published',
      }) async {
    try {
      // Upload SVGs if new files picked
      String headerSvgUrl = cubit.current.headerSvgUrl;
      if (_hSvg.bytes != null) {
        headerSvgUrl = await cubit.uploadHeaderSvg(_hSvg.bytes!);
      }

      String confirmSvgUrl = cubit.current.confirmSvgUrl;
      if (_cSvg.bytes != null) {
        confirmSvgUrl = await cubit.uploadConfirmSvg(_cSvg.bytes!);
      }

      // Build questions list
      final questions = <DemoQuestionModel>[];
      for (var i = 0; i < _qs.length; i++) {
        final q = _qs[i];
        final values = <QuestionValueModel>[];
        for (var vi = 0; vi < q.values.length; vi++) {
          final v = q.values[vi];
          values.add(QuestionValueModel(
            id: v.id,
            label: BiText(en: v.en.text, ar: v.ar.text),
          ));
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

      // Build updated model
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.r,
                    height: 60.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF43A047),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: Colors.white, size: 36.r),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Published Successfully',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your changes have been published successfully',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text.withOpacity(0.6)),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Get.forceAppUpdate();
                      html.window.location.reload();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: ColorPick.primary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          'OK',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: Colors.white),
                        ),
                      ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.r,
                    height: 60.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline,
                        color: Colors.white, size: 36.r),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'An error occurred: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text.withOpacity(0.6)),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: ColorPick.primary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          'OK',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: Colors.white),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestDemoCmsCubit, RequestDemoCmsState>(
      builder: (ctx, state) {
        if (state is RequestDemoCmsLoaded) _seed(state.data);
        final cubit = ctx.read<RequestDemoCmsCubit>();
        if (state is RequestDemoCmsInitial || state is RequestDemoCmsLoading)
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AdminSubNavBar(activeIndex: 7),
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing Request Demo Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _acc('header', 'Header', [_headerBody()]),
                          SizedBox(height: 10.h),
                          _acc('questions', 'Demo Related Questions', [
                            _questionsBody(),
                          ]),
                          SizedBox(height: 10.h),
                          _acc('confirm', 'Confirm Message', [_confirmBody()]),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Preview',
                                  Color(0xFF8A5C70),
                                      () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RequestDemoPreviewPage(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 300.w),
                              Expanded(
                                child: _btn(
                                  'Publish',
                                  ColorPick.primary,
                                      () {
                                    if (!_validateAllFields()) {
                                      setState(() => _sub = true);
                                      _showValidationErrorDialog();
                                      return;
                                    }
                                    showPublishConfirmDialog(
                                      context: context,
                                      title: 'EDITING REQUEST DEMO DETAILS',
                                      subtitle:
                                      'Do you want to save the changes made to this Request Demo?',
                                      onConfirm: () => _save(cubit),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Discard',
                                  ColorPick.discard,
                                      () => Navigator.pop(context),
                                ),
                              ),
                              SizedBox(width: 300.w),
                              Expanded(child: Container()),
                            ],
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _btn(String l, Color bg, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: Text(
          l,
          style:
          StyleText.fontSize14Weight600.copyWith(color: Colors.white),
        ),
      ),
    ),
  );

  Widget _acc(String key, String title, List<Widget> ch) {
    final o = _open[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !o),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  o
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (o)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: ch),
      ],
    );
  }
  final _primaryColor      = TextEditingController(text: '#008037');

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return ColorPick.primary;
  }

  // ── HEADER ───────────────────────────────────────────────────────────────
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
            child: Text(
              'SVG image is required',
              style: StyleText.fontSize10Weight400.copyWith(
                color: ColorPick.red,
              ),
            ),
          ),
        SizedBox(height: 14.h),
        _biFields('Title', 'العنوان', _hTitleEn, _hTitleAr),
      ],
    ),
  );

  // ── QUESTIONS ────────────────────────────────────────────────────────────
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

                // Only relevant for dropdown type questions
                if (lastQ.type != QuestionType.dropdown) {
                  _showErrorDialog(
                    'Not a Dropdown',
                    'Values can only be added to dropdown-type questions. Please change the question type to Dropdown first.',
                  );
                  return;
                }

                // Prevent adding if the last existing value is still empty
                if (lastQ.values.isNotEmpty) {
                  final lastVal = lastQ.values.last;
                  if (lastVal.en.text.trim().isEmpty ||
                      lastVal.ar.text.trim().isEmpty) {
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
            _addBtn(
              'Question',
                  () => setState(
                    () => _qs.add(
                  _QLocal(
                      id:
                      'q_${DateTime.now().millisecondsSinceEpoch}'),
                ),
              ),
            ),
          ],
        ),
        if (_sub && _qs.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'At least one question is required',
              style: StyleText.fontSize10Weight400.copyWith(
                color: ColorPick.red,
              ),
            ),
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
                      label: 'Question',
                      hint: 'Text Here',
                      controller: q.qEn,
                      height: 36,
                      submitted: _sub,
                      fillColor: Colors.white,
                      primaryColor: _p,
                    ),
                    _removeDot(
                          () => setState(() {
                        final r = _qs.removeAt(i);
                        WidgetsBinding.instance.addPostFrameCallback(
                              (_) => r.dispose(),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'سؤال',
                    hint: 'أدخل النص هنا',
                    controller: q.qAr,
                    height: 36,
                    submitted: _sub,
                    fillColor: Colors.white,
                    textDirection: ui.TextDirection.rtl,
                    textAlign: TextAlign.right,
                    primaryColor: _p,
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
                  hint: Text(
                    'Text',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  selectedValue: q.type.toValue(),
                  items: _kTypes,
                  widthIcon: 18,
                  heightIcon: 18,
                  height: 36,
                  dropdownColor: Colors.white,
                  onChanged: (val) =>
                      setState(() => q.type = QuestionType.fromValue(val)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Required',
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    Spacer(),
                    FlutterSwitch(
                      width: 38.sp,
                      height: 22.sp,
                      padding: 3.sp,
                      borderRadius: 20.sp,
                      toggleSize: 16.sp,
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

              // Detect if this value is a duplicate of another in the same question
              final isDupEn = q.values
                  .where((other) => other.id != v.id)
                  .any((other) =>
              other.en.text.trim().toLowerCase() ==
                  v.en.text.trim().toLowerCase() &&
                  v.en.text.trim().isNotEmpty);
              final isDupAr = q.values
                  .where((other) => other.id != v.id)
                  .any((other) =>
              other.ar.text.trim() == v.ar.text.trim() &&
                  v.ar.text.trim().isNotEmpty);
              final isDuplicate = isDupEn || isDupAr;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomValidatedTextFieldMaster(
                          hint: 'Text Here',
                          label: 'Values',
                          controller: v.en,
                          labelTrailing: _removeDot(
                                () => setState(() {
                              final r = q.values.removeAt(vi);
                              WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => r.dispose(),
                              );
                            }),
                          ),
                          height: 36,
                          submitted: _sub,
                          fillColor: Colors.white,
                          primaryColor:
                          isDuplicate ? ColorPick.red : _p,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: CustomValidatedTextFieldMaster(
                            hint: 'أدخل النص هنا',
                            controller: v.ar,
                            label: "القيم",
                            height: 36,
                            submitted: _sub,
                            fillColor: Colors.white,
                            textDirection: ui.TextDirection.rtl,
                            textAlign: TextAlign.right,
                            primaryColor:
                            isDuplicate ? ColorPick.red : _p,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Show inline duplicate warning beneath the row
                  if (isDuplicate)
                    Text(
                      'Duplicate value — each option must be unique',
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: ColorPick.red,
                      ),
                    ),
                ],
              );
            }),
            if (_sub && q.type == QuestionType.dropdown && q.values.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'At least one value is required for dropdown questions',
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: ColorPick.red,
                  ),
                ),
              ),
          ],

        ],
      ),
    );
  }

  // ── CONFIRM ──────────────────────────────────────────────────────────────
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
            child: Text(
              'SVG image is required',
              style: StyleText.fontSize10Weight400.copyWith(
                color: ColorPick.red,
              ),
            ),
          ),
        SizedBox(height: 14.h),
        _biFields('Title', 'العنوان', _cTitleEn, _cTitleAr),
        SizedBox(height: 10.h),
        CustomValidatedTextFieldMaster(
          label: 'Description',
          hint: 'Text Here',
          controller: _cDescEn,
          maxLines: 4,
          height: 100,
          submitted: _sub,
          fillColor: Colors.white,
          showCharCount: true,
          primaryColor: _p,
        ),
        SizedBox(height: 10.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف',
            hint: 'أدخل النص هنا',
            controller: _cDescAr,
            maxLines: 4,
            height: 100,
            submitted: _sub,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            showCharCount: true,
            primaryColor: _p,
          ),
        ),
      ],
    ),
  );

  // ── SHARED ───────────────────────────────────────────────────────────────
  Widget _lbl(String t) =>
      Text(t, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  Widget _biFields(
      String enL,
      String arL,
      TextEditingController enC,
      TextEditingController arC,
      ) =>
      Row(
        children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: enL,
              hint: 'Text Here',
              controller: enC,
              height: 36,
              submitted: _sub,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.ltr,
              textAlign: TextAlign.left,
              primaryColor: _p,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: arL,
                hint: 'أدخل النص هنا',
                controller: arC,
                height: 36,
                submitted: _sub,
                fillColor: Colors.white,
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.right,
                primaryColor: _p,
              ),
            ),
          ),
        ],
      );

  Widget _removeDot(VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      width: 16.w,
      height: 16.h,
      decoration: const BoxDecoration(
          color: ColorPick.red, shape: BoxShape.circle),
      child: Icon(Icons.remove, color: Colors.white, size: 10.sp),
    ),
  );

  Widget _addBtn(String l, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Color(0xFF797979),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            l,
            style:
            StyleText.fontSize12Weight500.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );

  Widget _imgBox(_Img picked, VoidCallback onPick) {
    Widget content;

    if (picked.bytes != null) {
      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-req-bytes-${picked.bytes!.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: SizedBox(
            width: 70.w,
            height: 70.h,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      final viewId = 'svg-req-url-${picked.url!.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = picked.url!
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: SizedBox(
            width: 70.w,
            height: 70.h,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      );
    } else {
      content = Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: _sub && picked.isEmpty
              ? ColorPick.red.withOpacity(0.1)
              : const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            size: 24.sp,
            color: _sub && picked.isEmpty ? ColorPick.red : AppColors.secondaryText,
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(onTap: onPick, child: content),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: ColorPick.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: 'assets/control/camera.svg',
                  width: 12.w,
                  height: 12.h,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
