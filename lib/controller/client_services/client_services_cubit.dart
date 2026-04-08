/// ******************* FILE INFO *******************
/// File Name: client_services_cubit.dart
/// Description: Cubit for Client Services CMS module.
///              Manages: Header (SVG + Title + Description),
///              Download Applications, Mockups (add/remove/update/upload + layout).
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/client_services/client_services_model.dart';
import '../../repo/client_services/client_services_repo.dart';
import 'client_services_state.dart';

class ClientServicesCmsCubit extends Cubit<ClientServicesCmsState> {
  final ClientServicesRepo _repo;

  ClientServicesCmsCubit(this._repo) : super(ClientServicesCmsInitial());

  ClientServicesPageModel _current = const ClientServicesPageModel();
  ClientServicesPageModel get current => _current;

  String _activeGender = 'female';
  String get activeGender => _activeGender;

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load({String gender = 'female'}) async {
    print('🟡 [ClientServicesCmsCubit] load: gender=$gender');
    _activeGender = gender;
    emit(ClientServicesCmsLoading());
    try {
      _current = await _repo.fetchPage(gender: gender);
      print('🟢 [ClientServicesCmsCubit] load: ✅ mockups=${_current.mockups.items.length}');
      emit(ClientServicesCmsLoaded(_current));
    } catch (e) {
      print('🔴 [ClientServicesCmsCubit] load: ERROR $e');
      emit(ClientServicesCmsError(e.toString()));
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
      header: _current.header.copyWith(description: BiText(en: en, ar: ar)),
    );
  }

  Future<void> uploadHeaderSvg(Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'clientServices/$_activeGender/header',
      bytes: bytes,
      fileName: 'header_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    _current = _current.copyWith(
      header: _current.header.copyWith(svgUrl: url),
    );
  }

  void removeHeaderSvg() {
    _current = _current.copyWith(
      header: _current.header.copyWith(svgUrl: ''),
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
    List<ClientServicesMockupItemModel>.from(_current.mockups.items);
    items.add(ClientServicesMockupItemModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      order: items.length,
    ));
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  void removeMockupItem(String id) {
    final items = _current.mockups.items.where((e) => e.id != id).toList();
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupTitle(String id,
      {required String en, required String ar}) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(title: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupDescription(String id,
      {required String en, required String ar}) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(description: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  void updateMockupLayout(String id, MockupLayout layout) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(layout: layout);
      return e;
    }).toList();
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  Future<void> uploadMockupSvg(String id, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'clientServices/$_activeGender/mockups',
      bytes: bytes,
      fileName: '${id}_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(svgUrl: url);
      return e;
    }).toList();
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  void removeMockupSvg(String id) {
    final items = _current.mockups.items.map((e) {
      if (e.id == id) return e.copyWith(svgUrl: '');
      return e;
    }).toList();
    _current = _current.copyWith(
        mockups: _current.mockups.copyWith(items: items));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> save({String publishStatus = 'published'}) async {
    print('🟡 [ClientServicesCmsCubit] save: status=$publishStatus');
    try {
      _current = _current.copyWith(
        status: publishStatus,
        lastUpdated: DateTime.now(),
      );
      await _repo.savePage(_current);
      print('🟢 [ClientServicesCmsCubit] save: ✅ DONE');
      emit(ClientServicesCmsSaved(_current));
    } catch (e) {
      print('🔴 [ClientServicesCmsCubit] save: ERROR $e');
      emit(ClientServicesCmsError(e.toString()));
    }
  }
}