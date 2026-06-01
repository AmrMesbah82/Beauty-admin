/// ******************* FILE INFO *******************
/// File Name: home_edit.dart
/// Page 2 — "Editing Main Details"
/// UPDATED: Footer column title is now a dropdown populated from nav items.
///          Selecting a nav item auto-fills EN + AR title and sets the route.
///          Each label row now has a destination dropdown (fixed list) plus
///          free-text EN / AR fields.
///          Label map type changed from Map<String,TextEditingController>
///          to Map<String,dynamic> to hold the extra 'route' String? field.
/// FIXED:   _save() now syncs navButtons ORDER to cubit before updating
///          name/status — uses reorderNavButtons() so drag reorder persists.
/// UPDATED: _kLabelDestinations now use /about?tab=... query-param routes
///          so footer links deep-link directly into the correct About Us tab.
/// UPDATED: Removed _isSaving + full-screen overlay. CircularProgressIndicator
///          now shows only inside the publish confirm dialog while saving.
/// UPDATED: "App Link" section replaces "Download the App" — now has
///          Navigation Label (EN/AR), two icon pickers (iOS/Android),
///          and two link fields matching Figma design.
/// UPDATED: Publish now validates all required fields first — sets _submitted
///          to true so CustomValidatedTextFieldMaster shows inline errors.
/// UPDATED: Publish button is disabled until:
///          1. All validation passes
///          2. There are actual changes to save (no unnecessary saves)
/// FIXED:   Removed setState() from build method - added _validateSilent()
/// UPDATED: Added Male Primary Color + Main Widget Color to branding section ✅

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:beauty_admin/core/widgets/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:go_router/go_router.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widgets/circle_progress.dart';
import 'package:beauty_admin/core/widgets/custom_dropdown.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';

import '../../../../../core/widgets/textfield.dart';
import '../../../data/models/home_model.dart';
import '../../controller/home_cubit.dart';
import '../../controller/home_state.dart';
import 'home_main.dart';
import 'home_preview.dart';

part '../widgets/home_edit/c.dart';
part '../widgets/home_edit/header_item.dart';
part '../widgets/home_edit/picked_image.dart';
part '../widgets/home_edit/link_item.dart';
part '../widgets/home_edit/color_picker_field.dart';
part '../widgets/home_edit/color_wheel_overlay.dart';
part '../widgets/home_edit/logic_helpers.dart';
part '../widgets/home_edit/ui_helpers.dart';
part '../widgets/home_edit/sections.dart';
part '../widgets/home_edit/sections_links.dart';

