// ******************* FILE INFO *******************
// File Name: logic_helpers.dart
// Description: Business-logic helpers for Overview edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_edit

part of '../../pages/overview_edit.dart';

extension _OverviewEditLogic on _OverviewEditPageState {
  bool _isValidEnglish(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[؀-ۿ]').hasMatch(text);
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

    final svcTitleOk = _isValidEnglish(_svcTitleEn.text) && _isValidArabic(_svcTitleAr.text);

    bool servicesOk = _services.isNotEmpty;
    for (var i = 0; i < _services.length; i++) {
      if (!_isValidEnglish(_services[i].nameEn.text) || !_isValidArabic(_services[i].nameAr.text)) {
        servicesOk = false; break;
      }
    }

    final cmtTitleOk = _isValidEnglish(_cmtTitleEn.text) && _isValidArabic(_cmtTitleAr.text);

    bool commentsOk = _comments.isNotEmpty;
    for (var i = 0; i < _comments.length; i++) {
      if (!_isValidEnglish(_comments[i].firstNameEn.text) ||
          !_isValidArabic(_comments[i].firstNameAr.text) ||
          !_isValidEnglish(_comments[i].lastNameEn.text) ||
          !_isValidArabic(_comments[i].lastNameAr.text) ||
          !_isValidEnglish(_comments[i].feedbackEn.text) ||
          !_isValidArabic(_comments[i].feedbackAr.text)) {
        commentsOk = false; break;
      }
    }

    final dlTitleOk = _isValidEnglish(_dlTitleEn.text) && _isValidArabic(_dlTitleAr.text);
    final publishDateOk = _publishDate != null;

    return headingsOk && svcTitleOk && servicesOk && cmtTitleOk && commentsOk && dlTitleOk && publishDateOk;
  }

  List<String> _getMissingFields() {
    final missing = <String>[];

    if (_headTitleEn.text.trim().isEmpty) { missing.add('Heading Title (EN)'); }
    else if (RegExp(r'[؀-ۿ]').hasMatch(_headTitleEn.text)) { missing.add('Heading Title (EN) - contains Arabic characters'); }
    if (_headTitleAr.text.trim().isEmpty) { missing.add('Heading Title (AR)'); }
    else if (RegExp(r'[a-zA-Z]').hasMatch(_headTitleAr.text)) { missing.add('Heading Title (AR) - contains English characters'); }
    if (_headDescEn.text.trim().isEmpty) { missing.add('Heading Description (EN)'); }
    else if (RegExp(r'[؀-ۿ]').hasMatch(_headDescEn.text)) { missing.add('Heading Description (EN) - contains Arabic characters'); }
    if (_headDescAr.text.trim().isEmpty) { missing.add('Heading Description (AR)'); }
    else if (RegExp(r'[a-zA-Z]').hasMatch(_headDescAr.text)) { missing.add('Heading Description (AR) - contains English characters'); }

    if (_svcTitleEn.text.trim().isEmpty) { missing.add('Services Title (EN)'); }
    else if (RegExp(r'[؀-ۿ]').hasMatch(_svcTitleEn.text)) { missing.add('Services Title (EN) - contains Arabic characters'); }
    if (_svcTitleAr.text.trim().isEmpty) { missing.add('Services Title (AR)'); }
    else if (RegExp(r'[a-zA-Z]').hasMatch(_svcTitleAr.text)) { missing.add('Services Title (AR) - contains English characters'); }

    if (_services.isEmpty) {
      missing.add('At least one Service item');
    } else {
      for (var i = 0; i < _services.length; i++) {
        if (_services[i].nameEn.text.trim().isEmpty) { missing.add('Service ${i + 1} Name (EN)'); }
        else if (RegExp(r'[؀-ۿ]').hasMatch(_services[i].nameEn.text)) { missing.add('Service ${i + 1} Name (EN) - contains Arabic characters'); }
        if (_services[i].nameAr.text.trim().isEmpty) { missing.add('Service ${i + 1} Name (AR)'); }
        else if (RegExp(r'[a-zA-Z]').hasMatch(_services[i].nameAr.text)) { missing.add('Service ${i + 1} Name (AR) - contains English characters'); }
      }
    }

    if (_cmtTitleEn.text.trim().isEmpty) { missing.add('Client Comments Title (EN)'); }
    else if (RegExp(r'[؀-ۿ]').hasMatch(_cmtTitleEn.text)) { missing.add('Client Comments Title (EN) - contains Arabic characters'); }
    if (_cmtTitleAr.text.trim().isEmpty) { missing.add('Client Comments Title (AR)'); }
    else if (RegExp(r'[a-zA-Z]').hasMatch(_cmtTitleAr.text)) { missing.add('Client Comments Title (AR) - contains English characters'); }

    if (_comments.isEmpty) {
      missing.add('At least one Client Feedback');
    } else {
      for (var i = 0; i < _comments.length; i++) {
        if (_comments[i].firstNameEn.text.trim().isEmpty) { missing.add('Feedback ${i + 1} First Name (EN)'); }
        else if (RegExp(r'[؀-ۿ]').hasMatch(_comments[i].firstNameEn.text)) { missing.add('Feedback ${i + 1} First Name (EN) - contains Arabic characters'); }
        if (_comments[i].firstNameAr.text.trim().isEmpty) { missing.add('Feedback ${i + 1} First Name (AR)'); }
        else if (RegExp(r'[a-zA-Z]').hasMatch(_comments[i].firstNameAr.text)) { missing.add('Feedback ${i + 1} First Name (AR) - contains English characters'); }
        if (_comments[i].lastNameEn.text.trim().isEmpty) { missing.add('Feedback ${i + 1} Last Name (EN)'); }
        else if (RegExp(r'[؀-ۿ]').hasMatch(_comments[i].lastNameEn.text)) { missing.add('Feedback ${i + 1} Last Name (EN) - contains Arabic characters'); }
        if (_comments[i].lastNameAr.text.trim().isEmpty) { missing.add('Feedback ${i + 1} Last Name (AR)'); }
        else if (RegExp(r'[a-zA-Z]').hasMatch(_comments[i].lastNameAr.text)) { missing.add('Feedback ${i + 1} Last Name (AR) - contains English characters'); }
        if (_comments[i].feedbackEn.text.trim().isEmpty) { missing.add('Feedback ${i + 1} Feedback (EN)'); }
        else if (RegExp(r'[؀-ۿ]').hasMatch(_comments[i].feedbackEn.text)) { missing.add('Feedback ${i + 1} Feedback (EN) - contains Arabic characters'); }
        if (_comments[i].feedbackAr.text.trim().isEmpty) { missing.add('Feedback ${i + 1} Feedback (AR)'); }
        else if (RegExp(r'[a-zA-Z]').hasMatch(_comments[i].feedbackAr.text)) { missing.add('Feedback ${i + 1} Feedback (AR) - contains English characters'); }
      }
    }

    if (_dlTitleEn.text.trim().isEmpty) { missing.add('Download Title (EN)'); }
    else if (RegExp(r'[؀-ۿ]').hasMatch(_dlTitleEn.text)) { missing.add('Download Title (EN) - contains Arabic characters'); }
    if (_dlTitleAr.text.trim().isEmpty) { missing.add('Download Title (AR)'); }
    else if (RegExp(r'[a-zA-Z]').hasMatch(_dlTitleAr.text)) { missing.add('Download Title (AR) - contains English characters'); }

    if (_publishDate == null) missing.add('Publish Date');
    return missing;
  }

