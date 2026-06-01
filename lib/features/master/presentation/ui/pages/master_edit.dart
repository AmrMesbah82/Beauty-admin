/// ******************* FILE INFO *******************
/// File Name: master_edit.dart
/// Description: Edit page for the Master CMS module.

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'dart:ui' as ui;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widgets/circle_progress.dart';
import 'package:beauty_admin/core/widgets/textfield.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../../core/widgets/date_pic.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/master_model.dart';
import '../../controller/master_cubit.dart';
import '../../controller/master_state.dart';
import 'master_preview.dart';
import 'master_main.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;

part '../widgets/master_edit/picked_image.dart';
part '../widgets/master_edit/logic_helpers.dart';
part '../widgets/master_edit/ui_helpers.dart';
part '../widgets/master_edit/sections.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

class MasterEditPage extends StatefulWidget {
  const MasterEditPage({super.key});

  @override
  State<MasterEditPage> createState() => _MasterEditPageState();
}

class _MasterEditPageState extends State<MasterEditPage> {
  bool _submitted = false;
  bool _isEditingDraft = false;
  int? _seededModelHash;

  // ── Header ────────────────────────────────────────────────────────────────
  final _headerTitleEn    = TextEditingController();
  final _headerTitleAr    = TextEditingController();
  final _headerShortEn    = TextEditingController();
  final _headerShortAr    = TextEditingController();
  _PickedImage _headerImage = const _PickedImage();
  bool _headerVisibility   = true;

  // ── About Us ──────────────────────────────────────────────────────────────
  final _aboutTitleEn = TextEditingController();
  final _aboutTitleAr = TextEditingController();
  final _aboutDescEn  = TextEditingController();
  final _aboutDescAr  = TextEditingController();

  // ── Footer ────────────────────────────────────────────────────────────────
  final _footerTitleEn = TextEditingController();
  final _footerTitleAr = TextEditingController();
  final _footerDescEn  = TextEditingController();
  final _footerDescAr  = TextEditingController();
  _PickedImage _footerImage = const _PickedImage();
  bool _footerVisibility    = true;

  // ── App Links ─────────────────────────────────────────────────────────────
  final _appStoreLink   = TextEditingController();
  final _googlePlayLink = TextEditingController();

  // ── Publish Schedule ──────────────────────────────────────────────────────
  DateTime? _publishDate;

  // ── Accordion ─────────────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'header': true,
    'aboutUs': true,
    'footer': true,
    'schedule': true,
  };

  Color get _resolvedPrimaryColor => ColorPick.primary;

  @override
  void initState() {
    super.initState();
    _seededModelHash = null;
    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterCmsCubit, MasterCmsState>(
      listener: (context, state) {

        if (state is MasterCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MasterMainPage()),
                (route) => false,
              );
            }
          });
        }

        if (state is MasterCmsDraftSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MasterMainPage()),
                (route) => false,
              );
            }
          });
        }

        if (state is MasterCmsDraftDeleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MasterMainPage()),
                (route) => false,
              );
            }
          });
        }

        if (state is MasterCmsError) {
          if (mounted) {}
        }
      },
      builder: (context, state) {
        if (state is MasterCmsLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _seedFromModel(state.data, isFromDraft: state.isFromDraft);
          });
        }

        final cubit = context.read<MasterCmsCubit>();

        if (state is MasterCmsInitial || state is MasterCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        return Scaffold(
          backgroundColor: ColorPick.background,
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
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Editing Home',
                                style: StyleText.fontSize45Weight600.copyWith(
                                  color: ColorPick.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_isEditingDraft) ...[
                                SizedBox(width: 12.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: ColorPick.draftColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'EDITING DRAFT',
                                    style: StyleText.fontSize12Weight600.copyWith(
                                      color: ColorPick.draftColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_isEditingDraft)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'You are editing a saved draft. The published version is still live.',
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          SizedBox(height: 16.h),

                          _accordion(
                            key: 'header',
                            title: 'Header Section',
                            children: [_headerSectionBody()],
                          ),
                          SizedBox(height: 10.h),

                          _accordion(
                            key: 'aboutUs',
                            title: 'About Us',
                            children: [_aboutUsSectionBody()],
                          ),
                          SizedBox(height: 10.h),

                          _accordion(
                            key: 'footer',
                            title: 'Footer Section',
                            children: [_footerSectionBody()],
                          ),
                          SizedBox(height: 10.h),

                          _accordion(
                            key: 'schedule',
                            title: 'Publish Schedule',
                            children: [_publishScheduleBody()],
                          ),

                          _actionButtons(cubit),
                          SizedBox(height: 10.h),
                          _secondaryButtons(cubit),
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
}
