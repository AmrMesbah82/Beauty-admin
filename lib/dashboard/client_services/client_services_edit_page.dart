/// ******************* FILE INFO *******************
/// File Name: client_services_edit_page.dart
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
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/client_services/client_services_cubit.dart';
import '../../controller/client_services/client_services_state.dart';
import '../../model/client_services/client_services_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';
import 'client_services_preview_page.dart';

class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText = Color(0xFFAAAAAA);
  static const Color remove = Color(0xFFE53935);
  static const Color back = Color(0xFFF1F2ED);
  static const Color addBtn = Color(0xFF797979);
  static const Color border = Color(0xFFE0E0E0);
}

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});

  factory _PickedImage.empty() => const _PickedImage();

  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

class _MockupLocal {
  final String id;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage svg;
  MockupLayout layout;

  _MockupLocal({required this.id})
    : titleEn = TextEditingController(),
      titleAr = TextEditingController(),
      descEn = TextEditingController(),
      descAr = TextEditingController(),
      svg = _PickedImage.empty(),
      layout = MockupLayout.left;

  void dispose() {
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
  }
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

  Color get _prim => _C.primary;

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

  // ── Validation ────────────────────────────────────────────────────────────
  /// Validates all required fields before publishing.
  /// Returns true if all fields are valid, false otherwise.
  /// Note: Publish date is NOT required (can be null)
  bool _validate() {
    // Mark submitted so all fields show errors immediately
    setState(() => _submitted = true);

    // ── Header ──────────────────────────────────────────────────────────────
    if (_hdrTitleEn.text.trim().isEmpty) return false;
    if (_hdrTitleAr.text.trim().isEmpty) return false;
    if (_hdrDescEn.text.trim().isEmpty) return false;
    if (_hdrDescAr.text.trim().isEmpty) return false;
    // SVG is optional - not validated

    // ── Download Title ──────────────────────────────────────────────────────
    if (_dlTitleEn.text.trim().isEmpty) return false;
    if (_dlTitleAr.text.trim().isEmpty) return false;
    // appStoreLink and googlePlay are optional - not validated

    // ── Mockups ─────────────────────────────────────────────────────────────
    for (var i = 0; i < _mockups.length; i++) {
      if (_mockups[i].titleEn.text.trim().isEmpty) return false;
      if (_mockups[i].titleAr.text.trim().isEmpty) return false;
      if (_mockups[i].descEn.text.trim().isEmpty) return false;
      if (_mockups[i].descAr.text.trim().isEmpty) return false;
      // SVG is optional - not validated
    }

    return true;
  }

  // ── Seed ──────────────────────────────────────────────────────────────────
  void _seed(ClientServicesPageModel d) {
    final h = Object.hashAll([
      d.header.svgUrl,
      d.mockups.items.length,
      d.download.appStoreLink,
    ]);
    if (_seededHash == h) return;
    _seededHash = h;

    _hdrTitleEn.text = d.header.title.en;
    _hdrTitleAr.text = d.header.title.ar;
    _hdrDescEn.text = d.header.description.en;
    _hdrDescAr.text = d.header.description.ar;
    _hdrSvg = d.header.svgUrl.isNotEmpty
        ? _PickedImage(url: d.header.svgUrl)
        : _PickedImage.empty();

    _dlTitleEn.text = d.download.title.en;
    _dlTitleAr.text = d.download.title.ar;
    _appStoreLink.text = d.download.appStoreLink;
    _googlePlay.text = d.download.googlePlayLink;

    for (final m in _mockups) m.dispose();
    _mockups.clear();
    for (final item in d.mockups.items) {
      final local = _MockupLocal(id: item.id);
      local.titleEn.text = item.title.en;
      local.titleAr.text = item.title.ar;
      local.descEn.text = item.description.en;
      local.descAr.text = item.description.ar;
      local.layout = item.layout;
      local.svg = item.svgUrl.isNotEmpty
          ? _PickedImage(url: item.svgUrl)
          : _PickedImage.empty();
      _mockups.add(local);
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    final c = Completer<_PickedImage?>();
    bool done = false;
    final input = html.FileUploadInputElement()..accept = '.svg'; // ONLY SVG
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!done) {
          done = true;
          c.complete(null);
        }
        return;
      }

