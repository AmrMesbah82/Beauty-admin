/// ******************* FILE INFO *******************
/// File Name: main_main.dart
/// Page 1 — "Main" read-only overview page

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widgets/circle_progress.dart';
import 'package:beauty_admin/core/widgets/navigator.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import 'main_edit.dart';
import 'main_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:intl/intl.dart';
import 'dart:ui' as ui;

part '../widgets/main_main/c.dart';
part '../widgets/main_main/sections.dart';

class HomeMainPage extends StatefulWidget {
  const HomeMainPage({super.key});
  @override
  State<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage> {
  final Map<String, bool> _open = {
    'theme': true,
    'header': true,
    'footer': true,
    'appLink': true,
    'links': true,
  };

  void _goToEdit() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const HomeEditPage()));

  String _fmtDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        HomePageModel? data;
        if (state is HomeCmsLoaded) data = state.data;
        if (state is HomeCmsSaved)  data = state.data;

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000.w),
                child: Column(
                  children: [
                    AppAdminNavbar(
                      activeLabel: 'Web Page',
                      homePage: HomeMainPage(),
                      webPage: HomeMainPage(),
                      jobListingPage: HomeMainPage(),
                    ),
                    SizedBox(height: 20.h),
                    AdminSubNavBar(activeIndex: 0),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.w, vertical: 20.h),
                      child: SizedBox(
                        width: 1000.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Main',
                                  style: StyleText.fontSize45Weight600.copyWith(
                                    color: ColorPick.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const HomePreviewPage(
                                          showPublish: false),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color: ColorPick.primary,
                                      borderRadius:
                                          BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'Preview Screen',
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: ColorPick.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    data?.lastUpdatedAt != null
                                        ? 'Last Updated On ${_fmtDate(data!.lastUpdatedAt)}'
                                        : 'Last Updated On —',
                                    style: StyleText.fontSize13Weight500
                                        .copyWith(color: ColorPick.primary),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _goToEdit,
                                  child: Container(
                                    width: 130.w, height: 36.h,
                                    decoration: BoxDecoration(
                                      color: ColorPick.white,
                                      borderRadius:
                                          BorderRadius.circular(4.r),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Edit Details',
                                            style: StyleText
                                                .fontSize14Weight500
                                                .copyWith(
                                                    color: Colors.black),
                                          ),
                                          SizedBox(width: 6.w),
                                          CustomSvg(
                                            assetPath:
                                                'assets/control/edit_icon_pick.svg',
                                            width: 20.w, height: 20.h,
                                            fit: BoxFit.scaleDown,
                                            color: ColorPick.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            if (data != null) ...[
                              _accordion(
                                key: 'theme',
                                title: 'Theme and Logo',
                                children: [_readOnlyLogoSection(data)],
                              ),
                              SizedBox(height: 10.h),
                              _accordion(
                                key: 'header',
                                title: 'Header',
                                children: [_readOnlyHeaderSection(data)],
                              ),
                              SizedBox(height: 10.h),
                              _accordion(
                                key: 'footer',
                                title: 'Footer',
                                children: [_readOnlyFooterSection(data)],
                              ),
                              SizedBox(height: 10.h),
                              _accordion(
                                key: 'appLink',
                                title: 'App Link',
                                children: [_readOnlyAppLinkSection(data)],
                              ),
                              SizedBox(height: 10.h),
                              _accordion(
                                key: 'links',
                                title: 'Links',
                                children: [_readOnlyLinksSection(data)],
                              ),
                            ] else ...[
                              const Center(
                                child: CircularProgressIndicator(
                                    color: ColorPick.primary),
                              ),
                            ],
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
