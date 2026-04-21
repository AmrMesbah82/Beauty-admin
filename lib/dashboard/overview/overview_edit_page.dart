/// ******************* FILE INFO *******************
/// File Name: overview_edit_page.dart
/// Description: Edit page for Master CMS (Overview-style).
///              Sections: Headings, Services (+Service btn, dynamic),
///              Gallery (+Image btn, dynamic 12 slots),
///              Client Comments (+Feedback btn, dynamic),
///              Download Applications, Publish Schedule.
///              Buttons: Preview / Publish / Discard / Save For Later.
///
///  ✅ Publish button is disabled until ALL required fields are filled
///     AND validation passes (no language mixing in EN/AR fields)
///     Publish date is REQUIRED for overview (blocks publishing)
///     Any validation error keeps the button inactive
///
///  ✅ DUAL-DOCUMENT ARCHITECTURE:
///     - "Publish" (no schedule date)  → saves to published doc, deletes draft
///     - "Publish" (with future date)  → saves to draft doc with status='scheduled'
///     - "Save For Later"              → saves to draft doc ONLY (published untouched)
///     - "Discard" (editing draft)     → deletes the draft doc
///     - Schedule mode                 → saves to draft doc with status='scheduled'
///
/// Created by: Amr Mesbah
/// Last Update: 19/04/2026
/// UPDATED: Dual-document draft system ✅

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
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/overview/overview_cubit.dart';
import '../../controller/overview/overview_state.dart';
import '../../model/overview/overview_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';
import 'overview_main_page.dart';
import 'overview_preview_page.dart';

class _C {
  static const Color primary    = Color(0xFFD16F9A);
  static const Color sectionBg  = Color(0xFFF5F5F5);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color remove     = Color(0xFFE53935);
  static const Color back       = Color(0xFFF1F2ED);
  static const Color addBtn     = Color(0xFF797979);
  static const Color error      = Color(0xFFE53935);
  static const Color draftBadge = Color(0xFFF59E0B);
}

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
  bool get isValid => bytes != null || (url != null && url!.isNotEmpty);
}

// ── Local service item for editing ───────────────────────────────────────────
class _ServiceLocal {
  final String id;
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  _PickedImage image;

  _ServiceLocal({required this.id})
      : nameEn = TextEditingController(),
        nameAr = TextEditingController(),
        image = const _PickedImage();

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

// ── Local gallery item ───────────────────────────────────────────────────────
class _GalleryLocal {
  final String id;
  _PickedImage image;
  _GalleryLocal({required this.id}) : image = const _PickedImage();

  void dispose() {}
}

// ── Local client comment item ────────────────────────────────────────────────
class _CommentLocal {
  final String id;
  final TextEditingController firstNameEn;
  final TextEditingController firstNameAr;
  final TextEditingController lastNameEn;
  final TextEditingController lastNameAr;
  final TextEditingController feedbackEn;
  final TextEditingController feedbackAr;
  _PickedImage image;

  _CommentLocal({required this.id})
      : firstNameEn = TextEditingController(),
        firstNameAr = TextEditingController(),
        lastNameEn  = TextEditingController(),
        lastNameAr  = TextEditingController(),
        feedbackEn  = TextEditingController(),
        feedbackAr  = TextEditingController(),
        image = const _PickedImage();

  void dispose() {
    firstNameEn.dispose();
    firstNameAr.dispose();
    lastNameEn.dispose();
    lastNameAr.dispose();
    feedbackEn.dispose();
    feedbackAr.dispose();
  }
}

class OverviewEditPage extends StatefulWidget {
  const OverviewEditPage({super.key});

  @override
  State<OverviewEditPage> createState() => _OverviewEditPageState();
}

class _OverviewEditPageState extends State<OverviewEditPage> {
  bool _submitted = false;
  bool _hasSeededOnce = false;

  /// Whether the data currently loaded came from a draft document.
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
    'headings': true,
    'services': true,
    'gallery': true,
    'comments': true,
    'download': true,
    'schedule': true,
  };

  Color get _resolvedPrimary => _C.primary;

