// ******************* FILE INFO *******************
// File Name: home_cubit.dart
// Description: BLoC Cubit for Home CMS.
// Created by: Amr Mesbah
// UPDATED: updateAppDownloadLinks() now accepts labelEn, labelAr params ✅
// ADDED: uploadAppLinkIcon() — uploads iOS/Android icon to Firebase Storage ✅
// FIXED: emit(HomeCmsLoaded(_model)) added after every upload method ✅

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';


import '../../data/models/home_model.dart';
import '../../domain/base_repository/home_repo.dart';
import 'home_state.dart';

class HomeCmsCubit extends Cubit<HomeCmsState> {
  HomeCmsCubit({required HomeRepository repository})
      : _repo = repository,
        super(HomeCmsInitial());

  final HomeRepository _repo;
  final _storage = GetStorage();

  HomePageModel _model = HomePageModel.defaultModel;

  HomePageModel get current => _model;

  static final _rng = Random();
  static String _uid() {
    final ts   = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = _rng.nextInt(0xFFFFFF).toRadixString(36).padLeft(5, '0');
    return '${ts}_$rand';
  }

  // ✅ writes branding fonts to GetStorage so AppTextStyles reads them
  void _applyFontsToStorage(BrandingModel branding) {
    final engFont = branding.englishFont.isEmpty ? 'Cairo' : branding.englishFont;
    final arFont  = branding.arabicFont.isEmpty  ? 'Cairo' : branding.arabicFont;
    _storage.write('font',        engFont);
    _storage.write('font_arabic', arFont);
  }

  // ── Merge defaults ────────────────────────────────────────────────────────
  HomePageModel _mergeDefaults(HomePageModel loaded) {
    final defaults = HomePageModel.defaultModel.navButtons;

    final seen = <String>{};
    final deduped = loaded.navButtons.where((b) {
      if (seen.contains(b.id)) {
        return false;
      }
      seen.add(b.id);
      return true;
    }).toList();

    final existingRoutes = deduped.map((b) => b.route).toSet();
    final missing = defaults
        .where((d) => !existingRoutes.contains(d.route))
        .toList();

    if (missing.isNotEmpty) {
      for (final m in missing) {
      }
    }

    final merged = [...deduped, ...missing];

    for (var i = 0; i < merged.length; i++) {
    }

    return loaded.copyWith(navButtons: merged);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(HomeCmsLoading());
    try {
      final fetched = await _repo.fetchHomePageFresh();

      final result = _mergeDefaults(fetched);
      for (var i = 0; i < result.navButtons.length; i++) {
      }
      for (var i = 0; i < result.socialLinks.length; i++) {
      }

      _model = result;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsLoaded(_model));
    } catch (e, st) {
      emit(HomeCmsError('Failed to load home page: $e'));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> save({
    String publishStatus = 'published',
    DateTime? scheduledPublishDate,
  }) async
  {
    for (var i = 0; i < _model.navButtons.length; i++) {
    }
    for (var i = 0; i < _model.socialLinks.length; i++) {
    }

    emit(HomeCmsSaving(_model));

    try {
      HomePageModel saving;
      if (publishStatus == 'scheduled' && scheduledPublishDate != null) {
        saving = _model.copyWith(
          publishStatus: 'scheduled',
          scheduledPublishDate: scheduledPublishDate,
        );
      } else if (publishStatus == 'draft') {
        saving = _model.copyWith(
          publishStatus: 'draft',
          clearScheduledPublishDate: true,
        );
      } else {
        saving = _model.copyWith(
          publishStatus: 'published',
          clearScheduledPublishDate: true,
        );
      }

      await _repo.saveHomePage(saving);

      final fetched = await _repo.fetchHomePageFresh();

      final persisted = _mergeDefaults(fetched);
      for (var i = 0; i < persisted.navButtons.length; i++) {
      }

      _model = persisted;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsSaved(_model));

    } catch (e, st) {
      emit(HomeCmsError('Failed to save: $e', _model));
    }
  }

  // ── Scheduled Publish Date ────────────────────────────────────────────────

  void updateScheduledPublishDate(DateTime? date) {
    if (date == null) {
      _model = _model.copyWith(clearScheduledPublishDate: true);
    } else {
      _model = _model.copyWith(scheduledPublishDate: date);
    }
  }

  // ── Headings ──────────────────────────────────────────────────────────────

  void updateTitle({required String en, required String ar}) {
    _model = _model.copyWith(title: BiText(en: en, ar: ar));
  }



  // ── in the Branding / Logo section, after updateHeaderFooterColor() ───────

