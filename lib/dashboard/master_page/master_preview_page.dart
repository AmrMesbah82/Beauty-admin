/// ******************* FILE INFO *******************
/// File Name: master_preview_page.dart
/// Description: Preview page for the Master CMS module.
///              Shows Desktop / Tablet / Mobile device frames,
///              EN / AR language toggle, and renders the Home View
///              inside an accordion with all sections.
///              Back + Publish buttons at bottom.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

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
import '../../controller/master/master_cubit.dart';
import '../../controller/master/master_state.dart';
import '../../model/master/master_model.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color aboutBg   = Color(0xFFFFF0F5);
  static const Color downloadBg = Color(0xFFFCE4EC);
}

class MasterPreviewPage extends StatefulWidget {
  const MasterPreviewPage({super.key});

  @override
  State<MasterPreviewPage> createState() => _MasterPreviewPageState();
}

class _MasterPreviewPageState extends State<MasterPreviewPage> {
  int _deviceTab = 0; // 0=Desktop, 1=Tablet, 2=Mobile
  bool _isEnglish = true;
  bool _homeViewOpen = true;

  final List<String> _deviceLabels = ['Desktop', 'Tablet', 'Mobile'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterCmsCubit, MasterCmsState>(
      builder: (context, state) {
        MasterPageModel? model;
        if (state is MasterCmsLoaded) model = state.data;
        if (state is MasterCmsSaved) model = state.data;

        // Also read from cubit.current as fallback
        model ??= context.read<MasterCmsCubit>().current;

        final cubit = context.read<MasterCmsCubit>();

        if (state is MasterCmsInitial || state is MasterCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        // ── Device widths ─────────────────────────────────────────────────
        final double previewWidth;
        switch (_deviceTab) {
          case 1:
            previewWidth = 700.w;
            break;
          case 2:
            previewWidth = 380.w;
            break;
          default:
            previewWidth = 1000.w;
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
                  SizedBox(
                    width: 1000.w,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title ─────────────────────────────────────
                          Text(
                            'Preview Home Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Device tabs + EN/AR toggle ────────────────
                          Row(
                            children: [
                              ...List.generate(3, (i) {
                                final isActive = _deviceTab == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _deviceTab = i),
                                  child: Padding(
                                    padding:
                                    EdgeInsets.only(right: 16.w),
                                    child: Text(
                                      _deviceLabels[i],
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                        color: isActive
                                            ? _C.primary
                                            : _C.hintText,
                                        decoration: isActive
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        decorationColor: _C.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const Spacer(),
                              _langChip('EN', true),
                              SizedBox(width: 8.w),
                              _langChip('AR', false),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Home View accordion ───────────────────────
                          _homeViewAccordion(model!, previewWidth),

                          SizedBox(height: 24.h),

                          // ── Bottom buttons ────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _C.primary.withOpacity(0.5),
                                      borderRadius:
                                      BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: Text('Back',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showPublishConfirmDialog(
                                      context: context,
                                      onConfirm: () async {
                                        await cubit.save(
                                            publishStatus: 'published');
                                        Get.forceAppUpdate();
                                        html.window.location.reload();
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _C.primary,
                                      borderRadius:
                                      BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: Text('Publish',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
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

  // ── Language chip ──────────────────────────────────────────────────────────
  Widget _langChip(String label, bool isEn) {
    final isActive = _isEnglish == isEn;
    return GestureDetector(
      onTap: () => setState(() => _isEnglish = isEn),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? _C.primary : Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: isActive ? _C.primary : _C.border),
        ),
        child: Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: isActive ? Colors.white : _C.labelText,
          ),
        ),
      ),
    );
  }

  // ── Home View accordion ───────────────────────────────────────────────────
  Widget _homeViewAccordion(MasterPageModel model, double width) {
    return Center(
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            GestureDetector(
              onTap: () =>
                  setState(() => _homeViewOpen = !_homeViewOpen),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: _homeViewOpen
                      ? BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r))
                      : BorderRadius.circular(6.r),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text('Home View',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    _homeViewOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ]),
              ),
            ),
            if (_homeViewOpen)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(6.r),
                  ),
                  border: Border.all(color: _C.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header section preview ──────────────────────
                    _previewHeaderSection(model),

                    // ── About Us preview ────────────────────────────
                    _previewAboutUsSection(model),

                    // ── Footer / Download section preview ───────────
                    _previewFooterSection(model),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header section preview ────────────────────────────────────────────────
  Widget _previewHeaderSection(MasterPageModel model) {
    final header = model.sectionByKey('header');
    final titleText =
    _isEnglish ? model.title.en : model.title.ar;
    final shortDescText = _isEnglish
        ? model.shortDescription.en
        : model.shortDescription.ar;
    final imageUrl = header?.imageUrl ?? '';

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Image ──────────────────────────────────────────────────
          if (imageUrl.isNotEmpty)
            Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SvgPicture.network(
                imageUrl,
                fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                const CircleProgressMaster(),
              ),
            )
          else
            Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                color: _C.sectionBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(Icons.image,
                    size: 40.sp, color: _C.hintText),
              ),
            ),
          SizedBox(width: 24.w),

          // ── Text ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: _isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText.isNotEmpty ? titleText : 'Beauty App',
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize16Weight600
                      .copyWith(color: _C.labelText),
                ),
                SizedBox(height: 8.h),
                Text(
                  shortDescText.isNotEmpty
                      ? shortDescText
                      : 'Style & Simple Bright',
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize24Weight600
                      .copyWith(color: _C.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── About Us preview ──────────────────────────────────────────────────────
  Widget _previewAboutUsSection(MasterPageModel model) {
    final about = model.sectionByKey('aboutUs');
    final titleText =
    _isEnglish ? (about?.title.en ?? '') : (about?.title.ar ?? '');
    final descText = _isEnglish
        ? (about?.description.en ?? '')
        : (about?.description.ar ?? '');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 0),
      padding: EdgeInsets.all(24.w),
      color: _C.aboutBg,
      child: Column(
        crossAxisAlignment: _isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            titleText.isNotEmpty ? titleText : 'About Us',
            textDirection:
            _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: StyleText.fontSize20Weight600
                .copyWith(color: _C.labelText),
          ),
          SizedBox(height: 12.h),
          Text(
            descText.isNotEmpty
                ? descText
                : 'Welcome to Beauty App, where beauty meets tranquility.',
            textDirection:
            _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: StyleText.fontSize14Weight400
                .copyWith(color: _C.labelText, height: 1.6),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: _isEnglish
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                _isEnglish ? 'Read More' : 'اقرأ المزيد',
                style: StyleText.fontSize14Weight600
                    .copyWith(color: _C.primary),
              ),
              SizedBox(width: 4.w),
              Icon(
                _isEnglish
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: _C.primary,
                size: 16.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer / Download section preview ─────────────────────────────────────
  Widget _previewFooterSection(MasterPageModel model) {
    final footer = model.sectionByKey('footer');
    final titleText =
    _isEnglish ? (footer?.title.en ?? '') : (footer?.title.ar ?? '');
    final descText = _isEnglish
        ? (footer?.description.en ?? '')
        : (footer?.description.ar ?? '');
    final imageUrl = footer?.imageUrl ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Phone mockup image ─────────────────────────────────────
          if (imageUrl.isNotEmpty)
            Container(
              width: 200.w,
              height: 220.h,
              child: SvgPicture.network(
                imageUrl,
                fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                const CircleProgressMaster(),
              ),
            )
          else
            Container(
              width: 200.w,
              height: 220.h,
              decoration: BoxDecoration(
                color: _C.downloadBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(Icons.phone_iphone,
                    size: 60.sp, color: _C.primary),
              ),
            ),
          SizedBox(width: 24.w),

          // ── Text + store badges ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: _isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText.isNotEmpty
                      ? titleText
                      : (_isEnglish
                      ? 'Download Beauty App Now'
                      : 'حمل التطبيق الآن'),
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize20Weight600
                      .copyWith(color: _C.labelText),
                ),
                SizedBox(height: 10.h),
                Text(
                  descText.isNotEmpty
                      ? descText
                      : (_isEnglish
                      ? 'At Beauty, you will find luxury services.'
                      : 'ستجد لدينا أفضل الخدمات.'),
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: _C.labelText, height: 1.5),
                ),
                SizedBox(height: 16.h),

                // ── Store badges ─────────────────────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _storeBadge(
                      label: 'Google Play',
                      icon: Icons.play_arrow_rounded,
                    ),
                    SizedBox(width: 12.w),
                    _storeBadge(
                      label: 'App Store',
                      icon: Icons.apple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeBadge({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GET IT ON',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w400)),
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}