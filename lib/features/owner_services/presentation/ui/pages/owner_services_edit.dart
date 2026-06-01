/// ******************* FILE INFO *******************
/// File Name: owner_services_edit.dart
/// Description: Edit page for Owner Services CMS.

import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segment_tab.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../../core/widgets/textfield.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/owner_services_model.dart';
import '../../controller/owner_services_cubit.dart';
import '../../controller/owner_services_state.dart';
import 'owner_services_preview.dart';

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widgets/owner_services_edit/picked_image.dart';
part '../widgets/owner_services_edit/mockup_local.dart';
part '../widgets/owner_services_edit/logic_helpers.dart';
part '../widgets/owner_services_edit/ui_helpers.dart';
part '../widgets/owner_services_edit/sections.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

class OwnerServicesEditPage extends StatefulWidget {
  const OwnerServicesEditPage({super.key});

  @override
  State<OwnerServicesEditPage> createState() => _OwnerServicesEditPageState();
}

class _OwnerServicesEditPageState extends State<OwnerServicesEditPage> {
  bool _submitted = false;
  int? _seededModelHash;

  // ── Header ────────────────────────────────────────────────────────────────
  _PickedImage _headerImage = _PickedImage.empty();
  final _headerTitleEn = TextEditingController();
  final _headerTitleAr = TextEditingController();
  final _headerDescEn = TextEditingController();
  final _headerDescAr = TextEditingController();

  // ── Download ──────────────────────────────────────────────────────────────
  final _dlTitleEn = TextEditingController();
  final _dlTitleAr = TextEditingController();
  final _appStoreLink = TextEditingController();
  final _googlePlay = TextEditingController();

  // ── Mockups ───────────────────────────────────────────────────────────────
  final List<_MockupLocal> _mockups = [];

  // ── Accordion ─────────────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'header': true,
    'download': true,
    'mockups': true,
  };

  Color get _resolvedPrimary => ColorPick.primary;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _headerTitleEn.dispose();
    _headerTitleAr.dispose();
    _headerDescEn.dispose();
    _headerDescAr.dispose();
    _dlTitleEn.dispose();
    _dlTitleAr.dispose();
    _appStoreLink.dispose();
    _googlePlay.dispose();
    for (final m in _mockups) m.dispose();
    super.dispose();
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OwnerServicesPreviewPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      listener: (context, state) {
        if (state is OwnerServicesCmsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saved!',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white),
              ),
              backgroundColor: ColorPick.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }
        if (state is OwnerServicesCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OwnerServicesCmsLoaded) _seedFromModel(state.data);

        final cubit = context.read<OwnerServicesCmsCubit>();

        if (state is OwnerServicesCmsInitial || state is OwnerServicesCmsLoading) {
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
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppAdminNavbar(
                            activeLabel: 'Web Page',
                            homePage: HomeMainPage(),
                            webPage: HomeMainPage(),
                            jobListingPage: HomeMainPage(),
                          ),
                          SizedBox(height: 20.h),
                          AdminSubNavBar(activeIndex: 4),
                          SizedBox(height: 20.h),
                          Text(
                            'Editing Owner Services Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: ColorPick.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          _accordionWrap('header', 'Header', [_headerBody()]),
                          SizedBox(height: 10.h),

                          _accordionWrap('download', 'Download Applications', [
                            _downloadBody(),
                          ]),
                          SizedBox(height: 10.h),

                          _accordionWrap('mockups', 'Mockups', [_mockupsBody()]),
                          SizedBox(height: 20.h),

                          _actionRow(cubit),
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
