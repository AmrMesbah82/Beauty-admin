// ******************* FILE INFO *******************
/// File Name: overview_main.dart
/// Description: Main read-only view for Master CMS (Overview-style).
///              Sections: Headings, Services, Gallery, Client Comments,
///              Download Applications.
///              Published/Scheduled/Draft tabs, Female/Male toggle,
///              "Edit Overview" link.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/overview_model.dart';
import '../../controller/overview_cubit.dart';
import '../../controller/overview_state.dart';
import 'overview_edit.dart';  // Your edit page
import 'overview_preview.dart';  // Your preview page
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;


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
              : (unselectedColor ?? AppColors.secondaryText),
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

class OverviewMainPage extends StatefulWidget {
  const OverviewMainPage({super.key});

  @override
  State<OverviewMainPage> createState() => _OverviewMainPageState();
}

class _OverviewMainPageState extends State<OverviewMainPage> {
  int _statusTab = 0; // 0=Published, 1=Scheduled, 2=Draft
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

  String _fmtDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Navigation methods using Navigator.push with MaterialPageRoute
  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OverviewEditPage(),
      ),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OverviewPreviewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewCmsCubit, OverviewCmsState>(
      listener: (context, state) {
        if (state is OverviewCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
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
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title + Preview ───────────────────────
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Overview',
                                      style: StyleText.fontSize45Weight600
                                          .copyWith(
                                          color: ColorPick.primary,
                                          fontWeight: FontWeight.w700)),
                                  GestureDetector(
                                    onTap: _navigateToPreview,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                          color: ColorPick.primary,
                                          borderRadius:
                                          BorderRadius.circular(6.r)),
                                      child: Text('Preview Screen',
                                          style: StyleText.fontSize12Weight500
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // ── Status tabs (CustomSegmentedTabs) ─────
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
                                          .read<OverviewCmsCubit>()
                                          .switchGender(g);
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
                                    lastUpdated: model.lastUpdated,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // ── Sections ─────────────────────────────
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

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _open[key] = !isOpen),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: ColorPick.primary,
            borderRadius: BorderRadius.circular(8.r),
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
              bottomRight: Radius.circular(6.r),
            ),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
    ]);
  }

  // ── Headings section ───────────────────────────────────────────────────────
  Widget _headingsSection(OverviewPageModel m) => _accordion(
    key: 'headings',
    title: 'Headings',
    children: [
      _readOnlyBiRow(
          'Title', 'العنوان', m.headings.title.en, m.headings.title.ar),
      SizedBox(height: 10.h),
      _readOnlyLabel('Description'),
      SizedBox(height: 6.h),
      _readOnlyBox(m.headings.description.en, maxLines: 4),
      SizedBox(height: 8.h),
      Align(
          alignment: Alignment.centerRight,
          child: Text('الوصف',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.text))),
      SizedBox(height: 6.h),
      _readOnlyBox(m.headings.description.ar,
          maxLines: 4, textDirection: ui.TextDirection.rtl),
    ],
  );

  // ── Services section ───────────────────────────────────────────────────────
  Widget _servicesSection(OverviewPageModel m) => _accordion(
    key: 'services',
    title: 'Services',
    children: [
      _readOnlyBiRow(
          'Title', 'العنوان', m.services.title.en, m.services.title.ar),
      SizedBox(height: 10.h),
      ...m.services.items.map((item) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              _readOnlyLabel('Image'),
              SizedBox(height: 6.h),
              _readOnlyImageCircle(item.imageUrl),
              SizedBox(height: 10.h),
              _readOnlyBiRow('Service Name', 'اسم الخدمة',
                  item.name.en, item.name.ar),
            ]),
      )),
    ],
  );

  // ── Gallery section ────────────────────────────────────────────────────────
  Widget _gallerySection(OverviewPageModel m) => _accordion(
    key: 'gallery',
    title: 'Gallery',
    children: [
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: m.gallery.images.map((img) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _readOnlyLabel('Image'),
                SizedBox(height: 4.h),
                _readOnlyImageCircle(img.imageUrl),
              ]);
        }).toList(),
      ),
    ],
  );

  // ── Client Comments section ────────────────────────────────────────────────
  Widget _clientCommentsSection(OverviewPageModel m) => _accordion(
    key: 'comments',
    title: 'Client Comments',
    children: [
      _readOnlyBiRow('Title', 'العنوان', m.clientComments.title.en,
          m.clientComments.title.ar),
      SizedBox(height: 10.h),
      ...m.clientComments.comments.map((c) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _readOnlyImageCircle(c.imageUrl),
              SizedBox(height: 10.h),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('First Name',
                              style: StyleText.fontSize14Weight400
                                  .copyWith(color: AppColors.text)),
                          SizedBox(height: 6.h),
                          _readOnlyBox(c.firstName.en),
                        ])),
                SizedBox(width: 16.w),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('Last Name',
                              style: StyleText.fontSize14Weight400
                                  .copyWith(color: AppColors.text)),
                          SizedBox(height: 6.h),
                          _readOnlyBox(c.lastName.en),
                        ])),
              ]),
              SizedBox(height: 8.h),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text('اسم العائلة',
                              style: StyleText.fontSize14Weight400
                                  .copyWith(color: AppColors.text)),
                          SizedBox(height: 6.h),
                          _readOnlyBox(c.lastName.ar,
                              textDirection: ui.TextDirection.rtl),
                        ])),
                SizedBox(width: 16.w),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text('الاسم الأول',
                              style: StyleText.fontSize14Weight400
                                  .copyWith(color: AppColors.text)),
                          SizedBox(height: 6.h),
                          _readOnlyBox(c.firstName.ar,
                              textDirection: ui.TextDirection.rtl),
                        ])),
              ]),
              SizedBox(height: 8.h),
              _readOnlyLabel('Feedback'),
              SizedBox(height: 6.h),
              _readOnlyBox(c.feedback.en, maxLines: 4),
              SizedBox(height: 8.h),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text('ملاحظات',
                      style: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.text))),
              SizedBox(height: 6.h),
              _readOnlyBox(c.feedback.ar,
                  maxLines: 4, textDirection: ui.TextDirection.rtl),
            ]),
      )),
    ],
  );

  // ── Download section ───────────────────────────────────────────────────────
  Widget _downloadSection(OverviewPageModel m) => _accordion(
    key: 'download',
    title: 'Download Applications',
    children: [
      _readOnlyBiRow(
          'Title', 'العنوان', m.download.title.en, m.download.title.ar),
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
                  _readOnlyBox(m.download.appStoreLink),
                ])),
        SizedBox(width: 16.w),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Android Link',
                      style: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.text)),
                  SizedBox(height: 6.h),
                  _readOnlyBox(m.download.googlePlayLink),
                ])),
      ]),
    ],
  );

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _readOnlyLabel(String text) => Text(text,
      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  Widget _readOnlyBiRow(
      String enLabel, String arLabel, String enVal, String arVal) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(enLabel,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.text)),
                SizedBox(height: 6.h),
                _readOnlyBox(enVal),
              ])),
      SizedBox(width: 16.w),
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(arLabel,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.text)),
                SizedBox(height: 6.h),
                _readOnlyBox(arVal, textDirection: ui.TextDirection.rtl),
              ])),
    ]);
  }

  Widget _readOnlyBox(String text,
      {int maxLines = 1,
        ui.TextDirection textDirection = ui.TextDirection.ltr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
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

  Widget _readOnlyImageCircle(String url) {
    if (url.isNotEmpty) {
      final viewId = 'svg-overview-main-${url.hashCode}';

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
