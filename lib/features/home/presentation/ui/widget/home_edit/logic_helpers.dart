part of '../../pages/home_edit.dart';

extension _HomeEditLogic on _HomeEditPageState {
  void _setupChangeListeners() {
    _titleEn.addListener(() => setState(() => _hasChanges = true));
    _titleAr.addListener(() => setState(() => _hasChanges = true));
    _shortDescEn.addListener(() => setState(() => _hasChanges = true));
    _shortDescAr.addListener(() => setState(() => _hasChanges = true));

    for (final btn in _navBtns) {
      btn['nameEn']!.addListener(() => setState(() => _hasChanges = true));
      btn['nameAr']!.addListener(() => setState(() => _hasChanges = true));
    }

    _appLabelEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _appLabelArCtrl.addListener(() => setState(() => _hasChanges = true));
    _iosUrlCtrl.addListener(() => setState(() => _hasChanges = true));
    _androidUrlCtrl.addListener(() => setState(() => _hasChanges = true));

    _primaryColor.addListener(() => setState(() => _hasChanges = true));
    _malePrimaryColor.addListener(() => setState(() => _hasChanges = true));
    _secondaryColor.addListener(() => setState(() => _hasChanges = true));
    _bgColor.addListener(() => setState(() => _hasChanges = true));
    _headerFooterColor.addListener(() => setState(() => _hasChanges = true));
    _mainWidgetColor.addListener(() => setState(() => _hasChanges = true));

    for (final item in _headerItems) {
      item.en.addListener(() => setState(() => _hasChanges = true));
      item.ar.addListener(() => setState(() => _hasChanges = true));
    }

    for (final col in _footerColumns) {
      (col['titleEn'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
      (col['titleAr'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        (label['en'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
        (label['ar'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
      }
    }

    for (final link in _links) {
      link.text.addListener(() => setState(() => _hasChanges = true));
    }
  }

  Future<_PickedImage?> _pickImage() async {
    print('[HomeEditPage] _pickImage: opening file picker');
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
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }

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

  void _seedFromModel(HomePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl),
      ...d.socialLinks.map((s) => s.iconUrl),
      d.branding.logoUrl,
      d.appDownloadLinks.iosUrl,
      d.appDownloadLinks.androidUrl,
      d.appDownloadLinks.labelEn,
      d.appDownloadLinks.labelAr,
      d.appDownloadLinks.iosIconUrl,
      d.appDownloadLinks.androidIconUrl,
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    _titleEn.text     = d.title.en;
    _titleAr.text     = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    while (_navBtns.length > d.navButtons.length) {
      final removed = _navBtns.removeLast();
      removed['nameEn']!.dispose();
      removed['nameAr']!.dispose();
      _navRoutes.removeLast();
      _navStatus.removeLast();
    }
    while (_navBtns.length < d.navButtons.length) {
      _navBtns.add({
        'nameEn': TextEditingController(),
        'nameAr': TextEditingController(),
      });
      _navRoutes.add(null);
      _navStatus.add(true);
    }

    for (var i = 0; i < d.navButtons.length; i++) {
      _navBtns[i]['nameEn']!.text = d.navButtons[i].name.en;
      _navBtns[i]['nameAr']!.text = d.navButtons[i].name.ar;
      _navRoutes[i] = d.navButtons[i].route.isEmpty ? null : d.navButtons[i].route;
      _navStatus[i] = d.navButtons[i].status;
    }

    while (_navIcons.length > d.navButtons.length) _navIcons.removeLast();
    while (_navIcons.length < d.navButtons.length) _navIcons.add(const _PickedImage());

    for (var i = 0; i < d.navButtons.length; i++) {
      _navIcons[i] = d.navButtons[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.navButtons[i].iconUrl)
          : const _PickedImage();
    }

    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i]['textBox']!.text       = d.sections[i].textBoxColor;
      _sections[i]['description']!.text   = d.sections[i].description.en;
      _sections[i]['descriptionAr']!.text = d.sections[i].description.ar;
      _sectionImages[i]['image'] = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl)
          : const _PickedImage();
      _sectionImages[i]['icon'] = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl)
          : const _PickedImage();
    }

    for (var i = 0; i < _headerItems.length && i < d.headerItems.length; i++) {
      _headerItems[i].en.text = d.headerItems[i].title.en;
      _headerItems[i].ar.text = d.headerItems[i].title.ar;
      _headerItems[i].status  = d.headerItems[i].status;
    }

    while (_footerColumns.length > d.footerColumns.length) {
      final removed = _footerColumns.removeLast();
      _disposeColumn(removed);
    }
    while (_footerColumns.length < d.footerColumns.length) {
      _footerColumns.add(_newFooterColumn());
    }
    for (var i = 0; i < d.footerColumns.length; i++) {
      (_footerColumns[i]['titleEn'] as TextEditingController).text =
          d.footerColumns[i].title.en;
      (_footerColumns[i]['titleAr'] as TextEditingController).text =
          d.footerColumns[i].title.ar;
      _footerColumns[i]['route'] =
          d.footerColumns[i].route.isEmpty ? null : d.footerColumns[i].route;

      final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
      while (labels.length > d.footerColumns[i].labels.length) {
        _disposeLabel(labels.removeLast());
      }
      while (labels.length < d.footerColumns[i].labels.length) {
        labels.add(_newLabelRow());
      }
      for (var li = 0; li < d.footerColumns[i].labels.length; li++) {
        (labels[li]['en'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.en;
        (labels[li]['ar'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.ar;
        labels[li]['route'] = d.footerColumns[i].labels[li].route.isEmpty
            ? null
            : d.footerColumns[i].labels[li].route;
      }
    }

    while (_links.length > d.socialLinks.length) _links.removeLast().dispose();
    while (_links.length < d.socialLinks.length) _links.add(_LinkItem());
    for (var i = 0; i < d.socialLinks.length; i++) {
      _links[i].text.text = d.socialLinks[i].url;
      _links[i].icon = d.socialLinks[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.socialLinks[i].iconUrl)
          : const _PickedImage();
      _links[i].visibility = d.socialLinks[i].visibility;
    }

    _primaryColor.text      = d.branding.primaryColor;
    _malePrimaryColor.text  = d.branding.malePrimaryColor.isNotEmpty
        ? d.branding.malePrimaryColor
        : '#D9D9D9';
    _secondaryColor.text    = d.branding.secondaryColor;
    _bgColor.text           = d.branding.backgroundColor.isNotEmpty
        ? d.branding.backgroundColor
        : '#D9D9D9';
    _headerFooterColor.text = d.branding.headerFooterColor.isNotEmpty
        ? d.branding.headerFooterColor
        : '#D9D9D9';
    _mainWidgetColor.text   = d.branding.mainWidgetColor.isNotEmpty
        ? d.branding.mainWidgetColor
        : '#D9D9D9';
    _engFont     = d.branding.englishFont.isEmpty ? 'Cairo' : d.branding.englishFont;
    _arFont      = d.branding.arabicFont.isEmpty  ? 'Cairo' : d.branding.arabicFont;
    _logoPicked  = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl)
        : const _PickedImage();

    _iosUrlCtrl.text       = d.appDownloadLinks.iosUrl;
    _androidUrlCtrl.text   = d.appDownloadLinks.androidUrl;
    _appLabelEnCtrl.text   = d.appDownloadLinks.labelEn;
    _appLabelArCtrl.text   = d.appDownloadLinks.labelAr;
    _downloadAppVisibility = d.appDownloadLinks.visibility;
    _iosIconPicked = d.appDownloadLinks.iosIconUrl.isNotEmpty
        ? _PickedImage(url: d.appDownloadLinks.iosIconUrl)
        : const _PickedImage();
    _androidIconPicked = d.appDownloadLinks.androidIconUrl.isNotEmpty
        ? _PickedImage(url: d.appDownloadLinks.androidIconUrl)
        : const _PickedImage();

    _hasChanges = false;
  }

  Map<String, dynamic> _newFooterColumn() => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'route':   null as String?,
    'labels':  <Map<String, dynamic>>[_newLabelRow()],
  };

  Map<String, dynamic> _newLabelRow() => {
    'en':    TextEditingController(),
    'ar':    TextEditingController(),
    'route': null as String?,
  };

  void _disposeColumn(Map<String, dynamic> col) {
    (col['titleEn'] as TextEditingController).dispose();
    (col['titleAr'] as TextEditingController).dispose();
    for (final l in col['labels'] as List<Map<String, dynamic>>) {
      _disposeLabel(l);
    }
  }

  void _disposeLabel(Map<String, dynamic> label) {
    (label['en'] as TextEditingController).dispose();
    (label['ar'] as TextEditingController).dispose();
  }

  bool _validate() {
    setState(() => _submitted = true);

    for (var i = 0; i < _navBtns.length; i++) {
      if (_navBtns[i]['nameEn']!.text.trim().isEmpty) return false;
      if (_navBtns[i]['nameAr']!.text.trim().isEmpty) return false;
    }

    for (final col in _footerColumns) {
      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        if ((label['en'] as TextEditingController).text.trim().isEmpty) return false;
        if ((label['ar'] as TextEditingController).text.trim().isEmpty) return false;
      }
    }

    for (final link in _links) {
      if (link.text.text.trim().isEmpty) return false;
    }

    if (_appLabelEnCtrl.text.trim().isEmpty) return false;
    if (_appLabelArCtrl.text.trim().isEmpty) return false;
    if (_iosUrlCtrl.text.trim().isEmpty) return false;
    if (_androidUrlCtrl.text.trim().isEmpty) return false;

    return true;
  }

  bool _validateSilent() {
    for (var i = 0; i < _navBtns.length; i++) {
      if (_navBtns[i]['nameEn']!.text.trim().isEmpty) return false;
      if (_navBtns[i]['nameAr']!.text.trim().isEmpty) return false;
    }

    for (final col in _footerColumns) {
      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        if ((label['en'] as TextEditingController).text.trim().isEmpty) return false;
        if ((label['ar'] as TextEditingController).text.trim().isEmpty) return false;
      }
    }

    for (final link in _links) {
      if (link.text.text.trim().isEmpty) return false;
    }

    if (_appLabelEnCtrl.text.trim().isEmpty) return false;
    if (_appLabelArCtrl.text.trim().isEmpty) return false;
    if (_iosUrlCtrl.text.trim().isEmpty) return false;
    if (_androidUrlCtrl.text.trim().isEmpty) return false;

    return true;
  }

  Future<void> _save(HomeCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    setState(() => _submitted = true);

    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(en: _shortDescEn.text, ar: _shortDescAr.text);

      final snapshot  = List<NavButtonModel>.from(cubit.current.navButtons);
      final routeToId = { for (final b in snapshot) b.route: b.id };

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        if (localRoute.isEmpty) continue;
        final currentIndex =
            cubit.current.navButtons.indexWhere((b) => b.route == localRoute);
        if (currentIndex != -1 && currentIndex != i) {
          cubit.reorderNavButtonsSilent(currentIndex, i);
        }
      }

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        final id         = routeToId[localRoute];
        if (id == null) continue;

        cubit.updateNavButtonName(id,
            en: _navBtns[i]['nameEn']!.text,
            ar: _navBtns[i]['nameAr']!.text);
        cubit.updateNavButtonRoute(id, localRoute);

        if (_navIcons[i].bytes != null) {
          await cubit.uploadNavButtonIcon(id, _navIcons[i].bytes!);
        }

        final modelStatus = cubit.current.navButtons
            .firstWhere((b) => b.id == id,
                orElse: () => NavButtonModel(id: id))
            .status;
        if (modelStatus != _navStatus[i]) {
          cubit.toggleNavButtonStatus(id);
        }
      }

      while (cubit.current.footerColumns.length < _footerColumns.length) {
        cubit.addFooterColumn();
      }
      while (cubit.current.footerColumns.length > _footerColumns.length) {
        cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
      }
      for (var i = 0; i < _footerColumns.length; i++) {
        final colId = cubit.current.footerColumns[i].id;
        cubit.updateFooterColumnTitle(colId,
            en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
            ar: (_footerColumns[i]['titleAr'] as TextEditingController).text);
        cubit.updateFooterColumnRoute(
            colId, _footerColumns[i]['route'] as String? ?? '');

        final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
        while (cubit.current.footerColumns[i].labels.length < labels.length) {
          cubit.addFooterLabel(colId);
        }
        while (cubit.current.footerColumns[i].labels.length > labels.length) {
          cubit.removeFooterLabel(
              colId, cubit.current.footerColumns[i].labels.last.id);
        }
        for (var li = 0; li < labels.length; li++) {
          final lblId    = cubit.current.footerColumns[i].labels[li].id;
          final lblRoute = (labels[li]['route'] as String?) ?? '';
          cubit.updateFooterLabel(colId, lblId,
              en: (labels[li]['en'] as TextEditingController).text,
              ar: (labels[li]['ar'] as TextEditingController).text);
          cubit.updateFooterLabelRoute(colId, lblId, lblRoute);
        }
      }

      while (cubit.current.socialLinks.length < _links.length) {
        cubit.addSocialLink();
      }
      while (cubit.current.socialLinks.length > _links.length) {
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      }
      for (var i = 0; i < _links.length; i++) {
        final id = cubit.current.socialLinks[i].id;
        cubit.updateSocialLink(id,
            url:        _links[i].text.text,
            visibility: _links[i].visibility);
        if (_links[i].icon.bytes != null) {
          await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
        }
      }

      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);

      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateMalePrimaryColor(_malePrimaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateBackgroundColor(_bgColor.text);
      cubit.updateHeaderFooterColor(_headerFooterColor.text);
      cubit.updateMainWidgetColor(_mainWidgetColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont  ?? 'Cairo');

      cubit.updateAppDownloadLinks(
        iosUrl:     _iosUrlCtrl.text,
        androidUrl: _androidUrlCtrl.text,
        labelEn:    _appLabelEnCtrl.text,
        labelAr:    _appLabelArCtrl.text,
        visibility: _downloadAppVisibility,
      );
      if (_iosIconPicked.bytes != null) {
        await cubit.uploadAppLinkIcon('ios', _iosIconPicked.bytes!);
      }
      if (_androidIconPicked.bytes != null) {
        await cubit.uploadAppLinkIcon('android', _androidIconPicked.bytes!);
      }

      await cubit.save(publishStatus: publishStatus);

      _hasChanges = false;
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[HomeEditPage] _save: ❌ ERROR: $e\n$st');
      rethrow;
    }
  }
}