  void _showValidationError() {
    final missing = _getMissingFields();
    if (missing.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.error_outline, color: ColorPick.red, size: 24.sp),
          SizedBox(width: 8.w),
          const Text('Validation Error'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please fill all required fields correctly:'),
            const SizedBox(height: 12),
            ...missing.map((field) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('• ', style: TextStyle(color: ColorPick.red)),
                Expanded(child: Text(field)),
              ]),
            )),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
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

  void _seedFromModel(OverviewPageModel d, {bool isFromDraft = false}) {
    _isEditingDraft = isFromDraft;
    for (final ctrl in _allControllers) ctrl.removeListener(_onFieldChanged);

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
      local.image = item.imageUrl.isNotEmpty ? _PickedImage(url: item.imageUrl) : const _PickedImage();
      _services.add(local);
    }

    _galleryItems.clear();
    for (final img in d.gallery.images) {
      final local = _GalleryLocal(id: img.id);
      local.image = img.imageUrl.isNotEmpty ? _PickedImage(url: img.imageUrl) : const _PickedImage();
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
      local.image = cmt.imageUrl.isNotEmpty ? _PickedImage(url: cmt.imageUrl) : const _PickedImage();
      _comments.add(local);
    }

    _dlTitleEn.text    = d.download.title.en;
    _dlTitleAr.text    = d.download.title.ar;
    _appStoreLink.text = d.download.appStoreLink;
    _googlePlay.text   = d.download.googlePlayLink;
    _publishDate = d.publishSchedule.publishDate;

    for (final ctrl in _allControllers) ctrl.addListener(_onFieldChanged);
  }

  String _bytesToDataUrl(Uint8List bytes) {
    final b64 = base64Encode(bytes);
    final isSvg = bytes.length > 4 && String.fromCharCodes(bytes.sublist(0, 5)).contains('<');
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
        imageUrl: _resolvePreviewUrl(_services[i].image), order: i,
      ));
    }

    final galleryImages = <OverviewGalleryImageModel>[];
    for (var i = 0; i < _galleryItems.length; i++) {
      galleryImages.add(OverviewGalleryImageModel(
        id: _galleryItems[i].id, imageUrl: _resolvePreviewUrl(_galleryItems[i].image), order: i,
      ));
    }

    final clientComments = <OverviewClientCommentModel>[];
    for (var i = 0; i < _comments.length; i++) {
      clientComments.add(OverviewClientCommentModel(
        id: _comments[i].id,
        firstName: BiText(en: _comments[i].firstNameEn.text, ar: _comments[i].firstNameAr.text),
        lastName:  BiText(en: _comments[i].lastNameEn.text,  ar: _comments[i].lastNameAr.text),
        feedback:  BiText(en: _comments[i].feedbackEn.text,  ar: _comments[i].feedbackAr.text),
        imageUrl: _resolvePreviewUrl(_comments[i].image), order: i,
      ));
    }

    return OverviewPageModel(
      id: base.id, status: base.status, gender: base.gender,
      headings: OverviewHeadingsModel(
        title:       BiText(en: _headTitleEn.text, ar: _headTitleAr.text),
        description: BiText(en: _headDescEn.text,  ar: _headDescAr.text),
      ),
      services: OverviewServicesSectionModel(
        title: BiText(en: _svcTitleEn.text, ar: _svcTitleAr.text), items: serviceItems,
      ),
      gallery: OverviewGallerySectionModel(images: galleryImages),
      clientComments: OverviewClientCommentsSectionModel(
        title: BiText(en: _cmtTitleEn.text, ar: _cmtTitleAr.text), comments: clientComments,
      ),
      download: OverviewDownloadSectionModel(
        title: BiText(en: _dlTitleEn.text, ar: _dlTitleAr.text),
        appStoreLink: _appStoreLink.text, googlePlayLink: _googlePlay.text,
      ),
      publishSchedule: OverviewPublishScheduleModel(publishDate: _publishDate),
      lastUpdated: base.lastUpdated,
    );
  }

  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed = false;
    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg') && file.type != 'image/svg+xml') {
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is ByteBuffer) {
            completer.complete(_PickedImage(bytes: Uint8List.view(result)));
          } else if (result is List<int>) {
            completer.complete(_PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((e) {
        if (!completed) { completed = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();
    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) { completed = true; completer.complete(null); }
    });
    return await completer.future;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: ColorPick.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _publishDate = picked);
  }

  Future<void> _save(OverviewCmsCubit cubit, {String publishStatus = 'published'}) async {
    if (publishStatus == 'published') {
      setState(() => _submitted = true);
      if (!_isFormValid) { _showValidationError(); return; }
    }

    try {
      cubit.updateHeadingsTitle(en: _headTitleEn.text, ar: _headTitleAr.text);
      cubit.updateHeadingsDescription(en: _headDescEn.text, ar: _headDescAr.text);

      cubit.updateServicesTitle(en: _svcTitleEn.text, ar: _svcTitleAr.text);
      for (final item in List<OverviewServiceItemModel>.from(cubit.current.services.items)) {
        cubit.removeServiceItem(item.id);
      }
      for (var i = 0; i < _services.length; i++) cubit.addServiceItem();
      for (var i = 0; i < _services.length; i++) {
        final id = cubit.current.services.items[i].id;
        cubit.updateServiceItemName(id, en: _services[i].nameEn.text, ar: _services[i].nameAr.text);
        if (_services[i].image.bytes != null) {
          await cubit.uploadServiceItemImage(id, _services[i].image.bytes!);
        } else if (_services[i].image.url != null && _services[i].image.url!.isNotEmpty) {
          cubit.updateServiceItemImageUrl(id, _services[i].image.url!);
        }
      }

      for (final img in List<OverviewGalleryImageModel>.from(cubit.current.gallery.images)) {
        cubit.removeGalleryImage(img.id);
      }
      for (var i = 0; i < _galleryItems.length; i++) cubit.addGallerySlot();
      for (var i = 0; i < _galleryItems.length; i++) {
        final id = cubit.current.gallery.images[i].id;
        if (_galleryItems[i].image.bytes != null) {
          await cubit.uploadGalleryImage(id, _galleryItems[i].image.bytes!);
        } else if (_galleryItems[i].image.url != null && _galleryItems[i].image.url!.isNotEmpty) {
          cubit.updateGalleryImageUrl(id, _galleryItems[i].image.url!);
        }
      }

      cubit.updateClientCommentsTitle(en: _cmtTitleEn.text, ar: _cmtTitleAr.text);
      for (final cmt in List<OverviewClientCommentModel>.from(cubit.current.clientComments.comments)) {
        cubit.removeClientComment(cmt.id);
      }
      for (var i = 0; i < _comments.length; i++) cubit.addClientComment();
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

      cubit.updateDownloadTitle(en: _dlTitleEn.text, ar: _dlTitleAr.text);
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlay.text);
      cubit.updatePublishDate(_publishDate);

      String finalStatus = publishStatus;
      if (publishStatus == 'published' && _publishDate != null && _publishDate!.isAfter(DateTime.now())) {
        finalStatus = 'scheduled';
      }

      await cubit.save(publishStatus: finalStatus);
    } catch (e, st) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e',
              style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
          backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
