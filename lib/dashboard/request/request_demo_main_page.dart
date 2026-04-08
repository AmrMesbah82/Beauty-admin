/// File Name: request_demo_main_page.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../controller/request/request_demo_cubit.dart';
import '../../controller/request/request_demo_state.dart';
import '../../model/request/request_demo_model.dart';
import 'request_demo_edit_page.dart';
import 'request_demo_preview_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color tabActive = Color(0xFFD16F9A);
}

class RequestDemoMainPage extends StatefulWidget {
  const RequestDemoMainPage({super.key});
  @override
  State<RequestDemoMainPage> createState() => _RequestDemoMainPageState();
}

class _RequestDemoMainPageState extends State<RequestDemoMainPage> {
  String _gender = 'female';
  final Map<String, bool> _open = {'header': true, 'questions': true, 'confirm': true};

  @override
  void initState() {
    super.initState();
    context.read<RequestDemoCmsCubit>().load(gender: _gender);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestDemoCmsCubit, RequestDemoCmsState>(
      listener: (ctx, s) {
        if (s is RequestDemoCmsError)
          ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text('Error: ${s.message}'), backgroundColor: Colors.red));
      },
      builder: (ctx, state) {
        if (state is RequestDemoCmsInitial || state is RequestDemoCmsLoading)
          return const Scaffold(backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)));

        RequestDemoPageModel? m;
        if (state is RequestDemoCmsLoaded) m = state.data;
        if (state is RequestDemoCmsSaved) m = state.data;
        m ??= ctx.read<RequestDemoCmsCubit>().current;

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(width: double.infinity, height: double.infinity,
            child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [SizedBox(width: 1000.w, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 20.w),
                  const AdminSubNavBar(activeIndex: 6),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Title + Preview
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Request Demo', style: StyleText.fontSize45Weight600
                              .copyWith(color: _C.primary, fontWeight: FontWeight.w700)),
                          GestureDetector(
                            onTap: () => Navigator.push(ctx,
                                MaterialPageRoute(builder: (_) => const RequestDemoPreviewPage())),
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                                child: Text('Preview Screen',
                                    style: StyleText.fontSize12Weight500.copyWith(color: Colors.white))),
                          ),
                        ]),
                        SizedBox(height: 12.h),
                        // Gender + Last Updated + Edit
                        Row(children: [
                          _genderChip('Female', 'female'), SizedBox(width: 8.w),
                          _genderChip('Male', 'male'), const Spacer(),
                          if (m.lastUpdated != null)
                            Text('Last Updated On ${DateFormat('dd MMM yyyy').format(m.lastUpdated!)}',
                                style: StyleText.fontSize12Weight400.copyWith(color: _C.tabActive)),
                          SizedBox(width: 16.w),
                          GestureDetector(
                            onTap: () => Navigator.push(ctx,
                                MaterialPageRoute(builder: (_) => const RequestDemoEditPage())),
                            child: Row(children: [
                              Text('Edit Demo View', style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
                              SizedBox(width: 4.w),
                              Icon(Icons.edit_outlined, size: 14.sp, color: _C.labelText),
                            ]),
                          ),
                        ]),
                        SizedBox(height: 20.h),

                        // ── Header ─────────────────────────────────────────
                        _acc('header', 'Header', [
                          _lbl('SVG'), SizedBox(height: 6.h), _svgCircle(m.header.svgUrl),
                          SizedBox(height: 14.h),
                          _biRow('Title', 'العنوان', m.header.title.en, m.header.title.ar),
                        ]),
                        SizedBox(height: 10.h),

                        // ── Questions ──────────────────────────────────────
                        _acc('questions', 'Demo Related Questions',
                            m.demoQuestions.questions.expand((q) => [
                              _biRow('Question', 'سؤال', q.question.en, q.question.ar),
                              SizedBox(height: 8.h),
                              _roBox('Type Of Question', q.type.toValue()),
                              if (q.type == QuestionType.dropdown) ...[
                                SizedBox(height: 8.h),
                                _lbl('Values'), SizedBox(height: 4.h),
                                ...q.values.map((v) => Padding(
                                    padding: EdgeInsets.only(bottom: 6.h),
                                    child: _biRow('', '', v.label.en, v.label.ar))),
                              ],
                              SizedBox(height: 12.h), Divider(color: _C.border), SizedBox(height: 8.h),
                            ]).toList()),
                        SizedBox(height: 10.h),

                        // ── Confirm Message ────────────────────────────────
                        _acc('confirm', 'Confirm Message', [
                          _lbl('SVG'), SizedBox(height: 6.h), _svgCircle(m.confirmMessage.svgUrl),
                          SizedBox(height: 14.h),
                          _biRow('Title', 'العنوان', m.confirmMessage.title.en, m.confirmMessage.title.ar),
                          SizedBox(height: 10.h),
                          _lbl('Description'), SizedBox(height: 6.h),
                          _roField(m.confirmMessage.description.en, maxLines: 4),
                          SizedBox(height: 8.h),
                          Align(alignment: Alignment.centerRight,
                              child: Text('الوصف', style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text))),
                          SizedBox(height: 6.h),
                          _roField(m.confirmMessage.description.ar, maxLines: 4, dir: ui.TextDirection.rtl),
                        ]),
                        SizedBox(height: 40.h),
                      ])),
                ],
              ))],
            )),
          ),
        );
      },
    );
  }

  Widget _genderChip(String label, String val) {
    final a = _gender == val;
    return GestureDetector(
      onTap: () { setState(() => _gender = val); ctx.read<RequestDemoCmsCubit>().switchGender(val); },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(color: a ? _C.primary : Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: a ? _C.primary : _C.border)),
          child: Text(label, style: StyleText.fontSize12Weight500
              .copyWith(color: a ? Colors.white : _C.labelText))),
    );
  }

  // ignore: unused_element
  BuildContext get ctx => context;

  Widget _acc(String key, String title, List<Widget> children) {
    final o = _open[key] ?? true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _open[key] = !o),
        child: Container(width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(color: _C.primary,
                borderRadius: o ? BorderRadius.only(
                    topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r)),
            child: Row(children: [
              Expanded(child: Text(title, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              Icon(o ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp),
            ])),
      ),
      if (o) Container(width: double.infinity, padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: _C.cardBg,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r), bottomRight: Radius.circular(6.r))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
    ]);
  }

  Widget _lbl(String t) => Text(t, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _biRow(String enL, String arL, String enV, String arV) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (enL.isNotEmpty) ...[Text(enL, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)), SizedBox(height: 6.h)],
          _roField(enV),
        ])),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (arL.isNotEmpty) ...[Text(arL, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)), SizedBox(height: 6.h)],
          _roField(arV, dir: ui.TextDirection.rtl),
        ])),
      ]);

  Widget _roBox(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_lbl(label), SizedBox(height: 6.h), _roField(value)]);

  Widget _roField(String t, {int maxLines = 1, ui.TextDirection dir = ui.TextDirection.ltr}) =>
      Container(width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
          decoration: BoxDecoration(color: _C.sectionBg, borderRadius: BorderRadius.circular(4.r)),
          child: Text(t.isEmpty ? 'Text Here' : t, textDirection: dir,
              style: StyleText.fontSize12Weight400.copyWith(color: t.isEmpty ? _C.hintText : _C.labelText),
              maxLines: maxLines, overflow: TextOverflow.ellipsis));

  Widget _svgCircle(String url) {
    if (url.isNotEmpty) {
      return Container(width: 70.w, height: 70.h,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(child: ClipOval(child: Padding(padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(url, width: 30.w, height: 30.h,
                  fit: BoxFit.contain, placeholderBuilder: (_) => const CircleProgressMaster())))));
    }
    return Container(width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
        child: Center(child: Icon(Icons.insert_drive_file_outlined, size: 24.sp, color: _C.hintText)));
  }
}