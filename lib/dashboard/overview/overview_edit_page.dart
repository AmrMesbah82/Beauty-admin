/// ******************* FILE INFO *******************
/// File Name: overview_edit_page.dart
/// Description: Edit page for Master CMS (Overview-style).
///              Sections: Headings, Services (+Service btn, dynamic),
///              Gallery (+Image btn, dynamic 12 slots),
///              Client Comments (+Feedback btn, dynamic),
///              Download Applications, Publish Schedule.
///              Buttons: Preview / Publish / Discard / Save For Later.
/// UPDATED: Added validation before publish - checks all required fields
///          and shows inline errors via _submitted flag.
/// Created by: Amr Mesbah
/// Last Update: 15/04/2026

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
import 'overview_preview_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color addBtn    = Color(0xFF797979);
}

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});

  // Factory constructor for empty image - ensures unique instances
  factory _PickedImage.empty() => const _PickedImage();

  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
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
        image = _PickedImage.empty();

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

// ── Local gallery item ───────────────────────────────────────────────────────
class _GalleryLocal {
  final String id;
  _PickedImage image;
  _GalleryLocal({required this.id}) : image = _PickedImage.empty();

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
        image = _PickedImage.empty();

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
  int? _seededModelHash;

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

  @override
  void initState() {
    super.initState();
    print('[OverviewEditPage] ✅ initState');
  }

  @override
  void dispose() {
    print('[OverviewEditPage] 🔴 dispose');
    _headTitleEn.dispose();
    _headTitleAr.dispose();
    _headDescEn.dispose();
    _headDescAr.dispose();
    _svcTitleEn.dispose();
    _svcTitleAr.dispose();
    for (final s in _services) s.dispose();
    _cmtTitleEn.dispose();
    _cmtTitleAr.dispose();
    for (final c in _comments) c.dispose();
    _dlTitleEn.dispose();
    _dlTitleAr.dispose();
    _appStoreLink.dispose();
    _googlePlay.dispose();
    super.dispose();
  }

