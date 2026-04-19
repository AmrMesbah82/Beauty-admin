import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../controller/about_us/about_us_cubit.dart';
import '../controller/contact_us/contacu_us_location_cubit.dart';
import '../controller/home/home_cubit.dart';
import '../dashboard/about_page/about_main_page_master.dart';
import '../dashboard/contact_page/contact_us_main_page.dart';
import '../dashboard/master_page/master_main_page.dart';
import '../dashboard/overview/overview_main_page.dart';
import '../dashboard/client_services/client_services_main_page.dart';
import '../dashboard/owner_services/owner_services_main_page.dart';
import '../dashboard/request/request_demo_main_page.dart';

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
    'Main', 'Home', 'Overview', 'Client Services', 'Owner Services', 'About Us', 'Contact Us', 'Demo',
  ];

  void _onTap(BuildContext context, int i) {
    if (i == activeIndex) return;

    switch (i) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MasterMainPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OverviewMainPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClientServicesMainPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OwnerServicesMainPage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BlocProvider(
                  create: (_) => AboutCubit()..load(),
                  child: const AboutMainPageMasterDashboard(),
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        );
        break;
      case 6:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BlocProvider(
                  create: (_) => ContactUsCmsCubit()..load(),
                  child: const ContactUsMainPage(),
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestDemoMainPage()),
        );
        break;
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