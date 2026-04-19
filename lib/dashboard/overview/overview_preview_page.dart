/// ******************* FILE INFO *******************
/// File Name: overview_preview_page.dart
/// Description: Preview page for Master CMS (Overview-style).
///              Renders: Overview text, Top Services row,
///              Gallery grid, Client Comments cards,
///              Download section with store badges.
///              Desktop / Tablet / Mobile frames, EN / AR toggle.
///              Back + Publish buttons at bottom.
/// Updated: 15/04/2026 - UI now matches overview_page.dart design
/// Created by: Amr Mesbah

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
  static const Color primary = Color(0xFFD16F9A);
  static const Color back = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color aboutBg = Color(0xFFFFF0F5);
  static const Color galleryBg = Color(0xFFFCE4EC);
  static const Color downloadBg = Color(0xFFD16F9A);
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
  int _galleryActiveIndex = 0;

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
          case 1: previewWidth = 700.w; break;
          case 2: previewWidth = 380.w; break;
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

                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(6.r)),
                border: Border.all(color: _C.border),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _previewOverview(model),
                    SizedBox(height: 50.h),
                    _previewServices(model),
                    SizedBox(height: 50.h),
                    _previewGallery(model),
                    SizedBox(height: 50.h),
                    _previewComments(model),
                    SizedBox(height: 50.h),
                    _previewDownload(model),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // ── Overview section (matches overview_page.dart) ────────────────────────
  Widget _previewOverview(OverviewPageModel m) {
    final title = _isEnglish ? m.headings.title.en : m.headings.title.ar;
    final desc = _isEnglish
        ? m.headings.description.en
        : m.headings.description.ar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (title.isNotEmpty ? title : 'Overview'),
          style: StyleText.fontSize22Weight700.copyWith(
            color: _C.primary,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          desc.isNotEmpty
              ? desc
              : 'Welcome to Beauty App, where beauty meets tranquility.',
          textDirection:
          _isEnglish ? TextDirection.ltr : TextDirection.rtl,
          style: StyleText.fontSize14Weight400.copyWith(
            height: 1.7,
            color: _C.labelText,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEnglish ? 'Read More' : 'اقرأ المزيد',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: _C.primary),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.primary.withOpacity(0.15),
                    ),
                    child: Icon(
                      _isEnglish ? Icons.arrow_forward : Icons.arrow_back,
                      size: 14.sp,
                      color: _C.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Services preview (horizontal scroll row) ────────────────────────────
  Widget _previewServices(OverviewPageModel m) {
    if (m.services.items.isEmpty) return const SizedBox.shrink();
    final svcTitle =
    _isEnglish ? m.services.title.en : m.services.title.ar;

    return Column(
      crossAxisAlignment:
      _isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          svcTitle.isNotEmpty ? svcTitle : 'Top Services',
          textDirection:
          _isEnglish ? TextDirection.ltr : TextDirection.rtl,
          style: StyleText.fontSize22Weight700.copyWith(
            color: _C.primary,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 24.h),
        // Always horizontal scroll - no Wrap
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: m.services.items.map((item) {
              final name = _isEnglish ? item.name.en : item.name.ar;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _C.primary.withOpacity(0.2), width: 2.w),
                      ),
                      child: ClipOval(
                        child: Center(
                          child: item.imageUrl.isNotEmpty
                              ? SvgPicture.network(
                            item.imageUrl,
                            width: 48.w,
                            height: 48.w,
                            fit: BoxFit.scaleDown,
                            placeholderBuilder: (_) =>
                            const CircleProgressMaster(),
                          )
                              : Icon(Icons.spa_outlined,
                              color: _C.primary.withOpacity(0.4),
                              size: 28.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      name.isNotEmpty ? name : 'Service',
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: _C.labelText),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Gallery preview (with animated carousel like overview_page.dart) ─────
  Widget _previewGallery(OverviewPageModel m) {
    if (m.gallery.images.isEmpty) return const SizedBox.shrink();
    final visibleImages =
    m.gallery.images.where((img) => img.imageUrl.isNotEmpty).toList();
    if (visibleImages.isEmpty) return const SizedBox.shrink();

    // Reset active index if out of range
    if (_galleryActiveIndex >= visibleImages.length) {
      _galleryActiveIndex = visibleImages.length - 1;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double inactiveSize = isMobile ? 110.w : 200.w;
    final double activeSize = isMobile ? 160.w : 284.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEnglish ? 'Gallery' : 'المعرض',
          style: StyleText.fontSize22Weight700.copyWith(
            color: _C.primary,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: activeSize + 16.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(visibleImages.length, (i) {
                final bool isActive = _galleryActiveIndex == i;
                final double size = isActive ? activeSize : inactiveSize;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: GestureDetector(
                    onTap: () => setState(() => _galleryActiveIndex = i),
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      width: size,
                      height: size,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: visibleImages[i].imageUrl.isNotEmpty
                            ? SvgPicture.network(
                          visibleImages[i].imageUrl,
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          placeholderBuilder: (_) =>
                              Container(
                                color: _C.primary.withOpacity(0.12),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: _C.primary.withOpacity(0.4),
                                  size: 36.sp,
                                ),
                              ),
                        )
                            : Container(
                          color: _C.primary.withOpacity(0.12),
                          child: Icon(
                            Icons.image_outlined,
                            color: _C.primary.withOpacity(0.4),
                            size: 36.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(visibleImages.length, (i) {
            final bool active = _galleryActiveIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _galleryActiveIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 24.w : 8.w,
                height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: active
                      ? _C.primary
                      : _C.primary.withOpacity(0.3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Client Comments preview (with title highlight like overview_page.dart) ─
  Widget _previewComments(OverviewPageModel m) {
    if (m.clientComments.comments.isEmpty) return const SizedBox.shrink();
    final cmtTitle = _isEnglish
        ? m.clientComments.title.en
        : m.clientComments.title.ar;

    final highlightWord = _isEnglish ? 'Clients' : 'عملائنا';
    final titleText = cmtTitle.isNotEmpty
        ? cmtTitle
        : (_isEnglish ? 'What Our Clients Say About Us' : 'ماذا يقول عملاؤنا عنّا');

    return Column(
      crossAxisAlignment:
      _isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        _buildHighlightedTitle(titleText, highlightWord),
        SizedBox(height: 24.h),
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
              final fullName = '$firstName $lastName'.trim();

              return Container(
                width: 280.w,
                margin: EdgeInsets.only(right: 16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: _C.commentCard,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _C.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: cmt.imageUrl.isNotEmpty
                              ? SvgPicture.network(
                            cmt.imageUrl,
                            width: 48.r,
                            height: 48.r,
                            fit: BoxFit.cover,
                            placeholderBuilder: (_) =>
                                CircleAvatar(
                                  radius: 24.r,
                                  backgroundColor: _C.primary.withOpacity(0.15),
                                  child: Icon(Icons.person_outline,
                                      color: _C.primary, size: 22.sp),
                                ),
                          )
                              : CircleAvatar(
                            radius: 24.r,
                            backgroundColor: _C.primary.withOpacity(0.15),
                            child: Icon(Icons.person_outline,
                                color: _C.primary, size: 22.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            fullName.isNotEmpty ? fullName : 'Client Name',
                            style: StyleText.fontSize14Weight600.copyWith(
                              color: _C.labelText,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      feedback.isNotEmpty
                          ? feedback
                          : 'Great service! Highly recommended.',
                      textDirection: _isEnglish
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: StyleText.fontSize12Weight400.copyWith(
                        height: 1.6,
                        color: _C.labelText.withOpacity(0.75),
                      ),
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
    );
  }

  Widget _buildHighlightedTitle(String title, String highlightWord) {
    final idx = title.toLowerCase().indexOf(highlightWord.toLowerCase());
    if (idx == -1) {
      return Text(
        title,
        style: StyleText.fontSize22Weight700.copyWith(
          color: _C.labelText,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      );
    }

    final before = title.substring(0, idx);
    final keyword = title.substring(idx, idx + highlightWord.length);
    final after = title.substring(idx + highlightWord.length);

    return Text.rich(
      TextSpan(
        style: StyleText.fontSize22Weight700.copyWith(
          color: _C.labelText,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: keyword,
            style: TextStyle(color: _C.primary),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }

  // ── Download section preview (matches overview_page.dart style) ──────────
  Widget _previewDownload(OverviewPageModel m) {
    final title = _isEnglish ? m.download.title.en : m.download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (_isEnglish
        ? 'Download our app for the best experience'
        : 'قم بتنزيل تطبيقنا للحصول على أفضل تجربة');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    style: StyleText.fontSize20Weight600.copyWith(
                      color: _C.primary,
                      fontSize: 22.sp,
                    ),
                  ),
                ),
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
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                titleText,
                style: StyleText.fontSize20Weight600.copyWith(
                  color: _C.primary,
                  fontSize: 22.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
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
          );
        },
      ),
    );
  }

  Widget _storeBadge({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
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
              Text(
                'GET IT ON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}