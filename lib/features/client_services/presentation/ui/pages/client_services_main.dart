/// ******************* FILE INFO *******************
/// File Name: client_services_main.dart
/// Description: Main read-only view for Client Services CMS.
///              Sections: Header, Download Applications, Mockups.
///              Published/Scheduled/Draft tabs, Female/Male toggle.
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import 'dart:ui' as ui;
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
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/client_services_model.dart';
import '../../controller/client_services_cubit.dart';
import '../../controller/client_services_state.dart';
import 'client_services_edit.dart';
import 'client_services_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widgets/client_services_main/c.dart';
part '../widgets/client_services_main/sections.dart';

/// Custom Segmented Tabs Widget (reused from master_main_page)

class CustomSegmentedTabs extends StatelessWidget {
  const CustomSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.containerPadding,
    this.containerColor,
    this.borderRadius,
    this.spacing,
    this.tabHorizontalPadding,
    this.tabVerticalPadding,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.textStyle,
    this.equalWidth = false,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final EdgeInsets? containerPadding;
  final Color? containerColor;
  final double? borderRadius;
  final double? spacing;
  final double? tabHorizontalPadding;
  final double? tabVerticalPadding;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final TextStyle? textStyle;
  final bool equalWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        color: containerColor ?? ColorPick.white,
      ),
      padding: containerPadding ?? EdgeInsets.all(8.sp),
      child: Row(
        mainAxisSize: equalWidth ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(tabs.length * 2 - 1, (index) {
          if (index.isOdd) {
            return SizedBox(width: spacing ?? 10.sp);
          }

          final tabIndex = index ~/ 2;
          final isSelected = tabIndex == selectedIndex;

          return equalWidth
              ? Expanded(
                  child: _buildTab(
                    title: tabs[tabIndex],
                    isSelected: isSelected,
                    onTap: () => onTabSelected(tabIndex),
                  ),
                )
              : _buildTab(
                  title: tabs[tabIndex],
                  isSelected: isSelected,
                  onTap: () => onTabSelected(tabIndex),
                );
        }),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: isSelected
              ? (selectedColor ?? ColorPick.primary)
              : (unselectedColor ?? ColorPick.white),
        ),
        padding: EdgeInsets.symmetric(
          vertical: tabVerticalPadding ?? 6.sp,
          horizontal: tabHorizontalPadding ?? 6.sp,
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              title,
              style: (textStyle ?? StyleText.fontSize14Weight500).copyWith(
                height: 1,
                color: isSelected
                    ? (selectedTextColor ?? Colors.white)
                    : (unselectedTextColor ?? AppColors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClientServicesMainPage extends StatefulWidget {
  const ClientServicesMainPage({super.key});

  @override
  State<ClientServicesMainPage> createState() => _ClientServicesMainPageState();
}

class _ClientServicesMainPageState extends State<ClientServicesMainPage> {
  int _statusTab = 0;
  String _gender = 'female';
  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  final Map<String, bool> _open = {
    'header': true,
    'download': true,
    'mockups': true,
  };

  String _fmtDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    context.read<ClientServicesCmsCubit>().load(gender: _gender);
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClientServicesEditPage()),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientServicesPreviewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientServicesCmsCubit, ClientServicesCmsState>(
      listener: (context, state) {
        if (state is ClientServicesCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ClientServicesCmsInitial ||
            state is ClientServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child:
                    CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        ClientServicesPageModel? model;
        if (state is ClientServicesCmsLoaded) model = state.data;
        if (state is ClientServicesCmsSaved) model = state.data;
        model ??= context.read<ClientServicesCmsCubit>().current;

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
                        AdminSubNavBar(activeIndex: 3),
                        SizedBox(width: 20.w),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title + Preview ──────────────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Client Services Details',
                                    style: StyleText.fontSize45Weight600
                                        .copyWith(
                                      color: ColorPick.primary,
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
                                        color: ColorPick.primary,
                                        borderRadius:
                                            BorderRadius.circular(6.r),
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

                              // ── Status tabs ──────────────────────────────
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

                              // ── Gender toggle + Last Updated + Edit ──────
                              Row(
                                children: [
                                  CustomSegmentedTabs(
                                    tabs: const ['Female', 'Male'],
                                    selectedIndex:
                                        _gender == 'female' ? 0 : 1,
                                    onTabSelected: (index) {
                                      final g =
                                          index == 0 ? 'female' : 'male';
                                      setState(() => _gender = g);
                                      context
                                          .read<ClientServicesCmsCubit>()
                                          .switchGender(g);
                                    },
                                    selectedColor: ColorPick.primary,
                                    unselectedColor: Colors.white,
                                    selectedTextColor: Colors.white,
                                    unselectedTextColor: AppColors.text,
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
                                    lastUpdated: model.lastUpdated,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              _headerSection(model),
                              SizedBox(height: 10.h),
                              _downloadSection(model),
                              SizedBox(height: 10.h),
                              _mockupsSection(model),
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
