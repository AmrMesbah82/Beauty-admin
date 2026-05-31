// ******************* FILE INFO *******************
// File Name: admin_sub_navbar.dart
// Description: Admin sub-navigation bar widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets

import 'package:beauty_admin/core/constants/color.dart';
import 'package:beauty_admin/features/request/presentation/controller/request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';



import '../../features/about_us/presentation/controller/about_us_cubit.dart';
import '../../features/about_us/presentation/ui/pages/about_us_main.dart';
import '../../features/client_services/presentation/ui/pages/client_services_main.dart';
import '../../features/contact_us/presentation/controller/contact_us_location_cubit.dart';
import '../../features/contact_us/presentation/ui/pages/contact_us_main.dart';
import 'package:beauty_admin/features/request/presentation/controller/request_cubit.dart';
import '../../features/request/data/repository/request_repo_imp.dart';
import '../../features/request/domain/base_repository/request_repo.dart';
import '../../features/request/presentation/ui/pages/request_main.dart';

import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/master/presentation/ui/pages/master_main.dart';
import '../../features/overview/presentation/ui/pages/overview_main.dart';
import '../../features/owner_services/presentation/ui/pages/owner_services_main.dart';
import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FadeRoute — smooth fade transition between pages
// ─────────────────────────────────────────────────────────────────────────────

class _FadeRoute extends PageRouteBuilder {
  final Widget page;

  _FadeRoute({required this.page})
      : super(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

class AdminSubNavBar extends StatelessWidget {
  final int activeIndex;
  final HomeCmsCubit? homeCubit;

  const AdminSubNavBar({
    super.key,
    required this.activeIndex,
    this.homeCubit,
  });



  static const List<String> _labels = [
    'Main', 'Home', 'Overview', 'Client Services', 'Owner Services', 'About Us', 'Contact Us', 'Demo',
  ];

  void _onTap(BuildContext context, int i) {
    if (i == activeIndex) return;

    switch (i) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        Navigator.push(context, _FadeRoute(page: const MasterMainPage()));
        break;
      case 2:
        Navigator.push(context, _FadeRoute(page: const OverviewMainPage()));
        break;
      case 3:
        Navigator.push(context, _FadeRoute(page: const ClientServicesMainPage()));
        break;
      case 4:
        Navigator.push(context, _FadeRoute(page: const OwnerServicesMainPage()));
        break;
      case 5:
        Navigator.push(
          context,
          _FadeRoute(
            page: BlocProvider(
              create: (_) => AboutCubit()..load(),
              child: const AboutMainPageMasterDashboard(),
            ),
          ),
        );
        break;
      case 6:
        Navigator.push(
          context,
          _FadeRoute(
            page: BlocProvider(
              create: (_) => ContactUsCmsCubit()..load(),
              child: const ContactUsMainPage(),
            ),
          ),
        );
        break;
      case 7:
        Navigator.push(
          context,
          _FadeRoute(
            page: BlocProvider(
              create: (_) => RequestDemoCmsCubit(RequestDemoRepoImp())..load(gender: 'female'),
              child: const RequestDemoMainPage(),
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000.w,
      decoration: BoxDecoration(
        color: ColorPick.white,
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
                  color: active ? ColorPick.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _labels[i],
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: active ? Colors.white : AppColors.text,
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