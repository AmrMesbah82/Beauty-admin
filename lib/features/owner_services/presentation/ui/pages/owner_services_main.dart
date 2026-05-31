/// ******************* FILE INFO *******************
/// File Name: owner_services_main.dart
/// Description: Main (read-only) page for Owner Services CMS.
///              Shows: Header, Download Applications, Mockups sections
///              with Female/Male toggle, Last Updated timestamp,
///              Edit Owner View & Preview Screen buttons.
/// Created by: Amr Mesbah
/// Last Update: 15/04/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/owner_services_model.dart';
import '../../controller/owner_services_cubit.dart';
import '../../controller/owner_services_state.dart';
import 'owner_services_edit.dart';
import 'owner_services_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;


/// Custom Segmented Tabs Widget (reused from client services)

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

class OwnerServicesMainPage extends StatefulWidget {
  const OwnerServicesMainPage({super.key});

  @override
  State<OwnerServicesMainPage> createState() => _OwnerServicesMainPageState();
}

class _OwnerServicesMainPageState extends State<OwnerServicesMainPage> {
  String _gender = 'female';
  final List<String> _genderLabels = ['Female', 'Male'];

  // ── Accordion ─────────────────────────────────────────────────────────────
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
    context.read<OwnerServicesCmsCubit>().load(gender: _gender);
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OwnerServicesEditPage(),
      ),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OwnerServicesPreviewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      listener: (context, state) {
        if (state is OwnerServicesCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is OwnerServicesCmsInitial ||
            state is OwnerServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        final cubit = context.read<OwnerServicesCmsCubit>();
        final data = cubit.current;

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
                        AdminSubNavBar(activeIndex: 4),
                        SizedBox(width: 20.w),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title + Preview ─────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Owner Services Details',
                                      style: StyleText.fontSize45Weight600
                                          .copyWith(color: ColorPick.primary, fontWeight: FontWeight.w700)),
                                  GestureDetector(
                                    onTap: _navigateToPreview,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                          color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
                                      child: Text('Preview Screen',
                                          style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // ── Gender toggle + Last Updated + Edit ──
                              Row(
                                children: [
                                  CustomSegmentedTabs(
                                    tabs: const ['Female', 'Male'],
                                    selectedIndex: _gender == 'female' ? 0 : 1,
                                    onTabSelected: (index) {
                                      final g = index == 0 ? 'female' : 'male';
                                      setState(() => _gender = g);
                                      context
                                          .read<OwnerServicesCmsCubit>()
                                          .switchGender(g);
                                    },
                                    selectedColor: ColorPick.primary,
                                    unselectedColor: Colors.white,
                                    selectedTextColor: Colors.white,
                                    unselectedTextColor: AppColors.text,
                                    equalWidth: false,
                                    containerPadding: EdgeInsets.symmetric(
                                        horizontal: 8.sp, vertical: 4.sp),
                                    containerColor: Colors.white,
                                  ),
                                  const Spacer(),
                                  _lastUpdatedRow(
                                    onEdit: _navigateToEdit,
                                    lastUpdated: data.lastUpdated,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // ── Header section ───────────────────────
                              _headerSection(data),
                              SizedBox(height: 10.h),

                              // ── Download section ─────────────────────
                              _downloadSection(data),
                              SizedBox(height: 10.h),

                              // ── Mockups section ──────────────────────
                              _mockupsSection(data),
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

  // ── Last Updated Row Widget ────────────────────────────────────────────────
  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: ColorPick.white, borderRadius: BorderRadius.circular(4.r)),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: ColorPick.primary),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: ColorPick.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit Details',
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: Colors.black)),
                  SizedBox(width: 6.w),
                  CustomSvg(
                      assetPath: "assets/control/edit_icon_pick.svg",
                      width: 20.w,
                      height: 20.h,
                      fit: BoxFit.scaleDown,
                      color: ColorPick.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion wrapper ─────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text(title,
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _headerSection(OwnerServicesPageModel data) => _accordion(
    key: 'header',
    title: 'Header',
    children: [
      _readOnlyLabel('SVG'),
      SizedBox(height: 6.h),
      _readOnlyImageCircle(data.header.imageUrl),
      SizedBox(height: 14.h),
      _readOnlyBiRow('Title', 'العنوان', data.header.title.en,
          data.header.title.ar),
      SizedBox(height: 10.h),
      _readOnlyLabel('Description'),
      SizedBox(height: 6.h),
      _readOnlyBox(data.header.description.en, maxLines: 4),
      SizedBox(height: 8.h),
      Align(
          alignment: Alignment.centerRight,
          child: Text('الوصف',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.text))),
      SizedBox(height: 6.h),
      _readOnlyBox(data.header.description.ar,
          maxLines: 4, textDirection: ui.TextDirection.rtl),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _downloadSection(OwnerServicesPageModel data) => _accordion(
    key: 'download',
    title: 'Download Applications',
    children: [
      _readOnlyBiRow('Title', 'العنوان', data.download.title.en,
          data.download.title.ar),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apple Store Link',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.text)),
                SizedBox(height: 6.h),
                _readOnlyBox(data.download.appStoreLink),
              ],
            )),
        SizedBox(width: 16.w),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Android Link',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.text)),
                SizedBox(height: 6.h),
                _readOnlyBox(data.download.googlePlayLink),
              ],
            )),
      ]),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCKUPS SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _mockupsSection(OwnerServicesPageModel data) => _accordion(
    key: 'mockups',
    title: 'Mockups',
    children: [
      ...data.mockups.items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _readOnlyLabel('SVG'),
                const Spacer(),
                _alignmentChips(item.alignment),
              ]),
              SizedBox(height: 6.h),
              _readOnlyImageCircle(item.imageUrl),
              SizedBox(height: 10.h),
              _readOnlyBiRow('Title', 'العنوان', item.title.en,
                  item.title.ar),
              SizedBox(height: 8.h),
              _readOnlyLabel('Description'),
              SizedBox(height: 6.h),
              _readOnlyBox(item.description.en, maxLines: 4),
              SizedBox(height: 8.h),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text('الوصف',
                      style: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.text))),
              SizedBox(height: 6.h),
              _readOnlyBox(item.description.ar,
                  maxLines: 4, textDirection: ui.TextDirection.rtl),
              if (i < data.mockups.items.length - 1)
                Divider(height: 24.h, color: ColorPick.white),
            ],
          ),
        );
      }),
      if (data.mockups.items.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text('No mockups added yet.',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText)),
        ),
    ],
  );

  Widget _alignmentChips(String alignment) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (final a in ['left', 'centered', 'right'])
        Container(
          margin: EdgeInsets.only(left: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: a == alignment ? ColorPick.primary : Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
                color: a == alignment ? ColorPick.primary : ColorPick.white),
          ),
          child: Text(
            a[0].toUpperCase() + a.substring(1),
            style: StyleText.fontSize11Weight400.copyWith(
                color: a == alignment ? Colors.white : AppColors.text),
          ),
        ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED READ-ONLY HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _readOnlyLabel(String t) => Text(t,
      style:
      StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  Widget _readOnlyBox(String text,
      {int maxLines = 1,
        ui.TextDirection textDirection = ui.TextDirection.ltr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text.isEmpty ? 'Text Here' : text,
        textDirection: textDirection,
        style: StyleText.fontSize12Weight400.copyWith(
            color: text.isEmpty ? AppColors.secondaryText : AppColors.text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _readOnlyBiRow(
      String enLbl, String arLbl, String enVal, String arVal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(enLbl,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 6.h),
              _readOnlyBox(enVal),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(arLbl,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 6.h),
              _readOnlyBox(arVal, textDirection: ui.TextDirection.rtl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readOnlyImageCircle(String url) {
    if (url.isNotEmpty) {
      final viewId = 'svg-client-svc-main-${url.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: SizedBox(
            width: 70.w,
            height: 70.h,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      );
    }
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomSvg(
          assetPath: 'assets/home_control/image.svg',
          width: 20.w,
          height: 20.h,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
