/// ******************* FILE INFO *******************
/// File Name: master_main_page.dart
/// Description: Main listing / read-only view for the Master CMS page.
///              Shows Published / Scheduled / Draft tabs, Female / Male toggle,
///              and read-only sections (Header, About Us, Footer) with
///              "Edit Home View" link.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../controller/master/master_cubit.dart';
import '../../controller/master/master_state.dart';
import '../../model/master/master_model.dart';
import 'master_edit_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color tabActive = Color(0xFFD16F9A);
  static const Color tabInactive = Color(0xFF999999);
}

class MasterMainPage extends StatefulWidget {
  const MasterMainPage({super.key});

  @override
  State<MasterMainPage> createState() => _MasterMainPageState();
}

class _MasterMainPageState extends State<MasterMainPage> {
  int _statusTab = 0; // 0=Published, 1=Scheduled, 2=Draft
  String _gender = 'female';

  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  @override
  void initState() {
    super.initState();
    context.read<MasterCmsCubit>().load(gender: _gender);
  }

  // ── Accordion open/close ──────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'header': true,
    'aboutUs': true,
    'footer': true,
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterCmsCubit, MasterCmsState>(
      listener: (context, state) {
        if (state is MasterCmsError) {
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
        if (state is MasterCmsInitial || state is MasterCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        MasterPageModel? model;
        if (state is MasterCmsLoaded) model = state.data;
        if (state is MasterCmsSaved) model = state.data;

        return Scaffold(
          backgroundColor: _C.back,
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
                        SizedBox(width: 20.w),
                        AdminSubNavBar(activeIndex: 1),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title row ─────────────────────────────
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Home',
                                    style: StyleText.fontSize45Weight600
                                        .copyWith(
                                      color: _C.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context
                                        .pushNamed('master_preview'),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: _C.primary,
                                        borderRadius:
                                        BorderRadius.circular(6.r),
                                      ),
                                      child: Text('Preview Screen',
                                          style: StyleText.fontSize12Weight500
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // ── Status tabs ──────────────────────────
                              Row(
                                children: List.generate(3, (i) {
                                  final isActive = _statusTab == i;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _statusTab = i),
                                    child: Padding(
                                      padding:
                                      EdgeInsets.only(right: 24.w),
                                      child: Text(
                                        _statusLabels[i],
                                        style: StyleText.fontSize16Weight600
                                            .copyWith(
                                          color: isActive
                                              ? _C.tabActive
                                              : _C.tabInactive,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: 12.h),

                              // ── Gender toggle + Last Updated + Edit ──
                              Row(
                                children: [
                                  _genderChip('Female', 'female'),
                                  SizedBox(width: 8.w),
                                  _genderChip('Male', 'male'),
                                  const Spacer(),
                                  if (model?.lastUpdated != null)
                                    Text(
                                      'Last Updated On ${DateFormat('dd MMM yyyy').format(model!.lastUpdated!)}',
                                      style: StyleText.fontSize12Weight400
                                          .copyWith(color: _C.tabActive),
                                    ),
                                  SizedBox(width: 16.w),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MasterEditPage()), // Adjust widget name
                                    ),
                                    child: Row(
                                      children: [
                                        Text('Edit Home View',
                                            style: StyleText
                                                .fontSize12Weight500
                                                .copyWith(
                                                color: _C.labelText)),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.edit_outlined,
                                            size: 14.sp,
                                            color: _C.labelText),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // ── Sections ─────────────────────────────
                              if (model != null) ...[
                                _buildReadOnlySection(
                                  key: 'header',
                                  title: 'Header Section',
                                  section: model.sectionByKey('header'),
                                  showTitle: true,
                                  showShortDesc: true,
                                  mainTitle: model.title,
                                  mainShortDesc: model.shortDescription,
                                ),
                                SizedBox(height: 10.h),
                                _buildReadOnlySection(
                                  key: 'aboutUs',
                                  title: 'About Us',
                                  section: model.sectionByKey('aboutUs'),
                                  showTitle: true,
                                  showDescription: true,
                                ),
                                SizedBox(height: 10.h),
                                _buildReadOnlySection(
                                  key: 'footer',
                                  title: 'Footer Section',
                                  section: model.sectionByKey('footer'),
                                  showTitle: true,
                                  showDescription: true,
                                ),
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

  // ── Gender chip ────────────────────────────────────────────────────────────
  Widget _genderChip(String label, String value) {
    final isActive = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() => _gender = value);
        context.read<MasterCmsCubit>().switchGender(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? _C.primary : Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: isActive ? _C.primary : _C.border),
        ),
        child: Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: isActive ? Colors.white : _C.labelText,
          ),
        ),
      ),
    );
  }

  // ── Read-only section accordion ────────────────────────────────────────────
  Widget _buildReadOnlySection({
    required String key,
    required String title,
    MasterSectionModel? section,
    BiText? mainTitle,
    BiText? mainShortDesc,
    bool showTitle = false,
    bool showShortDesc = false,
    bool showDescription = false,
  }) {
    final isOpen = _open[key] ?? true;

    // Use mainTitle/mainShortDesc for header section, section fields otherwise
    final displayTitle = mainTitle ?? section?.title ?? const BiText();
    final displayShortDesc =
        mainShortDesc ?? section?.shortDescription ?? const BiText();
    final displayDesc = section?.description ?? const BiText();
    final imageUrl = section?.imageUrl ?? '';

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Accordion header ─────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
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
                          .copyWith(color: Colors.white)),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ]),
            ),
          ),

          // ── Accordion body ───────────────────────────────────────────
          if (isOpen)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _C.cardBg,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image ─────────────────────────────────────────────
                  _readOnlyLabel('Image'),
                  SizedBox(height: 6.h),
                  _readOnlyImageCircle(imageUrl),
                  SizedBox(height: 14.h),

                  // ── Title EN / AR ─────────────────────────────────────
                  if (showTitle) ...[
                    _readOnlyBiRow('Title', 'العنوان',
                        displayTitle.en, displayTitle.ar),
                    SizedBox(height: 10.h),
                  ],

                  // ── Short Description ─────────────────────────────────
                  if (showShortDesc) ...[
                    _readOnlyLabel('Short Description'),
                    SizedBox(height: 6.h),
                    _readOnlyBox(displayShortDesc.en),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('وصف مختصر',
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text)),
                    ),
                    SizedBox(height: 6.h),
                    _readOnlyBox(displayShortDesc.ar,
                        textDirection: ui.TextDirection.rtl),
                  ],

                  // ── Description ───────────────────────────────────────
                  if (showDescription) ...[
                    _readOnlyLabel('Description'),
                    SizedBox(height: 6.h),
                    _readOnlyBox(displayDesc.en, maxLines: 5),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('الوصف',
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text)),
                    ),
                    SizedBox(height: 6.h),
                    _readOnlyBox(displayDesc.ar,
                        maxLines: 5,
                        textDirection: ui.TextDirection.rtl),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _readOnlyLabel(String text) => Text(text,
      style:
      StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _readOnlyBiRow(
      String enLabel, String arLabel, String enVal, String arVal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(enLabel,
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
              Text(arLabel,
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

  Widget _readOnlyBox(String text,
      {int maxLines = 1,
        ui.TextDirection textDirection = ui.TextDirection.ltr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      constraints:
      maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text.isEmpty ? 'Text Here' : text,
        textDirection: textDirection,
        style: StyleText.fontSize12Weight400.copyWith(
          color: text.isEmpty ? _C.hintText : _C.labelText,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _readOnlyImageCircle(String url) {
    if (url.isNotEmpty) {
      return Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                url,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: const BoxDecoration(
          color: Color(0xFFD9D9D9), shape: BoxShape.circle),
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