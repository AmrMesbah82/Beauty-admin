/// ******************* FILE INFO *******************
/// File Name: master_edit_page.dart
/// Description: Edit page for the Master CMS module.
///              Matches "Editing Home" screenshot with:
///              - Header Section (Image + Visibility, Title EN/AR, Short Desc)
///              - About Us (Title EN/AR, Description EN/AR)
///              - Footer Section (Image + Visibility, Title EN/AR, Desc EN/AR,
///                App Store / Google Play links)
///              - Publish Schedule (date picker)
///              - Preview / Publish / Discard / Save For Later buttons
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

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
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/master/master_cubit.dart';
import '../../controller/master/master_state.dart';
import '../../core/widget/date_pic.dart';
import '../../model/master/master_model.dart';
import 'master_preview_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
}

// ── Picked image helper ──────────────────────────────────────────────────────
class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

class MasterEditPage extends StatefulWidget {
  const MasterEditPage({super.key});

  @override
  State<MasterEditPage> createState() => _MasterEditPageState();
}

class _MasterEditPageState extends State<MasterEditPage> {
  bool _submitted = false;

  // ── Seed guard ────────────────────────────────────────────────────────────
  int? _seededModelHash;

  // ── Header Section fields ─────────────────────────────────────────────────
  final _headerTitleEn    = TextEditingController();
  final _headerTitleAr    = TextEditingController();
  final _headerShortEn    = TextEditingController();
  final _headerShortAr    = TextEditingController();
  _PickedImage _headerImage = const _PickedImage();
  bool _headerVisibility   = true;

  // ── About Us Section fields ───────────────────────────────────────────────
  final _aboutTitleEn = TextEditingController();
  final _aboutTitleAr = TextEditingController();
  final _aboutDescEn  = TextEditingController();
  final _aboutDescAr  = TextEditingController();

  // ── Footer Section fields ─────────────────────────────────────────────────
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

  Color get _resolvedPrimaryColor => _C.primary;

  // ─── Init / Dispose ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    print('[MasterEditPage] ✅ initState');
    _seededModelHash = null;
  }

  @override
  void dispose() {
    print('[MasterEditPage] 🔴 dispose');
    _headerTitleEn.dispose();
    _headerTitleAr.dispose();
    _headerShortEn.dispose();
    _headerShortAr.dispose();
    _aboutTitleEn.dispose();
    _aboutTitleAr.dispose();
    _aboutDescEn.dispose();
    _aboutDescAr.dispose();
    _footerTitleEn.dispose();
    _footerTitleAr.dispose();
    _footerDescEn.dispose();
    _footerDescAr.dispose();
    _appStoreLink.dispose();
    _googlePlayLink.dispose();
    super.dispose();
  }

  // ─── Seed from model ──────────────────────────────────────────────────────
  void _seedFromModel(MasterPageModel d) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl + s.sectionKey),
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;
    print('[MasterEditPage] _seedFromModel: ▶ seeding');

    // ── Header ─────────────────────────────────────────────────────────────
    final header = d.sectionByKey('header');
    _headerTitleEn.text = header?.title.en ?? '';
    _headerTitleAr.text = header?.title.ar ?? '';
    _headerShortEn.text = header?.shortDescription.en ?? '';
    _headerShortAr.text = header?.shortDescription.ar ?? '';
    _headerImage = (header?.imageUrl.isNotEmpty ?? false)
        ? _PickedImage(url: header!.imageUrl)
        : const _PickedImage();
    _headerVisibility = header?.visibility ?? true;

    // ── About Us ───────────────────────────────────────────────────────────
    final about = d.sectionByKey('aboutUs');
    _aboutTitleEn.text = about?.title.en ?? '';
    _aboutTitleAr.text = about?.title.ar ?? '';
    _aboutDescEn.text  = about?.description.en ?? '';
    _aboutDescAr.text  = about?.description.ar ?? '';

    // ── Footer ─────────────────────────────────────────────────────────────
    final footer = d.sectionByKey('footer');
    _footerTitleEn.text = footer?.title.en ?? '';
    _footerTitleAr.text = footer?.title.ar ?? '';
    _footerDescEn.text  = footer?.description.en ?? '';
    _footerDescAr.text  = footer?.description.ar ?? '';
    _footerImage = (footer?.imageUrl.isNotEmpty ?? false)
        ? _PickedImage(url: footer!.imageUrl)
        : const _PickedImage();
    _footerVisibility = footer?.visibility ?? true;

    // ── App Links ──────────────────────────────────────────────────────────
    _appStoreLink.text   = d.appLinks.appStoreLink;
    _googlePlayLink.text = d.appLinks.googlePlayLink;

    // ── Publish schedule ───────────────────────────────────────────────────
    _publishDate = d.publishSchedule.publishDate;

    print('[MasterEditPage] _seedFromModel: ✅ DONE');
  }

  // ─── Image picker (SVG only) ──────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    print('[MasterEditPage] _pickImage: opening file picker');
    final completer = Completer<_PickedImage?>();
    bool completed  = false;

    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Only SVG files are allowed',
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ));
          }
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is List<int>) {
            completer.complete(
                _PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) {
        if (!completed) { completed = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();

    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) { completed = true; completer.complete(null); }
    });

    return completer.future;
  }

  // ─── Date picker ──────────────────────────────────────────────────────────