  // Navigation method for preview
  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OverviewPreviewPage(),
      ),
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────
  /// Validates all required fields before publishing.
  /// Returns true if all fields are valid, false otherwise.
  bool _validate() {
    // Mark submitted so all fields show errors immediately
    setState(() => _submitted = true);

    // ── Headings ────────────────────────────────────────────────────────────
    if (_headTitleEn.text.trim().isEmpty) return false;
    if (_headTitleAr.text.trim().isEmpty) return false;
    if (_headDescEn.text.trim().isEmpty) return false;
    if (_headDescAr.text.trim().isEmpty) return false;

    // ── Services Title ──────────────────────────────────────────────────────
    if (_svcTitleEn.text.trim().isEmpty) return false;
    if (_svcTitleAr.text.trim().isEmpty) return false;

    // ── Service Items ───────────────────────────────────────────────────────
    for (var i = 0; i < _services.length; i++) {
      if (_services[i].nameEn.text.trim().isEmpty) return false;
      if (_services[i].nameAr.text.trim().isEmpty) return false;
    }

    // ── Client Comments Title ───────────────────────────────────────────────
    if (_cmtTitleEn.text.trim().isEmpty) return false;
    if (_cmtTitleAr.text.trim().isEmpty) return false;

    // ── Client Comments ─────────────────────────────────────────────────────
    for (var i = 0; i < _comments.length; i++) {
      if (_comments[i].firstNameEn.text.trim().isEmpty) return false;
      if (_comments[i].firstNameAr.text.trim().isEmpty) return false;
      if (_comments[i].lastNameEn.text.trim().isEmpty) return false;
      if (_comments[i].lastNameAr.text.trim().isEmpty) return false;
      if (_comments[i].feedbackEn.text.trim().isEmpty) return false;
      if (_comments[i].feedbackAr.text.trim().isEmpty) return false;
    }

    // ── Download Links ──────────────────────────────────────────────────────
    if (_dlTitleEn.text.trim().isEmpty) return false;
    if (_dlTitleAr.text.trim().isEmpty) return false;

    // Note: appStoreLink and googlePlay are optional - not validated

    // ── Publish Schedule ────────────────────────────────────────────────────
    if (_publishDate == null) return false;

    return true;
  }

  // ── Seed from model ───────────────────────────────────────────────────────
  void _seedFromModel(OverviewPageModel d) {
    final hash = Object.hashAll([
      d.headings.title.en,
      d.headings.title.ar,
      d.headings.description.en,
      d.headings.description.ar,
      d.services.title.en,
      d.services.title.ar,
      d.services.items.length,
      d.gallery.images.length,
      d.clientComments.title.en,
      d.clientComments.title.ar,
      d.clientComments.comments.length,
      d.download.title.en,
      d.download.title.ar,
      d.download.appStoreLink,
      d.download.googlePlayLink,
      d.publishSchedule.publishDate,
    ]);

    if (_seededModelHash == hash) return;
    _seededModelHash = hash;
    print('[OverviewEditPage] _seedFromModel ▶ seeding');

    // Headings
    _headTitleEn.text = d.headings.title.en;
    _headTitleAr.text = d.headings.title.ar;
    _headDescEn.text  = d.headings.description.en;
    _headDescAr.text  = d.headings.description.ar;

    // Services
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
          : _PickedImage.empty();
      _services.add(local);
    }

    // Gallery
    _galleryItems.clear();
    for (final img in d.gallery.images) {
      final local = _GalleryLocal(id: img.id);
      local.image = img.imageUrl.isNotEmpty
          ? _PickedImage(url: img.imageUrl)
          : _PickedImage.empty();
      _galleryItems.add(local);
    }

    // Client Comments
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
          : _PickedImage.empty();
      _comments.add(local);
    }

    // Download
    _dlTitleEn.text    = d.download.title.en;
    _dlTitleAr.text    = d.download.title.ar;
    _appStoreLink.text = d.download.appStoreLink;
    _googlePlay.text   = d.download.googlePlayLink;

    // Publish
    _publishDate = d.publishSchedule.publishDate;

    print('[OverviewEditPage] _seedFromModel ✅ DONE, services count: ${_services.length}');
  }

  // ── Image picker ──────────────────────────────────────────────────────────
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

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
            Theme.of(ctx).colorScheme.copyWith(primary: _C.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _publishDate = picked);
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(OverviewCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    setState(() => _submitted = true);
    try {
      print('[OverviewEditPage] _save: Starting save with ${_services.length} services');

      // ── Headings ──────────────────────────────────────────────────────────
      cubit.updateHeadingsTitle(en: _headTitleEn.text, ar: _headTitleAr.text);
      cubit.updateHeadingsDescription(
          en: _headDescEn.text, ar: _headDescAr.text);

      // ── Services title ────────────────────────────────────────────────────
      cubit.updateServicesTitle(en: _svcTitleEn.text, ar: _svcTitleAr.text);

      // ── Services items: clear all → re-add → update by aligned index ──────
      print('[OverviewEditPage] _save: Clearing existing services');
      for (final item in List<OverviewServiceItemModel>.from(
          cubit.current.services.items)) {
        cubit.removeServiceItem(item.id);
      }

      print('[OverviewEditPage] _save: Adding ${_services.length} new services');
      for (var i = 0; i < _services.length; i++) {
        cubit.addServiceItem();
      }

      print('[OverviewEditPage] _save: Updating service details');
      for (var i = 0; i < _services.length; i++) {
        final id = cubit.current.services.items[i].id;
        print('[OverviewEditPage] _save: Updating service $i with id $id');

        cubit.updateServiceItemName(id,
            en: _services[i].nameEn.text, ar: _services[i].nameAr.text);

        if (_services[i].image.bytes != null) {
          print('[OverviewEditPage] _save: Uploading new image for service $i');
          await cubit.uploadServiceItemImage(id, _services[i].image.bytes!);
        } else if (_services[i].image.url != null &&
            _services[i].image.url!.isNotEmpty) {
          print('[OverviewEditPage] _save: Using existing URL for service $i: ${_services[i].image.url}');
          cubit.updateServiceItemImageUrl(id, _services[i].image.url!);
        }
      }

      // ── Gallery: clear all → re-add → update by aligned index ─────────────
      print('[OverviewEditPage] _save: Processing gallery with ${_galleryItems.length} items');
      for (final img in List<OverviewGalleryImageModel>.from(
          cubit.current.gallery.images)) {
        cubit.removeGalleryImage(img.id);
      }

      for (var i = 0; i < _galleryItems.length; i++) {
        cubit.addGallerySlot();
      }

      for (var i = 0; i < _galleryItems.length; i++) {
        final id = cubit.current.gallery.images[i].id;
        if (_galleryItems[i].image.bytes != null) {
          await cubit.uploadGalleryImage(id, _galleryItems[i].image.bytes!);
        } else if (_galleryItems[i].image.url != null &&
            _galleryItems[i].image.url!.isNotEmpty) {
          cubit.updateGalleryImageUrl(id, _galleryItems[i].image.url!);
        }
      }

      // ── Client Comments title ─────────────────────────────────────────────
      cubit.updateClientCommentsTitle(
          en: _cmtTitleEn.text, ar: _cmtTitleAr.text);

      // ── Comments: clear all → re-add → update by aligned index ────────────
      print('[OverviewEditPage] _save: Processing comments with ${_comments.length} items');
      for (final cmt in List<OverviewClientCommentModel>.from(
          cubit.current.clientComments.comments)) {
        cubit.removeClientComment(cmt.id);
      }

      for (var i = 0; i < _comments.length; i++) {
        cubit.addClientComment();
      }

      for (var i = 0; i < _comments.length; i++) {
        final id = cubit.current.clientComments.comments[i].id;
        cubit.updateClientCommentFirstName(id,
            en: _comments[i].firstNameEn.text,
            ar: _comments[i].firstNameAr.text);
        cubit.updateClientCommentLastName(id,
            en: _comments[i].lastNameEn.text,
            ar: _comments[i].lastNameAr.text);
        cubit.updateClientCommentFeedback(id,
            en: _comments[i].feedbackEn.text,
            ar: _comments[i].feedbackAr.text);

        if (_comments[i].image.bytes != null) {
          await cubit.uploadClientCommentImage(
              id, _comments[i].image.bytes!);
        } else if (_comments[i].image.url != null &&
            _comments[i].image.url!.isNotEmpty) {
          cubit.updateClientCommentImageUrl(id, _comments[i].image.url!);
        }
      }

      // ── Download ──────────────────────────────────────────────────────────
      cubit.updateDownloadTitle(en: _dlTitleEn.text, ar: _dlTitleAr.text);
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlay.text);

      // ── Schedule ──────────────────────────────────────────────────────────
      cubit.updatePublishDate(_publishDate);

      print('[OverviewEditPage] _save: Saving to repository');
      await cubit.save(publishStatus: publishStatus);
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[OverviewEditPage] _save: ❌ ERROR: $e\n$st');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OverviewCmsCubit, OverviewCmsState>(
      listener: (context, state) {
        if (state is OverviewCmsSaved) {

        }
        if (state is OverviewCmsError) {

        }
      },
      builder: (context, state) {
        if (state is OverviewCmsLoaded) _seedFromModel(state.data);

        final cubit = context.read<OverviewCmsCubit>();

        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
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
                          Text('Editing Overview',
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 16.h),

                          _accordionWrap('headings', 'Headings',
                              [_headingsBody()]),
                          SizedBox(height: 10.h),

                          _accordionWrap('services', 'Services',
                              [_servicesBody()]),
                          SizedBox(height: 10.h),

                          _accordionWrap('gallery', 'Gallery',
                              [_galleryBody()]),
                          SizedBox(height: 10.h),

                          _accordionWrap('comments', 'Client Comments',
                              [_commentsBody()]),
                          SizedBox(height: 10.h),

                          _accordionWrap('download', 'Download Applications',
                              [_downloadBody()]),
                          SizedBox(height: 10.h),

                          _accordionWrap('schedule', 'Publish Schedule',
                              [_scheduleBody()]),


                          // ── Action buttons ─────────────────────────
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
                topLeft: Radius.circular(6.r),
                topRight: Radius.circular(6.r))
                : BorderRadius.circular(6.r),
          ),
          child: Row(children: [
            Expanded(
                child: Text(title,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white))),
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
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADINGS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _headingsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title', 'العنوان', _headTitleEn, _headTitleAr,
          useRow: true),
      SizedBox(height: 10.h),
      CustomValidatedTextFieldMaster(
        label: 'Description',
        hint: 'Text Here',
        controller: _headDescEn,
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
          controller: _headDescAr,
          maxLines: 4,
          height: 100,
          submitted: _submitted,
          fillColor: Colors.white,
          textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: _resolvedPrimary,
        ),
      ),
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _servicesBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title', 'العنوان', _svcTitleEn, _svcTitleAr,
          useRow: true),
      SizedBox(height: 10.h),
      ...List.generate(_services.length, (i) => _serviceItemRow(i)),
      SizedBox(height: 8.h),
      _addButton('Service', () {
        setState(() => _services.add(_ServiceLocal(
            id: 'svc_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _serviceItemRow(int i) {
    final svc = _services[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: _C.remove,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text('Remove',
                          style: StyleText.fontSize10Weight400.copyWith(color: Colors.white)),
                    ],
                  ),
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
          _biRow('Service Name', 'اسم الخدمة', svc.nameEn, svc.nameAr,
              useRow: true),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _galleryBody() => Padding(
    padding: EdgeInsets.all(16.w),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: List.generate(
            _galleryItems.length, (i) => _gallerySlot(i)),
      ),
      SizedBox(height: 8.h),
      _addButton('Image', () {
        setState(() => _galleryItems.add(_GalleryLocal(
            id: 'gal_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _gallerySlot(int i) {
    final gal = _galleryItems[i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sectionLabel('Image ${i + 1}'),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => setState(() => _galleryItems.removeAt(i)),
              child: Container(
                width: 14.w,
                height: 14.h,
                decoration: const BoxDecoration(
                    color: _C.remove, shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.white, size: 10.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        _imgBox(
          picked: gal.image,
          onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => gal.image = p);
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLIENT COMMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _commentsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title', 'العنوان', _cmtTitleEn, _cmtTitleAr,
          useRow: true),
      SizedBox(height: 10.h),
      ...List.generate(_comments.length, (i) => _commentItemRow(i)),
      SizedBox(height: 8.h),
      _addButton('Feedback', () {
        setState(() => _comments.add(_CommentLocal(
            id: 'cmt_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _commentItemRow(int i) {
    final cmt = _comments[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: _C.remove,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text('Remove',
                          style: StyleText.fontSize10Weight400.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Image
          _imgBox(
            picked: cmt.image,
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => cmt.image = p);
            },
          ),
          SizedBox(height: 10.h),

          // First Name EN / Last Name EN
          Row(children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'First Name',
                hint: 'Text Here',
                controller: cmt.firstNameEn,
                height: 36,
                submitted: _submitted,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Last Name',
                hint: 'Text Here',
                controller: cmt.lastNameEn,
                height: 36,
                submitted: _submitted,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimary,
              ),
            ),
          ]),
          SizedBox(height: 8.h),

          // Last Name AR / First Name AR
          Row(children: [
            Expanded(
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: CustomValidatedTextFieldMaster(
                  label: 'اسم العائلة',
                  hint: 'أدخل النص هنا',
                  controller: cmt.lastNameAr,
                  height: 36,
                  submitted: _submitted,
                  fillColor: Colors.white,
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
                  label: 'الاسم الأول',
                  hint: 'أدخل النص هنا',
                  controller: cmt.firstNameAr,
                  height: 36,
                  submitted: _submitted,
                  fillColor: Colors.white,
                  textDirection: ui.TextDirection.rtl,
                  textAlign: TextAlign.right,
                  primaryColor: _resolvedPrimary,
                ),
              ),
            ),
          ]),
          SizedBox(height: 8.h),

          // Feedback EN
          CustomValidatedTextFieldMaster(
            label: 'Feedback',
            hint: 'Text Here',
            controller: cmt.feedbackEn,
            maxLines: 3,
            height: 80,
            submitted: _submitted,
            fillColor: Colors.white,
            primaryColor: _resolvedPrimary,
          ),
          SizedBox(height: 8.h),

          // Feedback AR
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'ملاحظات',
              hint: 'أدخل النص هنا',
              controller: cmt.feedbackAr,
              maxLines: 3,
              height: 80,
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
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD APPLICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _downloadBody() => Padding(
    padding: EdgeInsets.symmetric(vertical:  16.h),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title', 'العنوان', _dlTitleEn, _dlTitleAr,
          useRow: true),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            label: 'Apple Store Link',
            hint: 'Insert Links',
            controller: _appStoreLink,
            height: 36,
            submitted: _submitted,  // ✅ UPDATED: now uses _submitted
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
            submitted: _submitted,  // ✅ UPDATED: now uses _submitted
            fillColor: Colors.white,
            primaryColor: _resolvedPrimary,
          ),
        ),
      ]),
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLISH SCHEDULE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _scheduleBody() => Padding(
    padding: EdgeInsets.symmetric(vertical:  16.h),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      border: _publishDate == null && _submitted
                          ? Border.all(color: Colors.red, width: 1)
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
                    child: Text(
                      'Please select a publish date',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10.sp,
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
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _actionRow(OverviewCmsCubit cubit) => Row(children: [
    Expanded(
      child: GestureDetector(
        onTap: _navigateToPreview,
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
      child: GestureDetector(
        onTap: () {
          // ✅ VALIDATION: Check all required fields before showing confirm dialog
          if (!_validate()) {

            return;
          }
          // ✅ All fields valid — show confirm dialog
          showPublishConfirmDialog(
            context: context,
            onConfirm: () => _save(cubit, publishStatus: 'published'),
          );
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(6.r)),
          child: Center(
              child: Text('Publish',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white))),
        ),
      ),
    ),
  ]);

  Widget _secondaryRow(OverviewCmsCubit cubit) => Row(children: [
    Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
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
    Expanded(
      child: GestureDetector(
        onTap: () {
          // ✅ VALIDATION: Check required fields before saving as draft too
          if (!_validate()) {

            return;
          }
          showPublishConfirmDialog(
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

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _sectionLabel(String t) => Text(t,
      style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _biRow(String enLbl, String arLbl, TextEditingController enC,
      TextEditingController arC,
      {int maxLines = 1, bool useRow = false}) {
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
        Expanded(child: ar)
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
          color: _C.primary,
          borderRadius: BorderRadius.circular(4.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text(label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _imgBox({
    required _PickedImage picked,
    VoidCallback? onPick,
    VoidCallback? onRemove,
  })
  {
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
                    child: SvgPicture.memory(picked.bytes!,
                        width: 30.w,
                        height: 30.h,
                        fit: BoxFit.scaleDown,
                        placeholderBuilder: (_) => _placeholderCircle())))),
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
                    child: SvgPicture.network(picked.url!,
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.contain,
                        placeholderBuilder: (_) =>
                        const CircleProgressMaster())))),
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