class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});

  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  bool _submitted  = false;
  bool _hasChanges = false;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _navBtns = List.of(
    List.generate(3, (_) => {
      'nameEn': TextEditingController(),
      'nameAr': TextEditingController(),
    }),
  );
  final List<String?> _navRoutes = List.of([null, null, null]);
  final List<bool>    _navStatus = List.of([true,  true,  true]);

  // ── Sections 1–4 ──────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _sections =
      List.generate(4, (_) => {
        'textBox':       TextEditingController(text: '#008037'),
        'description':   TextEditingController(),
        'descriptionAr': TextEditingController(),
      });

  final List<Map<String, _PickedImage>> _sectionImages = List.generate(
    4,
    (_) => {'image': const _PickedImage(), 'icon': const _PickedImage()},
  );

  // ── Header titles ─────────────────────────────────────────────────────────
  late final List<_HeaderItem> _headerItems;

  // ── Footer columns ────────────────────────────────────────────────────────
  late final List<Map<String, dynamic>> _footerColumns;

  // ── Social links ──────────────────────────────────────────────────────────
  late final List<_LinkItem> _links;

  // ── Logo ──────────────────────────────────────────────────────────────────
  _PickedImage _logoPicked = const _PickedImage();

  // ── Branding ──────────────────────────────────────────────────────────────
  final _primaryColor      = TextEditingController(text: '#008037');
  final _malePrimaryColor  = TextEditingController(text: '#D9D9D9');
  final _secondaryColor    = TextEditingController(text: '#D9D9D9');
  final _bgColor           = TextEditingController(text: '#D9D9D9');
  final _headerFooterColor = TextEditingController(text: '#D9D9D9');
  final _mainWidgetColor   = TextEditingController(text: '#D9D9D9');
  String? _engFont = 'Cairo';
  String? _arFont  = 'Cairo';

  // ── App Link ──────────────────────────────────────────────────────────────
  final _iosUrlCtrl       = TextEditingController();
  final _androidUrlCtrl   = TextEditingController();
  final _appLabelEnCtrl   = TextEditingController();
  final _appLabelArCtrl   = TextEditingController();
  bool  _downloadAppVisibility = true;
  _PickedImage _iosIconPicked     = const _PickedImage();
  _PickedImage _androidIconPicked = const _PickedImage();

  // ── Accordion open/close ──────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'theme': true, 'header': true, 'footer': true, 'links': true,
    'headings': true, 'navBtn': true, 'downloadApp': true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  // ── Seed-hash guard ───────────────────────────────────────────────────────
  int? _seededModelHash;

  late final List<_PickedImage> _navIcons;

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return ColorPick.primary;
  }

  List<Map<String, String>> _buildNavDropdownItems() {
    final items = <Map<String, String>>[
      {'key': '', 'value': 'None'},
    ];
    for (var i = 0; i < _navBtns.length; i++) {
      final en    = _navBtns[i]['nameEn']!.text.trim();
      final route = _navRoutes[i] ?? '';
      if (route.isEmpty) continue;
      items.add({'key': route, 'value': en.isNotEmpty ? en : route});
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _navIcons      = List.generate(3, (_) => const _PickedImage());
    _seededModelHash = null;
    _headerItems   = List.generate(5, (i) => _HeaderItem(id: 'hi_$i'));
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    _links         = List.generate(4, (_) => _LinkItem());
    _setupChangeListeners();
  }

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _shortDescEn.dispose();
    _shortDescAr.dispose();
    for (final m in _navBtns) {
      for (final c in m.values) c.dispose();
    }
    for (final m in _sections) {
      for (final c in m.values) c.dispose();
    }
    for (final item in _headerItems) item.dispose();
    for (final col in _footerColumns) _disposeColumn(col);
    for (final link in _links) link.dispose();
    _primaryColor.dispose();
    _malePrimaryColor.dispose();
    _secondaryColor.dispose();
    _bgColor.dispose();
    _headerFooterColor.dispose();
    _mainWidgetColor.dispose();
    _iosUrlCtrl.dispose();
    _androidUrlCtrl.dispose();
    _appLabelEnCtrl.dispose();
    _appLabelArCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        if (state is HomeCmsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Home page saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: ColorPick.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }
        if (state is HomeCmsError) {
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
        if (state is HomeCmsLoaded) _seedFromModel(state.data);

        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        final bool isFormValid = _validateSilent();
        final bool canPublish  = isFormValid && _hasChanges;

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppAdminNavbar(
                            activeLabel: 'Web Page',
                            homePage: HomeMainPage(),
                            webPage: HomeMainPage(),
                            jobListingPage: HomeMainPage(),
                          ),
                          SizedBox(width: 20.w),
                          AdminSubNavBar(activeIndex: 0),
                          SizedBox(
                            width: 1050.w,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Editing Main Details',
                                    style: StyleText.fontSize45Weight600.copyWith(
                                      color: ColorPick.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  _accordion(
                                      key: 'theme',
                                      title: 'Theme and Logo',
                                      children: [_logoAndBrandingSection()]),
                                  _gap(),
                                  _navSection(),
                                  _gap(),
                                  _footerSection(cubit),
                                  _gap(),
                                  _appLinkSection(),
                                  _gap(),
                                  _linksSection(),
                                  _gap(),
                                  _bottomActions(cubit, canPublish),
                                  _gap(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            height: 44.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF797979),
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Center(
                                              child: Text('Discard',
                                                  style: StyleText
                                                      .fontSize14Weight600
                                                      .copyWith(
                                                          color:
                                                              Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15.sp),
                                      Expanded(child: Container()),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
