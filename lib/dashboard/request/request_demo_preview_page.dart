/// File Name: request_demo_preview_page.dart
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/request/request_demo_cubit.dart';
import '../../controller/request/request_demo_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/request/request_demo_model.dart';
import '../../widgets/admin_sub_navbar.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color back = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFF5F5F5);
}

class RequestDemoPreviewPage extends StatefulWidget {
  const RequestDemoPreviewPage({super.key});
  @override
  State<RequestDemoPreviewPage> createState() => _RequestDemoPreviewPageState();
}

class _RequestDemoPreviewPageState extends State<RequestDemoPreviewPage> {
  int _device = 0;
  bool _headerOpen = true;
  final _devLabels = ['Desktop', 'Tablet', 'Mobile'];
  bool _isEnglish = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestDemoCmsCubit, RequestDemoCmsState>(
      builder: (ctx, state) {
        RequestDemoPageModel? m;
        if (state is RequestDemoCmsLoaded) m = state.data;
        if (state is RequestDemoCmsSaved) m = state.data;
        m ??= ctx.read<RequestDemoCmsCubit>().current;
        final cubit = ctx.read<RequestDemoCmsCubit>();

        if (state is RequestDemoCmsInitial || state is RequestDemoCmsLoading)
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );

        final double pw;
        switch (_device) {
          case 1:
            pw = 700.w;
            break;
          case 2:
            pw = 380.w;
            break;
          default:
            pw = 1000.w;
        }

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
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview Request Demo Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Device tabs + lang ───────────────────────────
                          Row(
                            children: [
                              ...List.generate(3, (i) {
                                final a = _device == i;
                                return GestureDetector(
                                  onTap: () => setState(() => _device = i),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16.w),
                                    child: Text(
                                      _devLabels[i],
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                        color: a ? _C.primary : _C.hintText,
                                        decoration: a
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        decorationColor: _C.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const Spacer(),
                              SizedBox(
                                width: 100.w,
                                height: 32.h,
                                child: CustomSegmentedTabs(
                                  tabs: ['EN', 'AR'],
                                  selectedIndex: _isEnglish ? 0 : 1,
                                  onTabSelected: (index) {
                                    setState(() => _isEnglish = index == 0);
                                  },
                                  containerColor: Colors.white,
                                  selectedColor: _C.primary,
                                  unselectedColor: Colors.transparent,
                                  selectedTextColor: Colors.white,
                                  unselectedTextColor: _C.hintText,
                                  textStyle: StyleText.fontSize12Weight600,
                                  equalWidth: true,
                                  spacing: 8.sp,
                                  tabHorizontalPadding: 12.w,
                                  tabVerticalPadding: 6.h,
                                  containerPadding: EdgeInsets.all(4.sp),
                                  borderRadius: 6,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Header accordion ─────────────────────────────
                          _headerAccordion(m!, pw),
                          SizedBox(height: 24.h),

                          // ── Buttons ──────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Discard',
                                  _C.hintText,
                                      () => Navigator.pop(context),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _btn(
                                  'Save',
                                  _C.primary,
                                      () => showPublishConfirmDialog(
                                    context: context,
                                    onConfirm: () async {
                                      await cubit.save(
                                        publishStatus: 'published',
                                      );
                                      Get.forceAppUpdate();
                                      html.window.location.reload();
                                    },
                                  ),
                                ),
                              ),
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

  Widget _headerAccordion(RequestDemoPageModel m, double w) {
    return Center(
      child: SizedBox(
        width: w,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _headerOpen = !_headerOpen),
              child: Container(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: _headerOpen
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
                        'Confirm Message Preview',
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      _headerOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (_headerOpen)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(6.r),
                  ),
                  border: Border.all(color: _C.border),
                ),
                child: _confirmPreview(m),
              ),
          ],
        ),
      ),
    );
  }

  /// Renders the confirm message SVG centered with title and description below
  Widget _confirmPreview(RequestDemoPageModel m) {
    final title =
    _isEnglish ? m.confirmTitle.en : m.confirmTitle.ar;
    final desc = _isEnglish
        ? m.confirmDescription.en
        : m.confirmDescription.ar;
    final dir = _isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final svgUrl = m.confirmSvgUrl;

    return Column(
      children: [
        // ── SVG Image ────────────────────────────────────────────────
        if (svgUrl.isNotEmpty)
          SvgPicture.network(
            svgUrl,
            height: 200.h,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const CircleProgressMaster(),
          )
        else
          Container(
            height: 200.h,
            width: double.infinity,
            color: _C.sectionBg,
            child: Center(
              child: Icon(Icons.image, size: 40.sp, color: _C.hintText),
            ),
          ),

        SizedBox(height: 16.h),

        // ── Title ────────────────────────────────────────────────────
        Text(
          title.isNotEmpty
              ? title
              : 'Waiting till Customer Services Call You',
          textDirection: dir,
          textAlign: TextAlign.center,
          style: StyleText.fontSize16Weight600.copyWith(color: _C.primary),
        ),
        SizedBox(height: 8.h),

        // ── Description ──────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            desc.isNotEmpty
                ? desc
                : 'Your demo request has been successfully submitted, thank you! We\'ll be in touch soon to confirm the details.',
            textDirection: dir,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: _C.labelText,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}