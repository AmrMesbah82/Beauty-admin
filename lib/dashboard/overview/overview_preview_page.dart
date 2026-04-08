/// ******************* FILE INFO *******************
/// File Name: overview_preview_page.dart
/// Description: Preview page for Master CMS (Overview-style).
///              Renders: Overview text, Top Services row,
///              Gallery grid, Client Comments cards,
///              Download section with store badges.
///              Desktop / Tablet / Mobile frames, EN / AR toggle.
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
import '../../controller/overview/overview_cubit.dart';
import '../../controller/overview/overview_state.dart';
import '../../model/overview/overview_model.dart';

class _C {
  static const Color primary     = Color(0xFFD16F9A);
  static const Color back        = Color(0xFFF1F2ED);
  static const Color labelText   = Color(0xFF333333);
  static const Color hintText    = Color(0xFFAAAAAA);
  static const Color border      = Color(0xFFE0E0E0);
  static const Color cardBg      = Color(0xFFFFFFFF);
  static const Color aboutBg     = Color(0xFFFFF0F5);
  static const Color galleryBg   = Color(0xFFFCE4EC);
  static const Color downloadBg  = Color(0xFFD16F9A);
  static const Color commentCard = Color(0xFFF8F8F8);
}

class OverviewPreviewPage extends StatefulWidget {
  const OverviewPreviewPage({super.key});

  @override
  State<OverviewPreviewPage> createState() => _OverviewPreviewPageState();
}

class _OverviewPreviewPageState extends State<OverviewPreviewPage> {
  int _deviceTab = 0;
  bool _isEnglish = true;
  bool _homeViewOpen = true;

