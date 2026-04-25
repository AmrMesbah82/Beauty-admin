/// File Name: request_demo_edit_page.dart
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
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/request/request_demo_cubit.dart';
import '../../controller/request/request_demo_state.dart';
import '../../model/request/request_demo_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import 'request_demo_preview_page.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color label = Color(0xFF333333);
  static const Color hint = Color(0xFFAAAAAA);
  static const Color remove = Color(0xFFE53935);
  static const Color back = Color(0xFFF1F2ED);
  static const Color addBtn = Color(0xFF797979);
  static const Color border = Color(0xFFE0E0E0);
}

class _Img {
  final Uint8List? bytes;
  final String? url;
  const _Img({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

const List<Map<String, String>> _kTypes = [
  {'key': 'text', 'value': 'Text'},
  {'key': 'dropdown', 'value': 'Dropdown'},
];

class _QLocal {
  final String id;
  final TextEditingController qEn, qAr;
  QuestionType type;
  bool required;
  final List<_VLocal> values;

  _QLocal({required this.id})
      : qEn = TextEditingController(),
        qAr = TextEditingController(),
        type = QuestionType.text,
        required = false,
        values = [];

  void dispose() {
    qEn.dispose();
    qAr.dispose();
    for (final v in values) v.dispose();
  }
}

class _VLocal {
  final String id;
  final TextEditingController en, ar;
  _VLocal({required this.id})
      : en = TextEditingController(),
        ar = TextEditingController();
  void dispose() {
    en.dispose();
    ar.dispose();
  }
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
  Color get _p => _C.primary;

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
          c.complete(
            x is List<int> ? _Img(bytes: Uint8List.fromList(x)) : null,
          );
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
                    .copyWith(color: _C.label),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: _C.label.withOpacity(0.6)),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: _C.primary,
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
      }
    }

    if (_cTitleEn.text.trim().isEmpty) return false;
    if (_cTitleAr.text.trim().isEmpty) return false;
    if (_cDescEn.text.trim().isEmpty) return false;
    if (_cDescAr.text.trim().isEmpty) return false;
    if (_cSvg.isEmpty) return false;

    return true;
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
                    .copyWith(color: _C.label),
              ),
              SizedBox(height: 8.h),
              Container(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: SingleChildScrollView(
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.left,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: _C.label.withOpacity(0.8)),
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
                    color: _C.primary,
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
                        .copyWith(color: _C.label),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your changes have been published successfully',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: _C.label.withOpacity(0.6)),
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
                        color: _C.primary,
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
                        .copyWith(color: _C.label),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'An error occurred: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: _C.label.withOpacity(0.6)),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: _C.primary,
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
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );

        return Scaffold(
          backgroundColor: _C.back,
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
                              color: _C.primary,
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
                                  _C.primary.withOpacity(0.5),
                                      () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RequestDemoPreviewPage(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _btn(
                                  'Publish',
                                  _C.primary,
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
                                  _C.addBtn,
                                      () => Navigator.pop(context),
                                ),
                              ),
                              SizedBox(width: 16.w),
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
              color: _C.primary,
              borderRadius: o
                  ? BorderRadius.only(
                topLeft: Radius.circular(6.r),
                topRight: Radius.circular(6.r),
              )
                  : BorderRadius.circular(6.r),
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
                color: _C.remove,
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
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_qs.length, (i) => _qRow(i)),
        SizedBox(height: 8.h),
        Row(
          children: [
            _addBtn('Value', () {
              if (_qs.isNotEmpty)
                setState(
                      () => _qs.last.values.add(
                    _VLocal(
                        id:
                        'v_${DateTime.now().millisecondsSinceEpoch}'),
                  ),
                );
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
                color: _C.remove,
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
            children: [
              Expanded(
                child: CustomDropdownFormFieldInvMaster(
                  label: 'Type Of Question',
                  hint: Text(
                    'Text',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: _C.hint,
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
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: _C.label,
                      ),
                    ),
                    Spacer(),
                    FlutterSwitch(
                      width: 38.sp,
                      height: 22.sp,
                      padding: 3.sp,
                      borderRadius: 20.sp,
                      toggleSize: 16.sp,
                      activeColor: _C.primary,
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
            _lbl('Values'),
            SizedBox(height: 4.h),
            ...List.generate(q.values.length, (vi) {
              final v = q.values[vi];
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomValidatedTextFieldMaster(
                        hint: 'Text Here',
                        controller: v.en,
                        height: 36,
                        submitted: _sub,
                        fillColor: Colors.white,
                        primaryColor: _p,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
                      child: _removeDot(
                            () => setState(() {
                          final r = q.values.removeAt(vi);
                          WidgetsBinding.instance.addPostFrameCallback(
                                (_) => r.dispose(),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: CustomValidatedTextFieldMaster(
                          hint: 'أدخل النص هنا',
                          controller: v.ar,
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
              );
            }),
            if (_sub && q.type == QuestionType.dropdown && q.values.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'At least one value is required for dropdown questions',
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: _C.remove,
                  ),
                ),
              ),
          ],
          Divider(color: _C.border),
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
                color: _C.remove,
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
      Text(t, style: StyleText.fontSize12Weight500.copyWith(color: _C.label));

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
          color: _C.remove, shape: BoxShape.circle),
      child: Icon(Icons.remove, color: Colors.white, size: 10.sp),
    ),
  );

  Widget _addBtn(String l, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _C.primary,
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
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                picked.url!,
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: _sub && picked.isEmpty
              ? _C.remove.withOpacity(0.1)
              : const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
          border: _sub && picked.isEmpty
              ? Border.all(color: _C.remove, width: 1)
              : null,
        ),
        child: Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            size: 24.sp,
            color: _sub && picked.isEmpty ? _C.remove : _C.hint,
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
                color: _C.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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