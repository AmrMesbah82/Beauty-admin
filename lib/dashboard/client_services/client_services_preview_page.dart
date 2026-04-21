/// ******************* FILE INFO *******************
/// File Name: client_services_preview_page.dart
/// Description: Preview page for Client Services CMS.
///              Renders mockups using OurProductsPage layout pattern:
///              - left  → text LEFT, image RIGHT
///              - right → image LEFT, text RIGHT
///              - centered → image CENTER (above), text CENTER (below)
///              Download bar with store badges between header and mockups.
///              Desktop / Tablet / Mobile + EN / AR toggles.
/// UPDATED: EN/AR toggle now uses CustomSegmentedTabs
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

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
import '../../controller/client_services/client_services_cubit.dart';
import '../../controller/client_services/client_services_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/client_services/client_services_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color back = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFFFF0F5);
  static const Color downloadBg = Color(0xFFF5F5F5);
}

class ClientServicesPreviewPage extends StatefulWidget {
  const ClientServicesPreviewPage({super.key});

  @override
  State<ClientServicesPreviewPage> createState() =>
      _ClientServicesPreviewPageState();
}

class _ClientServicesPreviewPageState extends State<ClientServicesPreviewPage> {
  int _deviceTab = 0;
  int _langIndex = 0; // 0 = EN, 1 = AR
  bool get _isEnglish => _langIndex == 0;
  bool _viewOpen = true;
  final List<String> _deviceLabels = ['Desktop', 'Tablet', 'Mobile'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientServicesCmsCubit, ClientServicesCmsState>(
      builder: (context, state) {
        ClientServicesPageModel? model;
        if (state is ClientServicesCmsLoaded) model = state.data;
        if (state is ClientServicesCmsSaved) model = state.data;
        model ??= context.read<ClientServicesCmsCubit>().current;
        final cubit = context.read<ClientServicesCmsCubit>();

        if (state is ClientServicesCmsInitial ||
            state is ClientServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final double pw;
        switch (_deviceTab) {
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
                  AppAdminNavbar(
                    activeLabel: 'Web Pages',
                    homePage: HomeMainPage(),
                    webPage: HomeMainPage(),
                    jobListingPage: HomeMainPage(),
                  ),
                  SizedBox(width: 20.w),
                  AdminSubNavBar(activeIndex: 3),
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
                            'Preview Client Services Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Device tabs + lang ─────────────────────────────
                          Row(
                            children: [
                              ...List.generate(3, (i) {
                                final a = _deviceTab == i;
                                return GestureDetector(
                                  onTap: () => setState(() => _deviceTab = i),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16.w),
                                    child: Text(
                                      _deviceLabels[i],
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
                              // ── EN / AR toggle using CustomSegmentedTabs ──
                              CustomSegmentedTabs(
                                tabs: const ['EN', 'AR'],
                                selectedIndex: _langIndex,
                                onTabSelected: (i) =>
                                    setState(() => _langIndex = i),
                                selectedColor: _C.primary,
                                unselectedColor: Colors.white,
                                selectedTextColor: Colors.white,
                                unselectedTextColor: _C.labelText,
                                containerColor: Colors.white,
                                equalWidth: false,
                                containerPadding: EdgeInsets.symmetric(horizontal: 8.sp,vertical: 4.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── View accordion ─────────────────────────────────
                          _viewAccordion(model!, pw),
                          SizedBox(height: 24.h),

                          // ── Buttons ────────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Back',
                                  _C.primary.withOpacity(0.5),
                                      () => Navigator.pop(context),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _btn(
                                  'Publish',
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

  Widget _btn(String l, Color bg, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: Text(
          l,
          style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
        ),
      ),
    ),
  );

  Widget _viewAccordion(ClientServicesPageModel model, double width) {
    return Center(
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _viewOpen = !_viewOpen),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: _viewOpen
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
                        'View',
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      _viewOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (_viewOpen)
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
                    _previewHeader(model),
                    _previewDownloadBar(model),
                    ...model.mockups.items.map((item) => _previewMockup(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _previewHeader(ClientServicesPageModel m) {
    final title = _isEnglish ? m.header.title.en : m.header.title.ar;
    final desc = _isEnglish ? m.header.description.en : m.header.description.ar;
    final dir = _isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      color: _C.sectionBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: _isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  title.isNotEmpty ? title : 'Our Services',
                  textDirection: dir,
                  style: StyleText.fontSize20Weight600.copyWith(
                    color: _C.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  desc.isNotEmpty
                      ? desc
                      : 'Beauty App provides you with many salons…',
                  textDirection: dir,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: _C.labelText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            flex: 4,
            child: m.header.svgUrl.isNotEmpty
                ? SvgPicture.network(
              m.header.svgUrl,
              height: 200.h,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => const CircleProgressMaster(),
            )
                : Container(
              height: 200.h,
              color: _C.downloadBg,
              child: Center(
                child: Icon(Icons.image, size: 40.sp, color: _C.hintText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewDownloadBar(ClientServicesPageModel m) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _C.downloadBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            _isEnglish
                ? 'At Beauty, you will find luxury services.'
                : 'ستجد لدينا أفضل الخدمات.',
            style: StyleText.fontSize12Weight400.copyWith(color: _C.labelText),
          ),
          const Spacer(),
          _storeBadge('Google Play', Icons.play_arrow_rounded),
          SizedBox(width: 10.w),
          _storeBadge('App Store', Icons.apple),
        ],
      ),
    );
  }

  Widget _previewMockup(ClientServicesMockupItemModel item) {
    final title = _isEnglish ? item.title.en : item.title.ar;
    final desc = _isEnglish ? item.description.en : item.description.ar;
    final dir = _isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;

    final imageWidget = item.svgUrl.isNotEmpty
        ? SvgPicture.network(
      item.svgUrl,
      height: 280.h,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => const CircleProgressMaster(),
    )
        : Container(
      height: 280.h,
      width: double.infinity,
      color: _C.downloadBg,
      child: Center(
        child: Icon(Icons.phone_iphone, size: 60.sp, color: _C.primary),
      ),
    );

    final textWidget = Column(
      crossAxisAlignment: _isEnglish
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.isNotEmpty ? title : 'Section Title',
          textDirection: dir,
          style: StyleText.fontSize20Weight600.copyWith(color: _C.labelText),
        ),
        SizedBox(height: 12.h),
        Text(
          desc.isNotEmpty ? desc : 'Description text here…',
          textDirection: dir,
          style: StyleText.fontSize14Weight400.copyWith(
            color: _C.labelText,
            height: 1.6,
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 500;

          switch (item.layout) {
            case MockupLayout.centered:
              return Column(
                children: [
                  imageWidget,
                  SizedBox(height: 16.h),
                  textWidget,
                ],
              );

            case MockupLayout.left:
              if (!isWide)
                return Column(
                  children: [
                    imageWidget,
                    SizedBox(height: 16.h),
                    textWidget,
                  ],
                );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: textWidget),
                  SizedBox(width: 20.w),
                  Expanded(flex: 4, child: imageWidget),
                ],
              );

            case MockupLayout.right:
              if (!isWide)
                return Column(
                  children: [
                    imageWidget,
                    SizedBox(height: 16.h),
                    textWidget,
                  ],
                );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 4, child: imageWidget),
                  SizedBox(width: 20.w),
                  Expanded(flex: 6, child: textWidget),
                ],
              );
          }
        },
      ),
    );
  }

  Widget _storeBadge(String label, IconData icon) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16.sp),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GET IT ON',
              style: TextStyle(
                color: Colors.white,
                fontSize: 6.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}