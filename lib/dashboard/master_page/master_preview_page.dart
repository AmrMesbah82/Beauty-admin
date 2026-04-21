/// ******************* FILE INFO *******************
/// File Name: master_preview_page.dart
/// Description: Preview page for the Master CMS module.
///              Accepts an optional [previewModel] so unsaved edits from the
///              edit page are reflected immediately without requiring a save.
///              Shows Desktop / Tablet / Mobile device frames,
///              EN / AR language toggle, and renders the Home View
///              inside an accordion with all sections.
///              Back + Publish buttons at bottom.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/master/master_cubit.dart';
import '../../controller/master/master_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/master/master_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';



class _C {
  static const Color primary    = Color(0xFFD16F9A);
  static const Color back       = Color(0xFFF1F2ED);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color sectionBg  = Color(0xFFF5F5F5);
  static const Color aboutBg    = Color(0xFFFFF0F5);
  static const Color downloadBg = Color(0xFFFCE4EC);
}

class MasterPreviewPage extends StatefulWidget {
  /// When provided, this model is used directly so that unsaved edits made
  /// on the edit page are visible in the preview without a save/publish step.
  /// Falls back to BLoC state when null.
  final MasterPageModel? previewModel;

  const MasterPreviewPage({super.key, this.previewModel});

  @override
  State<MasterPreviewPage> createState() => _MasterPreviewPageState();
}

class _MasterPreviewPageState extends State<MasterPreviewPage> {
  int  _deviceTab     = 0; // 0=Desktop, 1=Tablet, 2=Mobile
  bool _isEnglish     = true;
  bool _homeViewOpen  = true;

  final List<String> _deviceLabels = ['Desktop', 'Tablet', 'Mobile'];

  // Language tabs for CustomSegmentedTabs
  final List<String> _languageTabs = ['EN', 'AR'];

