/// ******************* FILE INFO *******************
/// File Name: master_edit.dart
/// Description: Edit page for the Master CMS module.
///              Matches "Editing Home" screenshot with:
///              - Header Section (Image + Visibility, Title EN/AR, Short Desc)
///              - About Us (Title EN/AR, Description EN/AR)
///              - Footer Section (Image + Visibility, Title EN/AR, Desc EN/AR,
///                App Store / Google Play links)
///              - Publish Schedule (date picker) - OPTIONAL
///              - Preview / Publish / Discard / Save For Later buttons
///
///  ✅ Publish button is disabled until ALL required fields are filled
///     AND BOTH SVGs are selected.
///     Publish date is OPTIONAL and does not block publishing.
///     Any validation error keeps the button inactive.
///
///  ✅ DUAL-DOCUMENT ARCHITECTURE:
///     - "Publish"        → saves to published doc, deletes draft
///     - "Save For Later" → saves to draft doc ONLY (published untouched)
///     - "Discard"        → if editing a draft, deletes the draft doc
///     - Schedule mode    → saves to draft doc with status='scheduled'
/// Created by: Amr Mesbah
/// Last Update: 19/04/2026
/// Fixed: setState during build error + publish button validation
/// UPDATED: Dual-document draft system ✅

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
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/widget/date_pic.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/master_model.dart';
import '../../controller/master_cubit.dart';
import '../../controller/master_state.dart';
import 'master_preview.dart';
import 'master_main.dart';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;  // ← add this

