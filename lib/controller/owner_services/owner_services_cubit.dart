/// ******************* FILE INFO *******************
/// File Name: owner_services_cubit.dart
/// Description: Cubit for the Owner Services CMS module.
///              Manages: Header (image + title + description),
///              Download Applications (title + links),
///              Mockups (add/remove/update/upload with alignment),
///              Publish Schedule.
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/owner_services/owner_services_model.dart';
import '../../repo/owner_services/owner_services_repo.dart';
import 'owner_services_state.dart';

class OwnerServicesCmsCubit extends Cubit<OwnerServicesCmsState> {
  final OwnerServicesRepo _repo;

  OwnerServicesCmsCubit(this._repo) : super(OwnerServicesCmsInitial());

  OwnerServicesPageModel _current = const OwnerServicesPageModel();
  OwnerServicesPageModel get current => _current;

  String _activeGender = 'female';
  String get activeGender => _activeGender;

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load({String gender = 'female'}) async {
    print('🟡 [OwnerServicesCmsCubit] load: gender=$gender');
    _activeGender = gender;
    emit(OwnerServicesCmsLoading());
    try {
      _current =
      await _repo.fetchOwnerServicesPage(gender: gender);
      print('🟢 [OwnerServicesCmsCubit] load: ✅');
      emit(OwnerServicesCmsLoaded(_current));
    } catch (e) {
      print('🔴 [OwnerServicesCmsCubit] load: ERROR $e');
      emit(OwnerServicesCmsError(e.toString()));
    }
  }

  Future<void> switchGender(String gender) async {
    if (gender == _activeGender) return;
    await load(gender: gender);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  void updateHeaderTitle({required String en, required String ar}) {
    _current = _current.copyWith(
      header: _current.header.copyWith(title: BiText(en: en, ar: ar)),
    );
  }

  void updateHeaderDescription({required String en, required String ar}) {
    _current = _current.copyWith(
      header:
      _current.header.copyWith(description: BiText(en: en, ar: ar)),
    );
  }

  void updateHeaderImageUrl(String url) {
    _current = _current.copyWith(
      header: _current.header.copyWith(imageUrl: url),
    );
  }

  Future<void> uploadHeaderImage(Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'ownerServicesPages/$_activeGender/header',
      bytes: bytes,
      fileName: 'header_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    _current = _current.copyWith(
      header: _current.header.copyWith(imageUrl: url),
    );
  }

  void removeHeaderImage() {
    _current = _current.copyWith(
      header: _current.header.copyWith(imageUrl: ''),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD APPLICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  void updateDownloadTitle({required String en, required String ar}) {
    _current = _current.copyWith(
      download: _current.download.copyWith(title: BiText(en: en, ar: ar)),
    );
  }

  void updateAppStoreLink(String link) {
    _current = _current.copyWith(
        download: _current.download.copyWith(appStoreLink: link));
  }

  void updateGooglePlayLink(String link) {
    _current = _current.copyWith(
        download: _current.download.copyWith(googlePlayLink: link));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCKUPS
  // ═══════════════════════════════════════════════════════════════════════════
  void addMockupItem() {
    final items =
    List<OwnerServicesMockupItemModel>.from(_current.mockups.items);
    items.add(OwnerServicesMockupItemModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}_${items.length}',
      order: items.length,
    ));
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  void removeMockupItem(String id) {
    final items = _current.mockups.items.where((e) => e.id != id).toList();
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupItemTitle(String id,
      {required String en, required String ar}) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(title: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupItemDescription(String id,
      {required String en, required String ar}) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) {
        return e.copyWith(description: BiText(en: en, ar: ar));
      }
      return e;
    }).toList();
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupItemAlignment(String id, String alignment) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(alignment: alignment);
      return e;
    }).toList();
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupItemImageUrl(String id, String url) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  Future<void> uploadMockupItemImage(String id, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'ownerServicesPages/$_activeGender/mockups',
      bytes: bytes,
      fileName: '${id}_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current =
        _current.copyWith(mockups: _current.mockups.copyWith(items: items));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLISH SCHEDULE
  // ═══════════════════════════════════════════════════════════════════════════
  void updatePublishDate(DateTime? date) {
    _current = _current.copyWith(
      publishSchedule:
      _current.publishSchedule.copyWith(publishDate: date),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> save({String publishStatus = 'published'}) async {
    print('🟡 [OwnerServicesCmsCubit] save: status=$publishStatus');
    try {
      _current = _current.copyWith(
        status: publishStatus,
        lastUpdated: DateTime.now(),
      );
      await _repo.saveOwnerServicesPage(_current);
      print('🟢 [OwnerServicesCmsCubit] save: ✅ DONE');
      emit(OwnerServicesCmsSaved(_current));
    } catch (e) {
      print('🔴 [OwnerServicesCmsCubit] save: ERROR $e');
      emit(OwnerServicesCmsError(e.toString()));
    }
  }
}