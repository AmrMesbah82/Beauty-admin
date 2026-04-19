// ******************* FILE INFO *******************
// File Name: home_cubit.dart
// Description: BLoC Cubit for Home CMS.
// Created by: Amr Mesbah
// UPDATED: updateAppDownloadLinks() now accepts labelEn, labelAr params ✅
// ADDED: uploadAppLinkIcon() — uploads iOS/Android icon to Firebase Storage ✅

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';



import '../../model/home/home_model.dart';
import '../../repo/home_repo/repo.dart';
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
    _storage.write('font',         engFont);
    _storage.write('font_arabic',  arFont);
    print('✅ [HomeCubit] _applyFontsToStorage() '
        'font=$engFont font_arabic=$arFont');
  }

  // ── Merge defaults ────────────────────────────────────────────────────────
  HomePageModel _mergeDefaults(HomePageModel loaded) {
    final defaults = HomePageModel.defaultModel.navButtons;

    final seen = <String>{};
    final deduped = loaded.navButtons.where((b) {
      if (seen.contains(b.id)) {
        print('⚠️  [HomeCubit] _mergeDefaults: removing duplicate id=${b.id}');
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
        print('   + inserting missing navButton: '
            'en=${m.name.en} route=${m.route}');
      }
    }

    final merged = [...deduped, ...missing];

    print('✅ [HomeCubit] _mergeDefaults() — result: ${merged.length} items');
    for (var i = 0; i < merged.length; i++) {
      print('   navButtons[$i] → '
          'en=${merged[i].name.en} '
          'route=${merged[i].route} '
          'iconUrl=${merged[i].iconUrl} '
          'status=${merged[i].status}');
    }

    return loaded.copyWith(navButtons: merged);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    print('🔵 [HomeCubit] load() called');
    emit(HomeCmsLoading());
    try {
      print('🔵 [HomeCubit] load() → fetching fresh from server...');
      final fetched = await _repo.fetchHomePageFresh();
      print('🟢 [HomeCubit] load() SUCCESS');
      print('   title.en               = ${fetched.title.en}');
      print('   navButtons.length      = ${fetched.navButtons.length}');
      print('   sections.length        = ${fetched.sections.length}');
      print('   branding.logoUrl       = ${fetched.branding.logoUrl}');
      print('   publishStatus          = ${fetched.publishStatus}');
      print('   scheduledPublishDate   = ${fetched.scheduledPublishDate}');
      print('   appDownloadLinks.iosUrl        = ${fetched.appDownloadLinks.iosUrl}');
      print('   appDownloadLinks.androidUrl    = ${fetched.appDownloadLinks.androidUrl}');
      print('   appDownloadLinks.labelEn       = ${fetched.appDownloadLinks.labelEn}');
      print('   appDownloadLinks.labelAr       = ${fetched.appDownloadLinks.labelAr}');
      print('   appDownloadLinks.iosIconUrl    = ${fetched.appDownloadLinks.iosIconUrl}');
      print('   appDownloadLinks.androidIconUrl= ${fetched.appDownloadLinks.androidIconUrl}');
      print('   appDownloadLinks.visibility    = ${fetched.appDownloadLinks.visibility}');

      final result = _mergeDefaults(fetched);
      print('   navButtons after merge = ${result.navButtons.length}');
      for (var i = 0; i < result.navButtons.length; i++) {
        print('   navButtons[$i] → '
            'en=${result.navButtons[i].name.en} | '
            'route=${result.navButtons[i].route} | '
            'iconUrl=${result.navButtons[i].iconUrl} | '
            'status=${result.navButtons[i].status}');
      }

      for (var i = 0; i < result.socialLinks.length; i++) {
        print('   socialLinks[$i] → '
            'id=${result.socialLinks[i].id} '
            'visibility=${result.socialLinks[i].visibility} '
            'url=${result.socialLinks[i].url}');
      }

      _model = result;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsLoaded(_model));
    } catch (e, st) {
      print('🔴 [HomeCubit] load() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Failed to load home page: $e'));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> save({
    String publishStatus = 'published',
    DateTime? scheduledPublishDate,
  }) async {
    print('🔵 [HomeCubit] save() called — publishStatus=$publishStatus '
        'scheduledPublishDate=$scheduledPublishDate');
    print('   _model.navButtons.length = ${_model.navButtons.length}');
    for (var i = 0; i < _model.navButtons.length; i++) {
      print('   BEFORE SAVE navButtons[$i] → '
          'id=${_model.navButtons[i].id} '
          'en=${_model.navButtons[i].name.en} '
          'route=${_model.navButtons[i].route} '
          'iconUrl=${_model.navButtons[i].iconUrl} '
          'status=${_model.navButtons[i].status}');
    }
    for (var i = 0; i < _model.socialLinks.length; i++) {
      print('   BEFORE SAVE socialLinks[$i] → '
          'id=${_model.socialLinks[i].id} '
          'visibility=${_model.socialLinks[i].visibility}');
    }
    print('   BEFORE SAVE appDownloadLinks → '
        'iosUrl=${_model.appDownloadLinks.iosUrl} '
        'androidUrl=${_model.appDownloadLinks.androidUrl} '
        'labelEn=${_model.appDownloadLinks.labelEn} '
        'labelAr=${_model.appDownloadLinks.labelAr} '
        'iosIconUrl=${_model.appDownloadLinks.iosIconUrl} '
        'androidIconUrl=${_model.appDownloadLinks.androidIconUrl} '
        'visibility=${_model.appDownloadLinks.visibility}');

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

      print('🔵 [HomeCubit] save() → calling _repo.saveHomePage()...');
      await _repo.saveHomePage(saving);
      print('🟢 [HomeCubit] save() → saveHomePage() DONE');

      print('🔵 [HomeCubit] save() → calling _repo.fetchHomePageFresh()...');
      final fetched = await _repo.fetchHomePageFresh();
      print('🟢 [HomeCubit] save() → fetchHomePageFresh() DONE');

      final persisted = _mergeDefaults(fetched);
      print('   persisted.navButtons.length = ${persisted.navButtons.length}');
      print('   persisted.publishStatus     = ${persisted.publishStatus}');
      for (var i = 0; i < persisted.navButtons.length; i++) {
        print('   AFTER SAVE navButtons[$i] → '
            'id=${persisted.navButtons[i].id} '
            'en=${persisted.navButtons[i].name.en} '
            'route=${persisted.navButtons[i].route} '
            'iconUrl=${persisted.navButtons[i].iconUrl} '
            'status=${persisted.navButtons[i].status}');
      }
      print('   AFTER SAVE appDownloadLinks → '
          'iosUrl=${persisted.appDownloadLinks.iosUrl} '
          'androidUrl=${persisted.appDownloadLinks.androidUrl} '
          'labelEn=${persisted.appDownloadLinks.labelEn} '
          'labelAr=${persisted.appDownloadLinks.labelAr} '
          'iosIconUrl=${persisted.appDownloadLinks.iosIconUrl} '
          'androidIconUrl=${persisted.appDownloadLinks.androidIconUrl} '
          'visibility=${persisted.appDownloadLinks.visibility}');

      _model = persisted;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsSaved(_model));
      print('🟢 [HomeCubit] save() → emitted HomeCmsSaved');

    } catch (e, st) {
      print('🔴 [HomeCubit] save() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Failed to save: $e', _model));
    }
  }

  // ── Scheduled Publish Date ────────────────────────────────────────────────

  void updateScheduledPublishDate(DateTime? date) {
    print('🔵 [HomeCubit] updateScheduledPublishDate() date=$date');
    if (date == null) {
      _model = _model.copyWith(clearScheduledPublishDate: true);
    } else {
      _model = _model.copyWith(scheduledPublishDate: date);
    }
  }

  // ── Headings ──────────────────────────────────────────────────────────────

  void updateTitle({required String en, required String ar}) {
    print('🔵 [HomeCubit] updateTitle() en="$en" ar="$ar"');
    _model = _model.copyWith(title: BiText(en: en, ar: ar));
  }

  void updateShortDescription({required String en, required String ar}) {
    print('🔵 [HomeCubit] updateShortDescription() en="$en"');
    _model = _model.copyWith(shortDescription: BiText(en: en, ar: ar));
  }

  // ── Nav Buttons ───────────────────────────────────────────────────────────

  void addNavButton() {
    print('🔵 [HomeCubit] addNavButton()');
    final updated = List<NavButtonModel>.from(_model.navButtons)
      ..add(NavButtonModel(id: _uid()));
    _model = _model.copyWith(navButtons: updated);
  }

  void removeNavButton(String id) {
    print('🔵 [HomeCubit] removeNavButton() id=$id');
    _model = _model.copyWith(
      navButtons: _model.navButtons.where((b) => b.id != id).toList(),
    );
  }

  void reorderNavButtons(int oldIndex, int newIndex) {
    print('🔵 [HomeCubit] reorderNavButtons() $oldIndex → $newIndex');
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
    emit(HomeCmsLoaded(_model));
    print('🟢 [HomeCubit] reorderNavButtons() done — new order:');
    for (var i = 0; i < _model.navButtons.length; i++) {
      print('   [$i] en=${_model.navButtons[i].name.en} '
          'route=${_model.navButtons[i].route}');
    }
  }

  void updateNavButtonName(String id,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateNavButtonName() id=$id en="$en"');
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) =>
      b.id == id ? b.copyWith(name: BiText(en: en, ar: ar)) : b)
          .toList(),
    );
  }

  void updateNavButtonRoute(String id, String route) {
    print('🔵 [HomeCubit] updateNavButtonRoute() id=$id route="$route"');
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
    print('🔵 [HomeCubit] toggleNavButtonStatus() '
        'id=$id before=$before → ${!(before ?? true)}');

    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(status: !b.status) : b)
          .toList(),
    );

    final after = _model.navButtons
        .where((b) => b.id == id)
        .map((b) => b.status)
        .firstOrNull;
    print('🟢 [HomeCubit] toggleNavButtonStatus() id=$id after=$after ✅');
  }

  // ── Nav Button Icon Upload ────────────────────────────────────────────────
  Future<void> uploadNavButtonIcon(String id, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadNavButtonIcon() id=$id bytes=${bytes.length}');
    final path = 'home_cms/nav_icons/${id}_${_uid()}.svg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadNavButtonIcon() SUCCESS → url=$url');
      _model = _model.copyWith(
        navButtons: _model.navButtons
            .map((b) => b.id == id ? b.copyWith(iconUrl: url) : b)
            .toList(),
      );
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadNavButtonIcon() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Nav icon upload failed: $e', _model));
    }
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  void updateSectionTextBoxColor(int index, String color) {
    print('🔵 [HomeCubit] updateSectionTextBoxColor() index=$index color=$color');
    _updateSection(index, (s) => s.copyWith(textBoxColor: color));
  }

  void updateSectionDescription(int index,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateSectionDescription() index=$index en="$en"');
    _updateSection(
        index, (s) => s.copyWith(description: BiText(en: en, ar: ar)));
  }

  void updateSectionVisibility(int index, bool visibility) {
    print('🔵 [HomeCubit] updateSectionVisibility() index=$index visibility=$visibility');
    _updateSection(index, (s) => s.copyWith(visibility: visibility));
  }

  Future<void> uploadSectionImage(int index, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadSectionImage() '
        'index=$index bytes=${bytes.length}');
    final path = 'home_cms/sections/$index/image_${_uid()}.jpg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadSectionImage() SUCCESS → url=$url');
      _updateSection(index, (s) => s.copyWith(imageUrl: url));
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadSectionImage() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Section image upload failed: $e', _model));
    }
  }

  Future<void> uploadSectionIcon(int index, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadSectionIcon() '
        'index=$index bytes=${bytes.length}');
    final path = 'home_cms/sections/$index/icon_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadSectionIcon() SUCCESS → url=$url');
      _updateSection(index, (s) => s.copyWith(iconUrl: url));
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadSectionIcon() ERROR: $e');
      print('   StackTrace: $st');
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
  }

  // ── Header Items ──────────────────────────────────────────────────────────

  void updateHeaderItemTitle(String id,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateHeaderItemTitle() id=$id en="$en"');
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) =>
      h.id == id ? h.copyWith(title: BiText(en: en, ar: ar)) : h)
          .toList(),
    );
  }

  void toggleHeaderItemStatus(String id) {
    print('🔵 [HomeCubit] toggleHeaderItemStatus() id=$id');
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) => h.id == id ? h.copyWith(status: !h.status) : h)
          .toList(),
    );
  }

  void reorderHeaderItems(int oldIndex, int newIndex) {
    print('🔵 [HomeCubit] reorderHeaderItems() $oldIndex → $newIndex');
    final list = List<HeaderItemModel>.from(_model.headerItems);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(headerItems: list);
  }

  // ── Footer Columns ────────────────────────────────────────────────────────

  void addFooterColumn() {
    print('🔵 [HomeCubit] addFooterColumn()');
    final updated = List<FooterColumnModel>.from(_model.footerColumns)
      ..add(FooterColumnModel(id: _uid()));
    _model = _model.copyWith(footerColumns: updated);
  }

  void removeFooterColumn(String id) {
    print('🔵 [HomeCubit] removeFooterColumn() id=$id');
    _model = _model.copyWith(
      footerColumns:
      _model.footerColumns.where((c) => c.id != id).toList(),
    );
  }

  void updateFooterColumnTitle(String colId,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateFooterColumnTitle() colId=$colId en="$en"');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) =>
      c.id == colId ? c.copyWith(title: BiText(en: en, ar: ar)) : c)
          .toList(),
    );
  }

  void updateFooterColumnRoute(String colId, String route) {
    print('🔵 [HomeCubit] updateFooterColumnRoute() '
        'colId=$colId route="$route"');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) => c.id == colId ? c.copyWith(route: route) : c)
          .toList(),
    );
  }

  void addFooterLabel(String colId) {
    print('🔵 [HomeCubit] addFooterLabel() colId=$colId');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
            labels: [...c.labels, FooterLabelModel(id: _uid())]);
      }).toList(),
    );
  }

  void removeFooterLabel(String colId, String labelId) {
    print('🔵 [HomeCubit] removeFooterLabel() '
        'colId=$colId labelId=$labelId');
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
    print('🔵 [HomeCubit] updateFooterLabel() '
        'colId=$colId labelId=$labelId en="$en"');
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

  void updateFooterLabelRoute(
      String colId, String labelId, String route) {
    print('🔵 [HomeCubit] updateFooterLabelRoute() '
        'colId=$colId labelId=$labelId route="$route"');
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
    print('🔵 [HomeCubit] addSocialLink() id=$id');
    _model = _model.copyWith(
      socialLinks: [..._model.socialLinks, SocialLinkModel(id: id)],
    );
  }

  void removeSocialLink(String id) {
    print('🔵 [HomeCubit] removeSocialLink() id=$id');
    _model = _model.copyWith(
      socialLinks:
      _model.socialLinks.where((s) => s.id != id).toList(),
    );
  }

  void updateSocialLink(String id, {required String url, bool? visibility}) {
    print('🔵 [HomeCubit] updateSocialLink() '
        'id=$id url="$url" visibility=$visibility');
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
    print('🔵 [HomeCubit] uploadSocialLinkIcon() '
        'id=$id bytes=${bytes.length}');
    final path = 'home_cms/social_icons/${id}_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadSocialLinkIcon() SUCCESS → url=$url');
      _model = _model.copyWith(
        socialLinks: _model.socialLinks
            .map((s) => s.id == id ? s.copyWith(iconUrl: url) : s)
            .toList(),
      );
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadSocialLinkIcon() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Social icon upload failed: $e', _model));
    }
  }

  // ── App Download Links ✅ UPDATED ─────────────────────────────────────────

  void updateAppDownloadLinks({
    String? iosUrl,
    String? androidUrl,
    String? labelEn,
    String? labelAr,
    bool? visibility,
  }) {
    print('🔵 [HomeCubit] updateAppDownloadLinks() '
        'iosUrl=$iosUrl androidUrl=$androidUrl '
        'labelEn=$labelEn labelAr=$labelAr visibility=$visibility');
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

  // ── App Link Icon Upload ✅ NEW ───────────────────────────────────────────

  /// Uploads an icon for the App Link section.
  /// [platform] must be 'ios' or 'android'.
  Future<void> uploadAppLinkIcon(String platform, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadAppLinkIcon() '
        'platform=$platform bytes=${bytes.length}');
    final path = 'home_cms/app_link_icons/${platform}_${_uid()}.svg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadAppLinkIcon() SUCCESS → url=$url');
      if (platform == 'ios') {
        _model = _model.copyWith(
          appDownloadLinks: _model.appDownloadLinks.copyWith(iosIconUrl: url),
        );
      } else {
        _model = _model.copyWith(
          appDownloadLinks: _model.appDownloadLinks.copyWith(androidIconUrl: url),
        );
      }
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadAppLinkIcon() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('App link icon upload failed: $e', _model));
    }
  }

  // ── Branding / Logo ───────────────────────────────────────────────────────

  Future<void> uploadLogo(Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadLogo() bytes=${bytes.length}');
    final path = 'home_cms/branding/logo_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadLogo() SUCCESS → url=$url');
      _model =
          _model.copyWith(branding: _model.branding.copyWith(logoUrl: url));
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadLogo() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Logo upload failed: $e', _model));
    }
  }

  void updatePrimaryColor(String hex) {
    print('🔵 [HomeCubit] updatePrimaryColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(primaryColor: hex));
  }

  void updateSecondaryColor(String hex) {
    print('🔵 [HomeCubit] updateSecondaryColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(secondaryColor: hex));
  }

  void updateBackgroundColor(String hex) {
    print('🔵 [HomeCubit] updateBackgroundColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(backgroundColor: hex));
  }

  void updateHeaderFooterColor(String hex) {
    print('🔵 [HomeCubit] updateHeaderFooterColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(headerFooterColor: hex));
  }

  void updateEnglishFont(String font) {
    print('🔵 [HomeCubit] updateEnglishFont() font=$font');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(englishFont: font));
  }

  void reorderNavButtonsSilent(int oldIndex, int newIndex) {
    print('🔵 [HomeCubit] reorderNavButtonsSilent() $oldIndex → $newIndex');
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
  }

  void updateArabicFont(String font) {
    print('🔵 [HomeCubit] updateArabicFont() font=$font');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(arabicFont: font));
  }
}