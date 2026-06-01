/// ******************* FILE INFO *******************
/// File Name: overview_edit.dart
/// Description: Edit page for Master CMS (Overview-style).

import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/overview_model.dart';
import '../../controller/overview_cubit.dart';
import '../../controller/overview_state.dart';
import 'overview_main.dart';
import 'overview_preview.dart';

part '../widgets/overview_edit/c.dart';
part '../widgets/overview_edit/picked_image.dart';
part '../widgets/overview_edit/service_local.dart';
part '../widgets/overview_edit/gallery_local.dart';
part '../widgets/overview_edit/comment_local.dart';
part '../widgets/overview_edit/logic_helpers.dart';
part '../widgets/overview_edit/ui_helpers.dart';
part '../widgets/overview_edit/sections.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

class OverviewEditPage extends StatefulWidget {
  const OverviewEditPage({super.key});
  @override
  State<OverviewEditPage> createState() => _OverviewEditPageState();
}

class _OverviewEditPageState extends State<OverviewEditPage> {
  bool _submitted = false;
  bool _hasSeededOnce = false;
  bool _isEditingDraft = false;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _headTitleEn = TextEditingController();
  final _headTitleAr = TextEditingController();
  final _headDescEn  = TextEditingController();
  final _headDescAr  = TextEditingController();

  // ── Services ──────────────────────────────────────────────────────────────
  final _svcTitleEn = TextEditingController();
  final _svcTitleAr = TextEditingController();
  final List<_ServiceLocal> _services = [];

  // ── Gallery ───────────────────────────────────────────────────────────────
  final List<_GalleryLocal> _galleryItems = [];

  // ── Client Comments ───────────────────────────────────────────────────────
  final _cmtTitleEn = TextEditingController();
  final _cmtTitleAr = TextEditingController();
  final List<_CommentLocal> _comments = [];

  // ── Download ──────────────────────────────────────────────────────────────
  final _dlTitleEn    = TextEditingController();
  final _dlTitleAr    = TextEditingController();
  final _appStoreLink = TextEditingController();
  final _googlePlay   = TextEditingController();

  // ── Publish Schedule ──────────────────────────────────────────────────────
  DateTime? _publishDate;

  // ── Accordion ─────────────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'headings': true, 'services': true, 'gallery': true,
    'comments': true, 'download': true, 'schedule': true,
  };

  Color get _resolvedPrimary => ColorPick.primary;

  @override
  void initState() {
    super.initState();
    for (final ctrl in _allControllers) ctrl.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    for (final s in _services) s.dispose();
    for (final c in _comments) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewCmsCubit, OverviewCmsState>(
      listener: (context, state) {

        if (state is OverviewCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => BlocProvider.value(
                  value: context.read<OverviewCmsCubit>(), child: const OverviewMainPage(),
                )),
                (route) => false,
              );
            }
          });
        }

        if (state is OverviewCmsDraftSaved) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.data.status == 'scheduled'
                    ? 'Scheduled draft saved! Published version is still live.'
                    : 'Draft saved! Published version is still live.',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white),
              ),
              backgroundColor: ColorPick.draftColor, behavior: SnackBarBehavior.floating,
            ));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => BlocProvider.value(
                  value: context.read<OverviewCmsCubit>(), child: const OverviewMainPage(),
                )),
                (route) => false,
              );
            }
          });
        }

        if (state is OverviewCmsDraftDeleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => BlocProvider.value(
                  value: context.read<OverviewCmsCubit>(), child: const OverviewMainPage(),
                )),
                (route) => false,
              );
            }
          });
        }

        if (state is OverviewCmsError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.message}',
                  style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
              backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
            ));
          }
        }
      },
      builder: (context, state) {
        if (state is OverviewCmsLoaded && !_hasSeededOnce) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasSeededOnce) {
              _hasSeededOnce = true;
              _seedFromModel(state.data, isFromDraft: state.isFromDraft);
              setState(() {});
            }
          });
        }

        final cubit = context.read<OverviewCmsCubit>();

        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        final bool canPublish = _isFormValid;

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
                    homePage: HomeMainPage(), webPage: HomeMainPage(), jobListingPage: HomeMainPage(),
                  ),
                  SizedBox(width: 20.w),
                  AdminSubNavBar(activeIndex: 2),
                  SizedBox(width: 20.w),
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('Editing Overview',
                                style: StyleText.fontSize45Weight600.copyWith(
                                    color: ColorPick.primary, fontWeight: FontWeight.w700)),
                            if (_isEditingDraft) ...[
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: ColorPick.draftColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text('EDITING DRAFT',
                                    style: StyleText.fontSize12Weight600.copyWith(color: ColorPick.draftColor)),
                              ),
                            ],
                          ]),
                          if (_isEditingDraft)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'You are editing a saved draft. The published version is still live.',
                                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                              ),
                            ),
                          SizedBox(height: 16.h),

                          _accordionWrap('headings', 'Headings',  [_headingsBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('services', 'Services',  [_servicesBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('gallery',  'Gallery',   [_galleryBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('comments', 'Client Comments',       [_commentsBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('download', 'Download Applications', [_downloadBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('schedule', 'Publish Schedule',      [_scheduleBody()]),
                          SizedBox(height: 15.h),
                          _actionRow(cubit, canPublish),
                          SizedBox(height: 10.h),
                          _secondaryRow(cubit),
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
