/// ******************* FILE INFO *******************
/// File Name: admin_sub_navbar.dart
/// Purpose: Shared sub-navbar used across ALL admin CMS pages.
///          Fix navigation in ONE place — no duplication.
///
/// Usage:
///   // Pages that HAVE HomeCmsCubit in their BlocProvider tree
///   // (home_main_page.dart, home_main_page_master.dart):
///   AdminSubNavBar(
///     activeIndex: 0,
///     homeCubit: context.read<HomeCmsCubit>(),
///   )
///
///   // Pages that do NOT have HomeCmsCubit
///   // (about, contact, careers pages):
///   AdminSubNavBar(activeIndex: 3)
///   // → tapping "Home" from these pages goes to /admin/dashboard first,
///   //   from which the "Home" tab works correctly.
///
/// Index map:
///   0 = Main (Dashboard)
///   1 = Home (Master CMS)
///   2 = Overview (Services)
///   3 = Client Services (Our Products)
///   4 = About Us
///   5 = Contact Us

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../controller/home/home_cubit.dart';
import '../dashboard/master_page/master_main_page.dart';
import '../dashboard/overview/overview_main_page.dart';
import '../dashboard/client_services/client_services_main_page.dart';
import '../theme/new_theme.dart';

class AdminSubNavBar extends StatelessWidget {
  final int activeIndex;
  final HomeCmsCubit? homeCubit;

  const AdminSubNavBar({
    super.key,
    required this.activeIndex,
    this.homeCubit,
  });

  static const Color _primary   = Color(0xFFD16F9A);
  static const Color _cardBg    = Color(0xFFFFFFFF);
  static const Color _labelText = Color(0xFF333333);

  static const List<String> _labels = [
    'Main', 'Home', 'Overview', 'Client Services', 'About Us', 'Contact Us',
  ];

  void _onTap(BuildContext context, int i) {
    if (i == activeIndex) return;

    if (i == 1) {
      // Navigate to Master CMS page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MasterMainPage()),
      );
    } else if (i == 2) {
      // Navigate to Overview page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OverviewMainPage()),
      );
    } else if (i == 3) {
      // Navigate to Client Services page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClientServicesMainPage()),
      );
    } else {
      switch (i) {
        case 0:
          context.go('/admin/dashboard');
          break;
        case 4:
          context.go('/admin/about-cms');
          break;
        case 5:
          context.go('/admin/contact-cms');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000.w,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_labels.length, (i) {
          final active = activeIndex == i;
          return GestureDetector(
            onTap: () => _onTap(context, i),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              child: Container(
                margin: EdgeInsets.only(right: 4.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: active ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _labels[i],
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: active ? Colors.white : _labelText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}