part of '../../pages/owner_services_edit.dart';

extension _OwnerServicesEditLogic on _OwnerServicesEditPageState {
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

    _headerImage = d.header.imageUrl.isNotEmpty
        ? _PickedImage(url: d.header.imageUrl)
        : _PickedImage.empty();
    _headerTitleEn.text = d.header.title.en;
    _headerTitleAr.text = d.header.title.ar;
    _headerDescEn.text = d.header.description.en;
    _headerDescAr.text = d.header.description.ar;

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
      local.alignment = item.alignment;
      local.image = item.imageUrl.isNotEmpty
          ? _PickedImage(url: item.imageUrl)
          : _PickedImage.empty();
      _mockups.add(local);
    }

    print('[OwnerServicesEditPage] _seedFromModel ✅ DONE, mockups count: ${_mockups.length}');
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

  Future<void> _save(
    OwnerServicesCmsCubit cubit, {
    String publishStatus = 'published',
  }) async {
    setState(() => _submitted = true);
    try {
      print('[OwnerServicesEditPage] _save: Starting save with ${_mockups.length} mockups');

      cubit.updateHeaderTitle(en: _headerTitleEn.text, ar: _headerTitleAr.text);
      cubit.updateHeaderDescription(en: _headerDescEn.text, ar: _headerDescAr.text);

      if (_headerImage.bytes != null) {
        await cubit.uploadHeaderImage(_headerImage.bytes!);
      } else if (_headerImage.url != null && _headerImage.url!.isNotEmpty) {
        cubit.updateHeaderImageUrl(_headerImage.url!);
      } else {
        cubit.removeHeaderImage();
      }

      cubit.updateDownloadTitle(en: _dlTitleEn.text, ar: _dlTitleAr.text);
      cubit.updateAppStoreLink(_appStoreLink.text);
      cubit.updateGooglePlayLink(_googlePlay.text);

      for (final item in List<OwnerServicesMockupItemModel>.from(
        cubit.current.mockups.items,
      )) {
        cubit.removeMockupItem(item.id);
      }

      for (var i = 0; i < _mockups.length; i++) {
        cubit.addMockupItem();
      }

      for (var i = 0; i < _mockups.length; i++) {
        final id = cubit.current.mockups.items[i].id;

        cubit.updateMockupItemTitle(id, en: _mockups[i].titleEn.text, ar: _mockups[i].titleAr.text);
        cubit.updateMockupItemDescription(id, en: _mockups[i].descEn.text, ar: _mockups[i].descAr.text);
        cubit.updateMockupItemAlignment(id, _mockups[i].alignment);

        if (_mockups[i].image.bytes != null) {
          await cubit.uploadMockupItemImage(id, _mockups[i].image.bytes!);
        } else if (_mockups[i].image.url != null && _mockups[i].image.url!.isNotEmpty) {
          cubit.updateMockupItemImageUrl(id, _mockups[i].image.url!);
        }
      }

      await cubit.save(publishStatus: publishStatus);
      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[OwnerServicesEditPage] _save: ❌ ERROR: $e\n$st');
      rethrow;
    }
  }
}