  final List<String> _deviceLabels = ['Desktop', 'Tablet', 'Mobile'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverviewCmsCubit, OverviewCmsState>(
      builder: (context, state) {
        OverviewPageModel? model;
        if (state is OverviewCmsLoaded) model = state.data;
        if (state is OverviewCmsSaved) model = state.data;
        model ??= context.read<OverviewCmsCubit>().current;

        final cubit = context.read<OverviewCmsCubit>();

        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final double previewWidth;
        switch (_deviceTab) {
          case 1:  previewWidth = 700.w;  break;
          case 2:  previewWidth = 380.w;  break;
          default: previewWidth = 1000.w;
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
                          Text('Preview Overview Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 12.h),

                          // ── Device tabs + lang toggle ─────────────────
                          Row(children: [
                            ...List.generate(3, (i) {
                              final isActive = _deviceTab == i;
                              return GestureDetector(
                                onTap: () => setState(() => _deviceTab = i),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16.w),
                                  child: Text(_deviceLabels[i],
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                          color: isActive
                                              ? _C.primary
                                              : _C.hintText,
                                          decoration: isActive
                                              ? TextDecoration.underline
                                              : TextDecoration.none,
                                          decorationColor: _C.primary)),
                                ),
                              );
                            }),
                            const Spacer(),
                            _langChip('EN', true),
                            SizedBox(width: 8.w),
                            _langChip('AR', false),
                          ]),
                          SizedBox(height: 16.h),

                          // ── Home View accordion ───────────────────────
                          _previewAccordion(model!, previewWidth),
                          SizedBox(height: 24.h),

                          // ── Bottom buttons ────────────────────────────
                          Row(children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                      color: _C.primary.withOpacity(0.5),
                                      borderRadius:
                                      BorderRadius.circular(6.r)),
                                  child: Center(
                                      child: Text('Back',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white))),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showPublishConfirmDialog(
                                  context: context,
                                  onConfirm: () async {
                                    await cubit.save(
                                        publishStatus: 'published');
                                    Get.forceAppUpdate();
                                    html.window.location.reload();
                                  },
                                ),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                      color: _C.primary,
                                      borderRadius:
                                      BorderRadius.circular(6.r)),
                                  child: Center(
                                      child: Text('Publish',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white))),
                                ),
                              ),
                            ),
                          ]),
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

  // ── Lang chip ─────────────────────────────────────────────────────────────
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
        child: Text(label,
            style: StyleText.fontSize12Weight500.copyWith(
                color: isActive ? Colors.white : _C.labelText)),
      ),
    );
  }

  // ── Preview accordion ─────────────────────────────────────────────────────
  Widget _previewAccordion(OverviewPageModel model, double width) {
    return Center(
      child: SizedBox(
        width: width,
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => _homeViewOpen = !_homeViewOpen),
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                            .copyWith(color: Colors.white))),
                Icon(
                    _homeViewOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp),
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
                    bottomRight: Radius.circular(6.r)),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _previewOverview(model),
                  _previewServices(model),
                  _previewGallery(model),
                  _previewComments(model),
                  _previewDownload(model),
                ],
              ),
            ),
        ]),
      ),
    );
  }

  // ── Overview section ──────────────────────────────────────────────────────
  Widget _previewOverview(OverviewPageModel m) {
    final title = _isEnglish ? m.headings.title.en : m.headings.title.ar;
    final desc = _isEnglish
        ? m.headings.description.en
        : m.headings.description.ar;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      color: _C.aboutBg,
      child: Column(
        crossAxisAlignment:
        _isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(title.isNotEmpty ? title : 'Overview',
              textDirection:
              _isEnglish ? TextDirection.ltr : TextDirection.rtl,
              style: StyleText.fontSize20Weight600
                  .copyWith(color: _C.labelText)),
          SizedBox(height: 12.h),
          Text(
            desc.isNotEmpty
                ? desc
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
              Text(_isEnglish ? 'Read More' : 'اقرأ المزيد',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: _C.primary)),
              SizedBox(width: 4.w),
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                    color: _C.primary, shape: BoxShape.circle),
                child: Icon(
                    _isEnglish
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Services preview ──────────────────────────────────────────────────────
  Widget _previewServices(OverviewPageModel m) {
    if (m.services.items.isEmpty) return const SizedBox.shrink();
    final svcTitle =
    _isEnglish ? m.services.title.en : m.services.title.ar;
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment:
        _isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(svcTitle.isNotEmpty ? svcTitle : 'Top Services',
              textDirection:
              _isEnglish ? TextDirection.ltr : TextDirection.rtl,
              style: StyleText.fontSize20Weight600
                  .copyWith(color: _C.primary)),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: m.services.items.map((item) {
                final name =
                _isEnglish ? item.name.en : item.name.ar;
                return Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Column(children: [
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.aboutBg,
                      ),
                      child: item.imageUrl.isNotEmpty
                          ? ClipOval(
                          child: SvgPicture.network(item.imageUrl,
                              fit: BoxFit.cover,
                              placeholderBuilder: (_) =>
                              const CircleProgressMaster()))
                          : Center(
                          child: Icon(Icons.spa,
                              color: _C.primary, size: 30.sp)),
                    ),
                    SizedBox(height: 8.h),
                    Text(name.isNotEmpty ? name : 'Service',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _C.labelText)),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gallery preview ───────────────────────────────────────────────────────
  Widget _previewGallery(OverviewPageModel m) {
    if (m.gallery.images.isEmpty) return const SizedBox.shrink();
    final visibleImages =
    m.gallery.images.where((img) => img.imageUrl.isNotEmpty).toList();
    if (visibleImages.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      color: _C.galleryBg.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEnglish ? 'Gallery' : 'المعرض',
              style: StyleText.fontSize20Weight600
                  .copyWith(color: _C.primary)),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: visibleImages.map((img) {
              return Container(
                width: 120.w,
                height: 100.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.white),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SvgPicture.network(img.imageUrl,
                      fit: BoxFit.cover,
                      placeholderBuilder: (_) =>
                      const CircleProgressMaster()),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Client Comments preview ───────────────────────────────────────────────
  Widget _previewComments(OverviewPageModel m) {
    if (m.clientComments.comments.isEmpty) return const SizedBox.shrink();
    final cmtTitle = _isEnglish
        ? m.clientComments.title.en
        : m.clientComments.title.ar;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment:
        _isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          RichText(
            textDirection:
            _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            text: TextSpan(
              children: [
                TextSpan(
                  text: _isEnglish ? 'What Our\n' : 'ماذا يقول\n',
                  style: StyleText.fontSize20Weight600
                      .copyWith(color: _C.labelText),
                ),
                TextSpan(
                  text: _isEnglish ? 'Clients ' : 'عملاؤنا ',
                  style: StyleText.fontSize20Weight600
                      .copyWith(color: _C.primary),
                ),
                TextSpan(
                  text: _isEnglish ? 'Say\nAbout Us' : 'عنّا',
                  style: StyleText.fontSize20Weight600
                      .copyWith(color: _C.labelText),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: m.clientComments.comments.map((cmt) {
                final firstName = _isEnglish
                    ? cmt.firstName.en
                    : cmt.firstName.ar;
                final lastName = _isEnglish
                    ? cmt.lastName.en
                    : cmt.lastName.ar;
                final feedback = _isEnglish
                    ? cmt.feedback.en
                    : cmt.feedback.ar;

                return Container(
                  width: 220.w,
                  margin: EdgeInsets.only(right: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _C.commentCard,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _C.border),
                  ),
                  child: Column(
                    crossAxisAlignment: _isEnglish
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Row(children: [
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _C.aboutBg),
                          child: cmt.imageUrl.isNotEmpty
                              ? ClipOval(
                              child: SvgPicture.network(
                                  cmt.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (_) =>
                                  const CircleProgressMaster()))
                              : Center(
                              child: Icon(Icons.person,
                                  size: 18.sp,
                                  color: _C.primary)),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text('$firstName $lastName',
                              style: StyleText.fontSize12Weight600
                                  .copyWith(color: _C.labelText),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      SizedBox(height: 10.h),
                      Text(
                        feedback.isNotEmpty
                            ? feedback
                            : 'Great service!',
                        textDirection: _isEnglish
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        style: StyleText.fontSize11Weight400
                            .copyWith(color: _C.labelText, height: 1.5),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Download section preview ──────────────────────────────────────────────
  Widget _previewDownload(OverviewPageModel m) {
    final title =
    _isEnglish ? m.download.title.en : m.download.title.ar;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
      color: _C.downloadBg,
      child: Column(
        crossAxisAlignment:
        _isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            title.isNotEmpty
                ? title
                : (_isEnglish
                ? 'At Beauty, you will find luxury services.'
                : 'ستجد لدينا أفضل الخدمات.'),
            textDirection:
            _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: StyleText.fontSize14Weight400
                .copyWith(color: Colors.white, height: 1.5),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {},
            child: Text(_isEnglish ? 'Learn More' : 'تعرف أكثر',
                style: StyleText.fontSize12Weight500.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white)),
          ),
          SizedBox(height: 16.h),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _storeBadge(label: 'Google Play', icon: Icons.play_arrow_rounded),
            SizedBox(width: 12.w),
            _storeBadge(label: 'App Store', icon: Icons.apple),
          ]),
        ],
      ),
    );
  }

  Widget _storeBadge({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(6.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
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
            ]),
      ]),
    );
  }
}