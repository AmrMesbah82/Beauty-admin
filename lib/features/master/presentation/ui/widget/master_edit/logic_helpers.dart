part of '../../pages/master_edit.dart';

extension _MasterEditLogic on _MasterEditPageState {
  bool _isValidEnglish(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[؀-ۿ]').hasMatch(text);
  }

  bool _isValidArabic(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  bool get _isFormValid {
    final englishFieldsOk = _isValidEnglish(_headerTitleEn.text) &&
        _isValidEnglish(_headerShortEn.text) &&
        _isValidEnglish(_aboutTitleEn.text) &&
        _isValidEnglish(_aboutDescEn.text) &&
        _isValidEnglish(_footerTitleEn.text) &&
        _isValidEnglish(_footerDescEn.text);

    final arabicFieldsOk = _isValidArabic(_headerTitleAr.text) &&
        _isValidArabic(_headerShortAr.text) &&
        _isValidArabic(_aboutTitleAr.text) &&
        _isValidArabic(_aboutDescAr.text) &&
        _isValidArabic(_footerTitleAr.text) &&
        _isValidArabic(_footerDescAr.text);

    final linksOk = _appStoreLink.text.trim().isNotEmpty &&
        _googlePlayLink.text.trim().isNotEmpty;

    final imagesOk = _headerImage.isValid && _footerImage.isValid;

    return englishFieldsOk && arabicFieldsOk && linksOk && imagesOk;
  }

  List<String> _getMissingFields() {
    final missing = <String>[];

    if (!_headerImage.isValid) missing.add('Header SVG image');

    if (_headerTitleEn.text.trim().isEmpty) {
      missing.add('Header Title (EN)');
    } else if (RegExp(r'[؀-ۿ]').hasMatch(_headerTitleEn.text)) {
      missing.add('Header Title (EN) - contains Arabic characters');
    }

    if (_headerShortEn.text.trim().isEmpty) {
      missing.add('Header Short Description (EN)');
    } else if (RegExp(r'[؀-ۿ]').hasMatch(_headerShortEn.text)) {
      missing.add('Header Short Description (EN) - contains Arabic characters');
    }

    if (_aboutTitleEn.text.trim().isEmpty) {
      missing.add('About Us Title (EN)');
    } else if (RegExp(r'[؀-ۿ]').hasMatch(_aboutTitleEn.text)) {
      missing.add('About Us Title (EN) - contains Arabic characters');
    }

    if (_aboutDescEn.text.trim().isEmpty) {
      missing.add('About Us Description (EN)');
    } else if (RegExp(r'[؀-ۿ]').hasMatch(_aboutDescEn.text)) {
      missing.add('About Us Description (EN) - contains Arabic characters');
    }

    if (_footerTitleEn.text.trim().isEmpty) {
      missing.add('Footer Title (EN)');
    } else if (RegExp(r'[؀-ۿ]').hasMatch(_footerTitleEn.text)) {
      missing.add('Footer Title (EN) - contains Arabic characters');
    }

    if (_footerDescEn.text.trim().isEmpty) {
      missing.add('Footer Description (EN)');
    } else if (RegExp(r'[؀-ۿ]').hasMatch(_footerDescEn.text)) {
      missing.add('Footer Description (EN) - contains Arabic characters');
    }

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
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

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

    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }

    print('[MasterEditPage] _seedFromModel: ✅ DONE');
  }

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

  Future<_PickedImage?> _pickImage() async {
    print('[_pickImage] ▶ START');
    final completer = Completer<_PickedImage?>();
    bool completed = false;

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
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

      final reader = html.FileReader();

      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is ByteBuffer) {
            final bytes = Uint8List.view(result);
            completer.complete(_PickedImage(bytes: bytes));
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
      if (!completed) {
        completed = true;
        completer.complete(null);
      }
    });

    return await completer.future;
  }

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

  Future<void> _save(MasterCmsCubit cubit,
      {String publishStatus = 'published'}) async {
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

      String finalStatus = publishStatus;
      if (publishStatus == 'published' && _publishDate != null) {
        final now = DateTime.now();
        if (_publishDate!.isAfter(now)) {
          finalStatus = 'scheduled';
        }
      }

      await cubit.save(publishStatus: finalStatus);
      Get.forceAppUpdate();
    } catch (e, st) {
      print('[MasterEditPage] _save: ❌ ERROR: $e\n$st');
      if (mounted) {}
    }
  }
}