// Replace the existing _pickDate method with this:

  Future<void> _pickDate() async {
    // Create an instance of your DatePicker class
    final datePicker = DatePicker();

    // Prepare the initial value (if any)
    List<DateTime?>? initialValue;
    if (_publishDate != null) {
      initialValue = [_publishDate];
    }

    // Show your custom date picker
    final result = await datePicker.showDatePicker(
      context,
      initialValue ?? [],
      _publishDate ?? DateTime.now(),
      CalendarDatePicker2Type.single, // Use 'single' since you're picking a single date
      firstDate: DateTime.now(), // To prevent selecting past dates
    );

    // Handle the result
    if (result != null && result.isNotEmpty && result[0] != null) {
      setState(() {
        _publishDate = result[0];
      });
    }
  }

  Future<void> _save(MasterCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    setState(() => _submitted = true);

    try {
      // ── Header / main root-level fields ──
      // cubit.updateTitle(en: _headerTitleEn.text, ar: _headerTitleAr.text);
      // cubit.updateShortDescription(
      //     en: _headerShortEn.text, ar: _headerShortAr.text);

      // ── ALSO sync to header section-level fields ──
      // (so public site can read from either root or section)
      cubit.updateSectionTitle('header',
          en: _headerTitleEn.text, ar: _headerTitleAr.text);
      cubit.updateSectionShortDescription('header',
          en: _headerShortEn.text, ar: _headerShortAr.text);

      // Header section image + visibility
      if (_headerImage.bytes != null) {
        await cubit.uploadSectionImage('header', _headerImage.bytes!);
      }
      final headerModel = cubit.current.sectionByKey('header');
      if (headerModel != null &&
          headerModel.visibility != _headerVisibility) {
        cubit.toggleSectionVisibility('header');
      }

      // ── About Us ──
      cubit.updateSectionTitle('aboutUs',
          en: _aboutTitleEn.text, ar: _aboutTitleAr.text);
      cubit.updateSectionDescription('aboutUs',
          en: _aboutDescEn.text, ar: _aboutDescAr.text);

      // ── Footer ──
      cubit.updateSectionTitle('footer',
          en: _footerTitleEn.text, ar: _footerTitleAr.text);
      cubit.updateSectionDescription('footer',
          en: _footerDescEn.text, ar: _footerDescAr.text);
      if (_footerImage.bytes != null) {
        await cubit.uploadSectionImage('footer', _footerImage.bytes!);
      }
      final footerModel = cubit.current.sectionByKey('footer');
      if (footerModel != null &&
          footerModel.visibility != _footerVisibility) {
        cubit.toggleSectionVisibility('footer');
      }

      // ── App links ──
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlayLink.text);

      // ── Publish schedule ──
      cubit.updatePublishDate(_publishDate);

      await cubit.save(publishStatus: publishStatus);
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[MasterEditPage] _save: ❌ ERROR: $e\n$st');
      rethrow;
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterCmsCubit, MasterCmsState>(
      listener: (context, state) {
        print('[MasterEditPage] 👂 listener: ${state.runtimeType}');
        if (state is MasterCmsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Master page saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }
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
        if (state is MasterCmsLoaded) _seedFromModel(state.data);

        final cubit = context.read<MasterCmsCubit>();

        if (state is MasterCmsInitial || state is MasterCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
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
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing Home',
                            style: StyleText.fontSize45Weight600.copyWith(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ── Header Section ─────────────────────────
                          _accordion(
                            key: 'header',
                            title: 'Header Section',
                            children: [_headerSectionBody()],
                          ),
                          SizedBox(height: 10.h),

                          // ── About Us ───────────────────────────────
                          _accordion(
                            key: 'aboutUs',
                            title: 'About Us',
                            children: [_aboutUsSectionBody()],
                          ),
                          SizedBox(height: 10.h),

                          // ── Footer Section ─────────────────────────
                          _accordion(
                            key: 'footer',
                            title: 'Footer Section',
                            children: [_footerSectionBody()],
                          ),
                          SizedBox(height: 10.h),

                          // ── Publish Schedule ───────────────────────
                          _accordion(
                            key: 'schedule',
                            title: 'Publish Schedule',
                            children: [_publishScheduleBody()],
                          ),


                          // ── Action buttons ─────────────────────────
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

  // ─── Accordion widget ─────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (isOpen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }

  // ─── Header Section body ──────────────────────────────────────────────────
  Widget _headerSectionBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + Visibility ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Image'),
              Row(children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: _C.labelText)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: _C.primary,
                  inactiveColor: Colors.grey.withOpacity(.16),
                  value: _headerVisibility,
                  onToggle: (val) =>
                      setState(() => _headerVisibility = val),
                ),
              ]),
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
          SizedBox(height: 14.h),

          // ── Title EN / AR ──────────────────────────────────────────────
          _biRow('Title', 'العنوان', _headerTitleEn, _headerTitleAr,
              useRow: true),
          SizedBox(height: 10.h),

          // ── Short Description EN ───────────────────────────────────────
          CustomValidatedTextFieldMaster(
            label: 'Short Description',
            hint: 'Text Here',
            controller: _headerShortEn,
            height: 36,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            primaryColor: _resolvedPrimaryColor,
          ),
          SizedBox(height: 10.h),

          // ── Short Description AR ───────────────────────────────────────
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'وصف مختصر',
              hint: 'أدخل النص هنا',
              controller: _headerShortAr,
              height: 36,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── About Us body ────────────────────────────────────────────────────────
  Widget _aboutUsSectionBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title EN / AR ──────────────────────────────────────────────
          _biRow('Title', 'العنوان', _aboutTitleEn, _aboutTitleAr,
              useRow: true),
          SizedBox(height: 10.h),

          // ── Description EN ─────────────────────────────────────────────
          CustomValidatedTextFieldMaster(
            label: 'Description',
            hint: 'Text Here',
            controller: _aboutDescEn,
            maxLines: 5,
            maxLength: 10000,
            height: 120,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            primaryColor: _resolvedPrimaryColor,
          ),
          SizedBox(height: 10.h),

          // ── Description AR ─────────────────────────────────────────────
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف',
              hint: 'أدخل النص هنا',
              controller: _aboutDescAr,
              maxLines: 5,
              height: 120,
              maxLength: 10000,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer Section body ──────────────────────────────────────────────────
  Widget _footerSectionBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + Visibility ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Image'),
              Row(children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: _C.labelText)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: _C.primary,
                  inactiveColor: Colors.grey.withOpacity(.16),
                  value: _footerVisibility,
                  onToggle: (val) =>
                      setState(() => _footerVisibility = val),
                ),
              ]),
            ],
          ),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _footerImage,
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => _footerImage = p);
            },
          ),
          SizedBox(height: 14.h),

          // ── Title EN / AR ──────────────────────────────────────────────
          _biRow('Title', 'العنوان', _footerTitleEn, _footerTitleAr,
              useRow: true),
          SizedBox(height: 10.h),

          // ── Description EN ─────────────────────────────────────────────
          CustomValidatedTextFieldMaster(
            label: 'Description',
            hint: 'Text Here',
            controller: _footerDescEn,
            maxLines: 5,
            height: 120,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            primaryColor: _resolvedPrimaryColor,
          ),
          SizedBox(height: 10.h),

          // ── Description AR ─────────────────────────────────────────────
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف',
              hint: 'أدخل النص هنا',
              controller: _footerDescAr,
              maxLines: 5,
              height: 120,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimaryColor,
            ),
          ),
          SizedBox(height: 14.h),

          // ── App Links ──────────────────────────────────────────────────
          Row(children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'ID',
                hint: 'Insert Apple Link',
                controller: _appStoreLink,
                height: 36,
                submitted: false,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: '',
                hint: 'Insert Android Link',
                controller: _googlePlayLink,
                height: 36,
                submitted: false,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Publish Schedule body ────────────────────────────────────────────────
  Widget _publishScheduleBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Publish Date'),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 36.h,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _publishDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_publishDate!)
                                    : 'select date',
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: _publishDate != null
                                      ? _C.labelText
                                      : _C.hintText,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                size: 16.sp, color: _C.hintText),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: Column())
            ],
          ),
        ],
      ),
    );
  }

  // ─── Action buttons: Preview + Publish ────────────────────────────────────
  Widget _actionButtons(MasterCmsCubit cubit) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
