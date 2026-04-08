/// ******************* FILE INFO *******************
/// File Name: master_cubit.dart
/// Description: Cubit for the Master CMS module.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/master/master_model.dart';
import '../../repo/master/master_repo.dart';
import 'master_state.dart';

class MasterCmsCubit extends Cubit<MasterCmsState> {
  final MasterRepo _repo;

  MasterCmsCubit(this._repo) : super(MasterCmsInitial());

  // ── In-memory working copy ─────────────────────────────────────────────────
  MasterPageModel _current = const MasterPageModel();
  MasterPageModel get current => _current;

  String _activeGender = 'female';
  String get activeGender => _activeGender;

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load({String gender = 'female'}) async {
    print('🟡 [MasterCmsCubit] load: gender=$gender');
    _activeGender = gender;
    emit(MasterCmsLoading());
    try {
      _current = await _repo.fetchMasterPage(gender: gender);
      print('🟢 [MasterCmsCubit] load: ✅ sections=${_current.sections.length}');
      emit(MasterCmsLoaded(_current));
    } catch (e) {
      print('🔴 [MasterCmsCubit] load: ERROR $e');
      emit(MasterCmsError(e.toString()));
    }
  }

  // ── Switch gender tab ──────────────────────────────────────────────────────
  Future<void> switchGender(String gender) async {
    if (gender == _activeGender) return;
    await load(gender: gender);
  }

  // ── Title / Short Description ──────────────────────────────────────────────
  void updateTitle({required String en, required String ar}) {
    _current = _current.copyWith(title: BiText(en: en, ar: ar));
  }

  void updateShortDescription({required String en, required String ar}) {
    _current =
        _current.copyWith(shortDescription: BiText(en: en, ar: ar));
  }

  // ── Section updates ────────────────────────────────────────────────────────
  void updateSectionTitle(String sectionKey,
      {required String en, required String ar}) {
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) {
          return s.copyWith(title: BiText(en: en, ar: ar));
        }
        return s;
      }).toList(),
    );
  }

  void updateSectionShortDescription(String sectionKey,
      {required String en, required String ar}) {
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) {
          return s.copyWith(shortDescription: BiText(en: en, ar: ar));
        }
        return s;
      }).toList(),
    );
  }

  void updateSectionDescription(String sectionKey,
      {required String en, required String ar}) {
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) {
          return s.copyWith(description: BiText(en: en, ar: ar));
        }
        return s;
      }).toList(),
    );
  }

  void updateSectionTextBoxColor(String sectionKey, String color) {
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) {
          return s.copyWith(textBoxColor: color);
        }
        return s;
      }).toList(),
    );
  }

  void toggleSectionVisibility(String sectionKey) {
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) {
          return s.copyWith(visibility: !s.visibility);
        }
        return s;
      }).toList(),
    );
  }

  // ── Section image uploads ──────────────────────────────────────────────────
  Future<void> uploadSectionImage(
      String sectionKey, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'masterPages/$_activeGender/sections/$sectionKey',
      bytes: bytes,
      fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) return s.copyWith(imageUrl: url);
        return s;
      }).toList(),
    );
  }

  Future<void> uploadSectionIcon(
      String sectionKey, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'masterPages/$_activeGender/sections/$sectionKey',
      bytes: bytes,
      fileName: 'icon_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    _current = _current.copyWith(
      sections: _current.sections.map((s) {
        if (s.sectionKey == sectionKey) return s.copyWith(iconUrl: url);
        return s;
      }).toList(),
    );
  }

  // ── App Links ──────────────────────────────────────────────────────────────
  void updateAppStoreLink(String link) {
    _current = _current.copyWith(
      appLinks: _current.appLinks.copyWith(appStoreLink: link),
    );
  }

  void updateGooglePlayLink(String link) {
    _current = _current.copyWith(
      appLinks: _current.appLinks.copyWith(googlePlayLink: link),
    );
  }

  // ── Publish Schedule ───────────────────────────────────────────────────────
  void updatePublishDate(DateTime? date) {
    _current = _current.copyWith(
      publishSchedule:
      _current.publishSchedule.copyWith(publishDate: date),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> save({String publishStatus = 'published'}) async {
    print('🟡 [MasterCmsCubit] save: status=$publishStatus');
    try {
      _current = _current.copyWith(
        status: publishStatus,
        lastUpdated: DateTime.now(),
      );
      await _repo.saveMasterPage(_current);
      print('🟢 [MasterCmsCubit] save: ✅ DONE');
      emit(MasterCmsSaved(_current));
    } catch (e) {
      print('🔴 [MasterCmsCubit] save: ERROR $e');
      emit(MasterCmsError(e.toString()));
    }
  }
}