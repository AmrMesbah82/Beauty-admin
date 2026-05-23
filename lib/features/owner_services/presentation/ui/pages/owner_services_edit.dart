/// ******************* FILE INFO *******************
/// File Name: owner_services_edit.dart
/// Description: Edit page for Owner Services CMS.
///              Sections: Header (SVG + Remove btn, Title EN/AR, Desc EN/AR),
///              Download Applications (Title EN/AR + links),
///              Mockups (+Mockup btn, dynamic: SVG + Remove btn,
///              Alignment Left/Centered/Right pills, Title EN/AR, Desc EN/AR).
///              Buttons: Preview / Save / Discard.
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

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

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_segmant_tab.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/textfield.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/owner_services_model.dart';
import '../../controller/owner_services_cubit.dart';
import '../../controller/owner_services_state.dart';
import 'owner_services_preview.dart';

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widget/owner_services_edit/picked_image.dart';
part '../widget/owner_services_edit/mockup_local.dart';

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
    print('[OwnerServicesEditPage] ✅ initState');
  }

  @override
  void dispose() {
    print('[OwnerServicesEditPage] 🔴 dispose');
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

  // Navigation method for preview
  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OwnerServicesPreviewPage()),
    );
  }

  // ── Seed from model ───────────────────────────────────────────────────────
  void _seedFromModel(OwnerServicesPageModel d) {
    final hash = Object.hashAll([
      d.header.imageUrl,
      d.header.title.en,
      d.header.title.ar,
      d.header.description.en,
      d.header.description.ar,
      d.download.title.en,
      d.download.title.ar,
      d.download.appStoreLink,
      d.download.googlePlayLink,
      d.mockups.items.length,
      d.publishSchedule.publishDate,
    ]);

    if (_seededModelHash == hash) return;
    _seededModelHash = hash;
    print('[OwnerServicesEditPage] _seedFromModel ▶ seeding');

    // Header
    _headerImage = d.header.imageUrl.isNotEmpty
        ? _PickedImage(url: d.header.imageUrl)
        : _PickedImage.empty();
    _headerTitleEn.text = d.header.title.en;
    _headerTitleAr.text = d.header.title.ar;
    _headerDescEn.text = d.header.description.en;
    _headerDescAr.text = d.header.description.ar;

    // Download
    _dlTitleEn.text = d.download.title.en;
    _dlTitleAr.text = d.download.title.ar;
    _appStoreLink.text = d.download.appStoreLink;
    _googlePlay.text = d.download.googlePlayLink;

    // Mockups
    for (final m in _mockups) m.dispose();
    _mockups.clear();
    for (final item in d.mockups.items) {
      final local = _MockupLocal(id: item.id);
      local.titleEn.text = item.title.en;
      local.titleAr.text = item.title.ar;
      local.descEn.text = item.description.en;
      local.descAr.text = item.description.ar;
      local.alignment = item.alignment;
      local.image = item.imageUrl.isNotEmpty
          ? _PickedImage(url: item.imageUrl)
          : _PickedImage.empty();
      _mockups.add(local);
    }

    print(
      '[OwnerServicesEditPage] _seedFromModel ✅ DONE, mockups count: ${_mockups.length}',
    );
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    print('[_pickImage] ▶ START');
    final completer = Completer<_PickedImage?>();
    bool completed = false;

    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    print('[_pickImage] input created, adding onChange listener');

    input.onChange.listen((event) {
      print('[_pickImage] onChange fired');
      final files = input.files;
      if (files == null || files.isEmpty) {
        print('[_pickImage] ❌ no files selected');
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

      final file = files.first;
      print('[_pickImage] file selected: name=${file.name} type=${file.type} size=${file.size}');

      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        print('[_pickImage] ❌ rejected: not an SVG (name=${file.name}, type=${file.type})');
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

      print('[_pickImage] ✅ SVG accepted, starting FileReader...');
      final reader = html.FileReader();

      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        print('[_pickImage] onLoadEnd: result runtimeType = ${result.runtimeType}');
        if (!completed) {
          completed = true;
          if (result is ByteBuffer) {
            // ✅ ByteBuffer is from dart:typed_data, not dart:html
            final bytes = Uint8List.view(result);
            print('[_pickImage] ✅ ByteBuffer → ${bytes.length} bytes');
            completer.complete(_PickedImage(bytes: bytes));
          } else if (result is List<int>) {
            print('[_pickImage] ✅ List<int> → ${result.length} bytes');
            completer.complete(_PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            print('[_pickImage] ❌ unknown result type: ${result.runtimeType}');
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((e) {
        print('[_pickImage] ❌ FileReader error: $e');
        if (!completed) { completed = true; completer.complete(null); }
      });

      reader.readAsArrayBuffer(file);
      print('[_pickImage] readAsArrayBuffer called');
    });

    input.click();
    print('[_pickImage] input.click() called — waiting for user...');

    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) {
        print('[_pickImage] ⏰ TIMEOUT after 5 minutes');
        completed = true;
        completer.complete(null);
      }
    });

    final result = await completer.future;
    print('[_pickImage] ◀ DONE — result: ${result == null ? 'null' : 'bytes=${result.bytes?.length} url=${result.url}'}');
    return result;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(
    OwnerServicesCmsCubit cubit, {
    String publishStatus = 'published',
  }) async {
    setState(() => _submitted = true);
    try {
      print(
        '[OwnerServicesEditPage] _save: Starting save with ${_mockups.length} mockups',
      );

      // ── Header ────────────────────────────────────────────────────────────
      cubit.updateHeaderTitle(en: _headerTitleEn.text, ar: _headerTitleAr.text);
      cubit.updateHeaderDescription(
        en: _headerDescEn.text,
        ar: _headerDescAr.text,
      );

      if (_headerImage.bytes != null) {
        print('[OwnerServicesEditPage] _save: Uploading header image');
        await cubit.uploadHeaderImage(_headerImage.bytes!);
      } else if (_headerImage.url != null && _headerImage.url!.isNotEmpty) {
        cubit.updateHeaderImageUrl(_headerImage.url!);
      } else {
        cubit.removeHeaderImage();
      }

      // ── Download ──────────────────────────────────────────────────────────
      cubit.updateDownloadTitle(en: _dlTitleEn.text, ar: _dlTitleAr.text);
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlay.text);

      // ── Mockups: clear all → re-add → update by aligned index ─────────────
      print('[OwnerServicesEditPage] _save: Clearing existing mockups');
      for (final item in List<OwnerServicesMockupItemModel>.from(
        cubit.current.mockups.items,
      )) {
        cubit.removeMockupItem(item.id);
      }

      print(
        '[OwnerServicesEditPage] _save: Adding ${_mockups.length} new mockups',
      );
      for (var i = 0; i < _mockups.length; i++) {
        cubit.addMockupItem();
      }

      print('[OwnerServicesEditPage] _save: Updating mockup details');
      for (var i = 0; i < _mockups.length; i++) {
        final id = cubit.current.mockups.items[i].id;
        print('[OwnerServicesEditPage] _save: Updating mockup $i with id $id');

        cubit.updateMockupItemTitle(
          id,
          en: _mockups[i].titleEn.text,
          ar: _mockups[i].titleAr.text,
        );
        cubit.updateMockupItemDescription(
          id,
          en: _mockups[i].descEn.text,
          ar: _mockups[i].descAr.text,
        );
        cubit.updateMockupItemAlignment(id, _mockups[i].alignment);

        if (_mockups[i].image.bytes != null) {
          print(
            '[OwnerServicesEditPage] _save: Uploading new image for mockup $i',
          );
          await cubit.uploadMockupItemImage(id, _mockups[i].image.bytes!);
        } else if (_mockups[i].image.url != null &&
            _mockups[i].image.url!.isNotEmpty) {
          print(
            '[OwnerServicesEditPage] _save: Using existing URL for mockup $i',
          );
          cubit.updateMockupItemImageUrl(id, _mockups[i].image.url!);
        }
      }

      print('[OwnerServicesEditPage] _save: Saving to repository');
      await cubit.save(publishStatus: publishStatus);
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[OwnerServicesEditPage] _save: ❌ ERROR: $e\n$st');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      listener: (context, state) {
        if (state is OwnerServicesCmsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
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
        if (state is OwnerServicesCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: Colors.white,
                ),
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

        if (state is OwnerServicesCmsInitial ||
            state is OwnerServicesCmsLoading) {
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
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

                          _accordionWrap('mockups', 'Mockups', [
                            _mockupsBody(),
                          ]),
                          SizedBox(height: 20.h),

                          // ── Action buttons ────────────────────────
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

  // ── Accordion wrapper ─────────────────────────────────────────────────────
  Widget _accordionWrap(String key, String title, List<Widget> children) {
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
                      topRight: Radius.circular(6.r),
                    )
                  : BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _headerBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SVG + Remove
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('SVG'),
            _removeButton(() {
              setState(() => _headerImage = _PickedImage.empty());
            }),
          ],
        ),
        SizedBox(height: 6.h),
        _imgBox(
          picked: _headerImage,
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => _headerImage = p);
          },
        ),
        SizedBox(height: 12.h),
        _biRow(
          'Title',
          'العنوان',
          _headerTitleEn,
          _headerTitleAr,
          useRow: true,
        ),
        SizedBox(height: 10.h),
        CustomValidatedTextFieldMaster(
          label: 'Description',
          hint: 'Text Here',
          controller: _headerDescEn,
          maxLines: 4,
          height: 100,
          submitted: _submitted,
          fillColor: Colors.white,
          primaryColor: _resolvedPrimary,
        ),
        SizedBox(height: 10.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف',
            hint: 'أدخل النص هنا',
            controller: _headerDescAr,
            maxLines: 4,
            height: 100,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD APPLICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _downloadBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _biRow('Title', 'العنوان', _dlTitleEn, _dlTitleAr, useRow: true),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Apple Store Link',
                hint: 'Insert Links',
                controller: _appStoreLink,
                height: 36,
                submitted: false,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Android Link',
                hint: 'Insert Links',
                controller: _googlePlay,
                height: 36,
                submitted: false,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCKUPS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _mockupsBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_mockups.length, (i) => _mockupItemRow(i)),
        SizedBox(height: 8.h),
        _addButton('Mockup', () {
          setState(
            () => _mockups.add(
              _MockupLocal(id: 'mock_${DateTime.now().millisecondsSinceEpoch}'),
            ),
          );
        }),
      ],
    ),
  );

  Widget _mockupItemRow(int i) {
    final mock = _mockups[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SVG label + Remove
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('SVG'),
              _removeButton(() {
                setState(() {
                  final removed = _mockups.removeAt(i);
                  removed.dispose();
                });
              }),
            ],
          ),
          SizedBox(height: 6.h),

          // Image + Alignment pills
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imgBox(
                picked: mock.image,
                onPick: () async {
                  final p = await _pickImage();
                  if (p != null) setState(() => mock.image = p);
                },
              ),
              const Spacer(),
              _alignmentPills(mock),
            ],
          ),
          SizedBox(height: 10.h),

          _biRow('Title', 'العنوان', mock.titleEn, mock.titleAr, useRow: true),
          SizedBox(height: 10.h),

          CustomValidatedTextFieldMaster(
            label: 'Description',
            hint: 'Text Here',
            controller: mock.descEn,
            maxLines: 4,
            height: 100,
            submitted: _submitted,
            fillColor: Colors.white,
            primaryColor: _resolvedPrimary,
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف',
              hint: 'أدخل النص هنا',
              controller: mock.descAr,
              maxLines: 4,
              height: 100,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimary,
            ),
          ),

          if (i < _mockups.length - 1) Divider(height: 24.h, color: ColorPick.white),
        ],
      ),
    );
  }

  Widget _alignmentPills(_MockupLocal mock) {
    const options = ['left', 'centered', 'right'];
    return CustomSegmentedTabs(
      tabs: const ['Left', 'Centered', 'Right'],
      selectedIndex: options.indexOf(mock.alignment).clamp(0, 2),
      onTabSelected: (index) => setState(() => mock.alignment = options[index]),
      selectedColor: ColorPick.primary,
      unselectedColor: Colors.white,
      selectedTextColor: Colors.white,
      unselectedTextColor: AppColors.text,
      equalWidth: false,
      containerPadding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      containerColor: Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _actionRow(OwnerServicesCmsCubit cubit) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: _navigateToPreview,
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Color(0xFF8A5C70),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Preview',
                style: StyleText.fontSize14Weight600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 300.w),
      Expanded(
        child: GestureDetector(
          onTap: () => showPublishConfirmDialog(
            title: 'EDITING ONER SERVICES DETAILS',
            subtitle:
                'Do you want to save the changes made to this ONER SERVICES?',
            context: context,
            onConfirm: () => _save(cubit, publishStatus: 'published'),
          ),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Save',
                style: StyleText.fontSize14Weight600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _secondaryRow(OwnerServicesCmsCubit cubit) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.discard,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Discard',
                style: StyleText.fontSize14Weight600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 300.w),
      Expanded(child: Column()),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _sectionLabel(String t) => Text(
    t,
    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
  );

  Widget _biRow(
    String enLbl,
    String arLbl,
    TextEditingController enC,
    TextEditingController arC, {
    int maxLines = 1,
    bool useRow = false,
  }) {
    final h = maxLines > 1 ? 100.0 : 36.0;
    final en = CustomValidatedTextFieldMaster(
      label: enLbl,
      hint: 'Text Here',
      fillColor: Colors.white,
      controller: enC,
      maxLines: maxLines,
      height: h,
      submitted: _submitted,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      primaryColor: _resolvedPrimary,
    );
    final ar = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLbl,
        fillColor: Colors.white,
        hint: 'أدخل النص هنا',
        controller: arC,
        maxLines: maxLines,
        height: h,
        submitted: _submitted,
        textDirection: ui.TextDirection.rtl,
        textAlign: TextAlign.right,
        primaryColor: _resolvedPrimary,
      ),
    );
    if (useRow) {
      return Row(
        children: [
          Expanded(child: en),
          SizedBox(width: 16.w),
          Expanded(child: ar),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        en,
        SizedBox(height: 10.h),
        ar,
      ],
    );
  }

  Widget _addButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: ColorPick.primary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            label,
            style: StyleText.fontSize12Weight500.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );

  Widget _removeButton(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: ColorPick.red,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            CustomSvg(assetPath: "assetPath",width: 20.w,height: 20.h,),
            SizedBox(width: 4.w),
          Text(
            'Remove',
            style: StyleText.fontSize10Weight400.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );

  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-preview-${picked.bytes!.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      content = Container(
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
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      final viewId = 'svg-url-preview-${picked.url!.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = picked.url!
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      content = Container(
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
    } else {
      content = _placeholderCircle();
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: ColorPick.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvg(
                assetPath: 'assets/control/camera.svg',
                width: 12.w,
                height: 12.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle() => Container(
    width: 50.w,
    height: 50.h,
    decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Center(
        child: CustomSvg(
            assetPath: 'assets/home_control/image.svg',
            width: 20.w,
            height: 20.h,
            fit: BoxFit.fill)),
  );

}
