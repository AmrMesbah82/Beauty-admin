// ******************* FILE INFO *******************
// File Name: logic_helpers.dart
// Description: Business-logic helpers for Contact Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_edit

part of '../../pages/contact_us_edit.dart';

extension _ContactUsEditLogic on _ContactUsCmsEditPageState {
  // ── Seed ────────────────────────────────────────────────────────────────────
  void _trySeed() {
    if (_seeded) {
      return;
    }
    if (_pendingContactModel == null) {
      return;
    }
    if (_footerSocialLinks.isEmpty) {
      return;
    }
    _seedFromModel(_pendingContactModel!);
  }

  void _seedFromModel(ContactUsCmsModel m) {
    if (_seeded) return;
    _seeded = true;

    _titleEnCtrl.text     = m.headings.title.en;
    _titleArCtrl.text     = m.headings.title.ar;
    _shortDescEnCtrl.text = m.headings.shortDescription.en;
    _shortDescArCtrl.text = m.headings.shortDescription.ar;
    _headingSvgUrl        = m.headings.svgUrl;

    _clientDescEnCtrl.text = m.clientDescription.description.en;
    _clientDescArCtrl.text = m.clientDescription.description.ar;
    _clientIsRequired      = m.clientDescription.isRequired;
    _clientReasons.clear();
    for (final r in m.clientDescription.reasons) {
      final item = _ReasonItem(id: r.id, counter: ++_clientReasonCounter);
      item.labelEnCtrl.text = r.label.en;
      item.labelArCtrl.text = r.label.ar;
      _clientReasons.add(item);
    }

    _ownerDescEnCtrl.text = m.ownerDescription.description.en;
    _ownerDescArCtrl.text = m.ownerDescription.description.ar;
    _ownerIsRequired      = m.ownerDescription.isRequired;
    _ownerReasons.clear();
    for (final r in m.ownerDescription.reasons) {
      final item = _ReasonItem(id: r.id, counter: ++_ownerReasonCounter);
      item.labelEnCtrl.text = r.label.en;
      item.labelArCtrl.text = r.label.ar;
      _ownerReasons.add(item);
    }

    _socialLinkItems.clear();
  }

  // ── SVG Picker ──────────────────────────────────────────────────────────────
  Future<Uint8List?> _pickSvgOnly() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file      = files.first;
      final isSvgExt  = file.name.toLowerCase().endsWith('.svg');
      final isSvgMime = file.type == 'image/svg+xml' || file.type.contains('svg');

