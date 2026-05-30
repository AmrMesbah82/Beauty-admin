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
import '../../../data/models/request_model.dart';
import '../../controller/request_cubit.dart';
import '../../controller/request_state.dart';
import 'request_preview.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;

part '../widget/request_edit/img.dart';
part '../widget/request_edit/q_local.dart';
part '../widget/request_edit/v_local.dart';
part '../widget/request_edit/logic_helpers.dart';
part '../widget/request_edit/ui_helpers.dart';
part '../widget/request_edit/sections.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

const _kTypes = <Map<String, String>>[
  {'key': 'text', 'value': 'Text'},
  {'key': 'dropdown', 'value': 'Dropdown'},
];

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

  final _primaryColor = TextEditingController(text: '#008037');

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return ColorPick.primary;
  }

  @override
  void dispose() {
    _hTitleEn.dispose();
    _hTitleAr.dispose();
    for (final q in _qs) q.dispose();
    _cTitleEn.dispose();
    _cTitleAr.dispose();
    _cDescEn.dispose();
    _cDescAr.dispose();
    _primaryColor.dispose();
    super.dispose();
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
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing Request Demo Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: ColorPick.primary, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 16.h),
                          _acc('header', 'Header', [_headerBody()]),
                          SizedBox(height: 10.h),
                          _acc('questions', 'Demo Related Questions', [_questionsBody()]),
                          SizedBox(height: 10.h),
                          _acc('confirm', 'Confirm Message', [_confirmBody()]),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                child: _btn('Preview', Color(0xFF8A5C70),
                                    () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const RequestDemoPreviewPage()))),
                              ),
                              SizedBox(width: 300.w),
                              Expanded(
                                child: _btn('Publish', ColorPick.primary, () {
                                  if (!_validateAllFields()) {
                                    setState(() => _sub = true);
                                    _showValidationErrorDialog();
                                    return;
                                  }
                                  showPublishConfirmDialog(
                                    context: context,
                                    title: 'EDITING REQUEST DEMO DETAILS',
                                    subtitle: 'Do you want to save the changes made to this Request Demo?',
                                    onConfirm: () => _save(cubit),
                                  );
                                }),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _btn('Discard', ColorPick.discard, () => Navigator.pop(context)),
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
}