  // ── Resolve the model: prefer the draft passed from edit page ─────────────
  MasterPageModel? _resolveModel(
      BuildContext context, MasterCmsState state) {
    // Always prefer the explicitly passed draft (contains unsaved edits)
    if (widget.previewModel != null) return widget.previewModel;

    // Fallback: read from BLoC state
    if (state is MasterCmsLoaded) return state.data;
    if (state is MasterCmsSaved) return state.data;

    // Last resort: read from cubit.current
    return context.read<MasterCmsCubit>().current;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterCmsCubit, MasterCmsState>(
      builder: (context, state) {
        final model    = _resolveModel(context, state);
        final cubit    = context.read<MasterCmsCubit>();
        final isLoading =
            state is MasterCmsInitial || state is MasterCmsLoading;

        if (isLoading && model == null) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        // ── Device preview widths ─────────────────────────────────────────
        final double previewWidth = switch (_deviceTab) {
          1 => 700.w,
          2 => 380.w,
          _ => 1000.w,
        };

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel: 'Web Page',
                    homePage:       HomeMainPage(),
                    webPage:        HomeMainPage(),
                    jobListingPage: HomeMainPage(),
                  ),
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 1),

                  SizedBox(
                    width: 1000.w,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title ─────────────────────────────────────
                          Text(
                            'Preview Home Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Device tabs + EN/AR toggle ────────────────
                          Row(
                            children: [
                              ...List.generate(3, (i) {
                                final isActive = _deviceTab == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _deviceTab = i),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16.w),
                                    child: Text(
                                      _deviceLabels[i],
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                        color: isActive
                                            ? _C.primary
                                            : _C.hintText,
                                        decoration: isActive
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        decorationColor: _C.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const Spacer(),
                              // Replace old language chips with CustomSegmentedTabs
                              SizedBox(
                                width: 85.w,
                                height: 36.h,
                                child: CustomSegmentedTabs(
                                  containerColor: Colors.white,
                                  tabs: _languageTabs,
                                  selectedIndex: _isEnglish ? 0 : 1,
                                  onTabSelected: (index) {
                                    setState(() {
                                      _isEnglish = index == 0;
                                    });
                                  },
                                  selectedColor: _C.primary,
                                  unselectedColor: Colors.white,
                                  textStyle: StyleText.fontSize16Weight500,
                                  selectedTextColor: Colors.white,
                                  unselectedTextColor: _C.labelText,
                                  containerPadding: EdgeInsets.symmetric(horizontal: 8.sp,vertical: 4.sp),
                                  equalWidth: false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Home View accordion ───────────────────────
                          if (model != null)
                            _homeViewAccordion(model, previewWidth)
                          else
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.h),
                                child: Text(
                                  'No data available',
                                  style: StyleText.fontSize14Weight400
                                      .copyWith(color: _C.hintText),
                                ),
                              ),
                            ),

                          SizedBox(height: 24.h),

                          // ── Bottom buttons ────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _C.primary.withOpacity(0.5),
                                      borderRadius:
                                      BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: Text('Back',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showPublishConfirmDialog(
                                      context: context,
                                      onConfirm: () async {
                                        // ✅ Sync the draft back into the cubit before saving
                                        if (widget.previewModel != null) {
                                          cubit.loadModel(widget.previewModel!);
                                        }
                                        await cubit.save(publishStatus: 'published');
                                        Get.forceAppUpdate();
                                        html.window.location.reload();
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: _C.primary,
                                      borderRadius:
                                      BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: Text('Publish',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
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

  // ── Home View accordion ───────────────────────────────────────────────────
  Widget _homeViewAccordion(MasterPageModel model, double width) {
    return Center(
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            GestureDetector(
              onTap: () =>
                  setState(() => _homeViewOpen = !_homeViewOpen),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: _homeViewOpen
                      ? BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r))
                      : BorderRadius.circular(6.r),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text('Home View',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    _homeViewOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ]),
              ),
            ),
            if (_homeViewOpen)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(6.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _previewHeaderSection(model),
                    _previewAboutUsSection(model),
                    _previewFooterSection(model),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header section preview (with AR/EN support) ────────────────────────────────
  Widget _previewHeaderSection(MasterPageModel model) {
    final header = model.sectionByKey('header');

    // Get title based on selected language
    String titleText;
    if (_isEnglish) {
      titleText = (header?.title.en.isNotEmpty == true)
          ? header!.title.en
          : (model.title.en.isNotEmpty ? model.title.en : 'Beauty App');
    } else {
      titleText = (header?.title.ar.isNotEmpty == true)
          ? header!.title.ar
          : (model.title.ar.isNotEmpty ? model.title.ar : 'تطبيق بيوتي');
    }

    // Get description based on selected language
    String shortDescText;
    if (_isEnglish) {
      shortDescText = (header?.shortDescription.en.isNotEmpty == true)
          ? header!.shortDescription.en
          : (model.shortDescription.en.isNotEmpty
          ? model.shortDescription.en
          : 'Style & Simple Bright');
    } else {
      shortDescText = (header?.shortDescription.ar.isNotEmpty == true)
          ? header!.shortDescription.ar
          : (model.shortDescription.ar.isNotEmpty
          ? model.shortDescription.ar
          : 'أناقة وبساطة مشرقة');
    }

    final imageUrl = header?.imageUrl ?? '';
    final isVisible = header?.visibility ?? true;

    // Skip if not visible
    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Image ─────────────────────────────────────────────────
          _previewImageBox(imageUrl, 200.w, 200.h),
          SizedBox(width: 24.w),

          // ── Text ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: _isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText,
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize16Weight600
                      .copyWith(color: _C.labelText),
                ),
                SizedBox(height: 8.h),
                Text(
                  shortDescText,
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize24Weight600
                      .copyWith(color: _C.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── About Us preview (with AR/EN support) ──────────────────────────────────────
  Widget _previewAboutUsSection(MasterPageModel model) {
    final about = model.sectionByKey('aboutUs');
    final isVisible = about?.visibility ?? true;

    // Skip if not visible
    if (!isVisible) return const SizedBox.shrink();

    // Get title based on selected language
    String titleText;
    if (_isEnglish) {
      titleText = (about?.title.en.isNotEmpty == true)
          ? about!.title.en
          : 'About Us';
    } else {
      titleText = (about?.title.ar.isNotEmpty == true)
          ? about!.title.ar
          : 'معلومات عنا';
    }

    // Get description based on selected language
    String descText;
    if (_isEnglish) {
      descText = (about?.description.en.isNotEmpty == true)
          ? about!.description.en
          : 'Welcome to Beauty App, where beauty meets tranquility.';
    } else {
      descText = (about?.description.ar.isNotEmpty == true)
          ? about!.description.ar
          : 'مرحباً بكم في تطبيق بيوتي، حيث يلتقي الجمال بالهدوء.';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: _C.aboutBg,
      child: Column(
        crossAxisAlignment: _isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            titleText,
            textDirection: _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: StyleText.fontSize20Weight600
                .copyWith(color: _C.labelText),
          ),
          SizedBox(height: 12.h),
          Text(
            descText,
            textDirection: _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: StyleText.fontSize14Weight400
                .copyWith(color: _C.labelText, height: 1.6),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: _isEnglish
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                _isEnglish ? 'Read More' : 'اقرأ المزيد',
                style: StyleText.fontSize14Weight600
                    .copyWith(color: _C.primary),
              ),
              SizedBox(width: 4.w),
              Icon(
                _isEnglish
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: _C.primary,
                size: 16.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer / Download section preview (with AR/EN support) ─────────────────────
  Widget _previewFooterSection(MasterPageModel model) {
    final footer = model.sectionByKey('footer');
    final isVisible = footer?.visibility ?? true;

    // Skip if not visible
    if (!isVisible) return const SizedBox.shrink();

    // Get title based on selected language
    String titleText;
    if (_isEnglish) {
      titleText = (footer?.title.en.isNotEmpty == true)
          ? footer!.title.en
          : 'Download Beauty App Now';
    } else {
      titleText = (footer?.title.ar.isNotEmpty == true)
          ? footer!.title.ar
          : 'حمل تطبيق بيوتي الآن';
    }

    // Get description based on selected language
    String descText;
    if (_isEnglish) {
      descText = (footer?.description.en.isNotEmpty == true)
          ? footer!.description.en
          : 'At Beauty, you will find luxury services.';
    } else {
      descText = (footer?.description.ar.isNotEmpty == true)
          ? footer!.description.ar
          : 'ستجد لدينا أفضل الخدمات الفاخرة.';
    }

    final imageUrl = footer?.imageUrl ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Phone mockup image ────────────────────────────────────
          _previewImageBox(imageUrl, 200.w, 220.h,
              fallbackIcon: Icons.phone_iphone,
              fallbackBg: _C.downloadBg),
          SizedBox(width: 24.w),

          // ── Text + store badges ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: _isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  titleText,
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize20Weight600
                      .copyWith(color: _C.labelText),
                ),
                SizedBox(height: 10.h),
                Text(
                  descText,
                  textDirection: _isEnglish
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: _C.labelText, height: 1.5),
                ),
                SizedBox(height: 16.h),

                // ── Store badges ──────────────────────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _storeBadge(
                        label: _isEnglish ? 'Google Play' : 'جوجل بلاي',
                        icon: Icons.play_arrow_rounded),
                    SizedBox(width: 12.w),
                    _storeBadge(
                        label: _isEnglish ? 'App Store' : 'آب ستور',
                        icon: Icons.apple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable image box ────────────────────────────────────────────────────
  Widget _previewImageBox(
      String imageUrl,
      double width,
      double height, {
        IconData fallbackIcon = Icons.image,
        Color fallbackBg = _C.sectionBg,
      }) {
    if (imageUrl.isNotEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: SvgPicture.network(
          imageUrl,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => const CircleProgressMaster(),
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fallbackBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(fallbackIcon, size: 48.sp, color: _C.hintText),
      ),
    );
  }

  // ── Visibility badge ──────────────────────────────────────────────────────
  Widget _visibilityBadge(bool isVisible) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          size: 14.sp,
          color: isVisible ? Colors.green : _C.hintText,
        ),
        SizedBox(width: 4.w),
        Text(
          isVisible ? 'Visible' : 'Hidden',
          style: StyleText.fontSize12Weight500.copyWith(
            color: isVisible ? Colors.green : _C.hintText,
          ),
        ),
      ],
    );
  }

  // ── Store badge ───────────────────────────────────────────────────────────
  Widget _storeBadge({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEnglish ? 'GET IT ON' : 'تحميل من',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w400),
              ),
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}