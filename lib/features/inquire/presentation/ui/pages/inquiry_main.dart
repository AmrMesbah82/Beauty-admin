// ******************* FILE INFO *******************
// File Name: inquiry_main.dart
// Description: Inquiry main page
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › pages

// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_main.dart
// ═══════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:beauty_admin/core/widgets/custom_dropdown.dart';
import 'package:beauty_admin/core/widgets/button.dart';
import 'package:beauty_admin/core/widgets/search.dart';
import 'package:beauty_admin/core/widgets/textfield.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_segment_tab.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/inquire_model.dart';
import '../../controller/inquiry_cubit.dart';
import '../../controller/inquiry_state.dart';
import 'inquiry_details.dart';
import 'package:beauty_admin/core/constants/color.dart';

part '../widgets/inquiry_main/c.dart';
part '../widgets/inquiry_main/pie_painter.dart';
part '../widgets/inquiry_main/donut_painter.dart';
part '../widgets/inquiry_main/logic_helpers.dart';
part '../widgets/inquiry_main/table_helpers.dart';
part '../widgets/inquiry_main/charts.dart';

class InquiryMainPage extends StatefulWidget {
  const InquiryMainPage({super.key});
  @override State<InquiryMainPage> createState() => _InquiryMainPageState();
}

class _InquiryMainPageState extends State<InquiryMainPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<InquiryCubit>();
    cubit.loadInquiries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.setUserTypeFilter('Client');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InquiryCubit, InquiryState>(
      listener: (context, state) {
        if (state is InquiryUpdated) context.read<InquiryCubit>().loadInquiries();
      },
      child: BlocBuilder<InquiryCubit, InquiryState>(
        builder: (context, state) {
          if (state is InquiryInitial || state is InquiryLoading) {
            return const Scaffold(
              backgroundColor: ColorPick.background,
              body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
            );
          }

          final cubit = context.read<InquiryCubit>();
          List<InquiryModel> inquiries = [];
          int totalCount = 0, newCount = 0, repliedCount = 0, closedCount = 0;
          Map<int, int>    monthlySubmissions   = {};
          Map<String, int> reasonCounts         = {};
          Map<String, int> languageCounts       = {};
          Map<String, int> genderCounts         = {};
          Map<String, int> locationCounts       = {};
          Map<String, int> priorityCounts       = {};
          Map<String, int> relevanceCounts      = {};
          Map<String, int> requiredActionCounts = {};
          String? activeStatus, activeUserType, activeGender, activeCountry;
          int? activeMonth;

          if (state is InquiryLoaded) {
            inquiries            = state.filtered;
            totalCount           = state.totalCount;
            newCount             = state.newCount;
            repliedCount         = state.repliedCount;
            closedCount          = state.closedCount;
            monthlySubmissions   = state.monthlySubmissions;
            reasonCounts         = state.reasonCounts;
            languageCounts       = state.languageCounts;
            genderCounts         = state.genderCounts;
            locationCounts       = state.locationCounts;
            priorityCounts       = state.priorityCounts;
            relevanceCounts      = state.relevanceCounts;
            requiredActionCounts = state.requiredActionCounts;
            activeStatus         = state.statusFilter;
            activeUserType       = state.userTypeFilter;
            activeGender         = state.genderFilter;
            activeCountry        = state.countryFilter;
            activeMonth          = state.monthFilter;
          }
          if (state is InquiryError && state.lastInquiries != null) {
            inquiries = state.lastInquiries!;
          }

          final int segmentIndex = _userTypeToIndex(activeUserType);

          return Scaffold(
            backgroundColor: ColorPick.background,
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1000.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAdminNavbar(
                        activeLabel:    'Inquiries',
                        homePage:       HomeMainPage(),
                        webPage:        HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),
                      SizedBox(height: 20.h),
                      Text('Inquires',
                          style: StyleText.fontSize45Weight600.copyWith(
                              color: ColorPick.primary, fontWeight: FontWeight.w700)),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: 220.w,
                        height: 36.h,
                        child: CustomSegmentedTabs(
                          tabs: const ['Client', 'Owner'],
                          selectedIndex: segmentIndex,
                          onTabSelected: (index) {
                            final label = index == 0 ? 'Client' : 'Owner';
                            if (activeUserType == label) {
                              cubit.setUserTypeFilter(null);
                            } else {
                              cubit.setUserTypeFilter(label);
                            }
                          },
                          selectedColor:        ColorPick.primary,
                          unselectedColor:      Colors.transparent,
                          selectedTextColor:    Colors.white,
                          unselectedTextColor:  Colors.grey.shade500,
                          containerColor:       ColorPick.white,
                          equalWidth:           true,
                          spacing:              8.w,
                          tabHorizontalPadding: 16.w,
                          tabVerticalPadding:   8.h,
                          borderRadius:         8.r,
                          containerPadding:     EdgeInsets.all(3.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: AppSearchTextField(
                          controller: _searchController,
                          onChanged: cubit.setSearch,
                          hintText: 'Search',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _summaryRow(totalCount, newCount, repliedCount, closedCount),
                      SizedBox(height: 16.h),
                      _buildFiltersRow(
                        cubit: cubit,
                        activeStatus:  activeStatus,
                        activeGender:  activeGender,
                        activeCountry: activeCountry,
                        activeMonth:   activeMonth,
                        inquiries:     inquiries,
                      ),
                      SizedBox(height: 16.h),
                      _buildTable(inquiries, context),
                      SizedBox(height: 40.h),
                      Text('Dashboard',
                          style: StyleText.fontSize24Weight600.copyWith(
                              color: ColorPick.primary, fontWeight: FontWeight.w700)),
                      SizedBox(height: 16.h),
                      _chartRow(
                        left:  _chartCard('Submission Received', 'Total: $totalCount', _buildBarChart(monthlySubmissions)),
                        right: _chartCard('Reasons', '', _buildPieSection(reasonCounts, _pieColors(reasonCounts.length))),
                      ),
                      SizedBox(height: 16.h),
                      _chartRow(
                        left:  _chartCard('Language', '', _buildPieSection(languageCounts, _pieColors(languageCounts.length))),
                        right: _chartCard('Gender',   '', _buildPieSection(genderCounts,   _pieColors(genderCounts.length))),
                      ),
                      SizedBox(height: 16.h),
                      _chartRow(
                        left:  _chartCard('Location',         '', _buildLocationChart(locationCounts)),
                        right: _chartCard('Inquiry Priority', '', _buildDonutSection(priorityCounts, _priorityColors())),
                      ),
                      SizedBox(height: 16.h),
                      _chartRow(
                        left:  _chartCard('Inquiry Relevance', '', _buildDonutSection(relevanceCounts,      _relevanceColors())),
                        right: _chartCard('Required Action',   '', _buildDonutSection(requiredActionCounts, _actionColors())),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
