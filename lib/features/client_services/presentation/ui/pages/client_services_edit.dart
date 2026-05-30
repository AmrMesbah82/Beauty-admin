/// ******************* FILE INFO *******************
/// File Name: client_services_edit.dart
/// Description: Edit page for Client Services CMS.
///              Header (SVG picker + Remove, Title, Description),
///              Download Applications (Title, Apple/Android links),
///              Mockups (dynamic: SVG picker + Remove, Left/Centered/Right chips,
///              Title, Description, + Mockup button),
///              Preview / Discard / Save buttons.
/// UPDATED: Added validation before publish - checks all required fields
///          and shows inline errors via _submitted flag.
///          Publish date is NOT required (can be null).
/// Created by: Amr Mesbah
/// Last Update: 15/04/2026

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segmant_tab.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/client_services_model.dart';
import '../../controller/client_services_cubit.dart';
import '../../controller/client_services_state.dart';
import 'client_services_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widget/client_services_edit/c.dart';
part '../widget/client_services_edit/picked_image.dart';
part '../widget/client_services_edit/mockup_local.dart';
part '../widget/client_services_edit/logic_helpers.dart';
part '../widget/client_services_edit/form_sections.dart';
part '../widget/client_services_edit/ui_helpers.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

class ClientServicesEditPage extends StatefulWidget {
  const ClientServicesEditPage({super.key});

  @override
  State<ClientServicesEditPage> createState() => _ClientServicesEditPageState();
}

class _ClientServicesEditPageState extends State<ClientServicesEditPage> {
  bool _submitted = false;
  int? _seededHash;

  // ── Header ────────────────────────────────────────────────────────────────
  final _hdrTitleEn = TextEditingController();
  final _hdrTitleAr = TextEditingController();
  final _hdrDescEn = TextEditingController();
  final _hdrDescAr = TextEditingController();
  _PickedImage _hdrSvg = _PickedImage.empty();

  // ── Download ──────────────────────────────────────────────────────────────
  final _dlTitleEn = TextEditingController();
  final _dlTitleAr = TextEditingController();
  final _appStoreLink = TextEditingController();
  final _googlePlay = TextEditingController();

  // ── Mockups ───────────────────────────────────────────────────────────────
  final List<_MockupLocal> _mockups = [];

  final Map<String, bool> _open = {
    'header': true,
    'download': true,
    'mockups': true,
  };

  Color get _prim => ColorPick.primary;

  @override
  void dispose() {
    _hdrTitleEn.dispose();
    _hdrTitleAr.dispose();
    _hdrDescEn.dispose();
    _hdrDescAr.dispose();
    _dlTitleEn.dispose();
    _dlTitleAr.dispose();
    _appStoreLink.dispose();
    _googlePlay.dispose();
    for (final m in _mockups) m.dispose();
    super.dispose();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientServicesCmsCubit, ClientServicesCmsState>(
      listener: (ctx, state) {
        if (state is ClientServicesCmsSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                'Saved!',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: ColorPick.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }
        if (state is ClientServicesCmsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (ctx, state) {
        if (state is ClientServicesCmsLoaded) _seed(state.data);
        final cubit = ctx.read<ClientServicesCmsCubit>();
        if (state is ClientServicesCmsInitial ||
            state is ClientServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child:
                    CircularProgressIndicator(color: ColorPick.primary)),
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
                    activeLabel: 'Web Pages',
                    homePage: HomeMainPage(),
                    webPage: HomeMainPage(),
                    jobListingPage: HomeMainPage(),
                  ),
                  SizedBox(width: 20.w),
                  AdminSubNavBar(activeIndex: 3),
                  SizedBox(width: 20.w),
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing Client Services Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          _accordionWrap('header', 'Header', [_headerBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('download', 'Download Applications',
                              [_downloadBody()]),
                          SizedBox(height: 10.h),
                          _accordionWrap('mockups', 'Mockups', [_mockupsBody()]),
                          SizedBox(height: 20.h),

                          // ── Buttons ──────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Preview',
                                  Color(0xFF8A5C70),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ClientServicesPreviewPage(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 300.w),
                              Expanded(
                                child: _btn('Publish', ColorPick.primary, () {
                                  if (!_validate()) return;
                                  showPublishConfirmDialog(
                                    title: 'EDITING CLIENT SERVICES DETAILS',
                                    subtitle:
                                        'Do you want to save the changes made to this CLIENT SERVICES?',
                                    context: context,
                                    onConfirm: () => _save(cubit),
                                  );
                                }),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Discard',
                                  ColorPick.discard,
                                  () => Navigator.pop(context),
                                ),
                              ),
                              SizedBox(width: 300.w),
                              Expanded(
                                child: _btn(
                                    'Save For Later', Color(0xFF525252), () {
                                  if (!_validate()) return;
                                  showPublishConfirmDialog(
                                    title: 'DRAFTING CLIENT SERVICES DETAILS',
                                    subtitle:
                                        'Do you want to DRAFTING CLIENT SERVICES?',
                                    context: context,
                                    onConfirm: () =>
                                        _save(cubit, status: 'draft'),
                                  );
                                }),
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
}