part '../widget/master_edit/picked_image.dart';

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
  /// Set to true the first time the user taps Publish, to reveal inline errors.
  bool _submitted = false;

  /// Whether the data currently loaded came from a draft document.
  bool _isEditingDraft = false;

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

  Color get _resolvedPrimaryColor => ColorPick.primary;

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ VALIDATION GATE - Returns true ONLY when ALL required fields are filled
  //    AND all content is valid (no language mixing, proper format)
  // ─────────────────────────────────────────────────────────────────────────

  /// Helper: Check if text is valid for English field (no Arabic chars)
  bool _isValidEnglish(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Helper: Check if text is valid for Arabic field (no English chars)
  bool _isValidArabic(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  bool get _isFormValid {
    // Check English fields (must have content AND no Arabic)
    final englishFieldsOk = _isValidEnglish(_headerTitleEn.text) &&
        _isValidEnglish(_headerShortEn.text) &&
        _isValidEnglish(_aboutTitleEn.text) &&
        _isValidEnglish(_aboutDescEn.text) &&
        _isValidEnglish(_footerTitleEn.text) &&
        _isValidEnglish(_footerDescEn.text);

    // Check Arabic fields (must have content AND no English)
    final arabicFieldsOk = _isValidArabic(_headerTitleAr.text) &&
        _isValidArabic(_headerShortAr.text) &&
        _isValidArabic(_aboutTitleAr.text) &&
        _isValidArabic(_aboutDescAr.text) &&
        _isValidArabic(_footerTitleAr.text) &&
        _isValidArabic(_footerDescAr.text);

    // Check link fields (just need content)
    final linksOk = _appStoreLink.text.trim().isNotEmpty &&
        _googlePlayLink.text.trim().isNotEmpty;

    // Check images (BOTH required)
    final imagesOk = _headerImage.isValid && _footerImage.isValid;

    return englishFieldsOk && arabicFieldsOk && linksOk && imagesOk;
  }

  // Get list of missing or invalid required fields
  List<String> _getMissingFields() {
    final missing = <String>[];

    if (!_headerImage.isValid) missing.add('Header SVG image');

    // English fields - check for empty OR Arabic characters
    if (_headerTitleEn.text.trim().isEmpty) {
      missing.add('Header Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_headerTitleEn.text)) {
      missing.add('Header Title (EN) - contains Arabic characters');
    }

    if (_headerShortEn.text.trim().isEmpty) {
      missing.add('Header Short Description (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_headerShortEn.text)) {
      missing.add('Header Short Description (EN) - contains Arabic characters');
    }

    if (_aboutTitleEn.text.trim().isEmpty) {
      missing.add('About Us Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_aboutTitleEn.text)) {
      missing.add('About Us Title (EN) - contains Arabic characters');
    }

    if (_aboutDescEn.text.trim().isEmpty) {
      missing.add('About Us Description (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_aboutDescEn.text)) {
      missing.add('About Us Description (EN) - contains Arabic characters');
    }

    if (_footerTitleEn.text.trim().isEmpty) {
      missing.add('Footer Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_footerTitleEn.text)) {
      missing.add('Footer Title (EN) - contains Arabic characters');
    }

    if (_footerDescEn.text.trim().isEmpty) {
      missing.add('Footer Description (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_footerDescEn.text)) {
      missing.add('Footer Description (EN) - contains Arabic characters');
    }

    // Arabic fields - check for empty OR English characters
    if (_headerTitleAr.text.trim().isEmpty) {
      missing.add('Header Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_headerTitleAr.text)) {
      missing.add('Header Title (AR) - contains English characters');
    }

    if (_headerShortAr.text.trim().isEmpty) {
      missing.add('Header Short Description (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_headerShortAr.text)) {
      missing.add('Header Short Description (AR) - contains English characters');
    }

    if (_aboutTitleAr.text.trim().isEmpty) {
      missing.add('About Us Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_aboutTitleAr.text)) {
      missing.add('About Us Title (AR) - contains English characters');
    }

    if (_aboutDescAr.text.trim().isEmpty) {
      missing.add('About Us Description (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_aboutDescAr.text)) {
      missing.add('About Us Description (AR) - contains English characters');
    }

    if (!_footerImage.isValid) missing.add('Footer SVG image');

    if (_footerTitleAr.text.trim().isEmpty) {
      missing.add('Footer Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_footerTitleAr.text)) {
      missing.add('Footer Title (AR) - contains English characters');
    }

    if (_footerDescAr.text.trim().isEmpty) {
      missing.add('Footer Description (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_footerDescAr.text)) {
      missing.add('Footer Description (AR) - contains English characters');
    }

    if (_appStoreLink.text.trim().isEmpty) missing.add('App Store Link');
    if (_googlePlayLink.text.trim().isEmpty) missing.add('Google Play Link');

    return missing;
  }

  // ─── Init / Dispose ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    print('[MasterEditPage] ✅ initState');
    _seededModelHash = null;

    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  List<TextEditingController> get _allControllers => [
    _headerTitleEn,
    _headerTitleAr,
    _headerShortEn,
    _headerShortAr,
    _aboutTitleEn,
    _aboutTitleAr,
    _aboutDescEn,
    _aboutDescAr,
    _footerTitleEn,
    _footerTitleAr,
    _footerDescEn,
    _footerDescAr,
    _appStoreLink,
    _googlePlayLink,
  ];

  void _onFieldChanged() {
    // Schedule setState for after the current build phase to avoid setState during build
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    print('[MasterEditPage] 🔴 dispose');
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    super.dispose();
  }

  // ─── Seed from model ──────────────────────────────────────────────────────
  void _seedFromModel(MasterPageModel d, {bool isFromDraft = false}) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl + s.sectionKey),
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;
    _isEditingDraft  = isFromDraft;
    print('[MasterEditPage] _seedFromModel: ▶ seeding (isFromDraft=$isFromDraft)');

    // Remove listeners temporarily to prevent setState during build
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
    }

    final header = d.sectionByKey('header');
    _headerTitleEn.text = header?.title.en ?? '';
    _headerTitleAr.text = header?.title.ar ?? '';
    _headerShortEn.text = header?.shortDescription.en ?? '';
    _headerShortAr.text = header?.shortDescription.ar ?? '';
    _headerImage = (header?.imageUrl.isNotEmpty ?? false)
        ? _PickedImage(url: header!.imageUrl)
        : const _PickedImage();
    _headerVisibility = header?.visibility ?? true;

    final about = d.sectionByKey('aboutUs');
    _aboutTitleEn.text = about?.title.en ?? '';
    _aboutTitleAr.text = about?.title.ar ?? '';
    _aboutDescEn.text  = about?.description.en ?? '';
    _aboutDescAr.text  = about?.description.ar ?? '';

    final footer = d.sectionByKey('footer');
    _footerTitleEn.text = footer?.title.en ?? '';
    _footerTitleAr.text = footer?.title.ar ?? '';
    _footerDescEn.text  = footer?.description.en ?? '';
    _footerDescAr.text  = footer?.description.ar ?? '';
    _footerImage = (footer?.imageUrl.isNotEmpty ?? false)
        ? _PickedImage(url: footer!.imageUrl)
        : const _PickedImage();
    _footerVisibility = footer?.visibility ?? true;

    _appStoreLink.text   = d.appLinks.appStoreLink;
    _googlePlayLink.text = d.appLinks.googlePlayLink;

    _publishDate = d.publishSchedule.publishDate;

    // Re-add listeners after seeding
    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }

    print('[MasterEditPage] _seedFromModel: ✅ DONE');
  }

  // ─── Build draft model from current form state ────────────────────────────
  MasterPageModel _buildDraftModel(MasterCmsCubit cubit) {
    final base = cubit.current;

    final patchedSections = base.sections.map((section) {
      switch (section.sectionKey) {
        case 'header':
          return section.copyWith(
            title: BiText(en: _headerTitleEn.text, ar: _headerTitleAr.text),
            shortDescription: BiText(en: _headerShortEn.text, ar: _headerShortAr.text),
            imageUrl: _headerImage.url ?? section.imageUrl,
            visibility: _headerVisibility,
          );
        case 'aboutUs':
          return section.copyWith(
            title: BiText(en: _aboutTitleEn.text, ar: _aboutTitleAr.text),
            description: BiText(en: _aboutDescEn.text, ar: _aboutDescAr.text),
          );
        case 'footer':
          return section.copyWith(
            title: BiText(en: _footerTitleEn.text, ar: _footerTitleAr.text),
            description: BiText(en: _footerDescEn.text, ar: _footerDescAr.text),
            imageUrl: _footerImage.url ?? section.imageUrl,
            visibility: _footerVisibility,
          );
        default:
          return section;
      }
    }).toList();

    return base.copyWith(
      sections: patchedSections,
      appLinks: MasterAppLinkModel(
        appStoreLink:   _appStoreLink.text,
        googlePlayLink: _googlePlayLink.text,
      ),
      publishSchedule: MasterPublishScheduleModel(publishDate: _publishDate),
    );
  }

  // ─── Image picker (SVG only) ──────────────────────────────────────────────
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

  // ─── Date picker ──────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final datePicker = DatePicker();

    List<DateTime?>? initialValue;
    if (_publishDate != null) {
      initialValue = [_publishDate];
    }

    final result = await datePicker.showDatePicker(
      context,
      initialValue ?? [],
      _publishDate ?? DateTime.now(),
      CalendarDatePicker2Type.single,
      firstDate: DateTime.now(),
    );

    if (result != null && result.isNotEmpty && result[0] != null) {
      setState(() {
        _publishDate = result[0];
      });
    }
  }

  // ─── Validation error dialog ──────────────────────────────────────────────
  void _showValidationError() {
    final missing = _getMissingFields();

    if (missing.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: ColorPick.red, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Validation Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please fill all required fields:'),
            const SizedBox(height: 12),
            ...missing.map((field) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: ColorPick.red)),
                  Expanded(child: Text(field)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(MasterCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    // Only validate fully for 'published' — drafts can be partial
    if (publishStatus == 'published') {
      setState(() => _submitted = true);
      if (!_isFormValid) {
        _showValidationError();
        return;
      }
    }

    try {
      cubit.updateSectionTitle('header',
          en: _headerTitleEn.text, ar: _headerTitleAr.text);
      cubit.updateSectionShortDescription('header',
          en: _headerShortEn.text, ar: _headerShortAr.text);

      if (_headerImage.bytes != null) {
        await cubit.uploadSectionImage('header', _headerImage.bytes!);
      }
      final headerModel = cubit.current.sectionByKey('header');
      if (headerModel != null && headerModel.visibility != _headerVisibility) {
        cubit.toggleSectionVisibility('header');
      }

      cubit.updateSectionTitle('aboutUs',
          en: _aboutTitleEn.text, ar: _aboutTitleAr.text);
      cubit.updateSectionDescription('aboutUs',
          en: _aboutDescEn.text, ar: _aboutDescAr.text);

      cubit.updateSectionTitle('footer',
          en: _footerTitleEn.text, ar: _footerTitleAr.text);
      cubit.updateSectionDescription('footer',
          en: _footerDescEn.text, ar: _footerDescAr.text);
      if (_footerImage.bytes != null) {
        await cubit.uploadSectionImage('footer', _footerImage.bytes!);
      }
      final footerModel = cubit.current.sectionByKey('footer');
      if (footerModel != null && footerModel.visibility != _footerVisibility) {
        cubit.toggleSectionVisibility('footer');
      }

      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlayLink.text);
      cubit.updatePublishDate(_publishDate);

      // ── Determine final status ──────────────────────────────────────────
      // If the user clicks "Publish" BUT a future schedule date is set,
      // override to 'scheduled' → saves as draft, published stays live.
      // The Cloud Function will auto-promote when the date arrives.
      String finalStatus = publishStatus;
      if (publishStatus == 'published' && _publishDate != null) {
        final now = DateTime.now();
        if (_publishDate!.isAfter(now)) {
          finalStatus = 'scheduled';
          print('[MasterEditPage] _save: 📅 schedule date is in the future '
              '(${_publishDate!.toIso8601String()}) → overriding to "scheduled"');
        }
        // If the date is in the past or today, publish immediately as normal
      }

      await cubit.save(publishStatus: finalStatus);
      Get.forceAppUpdate();

      // Navigation is handled in the BlocConsumer listener
    } catch (e, st) {
      print('[MasterEditPage] _save: ❌ ERROR: $e\n$st');
      if (mounted) {

      }
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterCmsCubit, MasterCmsState>(
      listener: (context, state) {
        print('[MasterEditPage] 👂 listener: ${state.runtimeType}');

        // ── Published successfully ──────────────────────────────────────
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

        // ── Draft saved successfully ────────────────────────────────────
        if (state is MasterCmsDraftSaved) {
          if (mounted) {

          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MasterMainPage()),
                    (route) => false,
              );
            }
          });
        }

        // ── Draft deleted (discard) ─────────────────────────────────────
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

        // ── Error ───────────────────────────────────────────────────────
        if (state is MasterCmsError) {
          if (mounted) {

          }
        }
      },
      builder: (context, state) {
        if (state is MasterCmsLoaded) {
          // Schedule seeding after build completes
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
                      padding: EdgeInsets.symmetric( vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title row with draft badge ─────────────────────
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
                                    color: ColorPick.draftColor.withOpacity(0.15),
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

  // ─── Accordion widget ─────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
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
                    topLeft:  Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Image'),
              Row(children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: ColorPick.primary,
                  inactiveColor: Colors.grey.withOpacity(.16),
                  value: _headerVisibility,
                  onToggle: (val) => setState(() => _headerVisibility = val),
                ),
              ]),
            ],
          ),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _headerImage,
            // In _headerSectionBody onPick:
            onPick: () async {
              print('[Header] onPick tapped');
              final p = await _pickImage();
              print('[Header] _pickImage returned: ${p == null ? 'null' : 'bytes=${p.bytes?.length}'}');
              if (p != null && mounted) {
                print('[Header] calling setState with new image');
                setState(() => _headerImage = p);
              } else {
                print('[Header] ❌ NOT setting state — p=$p mounted=$mounted');
              }
            },
          ),
          if (_submitted && _headerImage.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Header SVG image is required',
                style: StyleText.fontSize12Weight400.copyWith(color: ColorPick.red),
              ),
            ),
          SizedBox(height: 14.h),
          _biRow('Title *', 'العنوان *', _headerTitleEn, _headerTitleAr,
              useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Short Description *',
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
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'وصف مختصر *',
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
          _biRow('Title *', 'العنوان *', _aboutTitleEn, _aboutTitleAr,
              useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Description *',
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
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف *',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Image *'),
              Row(children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: ColorPick.primary,
                  inactiveColor: Colors.grey.withOpacity(.16),
                  value: _footerVisibility,
                  onToggle: (val) => setState(() => _footerVisibility = val),
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
          if (_submitted && _footerImage.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Footer SVG image is required',
                style: StyleText.fontSize12Weight400.copyWith(color: ColorPick.red),
              ),
            ),
          SizedBox(height: 14.h),
          _biRow('Title *', 'العنوان *', _footerTitleEn, _footerTitleAr,
              useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Description *',
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
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف *',
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
          Row(children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'App Store Link *',
                hint: 'Insert Apple Link',
                controller: _appStoreLink,
                height: 36,
                submitted: _submitted,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Google Play Link *',
                hint: 'Insert Android Link',
                controller: _googlePlayLink,
                height: 36,
                submitted: _submitted,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Publish Schedule body (OPTIONAL - no validation) ─────────────────────
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
                    _sectionLabel('Publish Date (Optional)'),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 36.h,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _publishDate != null
                                    ? DateFormat('dd MMM yyyy').format(_publishDate!)
                                    : 'Select date',
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: _publishDate != null ? AppColors.text : AppColors.secondaryText,
                                ),
                              ),
                            ),
                            CustomSvg(assetPath: "assets/calendar.svg",width: 20.w,height: 20.h,fit: BoxFit.scaleDown,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: Column()),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Action buttons: Preview + Publish ────────────────────────────────────
  Widget _actionButtons(MasterCmsCubit cubit) {
    final bool canPublish = _isFormValid;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              final draft = _buildDraftModel(cubit);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: MasterPreviewPage(previewModel: draft),
                  ),
                ),
              );
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Color(0xFF8A5C70),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Preview',
                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
        SizedBox(width: 300.w),

        Expanded(
          child: AbsorbPointer(
            absorbing: !canPublish,
            child: Opacity(
              opacity: canPublish ? 1.0 : 0.6,
              child: GestureDetector(
                onTap: () {
                  if (!canPublish) {
                    setState(() => _submitted = true);
                    _showValidationError();
                    return;
                  }
                  final bool isScheduled = _publishDate != null &&
                      _publishDate!.isAfter(DateTime.now());

                  showPublishConfirmDialog(
                    title: isScheduled
                        ? 'SCHEDULE HOMEPAGE'
                        : 'EDITING HOMEPAGE DETAILS',
                    subtitle: isScheduled
                        ? 'Your changes will be scheduled for '
                        '${DateFormat('dd/MM/yyyy').format(_publishDate!)}. '
                        'The published version will remain live until then.'
                        : 'Do you want to save the changes made to this HOMEPAGE?',
                    context: context,
                    onConfirm: () => _save(cubit, publishStatus: 'published'),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: canPublish ? ColorPick.primary : ColorPick.primary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Publish',
                            style: StyleText.fontSize14Weight600.copyWith(
                              color: Colors.white.withOpacity(canPublish ? 1.0 : 0.55),
                            )),
                      ],
                    ),
                  ),
                ),
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
        // ── Discard button ────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isEditingDraft) {
                // If editing a draft, confirm before deleting it
                showPublishConfirmDialog(
                  title: 'DISCARD DRAFT',
                  subtitle:
                  'Are you sure you want to discard this draft? '
                      'The published version will remain unchanged.',
                  context: context,
                  onConfirm: () => cubit.discardDraft(),
                );
              } else {
                // Not editing a draft — just navigate back
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MasterMainPage()),
                  );
                }
              }
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF797979),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Discard',
                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
        SizedBox(width: 300.w),

        //GestureDetector(
        //             onTap: () {
        //               showPublishConfirmDialog(
        //                 title: 'SAVE AS DRAFT',
        //                 subtitle:
        //                 'Your changes will be saved as a draft. '
        //                     'The published version will remain live and unchanged.',
        //                 context: context,
        //                 onConfirm: () => _save(cubit, publishStatus: 'draft'),
        //               );
        //             },
        //             child: Container(
        //               height: 44.h,
        //               decoration: BoxDecoration(
        //                 color: const Color(0xFF797979),
        //                 borderRadius: BorderRadius.circular(6.r),
        //               ),
        //               child: Center(
        //                 child: Text('Save For Later',
        //                     style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
        //               ),
        //             ),
        //           ),
        // ── Save For Later button (saves as DRAFT, published stays live) ─
        Expanded(
          child: Expanded(child: Container())
        ),
      ],
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

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
      print('[_imgBox] rendering bytes: ${picked.bytes!.length}');

      final dataUrl = _svgBytesToDataUrl(picked.bytes!);
      final viewId = 'svg-preview-${picked.bytes!.hashCode}';

      // ignore: undefined_prefixed_name
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
    }

    else if (picked.url != null && picked.url!.isNotEmpty) {
      print('[_imgBox] rendering from URL: ${picked.url}');

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
    }

    else {
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
