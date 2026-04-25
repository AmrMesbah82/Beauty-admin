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
import '../../core/custom_segmant_tab.dart';

import '../../model/request/request_demo_model.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';
import 'request_demo_edit_page.dart';
import 'request_demo_preview_page.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color back = Color(0xFFF1F2ED);
  static const Color tabActive = Color(0xFFD16F9A);
}

class RequestDemoMainPage extends StatefulWidget {
  const RequestDemoMainPage({super.key});
  @override
  State<RequestDemoMainPage> createState() => _RequestDemoMainPageState();
}

class _RequestDemoMainPageState extends State<RequestDemoMainPage> {
  String _gender = 'female';
  final Map<String, bool> _open = {
    'header': true,
    'questions': true,
    'confirm': true,
  };

  @override
  void initState() {
    super.initState();
    context.read<RequestDemoCmsCubit>().load(gender: _gender);
  }

  String _fmtDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RequestDemoEditPage()),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RequestDemoPreviewPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestDemoCmsCubit, RequestDemoCmsState>(
      listener: (ctx, s) {
        if (s is RequestDemoCmsError)
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Error: ${s.message}'),
              backgroundColor: Colors.red,
            ),
          );
      },
      builder: (ctx, state) {
        if (state is RequestDemoCmsInitial || state is RequestDemoCmsLoading)
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );

        RequestDemoPageModel? m;
        if (state is RequestDemoCmsLoaded) m = state.data;
        if (state is RequestDemoCmsSaved) m = state.data;
        m ??= ctx.read<RequestDemoCmsCubit>().current;

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppAdminNavbar(
                          activeLabel: 'Web Page',
                          homePage: HomeMainPage(),
                          webPage: HomeMainPage(),
                          jobListingPage: HomeMainPage(),
                        ),
                        SizedBox(width: 20.w),
                        const AdminSubNavBar(activeIndex: 7),
                        SizedBox(width: 20.w),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title + Preview ─────────────────────────────
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Request Demo',
                                    style: StyleText.fontSize45Weight600
                                        .copyWith(
                                      color: _C.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _navigateToPreview,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _C.primary,
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Preview Screen',
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // ── Gender toggle + Last Updated + Edit ─────────
                              Row(
                                children: [
                                  CustomSegmentedTabs(
                                    tabs: const ['Female', 'Male'],
                                    selectedIndex: _gender == 'female' ? 0 : 1,
                                    onTabSelected: (index) {
                                      final g = index == 0 ? 'female' : 'male';
                                      setState(() => _gender = g);
                                      context
                                          .read<RequestDemoCmsCubit>()
                                          .switchGender(g);
                                    },
                                    selectedColor: _C.primary,
                                    unselectedColor: Colors.white,
                                    selectedTextColor: Colors.white,
                                    unselectedTextColor: _C.labelText,
                                    equalWidth: false,
                                    containerPadding: EdgeInsets.symmetric(
                                      horizontal: 8.sp,
                                      vertical: 4.sp,
                                    ),
                                    containerColor: Colors.white,
                                  ),
                                  const Spacer(),
                                  _lastUpdatedRow(
                                    onEdit: _navigateToEdit,
                                    lastUpdated: m.lastUpdated,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // ── Header ─────────────────────────────────────
                              _acc('header', 'Header', [
                                _lbl('SVG'),
                                SizedBox(height: 6.h),
                                _svgCircle(m.headerSvgUrl),
                                SizedBox(height: 14.h),
                                _biRow(
                                  'Title',
                                  'العنوان',
                                  m.headerTitle.en,
                                  m.headerTitle.ar,
                                ),
                              ]),
                              SizedBox(height: 10.h),

                              // ── Questions ──────────────────────────────────
                              _acc(
                                'questions',
                                'Demo Related Questions',
                                m.demoQuestions
                                    .expand(
                                      (q) => [
                                    _biRow(
                                      'Question',
                                      'سؤال',
                                      q.question.en,
                                      q.question.ar,
                                    ),
                                    SizedBox(height: 8.h),
                                    _roBox(
                                      'Type Of Question',
                                      q.type.toValue(),
                                    ),
                                    if (q.type ==
                                        QuestionType.dropdown) ...[
                                      SizedBox(height: 8.h),
                                      _lbl('Values'),
                                      SizedBox(height: 4.h),
                                      ...q.values.map(
                                            (v) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 6.h,
                                          ),
                                          child: _biRow(
                                            '',
                                            '',
                                            v.label.en,
                                            v.label.ar,
                                          ),
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 12.h),
                                    Divider(color: _C.border),
                                    SizedBox(height: 8.h),
                                  ],
                                )
                                    .toList(),
                              ),
                              SizedBox(height: 10.h),

                              // ── Confirm Message ────────────────────────────
                              _acc('confirm', 'Confirm Message', [
                                _lbl('SVG'),
                                SizedBox(height: 6.h),
                                _svgCircle(m.confirmSvgUrl),
                                SizedBox(height: 14.h),
                                _biRow(
                                  'Title',
                                  'العنوان',
                                  m.confirmTitle.en,
                                  m.confirmTitle.ar,
                                ),
                                SizedBox(height: 10.h),
                                _lbl('Description'),
                                SizedBox(height: 6.h),
                                _roField(
                                  m.confirmDescription.en,
                                  maxLines: 4,
                                ),
                                SizedBox(height: 8.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'الوصف',
                                    style: StyleText.fontSize14Weight400
                                        .copyWith(color: AppColors.text),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                _roField(
                                  m.confirmDescription.ar,
                                  maxLines: 4,
                                  dir: ui.TextDirection.rtl,
                                ),
                              ]),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ],
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

  // ── Last Updated Row ──────────────────────────────────────────────────────
  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: _C.primary),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Details',
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  CustomSvg(
                    assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.scaleDown,
                    color: _C.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _acc(String key, String title, List<Widget> children) {
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
              borderRadius: BorderRadius.circular(6.r),
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
                  size: 25.sp,
                ),
              ],
            ),
          ),
        ),
        if (o)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(6.r),
                bottomRight: Radius.circular(6.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  Widget _lbl(String t) => Text(
    t,
    style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
  );

  Widget _biRow(String enL, String arL, String enV, String arV) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (enL.isNotEmpty) ...[
              Text(
                enL,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 6.h),
            ],
            _roField(enV),
          ],
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (arL.isNotEmpty) ...[
              Text(
                arL,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 6.h),
            ],
            _roField(arV, dir: ui.TextDirection.rtl),
          ],
        ),
      ),
    ],
  );

  Widget _roBox(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lbl(label),
      SizedBox(height: 6.h),
      _roField(value),
    ],
  );

  Widget _roField(
      String t, {
        int maxLines = 1,
        ui.TextDirection dir = ui.TextDirection.ltr,
      }) =>
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          t.isEmpty ? 'Text Here' : t,
          textDirection: dir,
          style: StyleText.fontSize12Weight400.copyWith(
            color: t.isEmpty ? _C.hintText : _C.labelText,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _svgCircle(String url) {
    if (url.isNotEmpty) {
      return Container(
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
                url,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.insert_drive_file_outlined,
          size: 24.sp,
          color: _C.hintText,
        ),
      ),
    );
  }
}