      if (!isSvgExt && !isSvgMime) {
        completer.complete(null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:         Text('Only SVG files are allowed'),
              backgroundColor: const Color(0xFFD32F2F),
              duration:        Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          Uint8List? bytes;
          if (result is ByteBuffer)    bytes = Uint8List.view(result);
          else if (result is Uint8List) bytes = result;
          else if (result is List<int>) bytes = Uint8List.fromList(result);

          if (bytes != null && !_isValidSvgContent(bytes)) {
            completer.complete(null);
            return;
          }
          completer.complete(bytes);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  bool _isValidSvgContent(Uint8List bytes) {
    if (bytes.length < 10) return false;
    try {
      final content = String.fromCharCodes(
          bytes.sublist(0, bytes.length.clamp(0, 500)));
      final trimmed = content.trimLeft();
      return trimmed.startsWith('<svg') ||
          (trimmed.startsWith('<?xml') && trimmed.contains('<svg'));
    } catch (_) {
      return false;
    }
  }

  // ── Build Model ─────────────────────────────────────────────────────────────
  ContactUsCmsModel _buildModel(String status) {

    final socialIcons = <ContactSocialIcon>[];
    for (var i = 0; i < _socialLinkItems.length; i++) {
      final s = _socialLinkItems[i];

      final hasSelection =
          s.selectedIndex != null &&
              s.selectedIndex! < _footerSocialLinks.length;
      final selectedLink = hasSelection ? _footerSocialLinks[s.selectedIndex!] : null;

      final url     = selectedLink?.url ?? '';
      final iconUrl = (selectedLink != null && selectedLink.iconUrl.isNotEmpty)
          ? selectedLink.iconUrl
          : s.iconUrl;

      socialIcons.add(ContactSocialIcon(id: s.id, iconUrl: iconUrl, link: url));
    }

    return ContactUsCmsModel(
      publishStatus: status,
      headings: ContactHeadings(
        svgUrl: _headingSvgUrl,
        title: ContactBilingualText(
          en: _titleEnCtrl.text.trim(),
          ar: _titleArCtrl.text.trim(),
        ),
        shortDescription: ContactBilingualText(
          en: _shortDescEnCtrl.text.trim(),
          ar: _shortDescArCtrl.text.trim(),
        ),
      ),
      clientDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: _clientDescEnCtrl.text.trim(),
          ar: _clientDescArCtrl.text.trim(),
        ),
        isRequired: _clientIsRequired,
        reasons: _clientReasons
            .map((r) => ContactReasonItem(
                  id:    r.id,
                  label: ContactBilingualText(
                    en: r.labelEnCtrl.text.trim(),
                    ar: r.labelArCtrl.text.trim(),
                  ),
                ))
            .toList(),
      ),
      ownerDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: _ownerDescEnCtrl.text.trim(),
          ar: _ownerDescArCtrl.text.trim(),
        ),
        isRequired: _ownerIsRequired,
        reasons: _ownerReasons
            .map((r) => ContactReasonItem(
                  id:    r.id,
                  label: ContactBilingualText(
                    en: r.labelEnCtrl.text.trim(),
                    ar: r.labelArCtrl.text.trim(),
                  ),
                ))
            .toList(),
      ),
      socialIcons: socialIcons,
    );
  }

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_headingSvgBytes != null) {
      uploads['contact_cms/headings/svg'] = _headingSvgBytes!;
    }
    return uploads;
  }

  // ── Validation & Save ───────────────────────────────────────────────────────
  bool _validate() {
    setState(() => _submitted = true);

    if (_titleEnCtrl.text.trim().isEmpty)     return false;
    if (_titleArCtrl.text.trim().isEmpty)     return false;
    if (_shortDescEnCtrl.text.trim().isEmpty) return false;
    if (_shortDescArCtrl.text.trim().isEmpty) return false;
    if (_headingSvgBytes == null && _headingSvgUrl.isEmpty) return false;

    if (_clientDescEnCtrl.text.trim().isEmpty) return false;
    if (_clientDescArCtrl.text.trim().isEmpty) return false;
    for (final r in _clientReasons) {
      if (r.labelEnCtrl.text.trim().isEmpty) return false;
      if (r.labelArCtrl.text.trim().isEmpty) return false;
    }

    if (_ownerDescEnCtrl.text.trim().isEmpty) return false;
    if (_ownerDescArCtrl.text.trim().isEmpty) return false;
    for (final r in _ownerReasons) {
      if (r.labelEnCtrl.text.trim().isEmpty) return false;
      if (r.labelArCtrl.text.trim().isEmpty) return false;
    }

    return true;
  }

  Future<void> _save(String status) async {
    final model   = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<ContactUsCmsCubit>().save(
      model:        model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  Future<void> _onSaveTap() async {

    if (!_validate()) {
      return;
    }

    await showPublishConfirmDialog(
      context:  context,
      title:    'EDITING CONTACT US DETAILS',
      subtitle: 'Do you want to save the changes made to this Contact Us page?',
      onConfirm: () => _save('published'),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── Add / Remove helpers ────────────────────────────────────────────────────
  void _addClientReason() => setState(() {
        _clientReasons.add(_ReasonItem(
          id:      'reason_client_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_clientReasonCounter,
        ));
      });

  void _removeClientReason(String id) =>
      setState(() => _clientReasons.removeWhere((r) => r.id == id));

  void _addOwnerReason() => setState(() {
        _ownerReasons.add(_ReasonItem(
          id:      'reason_owner_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_ownerReasonCounter,
        ));
      });

  void _removeOwnerReason(String id) =>
      setState(() => _ownerReasons.removeWhere((r) => r.id == id));

  void _addSocialLink() {
    final newItem = _SocialLinkItem(
      id:      'social_${DateTime.now().millisecondsSinceEpoch}',
      counter: ++_socialLinkCounter,
    );
    setState(() => _socialLinkItems.add(newItem));
  }

  void _removeSocialLink(String id) {
    setState(() => _socialLinkItems.removeWhere((s) => s.id == id));
  }
}