  void updateMalePrimaryColor(String hex) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(malePrimaryColor: hex));
  }

  void updateMainWidgetColor(String hex) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(mainWidgetColor: hex));
  }


  void updateShortDescription({required String en, required String ar}) {
    _model = _model.copyWith(shortDescription: BiText(en: en, ar: ar));
  }

  // ── Nav Buttons ───────────────────────────────────────────────────────────

  void addNavButton() {
    final updated = List<NavButtonModel>.from(_model.navButtons)
      ..add(NavButtonModel(id: _uid()));
    _model = _model.copyWith(navButtons: updated);
  }

  void removeNavButton(String id) {
    _model = _model.copyWith(
      navButtons: _model.navButtons.where((b) => b.id != id).toList(),
    );
  }

  void reorderNavButtons(int oldIndex, int newIndex) {
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
    emit(HomeCmsLoaded(_model));
    for (var i = 0; i < _model.navButtons.length; i++) {
    }
  }

  void reorderNavButtonsSilent(int oldIndex, int newIndex) {
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
  }

  void updateNavButtonName(String id,
      {required String en, required String ar}) {
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) =>
      b.id == id ? b.copyWith(name: BiText(en: en, ar: ar)) : b)
          .toList(),
    );
  }

  void updateNavButtonRoute(String id, String route) {
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(route: route) : b)
          .toList(),
    );
  }

  void toggleNavButtonStatus(String id) {
    final before = _model.navButtons
        .where((b) => b.id == id)
        .map((b) => b.status)
        .firstOrNull;
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(status: !b.status) : b)
          .toList(),
    );
    final after = _model.navButtons
        .where((b) => b.id == id)
        .map((b) => b.status)
        .firstOrNull;
  }

  // ── Nav Button Icon Upload ────────────────────────────────────────────────

  Future<void> uploadNavButtonIcon(String id, Uint8List bytes) async {
    final path = 'home_cms/nav_icons/${id}_${_uid()}.svg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _model = _model.copyWith(
        navButtons: _model.navButtons
            .map((b) => b.id == id ? b.copyWith(iconUrl: url) : b)
            .toList(),
      );
      emit(HomeCmsLoaded(_model)); // ✅ FIXED
    } catch (e, st) {
      emit(HomeCmsError('Nav icon upload failed: $e', _model));
    }
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  void updateSectionTextBoxColor(int index, String color) {
    _updateSection(index, (s) => s.copyWith(textBoxColor: color));
  }

  void updateSectionDescription(int index,
      {required String en, required String ar}) {
    _updateSection(
        index, (s) => s.copyWith(description: BiText(en: en, ar: ar)));
  }

  void updateSectionVisibility(int index, bool visibility) {
    _updateSection(index, (s) => s.copyWith(visibility: visibility));
  }

  Future<void> uploadSectionImage(int index, Uint8List bytes) async {
    final path = 'home_cms/sections/$index/image_${_uid()}.jpg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _updateSection(index, (s) => s.copyWith(imageUrl: url));
      emit(HomeCmsLoaded(_model)); // ✅ FIXED
    } catch (e, st) {
      emit(HomeCmsError('Section image upload failed: $e', _model));
    }
  }

  Future<void> uploadSectionIcon(int index, Uint8List bytes) async {
    final path = 'home_cms/sections/$index/icon_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _updateSection(index, (s) => s.copyWith(iconUrl: url));
      emit(HomeCmsLoaded(_model)); // ✅ FIXED
    } catch (e, st) {
      emit(HomeCmsError('Section icon upload failed: $e', _model));
    }
  }

  void _updateSection(
      int index, SectionCardModel Function(SectionCardModel) updater) {
    final sections = List<SectionCardModel>.from(_model.sections);
    while (sections.length <= index) {
      sections.add(const SectionCardModel());
    }
    sections[index] = updater(sections[index]);
    _model = _model.copyWith(sections: sections);
    // NOTE: no emit here — callers that need it emit themselves after calling
  }

  // ── Header Items ──────────────────────────────────────────────────────────

  void updateHeaderItemTitle(String id,
      {required String en, required String ar}) {
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) =>
      h.id == id ? h.copyWith(title: BiText(en: en, ar: ar)) : h)
          .toList(),
    );
  }

  void toggleHeaderItemStatus(String id) {
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) => h.id == id ? h.copyWith(status: !h.status) : h)
          .toList(),
    );
  }

  void reorderHeaderItems(int oldIndex, int newIndex) {
    final list = List<HeaderItemModel>.from(_model.headerItems);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(headerItems: list);
  }

  // ── Footer Columns ────────────────────────────────────────────────────────

  void addFooterColumn() {
    final updated = List<FooterColumnModel>.from(_model.footerColumns)
      ..add(FooterColumnModel(id: _uid()));
    _model = _model.copyWith(footerColumns: updated);
  }

  void removeFooterColumn(String id) {
    _model = _model.copyWith(
      footerColumns:
      _model.footerColumns.where((c) => c.id != id).toList(),
    );
  }

  void updateFooterColumnTitle(String colId,
      {required String en, required String ar}) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) =>
      c.id == colId ? c.copyWith(title: BiText(en: en, ar: ar)) : c)
          .toList(),
    );
  }

  void updateFooterColumnRoute(String colId, String route) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) => c.id == colId ? c.copyWith(route: route) : c)
          .toList(),
    );
  }

  void addFooterLabel(String colId) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
            labels: [...c.labels, FooterLabelModel(id: _uid())]);
      }).toList(),
    );
  }

  void removeFooterLabel(String colId, String labelId) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
            labels: c.labels.where((l) => l.id != labelId).toList());
      }).toList(),
    );
  }

  void updateFooterLabel(String colId, String labelId,
      {required String en, required String ar}) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
          labels: c.labels
              .map((l) => l.id == labelId
              ? l.copyWith(label: BiText(en: en, ar: ar))
              : l)
              .toList(),
        );
      }).toList(),
    );
  }

  void updateFooterLabelRoute(String colId, String labelId, String route) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
          labels: c.labels
              .map((l) =>
          l.id == labelId ? l.copyWith(route: route) : l)
              .toList(),
        );
      }).toList(),
    );
  }

  // ── Social Links ──────────────────────────────────────────────────────────

  void addSocialLink() {
    final id = 'sl_${_uid()}';
    _model = _model.copyWith(
      socialLinks: [..._model.socialLinks, SocialLinkModel(id: id)],
    );
  }

  void removeSocialLink(String id) {
    _model = _model.copyWith(
      socialLinks:
      _model.socialLinks.where((s) => s.id != id).toList(),
    );
  }

  void updateSocialLink(String id, {required String url, bool? visibility}) {
    _model = _model.copyWith(
      socialLinks: _model.socialLinks
          .map((s) => s.id == id
          ? s.copyWith(
        url:        url,
        visibility: visibility ?? s.visibility,
      )
          : s)
          .toList(),
    );
  }

  Future<void> uploadSocialLinkIcon(String id, Uint8List bytes) async {
    final path = 'home_cms/social_icons/${id}_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _model = _model.copyWith(
        socialLinks: _model.socialLinks
            .map((s) => s.id == id ? s.copyWith(iconUrl: url) : s)
            .toList(),
      );
      emit(HomeCmsLoaded(_model)); // ✅ FIXED
    } catch (e, st) {
      emit(HomeCmsError('Social icon upload failed: $e', _model));
    }
  }

  // ── App Download Links ────────────────────────────────────────────────────

  void updateAppDownloadLinks({
    String? iosUrl,
    String? androidUrl,
    String? labelEn,
    String? labelAr,
    bool? visibility,
  }) {
    _model = _model.copyWith(
      appDownloadLinks: _model.appDownloadLinks.copyWith(
        iosUrl:     iosUrl,
        androidUrl: androidUrl,
        labelEn:    labelEn,
        labelAr:    labelAr,
        visibility: visibility,
      ),
    );
  }

  // ── App Link Icon Upload ──────────────────────────────────────────────────

  Future<void> uploadAppLinkIcon(String platform, Uint8List bytes) async {
    final path = 'home_cms/app_link_icons/${platform}_${_uid()}.svg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      if (platform == 'ios') {
        _model = _model.copyWith(
          appDownloadLinks:
          _model.appDownloadLinks.copyWith(iosIconUrl: url),
        );
      } else {
        _model = _model.copyWith(
          appDownloadLinks:
          _model.appDownloadLinks.copyWith(androidIconUrl: url),
        );
      }
      emit(HomeCmsLoaded(_model)); // ✅ FIXED
    } catch (e, st) {
      emit(HomeCmsError('App link icon upload failed: $e', _model));
    }
  }

  // ── Branding / Logo ───────────────────────────────────────────────────────

  Future<void> uploadLogo(Uint8List bytes) async {
    final path = 'home_cms/branding/logo_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _model =
          _model.copyWith(branding: _model.branding.copyWith(logoUrl: url));
      emit(HomeCmsLoaded(_model)); // ✅ FIXED
    } catch (e, st) {
      emit(HomeCmsError('Logo upload failed: $e', _model));
    }
  }

  void updatePrimaryColor(String hex) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(primaryColor: hex));
  }

  void updateSecondaryColor(String hex) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(secondaryColor: hex));
  }

  void updateBackgroundColor(String hex) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(backgroundColor: hex));
  }

  void updateHeaderFooterColor(String hex) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(headerFooterColor: hex));
  }

  void updateEnglishFont(String font) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(englishFont: font));
  }

  void updateArabicFont(String font) {
    _model = _model.copyWith(
        branding: _model.branding.copyWith(arabicFont: font));
  }
}