  bool _isValidEnglish(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  bool _isValidArabic(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  bool get _isFormValid {
    final headingsOk = _isValidEnglish(_headTitleEn.text) &&
        _isValidArabic(_headTitleAr.text) &&
        _isValidEnglish(_headDescEn.text) &&
        _isValidArabic(_headDescAr.text);

    final svcTitleOk = _isValidEnglish(_svcTitleEn.text) &&
        _isValidArabic(_svcTitleAr.text);

    bool servicesOk = true;
    for (var i = 0; i < _services.length; i++) {
      if (!_isValidEnglish(_services[i].nameEn.text) ||
          !_isValidArabic(_services[i].nameAr.text)) {
        servicesOk = false;
        break;
      }
    }
    servicesOk = servicesOk && _services.isNotEmpty;

    final cmtTitleOk = _isValidEnglish(_cmtTitleEn.text) &&
        _isValidArabic(_cmtTitleAr.text);

    bool commentsOk = true;
    for (var i = 0; i < _comments.length; i++) {
      if (!_isValidEnglish(_comments[i].firstNameEn.text) ||
          !_isValidArabic(_comments[i].firstNameAr.text) ||
          !_isValidEnglish(_comments[i].lastNameEn.text) ||
          !_isValidArabic(_comments[i].lastNameAr.text) ||
          !_isValidEnglish(_comments[i].feedbackEn.text) ||
          !_isValidArabic(_comments[i].feedbackAr.text)) {
        commentsOk = false;
        break;
      }
    }
    commentsOk = commentsOk && _comments.isNotEmpty;

    final dlTitleOk = _isValidEnglish(_dlTitleEn.text) &&
        _isValidArabic(_dlTitleAr.text);

    final publishDateOk = _publishDate != null;

    return headingsOk && svcTitleOk && servicesOk && cmtTitleOk &&
        commentsOk && dlTitleOk && publishDateOk;
  }

  List<String> _getMissingFields() {
    final missing = <String>[];

    if (_headTitleEn.text.trim().isEmpty) {
      missing.add('Heading Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_headTitleEn.text)) {
      missing.add('Heading Title (EN) - contains Arabic characters');
    }
    if (_headTitleAr.text.trim().isEmpty) {
      missing.add('Heading Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_headTitleAr.text)) {
      missing.add('Heading Title (AR) - contains English characters');
    }
    if (_headDescEn.text.trim().isEmpty) {
      missing.add('Heading Description (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_headDescEn.text)) {
      missing.add('Heading Description (EN) - contains Arabic characters');
    }
    if (_headDescAr.text.trim().isEmpty) {
      missing.add('Heading Description (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_headDescAr.text)) {
      missing.add('Heading Description (AR) - contains English characters');
    }

    if (_svcTitleEn.text.trim().isEmpty) {
      missing.add('Services Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_svcTitleEn.text)) {
      missing.add('Services Title (EN) - contains Arabic characters');
    }
    if (_svcTitleAr.text.trim().isEmpty) {
      missing.add('Services Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_svcTitleAr.text)) {
      missing.add('Services Title (AR) - contains English characters');
    }

    if (_services.isEmpty) {
      missing.add('At least one Service item');
    } else {
      for (var i = 0; i < _services.length; i++) {
        if (_services[i].nameEn.text.trim().isEmpty) {
          missing.add('Service ${i + 1} Name (EN)');
        } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_services[i].nameEn.text)) {
          missing.add('Service ${i + 1} Name (EN) - contains Arabic characters');
        }
        if (_services[i].nameAr.text.trim().isEmpty) {
          missing.add('Service ${i + 1} Name (AR)');
        } else if (RegExp(r'[a-zA-Z]').hasMatch(_services[i].nameAr.text)) {
          missing.add('Service ${i + 1} Name (AR) - contains English characters');
        }
      }
    }

    if (_cmtTitleEn.text.trim().isEmpty) {
      missing.add('Client Comments Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_cmtTitleEn.text)) {
      missing.add('Client Comments Title (EN) - contains Arabic characters');
    }
    if (_cmtTitleAr.text.trim().isEmpty) {
      missing.add('Client Comments Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_cmtTitleAr.text)) {
      missing.add('Client Comments Title (AR) - contains English characters');
    }

    if (_comments.isEmpty) {
      missing.add('At least one Client Feedback');
    } else {
      for (var i = 0; i < _comments.length; i++) {
        if (_comments[i].firstNameEn.text.trim().isEmpty) {
          missing.add('Feedback ${i + 1} First Name (EN)');
        } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_comments[i].firstNameEn.text)) {
          missing.add('Feedback ${i + 1} First Name (EN) - contains Arabic characters');
        }
        if (_comments[i].firstNameAr.text.trim().isEmpty) {
          missing.add('Feedback ${i + 1} First Name (AR)');
        } else if (RegExp(r'[a-zA-Z]').hasMatch(_comments[i].firstNameAr.text)) {
          missing.add('Feedback ${i + 1} First Name (AR) - contains English characters');
        }
        if (_comments[i].lastNameEn.text.trim().isEmpty) {
          missing.add('Feedback ${i + 1} Last Name (EN)');
        } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_comments[i].lastNameEn.text)) {
          missing.add('Feedback ${i + 1} Last Name (EN) - contains Arabic characters');
        }
        if (_comments[i].lastNameAr.text.trim().isEmpty) {
          missing.add('Feedback ${i + 1} Last Name (AR)');
        } else if (RegExp(r'[a-zA-Z]').hasMatch(_comments[i].lastNameAr.text)) {
          missing.add('Feedback ${i + 1} Last Name (AR) - contains English characters');
        }
        if (_comments[i].feedbackEn.text.trim().isEmpty) {
          missing.add('Feedback ${i + 1} Feedback (EN)');
        } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_comments[i].feedbackEn.text)) {
          missing.add('Feedback ${i + 1} Feedback (EN) - contains Arabic characters');
        }
        if (_comments[i].feedbackAr.text.trim().isEmpty) {
          missing.add('Feedback ${i + 1} Feedback (AR)');
        } else if (RegExp(r'[a-zA-Z]').hasMatch(_comments[i].feedbackAr.text)) {
          missing.add('Feedback ${i + 1} Feedback (AR) - contains English characters');
        }
      }
    }

    if (_dlTitleEn.text.trim().isEmpty) {
      missing.add('Download Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_dlTitleEn.text)) {
      missing.add('Download Title (EN) - contains Arabic characters');
    }
    if (_dlTitleAr.text.trim().isEmpty) {
      missing.add('Download Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_dlTitleAr.text)) {
      missing.add('Download Title (AR) - contains English characters');
    }

    if (_publishDate == null) missing.add('Publish Date');

    return missing;
  }

  void _showValidationError() {
    final missing = _getMissingFields();
    if (missing.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: _C.error, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Validation Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please fill all required fields correctly:'),
            const SizedBox(height: 12),
            ...missing.map((field) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: _C.error)),
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

  List<TextEditingController> get _allControllers => [
    _headTitleEn, _headTitleAr, _headDescEn, _headDescAr,
    _svcTitleEn, _svcTitleAr,
    _cmtTitleEn, _cmtTitleAr,
    _dlTitleEn, _dlTitleAr,
    _appStoreLink, _googlePlay,
  ];

  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
    for (final s in _services) s.dispose();
    for (final c in _comments) c.dispose();
    super.dispose();
  }

  void _seedFromModel(OverviewPageModel d, {bool isFromDraft = false}) {
    _isEditingDraft = isFromDraft;

    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
    }

    _headTitleEn.text = d.headings.title.en;
    _headTitleAr.text = d.headings.title.ar;
    _headDescEn.text  = d.headings.description.en;
    _headDescAr.text  = d.headings.description.ar;

    _svcTitleEn.text = d.services.title.en;
    _svcTitleAr.text = d.services.title.ar;
    for (final s in _services) s.dispose();
    _services.clear();
    for (final item in d.services.items) {
      final local = _ServiceLocal(id: item.id);
      local.nameEn.text = item.name.en;
      local.nameAr.text = item.name.ar;
      local.image = item.imageUrl.isNotEmpty
          ? _PickedImage(url: item.imageUrl)
          : const _PickedImage();
      _services.add(local);
    }

    _galleryItems.clear();
    for (final img in d.gallery.images) {
      final local = _GalleryLocal(id: img.id);
      local.image = img.imageUrl.isNotEmpty
          ? _PickedImage(url: img.imageUrl)
          : const _PickedImage();
      _galleryItems.add(local);
    }

    _cmtTitleEn.text = d.clientComments.title.en;
    _cmtTitleAr.text = d.clientComments.title.ar;
    for (final c in _comments) c.dispose();
    _comments.clear();
    for (final cmt in d.clientComments.comments) {
      final local = _CommentLocal(id: cmt.id);
      local.firstNameEn.text = cmt.firstName.en;
      local.firstNameAr.text = cmt.firstName.ar;
      local.lastNameEn.text  = cmt.lastName.en;
      local.lastNameAr.text  = cmt.lastName.ar;
      local.feedbackEn.text  = cmt.feedback.en;
      local.feedbackAr.text  = cmt.feedback.ar;
      local.image = cmt.imageUrl.isNotEmpty
          ? _PickedImage(url: cmt.imageUrl)
          : const _PickedImage();
      _comments.add(local);
    }

    _dlTitleEn.text    = d.download.title.en;
    _dlTitleAr.text    = d.download.title.ar;
    _appStoreLink.text = d.download.appStoreLink;
    _googlePlay.text   = d.download.googlePlayLink;
    _publishDate = d.publishSchedule.publishDate;

    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  String _bytesToDataUrl(Uint8List bytes) {
    final b64 = base64Encode(bytes);
    final isSvg = bytes.length > 4 &&
        String.fromCharCodes(bytes.sublist(0, 5)).contains('<');
    final mime = isSvg ? 'image/svg+xml' : 'image/png';
    return 'data:$mime;base64,$b64';
  }

  String _resolvePreviewUrl(_PickedImage img) {
    if (img.bytes != null) return _bytesToDataUrl(img.bytes!);
    return img.url ?? '';
  }

  OverviewPageModel _buildDraftModel(OverviewCmsCubit cubit) {
    final base = cubit.current;

    final serviceItems = <OverviewServiceItemModel>[];
    for (var i = 0; i < _services.length; i++) {
      serviceItems.add(OverviewServiceItemModel(
        id: _services[i].id,
        name: BiText(en: _services[i].nameEn.text, ar: _services[i].nameAr.text),
        imageUrl: _resolvePreviewUrl(_services[i].image),
        order: i,
      ));
    }

    final galleryImages = <OverviewGalleryImageModel>[];
    for (var i = 0; i < _galleryItems.length; i++) {
      galleryImages.add(OverviewGalleryImageModel(
        id: _galleryItems[i].id,
        imageUrl: _resolvePreviewUrl(_galleryItems[i].image),
        order: i,
      ));
    }

    final clientComments = <OverviewClientCommentModel>[];
    for (var i = 0; i < _comments.length; i++) {
      clientComments.add(OverviewClientCommentModel(
        id: _comments[i].id,
        firstName: BiText(en: _comments[i].firstNameEn.text, ar: _comments[i].firstNameAr.text),
        lastName:  BiText(en: _comments[i].lastNameEn.text,  ar: _comments[i].lastNameAr.text),
        feedback:  BiText(en: _comments[i].feedbackEn.text,  ar: _comments[i].feedbackAr.text),
        imageUrl: _resolvePreviewUrl(_comments[i].image),
        order: i,
      ));
    }

    return OverviewPageModel(
      id: base.id,
      status: base.status,
      gender: base.gender,
      headings: OverviewHeadingsModel(
        title:       BiText(en: _headTitleEn.text, ar: _headTitleAr.text),
        description: BiText(en: _headDescEn.text,  ar: _headDescAr.text),
      ),
      services: OverviewServicesSectionModel(
        title: BiText(en: _svcTitleEn.text, ar: _svcTitleAr.text),
        items: serviceItems,
      ),
      gallery: OverviewGallerySectionModel(images: galleryImages),
      clientComments: OverviewClientCommentsSectionModel(
        title:    BiText(en: _cmtTitleEn.text, ar: _cmtTitleAr.text),
        comments: clientComments,
      ),
      download: OverviewDownloadSectionModel(
        title:          BiText(en: _dlTitleEn.text, ar: _dlTitleAr.text),
        appStoreLink:   _appStoreLink.text,
        googlePlayLink: _googlePlay.text,
      ),
      publishSchedule: OverviewPublishScheduleModel(publishDate: _publishDate),
      lastUpdated: base.lastUpdated,
    );
  }

  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed = false;
    final input = html.FileUploadInputElement()
      ..accept = '.svg,.png,.jpg,.jpeg,image/*';
    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is List<int>) {
            completer.complete(_PickedImage(bytes: Uint8List.fromList(result)));
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: _C.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _publishDate = picked);
  }

  Future<void> _save(OverviewCmsCubit cubit,
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
      // ── Headings ──────────────────────────────────────────────────────────
      cubit.updateHeadingsTitle(en: _headTitleEn.text, ar: _headTitleAr.text);
      cubit.updateHeadingsDescription(en: _headDescEn.text, ar: _headDescAr.text);

      // ── Services ──────────────────────────────────────────────────────────
      cubit.updateServicesTitle(en: _svcTitleEn.text, ar: _svcTitleAr.text);
      for (final item in List<OverviewServiceItemModel>.from(cubit.current.services.items)) {
        cubit.removeServiceItem(item.id);
      }
      for (var i = 0; i < _services.length; i++) {
        cubit.addServiceItem();
      }
      for (var i = 0; i < _services.length; i++) {
        final id = cubit.current.services.items[i].id;
        cubit.updateServiceItemName(id, en: _services[i].nameEn.text, ar: _services[i].nameAr.text);
        if (_services[i].image.bytes != null) {
          await cubit.uploadServiceItemImage(id, _services[i].image.bytes!);
        } else if (_services[i].image.url != null && _services[i].image.url!.isNotEmpty) {
          cubit.updateServiceItemImageUrl(id, _services[i].image.url!);
        }
      }

      // ── Gallery ───────────────────────────────────────────────────────────
      for (final img in List<OverviewGalleryImageModel>.from(cubit.current.gallery.images)) {
        cubit.removeGalleryImage(img.id);
      }
      for (var i = 0; i < _galleryItems.length; i++) {
        cubit.addGallerySlot();
      }
      for (var i = 0; i < _galleryItems.length; i++) {
        final id = cubit.current.gallery.images[i].id;
        if (_galleryItems[i].image.bytes != null) {
          await cubit.uploadGalleryImage(id, _galleryItems[i].image.bytes!);
        } else if (_galleryItems[i].image.url != null && _galleryItems[i].image.url!.isNotEmpty) {
          cubit.updateGalleryImageUrl(id, _galleryItems[i].image.url!);
        }
      }

      // ── Client Comments ───────────────────────────────────────────────────
      cubit.updateClientCommentsTitle(en: _cmtTitleEn.text, ar: _cmtTitleAr.text);
      for (final cmt in List<OverviewClientCommentModel>.from(cubit.current.clientComments.comments)) {
        cubit.removeClientComment(cmt.id);
      }
      for (var i = 0; i < _comments.length; i++) {
        cubit.addClientComment();
      }
      for (var i = 0; i < _comments.length; i++) {
        final id = cubit.current.clientComments.comments[i].id;
        cubit.updateClientCommentFirstName(id, en: _comments[i].firstNameEn.text, ar: _comments[i].firstNameAr.text);
        cubit.updateClientCommentLastName(id, en: _comments[i].lastNameEn.text, ar: _comments[i].lastNameAr.text);
        cubit.updateClientCommentFeedback(id, en: _comments[i].feedbackEn.text, ar: _comments[i].feedbackAr.text);
        if (_comments[i].image.bytes != null) {
          await cubit.uploadClientCommentImage(id, _comments[i].image.bytes!);
        } else if (_comments[i].image.url != null && _comments[i].image.url!.isNotEmpty) {
          cubit.updateClientCommentImageUrl(id, _comments[i].image.url!);
        }
      }

      // ── Download ──────────────────────────────────────────────────────────
      cubit.updateDownloadTitle(en: _dlTitleEn.text, ar: _dlTitleAr.text);
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlay.text);

      // ── Schedule ──────────────────────────────────────────────────────────
      cubit.updatePublishDate(_publishDate);

      // ── Determine final status ────────────────────────────────────────────
      // If the user clicks "Publish" BUT a future schedule date is set,
      // override to 'scheduled' → saves as draft, published stays live.
      String finalStatus = publishStatus;
      if (publishStatus == 'published' && _publishDate != null) {
        final now = DateTime.now();
        if (_publishDate!.isAfter(now)) {
          finalStatus = 'scheduled';
          print('[OverviewEditPage] _save: 📅 schedule date is in the future '
              '(${_publishDate!.toIso8601String()}) → overriding to "scheduled"');
        }
      }

      await cubit.save(publishStatus: finalStatus);

    } catch (e, st) {
      print('[OverviewEditPage] _save: ❌ ERROR: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e',
              style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewCmsCubit, OverviewCmsState>(
      listener: (context, state) {
        print('[OverviewEditPage] 👂 listener: ${state.runtimeType}');

        // ── Published successfully ──────────────────────────────────────
        if (state is OverviewCmsSaved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<OverviewCmsCubit>(),
                    child: const OverviewMainPage(),
                  ),
                ),
                    (route) => false,
              );
            }
          });
        }

        // ── Draft saved successfully ────────────────────────────────────
        if (state is OverviewCmsDraftSaved) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.data.status == 'scheduled'
                    ? 'Scheduled draft saved! Published version is still live.'
                    : 'Draft saved! Published version is still live.',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white),
              ),
              backgroundColor: _C.draftBadge,
              behavior: SnackBarBehavior.floating,
            ));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<OverviewCmsCubit>(),
                    child: const OverviewMainPage(),
                  ),
                ),
                    (route) => false,
              );
            }
          });
        }

        // ── Draft deleted (discard) ─────────────────────────────────────
        if (state is OverviewCmsDraftDeleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<OverviewCmsCubit>(),
                    child: const OverviewMainPage(),
                  ),
                ),
                    (route) => false,
              );
            }
          });
        }

        // ── Error ───────────────────────────────────────────────────────
        if (state is OverviewCmsError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.message}',
                  style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final bool canPublish = _isFormValid;

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
                  AdminSubNavBar(activeIndex: 2),
                  SizedBox(width: 20.w),
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title row with draft badge ─────────────────────
                          Row(
                            children: [
                              Text('Editing Overview',
                                  style: StyleText.fontSize45Weight600.copyWith(
                                      color: _C.primary, fontWeight: FontWeight.w700)),
                              if (_isEditingDraft) ...[
                                SizedBox(width: 12.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _C.draftBadge.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'EDITING DRAFT',
                                    style: StyleText.fontSize12Weight600.copyWith(
                                      color: _C.draftBadge,
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
                                  color: _C.hintText,
                                ),
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

  Widget _accordionWrap(String key, String title, List<Widget> children) {
    final isOpen = _open[key] ?? true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _open[key] = !isOpen),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: isOpen
                ? BorderRadius.only(
                topLeft:  Radius.circular(6.r),
                topRight: Radius.circular(6.r))
                : BorderRadius.circular(6.r),
          ),
          child: Row(children: [
            Expanded(
                child: Text(title,
                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
            Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 20.sp),
          ]),
        ),
      ),
      if (isOpen)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    ]);
  }

  Widget _headingsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _headTitleEn, _headTitleAr, useRow: true),
      SizedBox(height: 10.h),
      CustomValidatedTextFieldMaster(
        label: 'Description',
        hint: 'Text Here',
        controller: _headDescEn,
        maxLines: 4,
        height: 100,
        maxLength: 10000,
        submitted: _submitted,
        fillColor: Colors.white,
        primaryColor: _resolvedPrimary,
      ),
      SizedBox(height: 10.h),
      Directionality(
        textDirection: ui.TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'الوصف *',
          hint: 'أدخل النص هنا',
          controller: _headDescAr,
          maxLines: 4,
          height: 100,
          maxLength: 10000,
          submitted: _submitted,
          fillColor: Colors.white,
          textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: _resolvedPrimary,
        ),
      ),
    ]),
  );

  Widget _servicesBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _svcTitleEn, _svcTitleAr, useRow: true),
      SizedBox(height: 10.h),
      ...List.generate(_services.length, (i) => _serviceItemRow(i)),
      if (_submitted && _services.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text('At least one service item is required',
              style: StyleText.fontSize12Weight400.copyWith(color: _C.error)),
        ),
      SizedBox(height: 8.h),
      _addButton('Service', () {
        setState(() => _services.add(
            _ServiceLocal(id: 'svc_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _serviceItemRow(int i) {
    final svc = _services[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Service ${i + 1}'),
            GestureDetector(
              onTap: () => setState(() {
                final removed = _services.removeAt(i);
                removed.dispose();
              }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text('Remove',
                      style: StyleText.fontSize10Weight400.copyWith(color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _sectionLabel('Image'),
        SizedBox(height: 6.h),
        _imgBox(
          picked: svc.image,
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => svc.image = p);
          },
        ),
        SizedBox(height: 10.h),
        _biRow('Service Name *', 'اسم الخدمة *', svc.nameEn, svc.nameAr,
            useRow: true),
      ]),
    );
  }

  Widget _galleryBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: List.generate(_galleryItems.length, (i) => _gallerySlot(i)),
      ),
      SizedBox(height: 8.h),
      _addButton('Image', () {
        setState(() => _galleryItems.add(
            _GalleryLocal(id: 'gal_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _gallerySlot(int i) {
    final gal = _galleryItems[i];
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        _sectionLabel('Image ${i + 1}'),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => setState(() => _galleryItems.removeAt(i)),
          child: Container(
            width: 14.w,
            height: 14.h,
            decoration: const BoxDecoration(color: _C.remove, shape: BoxShape.circle),
            child: Icon(Icons.close, color: Colors.white, size: 10.sp),
          ),
        ),
      ]),
      SizedBox(height: 4.h),
      _imgBox(
        picked: gal.image,
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => gal.image = p);
        },
      ),
    ]);
  }

  Widget _commentsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _cmtTitleEn, _cmtTitleAr, useRow: true),
      SizedBox(height: 10.h),
      ...List.generate(_comments.length, (i) => _commentItemRow(i)),
      if (_submitted && _comments.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text('At least one client feedback is required',
              style: StyleText.fontSize12Weight400.copyWith(color: _C.error)),
        ),
      SizedBox(height: 8.h),
      _addButton('Feedback', () {
        setState(() => _comments.add(
            _CommentLocal(id: 'cmt_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _commentItemRow(int i) {
    final cmt = _comments[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Feedback ${i + 1}'),
            GestureDetector(
              onTap: () => setState(() {
                final removed = _comments.removeAt(i);
                removed.dispose();
              }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text('Remove',
                      style: StyleText.fontSize10Weight400.copyWith(color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _imgBox(
          picked: cmt.image,
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => cmt.image = p);
          },
        ),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: 'First Name *', hint: 'Text Here',
              controller: cmt.firstNameEn, height: 36,
              submitted: _submitted, fillColor: Colors.white,
              primaryColor: _resolvedPrimary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: 'Last Name *', hint: 'Text Here',
              controller: cmt.lastNameEn, height: 36,
              submitted: _submitted, fillColor: Colors.white,
              primaryColor: _resolvedPrimary,
            ),
          ),
        ]),
        SizedBox(height: 8.h),
        Row(children: [
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: 'اسم العائلة *', hint: 'أدخل النص هنا',
                controller: cmt.lastNameAr, height: 36,
                submitted: _submitted, fillColor: Colors.white,
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.right,
                primaryColor: _resolvedPrimary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: 'الاسم الأول *', hint: 'أدخل النص هنا',
                controller: cmt.firstNameAr, height: 36,
                submitted: _submitted, fillColor: Colors.white,
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.right,
                primaryColor: _resolvedPrimary,
              ),
            ),
          ),
        ]),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          label: 'Feedback *', hint: 'Text Here',
          controller: cmt.feedbackEn, maxLines: 3, height: 80,
          submitted: _submitted, fillColor: Colors.white,
          primaryColor: _resolvedPrimary,
        ),
        SizedBox(height: 8.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'ملاحظات *', hint: 'أدخل النص هنا',
            controller: cmt.feedbackAr, maxLines: 3, height: 80,
            submitted: _submitted, fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ]),
    );
  }

  Widget _downloadBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _dlTitleEn, _dlTitleAr, useRow: true),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            label: 'Apple Store Link', hint: 'Insert Links',
            controller: _appStoreLink, height: 36,
            submitted: _submitted, fillColor: Colors.white,
            primaryColor: _resolvedPrimary,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            label: 'Android Link', hint: 'Insert Links',
            controller: _googlePlay, height: 36,
            submitted: _submitted, fillColor: Colors.white,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ]),
    ]),
  );

  Widget _scheduleBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionLabel('Publish Date *'),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: _publishDate == null && _submitted
                      ? Border.all(color: _C.error, width: 1)
                      : null,
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      _publishDate != null
                          ? DateFormat('dd/MM/yyyy').format(_publishDate!)
                          : 'Select Date',
                      style: StyleText.fontSize12Weight400.copyWith(
                          color: _publishDate != null
                              ? _C.labelText
                              : _C.hintText),
                    ),
                  ),
                  Icon(Icons.calendar_today_outlined,
                      size: 16.sp, color: _C.hintText),
                ]),
              ),
            ),
            if (_publishDate == null && _submitted)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text('Publish date is required',
                    style: TextStyle(color: _C.error, fontSize: 10.sp)),
              ),
          ]),
        ),
        SizedBox(width: 16.w),
        Expanded(child: Column()),
      ]),
    ]),
  );

  // ── Action buttons: Preview + Publish ─────────────────────────────────────
  Widget _actionRow(OverviewCmsCubit cubit, bool canPublish) =>
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              final draft = _buildDraftModel(cubit);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: OverviewPreviewPage(
                      previewModel: draft,
                      onPublish: () => _save(cubit, publishStatus: 'published'),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                  color: _C.primary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6.r)),
              child: Center(
                  child: Text('Preview',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
            ),
          ),
        ),
        SizedBox(width: 16.w),
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
                        ? 'SCHEDULE OVERVIEW'
                        : 'PUBLISHING OVERVIEW',
                    subtitle: isScheduled
                        ? 'Your changes will be scheduled for '
                        '${DateFormat('dd/MM/yyyy').format(_publishDate!)}. '
                        'The published version will remain live until then.'
                        : 'Do you want to publish this OVERVIEW?',
                    context: context,
                    onConfirm: () async =>
                        _save(cubit, publishStatus: 'published'),
                  );
                },
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                      color: canPublish ? _C.primary : _C.primary.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(6.r)),
                  child: Center(
                      child: Text('Publish',
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: Colors.white))),
                ),
              ),
            ),
          ),
        ),
      ]);

  // ── Secondary buttons: Discard + Save For Later ───────────────────────────
  Widget _secondaryRow(OverviewCmsCubit cubit) => Row(children: [
    // ── Discard button ────────────────────────────────────────────────
    Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isEditingDraft) {
            showPublishConfirmDialog(
              title: 'DISCARD DRAFT',
              subtitle:
              'Are you sure you want to discard this draft? '
                  'The published version will remain unchanged.',
              context: context,
              onConfirm: () => cubit.discardDraft(),
            );
          } else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OverviewMainPage()));
            }
          }
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
              color: _C.addBtn,
              borderRadius: BorderRadius.circular(6.r)),
          child: Center(
              child: Text('Discard',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white))),
        ),
      ),
    ),
    SizedBox(width: 16.w),

    // ── Save For Later button (saves as DRAFT, published stays live) ─
    Expanded(
      child: GestureDetector(
        onTap: () {
          showPublishConfirmDialog(
            title: 'SAVE AS DRAFT',
            subtitle:
            'Your changes will be saved as a draft. '
                'The published version will remain live and unchanged.',
            context: context,
            onConfirm: () => _save(cubit, publishStatus: 'draft'),
          );
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
              color: _C.addBtn,
              borderRadius: BorderRadius.circular(6.r)),
          child: Center(
              child: Text('Save For Later',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white))),
        ),
      ),
    ),
  ]);

  Widget _sectionLabel(String t) =>
      Text(t, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

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
      return Row(children: [
        Expanded(child: en),
        SizedBox(width: 16.w),
        Expanded(child: ar),
      ]);
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [en, SizedBox(height: 10.h), ar]);
  }

  Widget _addButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
          color: _C.primary, borderRadius: BorderRadius.circular(4.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text(label,
            style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration:
        const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                ))),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration:
        const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                ))),
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
            ),
            child: Center(
                child: CustomSvg(
                    assetPath: 'assets/control/camera.svg',
                    width: 12.w,
                    height: 12.h,
                    fit: BoxFit.fill)),
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