// New code using standard navigation
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MasterPreviewPage()), // Adjust widget name
            ),            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Preview',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
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
                onConfirm: () =>
                    _save(cubit, publishStatus: 'published'),
              );
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Publish',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Secondary buttons: Discard + Save For Later ──────────────────────────
  Widget _secondaryButtons(MasterCmsCubit cubit) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF797979),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Discard',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
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
                onConfirm: () =>
                    _save(cubit, publishStatus: 'draft'),
              );
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF797979),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Save For Later',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style:
      StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _biRow(
      String enLabel,
      String arLabel,
      TextEditingController enCtrl,
      TextEditingController arCtrl, {
        int maxLines = 1,
        bool useRow = false,
      }) {
    final double fieldH = maxLines > 1 ? 120 : 36;
    final enField = CustomValidatedTextFieldMaster(
      label: enLabel,
      hint: 'Text Here',
      fillColor: Colors.white,
      controller: enCtrl,
      maxLines: maxLines,
      height: fieldH,
      submitted: _submitted,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      primaryColor: _resolvedPrimaryColor,
    );
    final arField = Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomValidatedTextFieldMaster(
        label: arLabel,
        fillColor: Colors.white,
        hint: 'أدخل النص هنا',
        controller: arCtrl,
        maxLines: maxLines,
        height: fieldH,
        submitted: _submitted,
        textDirection: ui.TextDirection.rtl,
        textAlign: TextAlign.right,
        primaryColor: _resolvedPrimaryColor,
      ),
    );
    if (useRow) {
      return Row(children: [
        Expanded(child: enField),
        SizedBox(width: 16.w),
        Expanded(child: arField),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [enField, SizedBox(height: 10.h), arField],
    );
  }

  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.scaleDown,
                placeholderBuilder: (_) => _placeholderCircle(),
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
            color: Colors.white, shape: BoxShape.circle),
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
        fit: BoxFit.fill,
      ),
    ),
  );
}