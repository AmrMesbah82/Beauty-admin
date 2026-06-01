// ******************* FILE INFO *******************
/// File Name: overview_main.dart
/// Description: Main read-only view for Master CMS (Overview-style).

import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widgets/circle_progress.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/overview_model.dart';
import '../../controller/overview_cubit.dart';
import '../../controller/overview_state.dart';
import 'overview_edit.dart';
import 'overview_preview.dart';

part '../widgets/overview_main/c.dart';
part '../widgets/overview_main/sections.dart';

class OverviewMainPage extends StatefulWidget {
  const OverviewMainPage({super.key});

  @override
  State<OverviewMainPage> createState() => _OverviewMainPageState();
}

class _OverviewMainPageState extends State<OverviewMainPage> {
  int _statusTab = 0;
  String _gender = 'female';
  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  final Map<String, bool> _open = {
    'headings': true,
    'services': true,
    'gallery': true,
    'comments': true,
    'download': true,
  };

  @override
  void initState() {
    super.initState();
    context.read<OverviewCmsCubit>().load(gender: _gender);
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OverviewEditPage()),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OverviewPreviewPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewCmsCubit, OverviewCmsState>(
      listener: (context, state) {
        if (state is OverviewCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        OverviewPageModel? model;
        if (state is OverviewCmsLoaded) model = state.data;
        if (state is OverviewCmsSaved) model = state.data;
        model ??= context.read<OverviewCmsCubit>().current;

        return Scaffold(
          backgroundColor: ColorPick.background,
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
                        AdminSubNavBar(activeIndex: 2),
                        SizedBox(width: 20.w),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Overview',
                                      style: StyleText.fontSize45Weight600.copyWith(
                                          color: ColorPick.primary,
                                          fontWeight: FontWeight.w700)),
                                  GestureDetector(
                                    onTap: _navigateToPreview,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                          color: ColorPick.primary,
                                          borderRadius: BorderRadius.circular(6.r)),
                                      child: Text('Preview Screen',
                                          style: StyleText.fontSize12Weight500
                                              .copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              CustomSegmentedTabs(
                                tabs: _statusLabels,
                                selectedIndex: _statusTab,
                                onTabSelected: (index) =>
                                    setState(() => _statusTab = index),
                                selectedColor: ColorPick.primary,
                                unselectedColor: ColorPick.white,
                                selectedTextColor: Colors.white,
                                unselectedTextColor: ColorPick.discard,
                                containerColor: Colors.white,
                                equalWidth: false,
                                spacing: 24,
                                tabHorizontalPadding: 10,
                                tabVerticalPadding: 8,
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  CustomSegmentedTabs(
                                    tabs: const ['Female', 'Male'],
                                    selectedIndex: _gender == 'female' ? 0 : 1,
                                    onTabSelected: (index) {
                                      final g = index == 0 ? 'female' : 'male';
                                      setState(() => _gender = g);
                                      context.read<OverviewCmsCubit>().switchGender(g);
                                    },
                                    selectedColor: ColorPick.primary,
                                    unselectedColor: Colors.white,
                                    selectedTextColor: Colors.white,
                                    unselectedTextColor: AppColors.secondaryText,
                                    equalWidth: false,
                                    containerPadding: EdgeInsets.symmetric(
                                        horizontal: 4.sp, vertical: 4.sp),
                                    containerColor: Colors.white,
                                  ),
                                  const Spacer(),
                                  _lastUpdatedRow(
                                    onEdit: _navigateToEdit,
                                    lastUpdated: model?.lastUpdated,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              if (model != null) ...[
                                _headingsSection(model),
                                SizedBox(height: 10.h),
                                _servicesSection(model),
                                SizedBox(height: 10.h),
                                _gallerySection(model),
                                SizedBox(height: 10.h),
                                _clientCommentsSection(model),
                                SizedBox(height: 10.h),
                                _downloadSection(model),
                              ],
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
}