      // Optional: Add file type validation
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        if (!done) {
          done = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only SVG files are allowed'),
              backgroundColor: Colors.red,
            ),
          );
          c.complete(null);
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        if (!done) {
          done = true;
          final r = reader.result;
          c.complete(
            r is List<int> ? _PickedImage(bytes: Uint8List.fromList(r)) : null,
          );
        }
      });
      reader.onError.listen((_) {
        if (!done) {
          done = true;
          c.complete(null);
        }
      });
      reader.readAsArrayBuffer(file);
    });
    input.click();
    Future.delayed(const Duration(minutes: 5), () {
      if (!done) {
        done = true;
        c.complete(null);
      }
    });
    return c.future;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(
    ClientServicesCmsCubit cubit, {
    String status = 'published',
  }) async {
    setState(() => _submitted = true);
    try {
      cubit.updateHeaderTitle(en: _hdrTitleEn.text, ar: _hdrTitleAr.text);
      cubit.updateHeaderDescription(en: _hdrDescEn.text, ar: _hdrDescAr.text);
      if (_hdrSvg.bytes != null) await cubit.uploadHeaderSvg(_hdrSvg.bytes!);

      cubit.updateDownloadTitle(en: _dlTitleEn.text, ar: _dlTitleAr.text);
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlay.text);

      // Sync mockups count
      while (cubit.current.mockups.items.length < _mockups.length)
        cubit.addMockupItem();
      while (cubit.current.mockups.items.length > _mockups.length)
        cubit.removeMockupItem(cubit.current.mockups.items.last.id);

      for (var i = 0; i < _mockups.length; i++) {
        final id = cubit.current.mockups.items[i].id;
        cubit.updateMockupTitle(
          id,
          en: _mockups[i].titleEn.text,
          ar: _mockups[i].titleAr.text,
        );
        cubit.updateMockupDescription(
          id,
          en: _mockups[i].descEn.text,
          ar: _mockups[i].descAr.text,
        );
        cubit.updateMockupLayout(id, _mockups[i].layout);
        if (_mockups[i].svg.bytes != null)
          await cubit.uploadMockupSvg(id, _mockups[i].svg.bytes!);
      }

      await cubit.save(publishStatus: status);
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e) {
      print('[ClientServicesEditPage] ❌ $e');
      rethrow;
    }
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
              backgroundColor: _C.primary,
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
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

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
                      padding: EdgeInsets.symmetric(

                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing Client Services Details',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
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

                          // ── Buttons ───────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _btn(
                                  'Preview',
                                  _C.primary.withOpacity(0.5),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ClientServicesPreviewPage(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _btn('Publish', _C.primary, () {
                                  // ✅ VALIDATION: Check all required fields before showing confirm dialog
                                  if (!_validate()) {
                                    return;
                                  }
                                  showPublishConfirmDialog(
                                    title: 'EDITING CLIENT SERVICES DETAILS',
                                    subtitle: 'Do you want to save the changes made to this CLIENT SERVICES?',
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
                                  _C.addBtn,
                                  () => Navigator.pop(context),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _btn('Save For Later', _C.addBtn, () {
                                  // ✅ VALIDATION: Check required fields before saving as draft too
                                  if (!_validate()) {
                                    return;
                                  }
                                  showPublishConfirmDialog(
                                    title: 'DRAFTING CLIENT SERVICES DETAILS',
                                    subtitle: 'Do you want to DRAFTING CLIENT SERVICES?',
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

  Widget _btn(String label, Color bg, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
        ),
      ),
    ),
  );

  // ── Accordion ─────────────────────────────────────────────────────────────
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
              color: _C.primary,
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
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16.h,
            ), // Changed from all(16) to symmetric(vertical: 16.h)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _headerBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _label('SVG'),
          if (!_hdrSvg.isEmpty)
            _removeChip(() => setState(() => _hdrSvg = _PickedImage.empty())),
        ],
      ),
      SizedBox(height: 6.h),
      _imgBox(
        picked: _hdrSvg,
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _hdrSvg = p);
        },
      ),
      SizedBox(height: 14.h),
      _biRow('Title', 'العنوان', _hdrTitleEn, _hdrTitleAr, useRow: true),
      SizedBox(height: 10.h),
      _descFields(_hdrDescEn, _hdrDescAr),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _downloadBody() => Column(
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
              submitted: _submitted,
              fillColor: Colors.white,
              primaryColor: _prim,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: 'Android Link',
              hint: 'Insert Links',
              controller: _googlePlay,
              height: 36,
              submitted: _submitted,
              fillColor: Colors.white,
              primaryColor: _prim,
            ),
          ),
        ],
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCKUPS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _mockupsBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...List.generate(_mockups.length, (i) => _mockupRow(i)),
      SizedBox(height: 8.h),
      _addButton('Mockup', () {
        setState(
          () => _mockups.add(
            _MockupLocal(id: 'mock_${DateTime.now().millisecondsSinceEpoch}'),
          ),
        );
      }),
    ],
  );

  Widget _mockupRow(int i) {
    final m = _mockups[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SVG + Remove + Layout chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('SVG'),
              _removeChip(
                () => setState(() {
                  final removed = _mockups.removeAt(i);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => removed.dispose(),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              _imgBox(
                picked: m.svg,
                onPick: () async {
                  final p = await _pickImage();
                  if (p != null) setState(() => m.svg = p);
                },
              ),
              const Spacer(),
              _layoutChipsEdit(m),
            ],
          ),
          SizedBox(height: 10.h),
          _biRow('Title', 'العنوان', m.titleEn, m.titleAr, useRow: true),
          SizedBox(height: 10.h),
          _descFields(m.descEn, m.descAr),
          SizedBox(height: 8.h),
          Divider(color: _C.border),
        ],
      ),
    );
  }

  Widget _layoutChipsEdit(_MockupLocal m) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in MockupLayout.values)
          GestureDetector(
            onTap: () => setState(() => m.layout = l),
            child: Container(
              margin: EdgeInsets.only(left: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: m.layout == l ? _C.primary : Colors.white,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: m.layout == l ? _C.primary : _C.border,
                ),
              ),
              child: Text(
                l.name[0].toUpperCase() + l.name.substring(1),
                style: StyleText.fontSize11Weight400.copyWith(
                  color: m.layout == l ? Colors.white : _C.labelText,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _label(String t) => Text(
    t,
    style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
  );

  Widget _removeChip(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _C.remove,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'Remove',
        style: StyleText.fontSize11Weight400.copyWith(color: Colors.white),
      ),
    ),
  );

  Widget _descFields(TextEditingController en, TextEditingController ar) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomValidatedTextFieldMaster(
            label: 'Description',
            hint: 'Text Here',
            controller: en,
            maxLines: 4,
            showCharCount: true,
            maxLength: 500,
            height: 100,
            submitted: _submitted,
            fillColor: Colors.white,
            primaryColor: _prim,
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف',
              hint: 'أدخل النص هنا',
              controller: ar,
              showCharCount: true,
              maxLength: 500,
              maxLines: 4,
              height: 100,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _prim,
            ),
          ),
        ],
      );

  Widget _biRow(
    String enL,
    String arL,
    TextEditingController enC,
    TextEditingController arC, {
    bool useRow = false,
  }) {
    final en = CustomValidatedTextFieldMaster(
      label: enL,
      hint: 'Text Here',
      fillColor: Colors.white,
      controller: enC,
      height: 36,
      submitted: _submitted,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      primaryColor: _prim,
    );
    final ar = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arL,
        fillColor: Colors.white,
        hint: 'أدخل النص هنا',
        controller: arC,
        height: 36,
        submitted: _submitted,
        textDirection: ui.TextDirection.rtl,
        textAlign: TextAlign.right,
        primaryColor: _prim,
      ),
    );
    if (useRow)
      return Row(
        children: [
          Expanded(child: en),
          SizedBox(width: 16.w),
          Expanded(child: ar),
        ],
      );
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
        color: _C.primary,
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

  Widget _imgBox({required _PickedImage picked, VoidCallback? onPick}) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.scaleDown,
                placeholderBuilder: (_) => _placeholder(),
              ),
            ),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                picked.url!,
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    } else {
      content = _placeholder();
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
                color: _C.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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
      ],
    );
  }

  Widget _placeholder() => Container(
    width: 50.w,
    height: 50.h,
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
