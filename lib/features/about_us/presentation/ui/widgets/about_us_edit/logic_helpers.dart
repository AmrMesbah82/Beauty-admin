// ******************* FILE INFO *******************
// File Name: logic_helpers.dart
// Description: Business-logic helpers for About Us edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › about_us_edit

part of '../../pages/about_us_edit.dart';

extension _AboutEditLogicHelpers on _AboutEditPageMasterState {
  void _seedFromModel(AboutPageModel m) {
    final modelHash = Object.hashAll([
      m.title.en,
      m.title.ar,
      m.svgUrl,
      m.navigationLabel.iconUrl,
      m.navigationLabel.title.en,
      m.navigationLabel.title.ar,
      m.vision.iconUrl,
      m.vision.svgUrl,
      m.vision.subDescription.en,
      m.vision.subDescription.ar,
      m.vision.description.en,
      m.vision.description.ar,
      m.mission.iconUrl,
      m.mission.svgUrl,
      m.mission.subDescription.en,
      m.mission.subDescription.ar,
      m.mission.description.en,
      m.mission.description.ar,
      m.values.length,
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    // Remove listeners while seeding to avoid spurious _hasChanges flips
    for (final ctrl in _allTextControllers) {
      ctrl.removeListener(_onFieldChanged);
    }

    _titleEnCtrl.text = m.title.en;
    _titleArCtrl.text = m.title.ar;
    _headingsSvgUrl = m.svgUrl;

    _navLabelIconUrl = m.navigationLabel.iconUrl;
    _navLabelTitleEnCtrl.text = m.navigationLabel.title.en;
    _navLabelTitleArCtrl.text = m.navigationLabel.title.ar;

    _visionSubEnCtrl.text = m.vision.subDescription.en;
    _visionSubArCtrl.text = m.vision.subDescription.ar;
    _visionDescEnCtrl.text = m.vision.description.en;
    _visionDescArCtrl.text = m.vision.description.ar;
    _visionIconUrl = m.vision.iconUrl;
    _visionSvgUrl = m.vision.svgUrl;

    _missionSubEnCtrl.text = m.mission.subDescription.en;
    _missionSubArCtrl.text = m.mission.subDescription.ar;
    _missionDescEnCtrl.text = m.mission.description.en;
    _missionDescArCtrl.text = m.mission.description.ar;
    _missionIconUrl = m.mission.iconUrl;
    _missionSvgUrl = m.mission.svgUrl;

    _valueItems.clear();
    for (final v in m.values) {
      final item = _ValueItem(id: v.id, counter: ++_valueCounter);
      item.titleEnCtrl.text = v.title.en;
      item.titleArCtrl.text = v.title.ar;
      item.shortDescEnCtrl.text = v.shortDescription.en;
      item.shortDescArCtrl.text = v.shortDescription.ar;
      item.iconUrl = v.iconUrl;
      _valueItems.add(item);
    }

    _hasChanges = false;
    _seeded = true;

    // Re-attach listeners
    for (final ctrl in _allTextControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  AboutPageModel _buildModel(String status) {
    return AboutPageModel(
      publishStatus: status,
      title: AboutBilingualText(
        en: _titleEnCtrl.text.trim(),
        ar: _titleArCtrl.text.trim(),
      ),
      svgUrl: _headingsSvgUrl,
      navigationLabel: AboutNavigationLabel(
        iconUrl: _navLabelIconUrl,
        title: AboutBilingualText(
          en: _navLabelTitleEnCtrl.text.trim(),
          ar: _navLabelTitleArCtrl.text.trim(),
        ),
      ),
      vision: AboutSection(
        iconUrl: _visionIconUrl,
        svgUrl: _visionSvgUrl,
        subDescription: AboutBilingualText(
          en: _visionSubEnCtrl.text.trim(),
          ar: _visionSubArCtrl.text.trim(),
        ),
        description: AboutBilingualText(
          en: _visionDescEnCtrl.text.trim(),
          ar: _visionDescArCtrl.text.trim(),
        ),
      ),
      mission: AboutSection(
        iconUrl: _missionIconUrl,
        svgUrl: _missionSvgUrl,
        subDescription: AboutBilingualText(
          en: _missionSubEnCtrl.text.trim(),
          ar: _missionSubArCtrl.text.trim(),
        ),
        description: AboutBilingualText(
          en: _missionDescEnCtrl.text.trim(),
          ar: _missionDescArCtrl.text.trim(),
        ),
      ),
      values: _valueItems
          .map(
            (v) => AboutValueItem(
              id: v.id,
              iconUrl: v.iconUrl,
              title: AboutBilingualText(
                en: v.titleEnCtrl.text.trim(),
                ar: v.titleArCtrl.text.trim(),
              ),
              shortDescription: AboutBilingualText(
                en: v.shortDescEnCtrl.text.trim(),
                ar: v.shortDescArCtrl.text.trim(),
              ),
            ),
          )
          .toList(),
    );
  }

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};

    if (_headingsSvgBytes != null)
      uploads['about_cms/headings/svg'] = _headingsSvgBytes!;
    if (_navLabelIconBytes != null)
      uploads['about_cms/navLabel/icon'] = _navLabelIconBytes!;
    if (_visionIconBytes != null)
      uploads['about_cms/vision/icon'] = _visionIconBytes!;
    if (_visionSvgBytes != null)
      uploads['about_cms/vision/svg'] = _visionSvgBytes!;
    if (_missionIconBytes != null)
      uploads['about_cms/mission/icon'] = _missionIconBytes!;
    if (_missionSvgBytes != null)
      uploads['about_cms/mission/svg'] = _missionSvgBytes!;
    for (final v in _valueItems) {
      if (v.iconBytes != null)
        uploads['about_cms/values/${v.id}/icon'] = v.iconBytes!;
    }
    return uploads;
  }
}
