// ******************* FILE INFO *******************
// File Name: logic_helpers.dart
// Description: Business-logic helpers for Client Services edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › client_services › presentation › ui › widget › client_services_edit

part of '../../pages/client_services_edit.dart';

extension _ClientServicesEditLogic on _ClientServicesEditPageState {
  // ── Validation ──────────────────────────────────────────────────────────────
  bool _validate() {
    setState(() => _submitted = true);

    if (_hdrTitleEn.text.trim().isEmpty) return false;
    if (_hdrTitleAr.text.trim().isEmpty) return false;
    if (_hdrDescEn.text.trim().isEmpty) return false;
    if (_hdrDescAr.text.trim().isEmpty) return false;

    if (_dlTitleEn.text.trim().isEmpty) return false;
    if (_dlTitleAr.text.trim().isEmpty) return false;

    for (var i = 0; i < _mockups.length; i++) {
      if (_mockups[i].titleEn.text.trim().isEmpty) return false;
      if (_mockups[i].titleAr.text.trim().isEmpty) return false;
      if (_mockups[i].descEn.text.trim().isEmpty) return false;
      if (_mockups[i].descAr.text.trim().isEmpty) return false;
    }

    return true;
  }

  // ── Seed ────────────────────────────────────────────────────────────────────
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

  // ── Image picker ────────────────────────────────────────────────────────────
  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed = false;

    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';


    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!completed) {
          completed = true;
          completer.complete(null);
        }
        return;
      }

      final file = files.first;

      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        if (!completed) {
          completed = true;
          completer.complete(null);
        }
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
            completer
                .complete(_PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            completer.complete(null);
          }
        }
      });

      reader.onError.listen((e) {
        if (!completed) {
          completed = true;
          completer.complete(null);
        }
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

    final result = await completer.future;
    return result;
  }

  // ── Save ────────────────────────────────────────────────────────────────────
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
      rethrow;
    }
  }
}
