/// ******************* FILE INFO *******************
/// File Name: master_cubit.dart
/// Description: Cubit for the Master CMS module.
///              Dual-document architecture:
///              - load() checks for draft first, falls back to published
///              - save(publishStatus: 'published') → writes published doc, deletes draft
///              - save(publishStatus: 'draft')     → writes draft doc only
///              - save(publishStatus: 'scheduled')  → writes draft doc with schedule date
///              - discardDraft() → deletes draft doc
/// Created by: Amr Mesbah
/// Last Update: 19/04/2026
/// UPDATED: Dual-document draft system ✅

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/master_model.dart';
import '../../domain/base_repository/master_repo.dart';

import 'master_state.dart';

class MasterCmsCubit extends Cubit<MasterCmsState> {
  final MasterRepo _repo;

  MasterCmsCubit(this._repo) : super(MasterCmsInitial());

  // ── In-memory working copy ─────────────────────────────────────────────────
  MasterPageModel _current = const MasterPageModel();
  MasterPageModel get current => _current;

  String _activeGender = 'female';
  String get activeGender => _activeGender;

  /// Whether the currently loaded data came from a draft document.
  bool _isFromDraft = false;
  bool get isFromDraft => _isFromDraft;

  // ── Load from draft (unsaved edits from edit page) ─────────────────────────
  void loadModel(MasterPageModel model) {
    _current = model;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOAD — draft-first strategy
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> load({String gender = 'female'}) async {
    _activeGender = gender;
    emit(MasterCmsLoading());
    try {
      // 1️⃣ Check if a draft exists
      final draft = await _repo.fetchDraft(gender: gender);
      if (draft != null) {
        _current     = draft;
        _isFromDraft = true;
        emit(MasterCmsLoaded(_current, isFromDraft: true));
        return;
      }

      // 2️⃣ No draft — load published
      _current     = await _repo.fetchMasterPage(gender: gender);
      _isFromDraft = false;
      emit(MasterCmsLoaded(_current, isFromDraft: false));
    } catch (e) {
      emit(MasterCmsError(e.toString()));
    }
  }

  // ── Switch gender tab ──────────────────────────────────────────────────────
  Future<void> switchGender(String gender) async {
    if (gender == _activeGender) return;
    await load(gender: gender);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FIELD UPDATE METHODS (unchanged API)
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE — routes to published or draft based on publishStatus
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> save({String publishStatus = 'published'}) async {
    try {
      _current = _current.copyWith(
        status: publishStatus,
        lastUpdated: DateTime.now(),
      );

      switch (publishStatus) {
      // ── PUBLISH: save to published doc, delete draft ────────────────
        case 'published':
          await _repo.saveMasterPage(_current);
          // Clean up any existing draft
          await _repo.deleteDraft(gender: _activeGender);
          _isFromDraft = false;
          emit(MasterCmsSaved(_current));
          break;

      // ── DRAFT: save to draft doc only, do NOT touch published ───────
        case 'draft':
          await _repo.saveDraft(_current);
          _isFromDraft = true;
          emit(MasterCmsDraftSaved(_current));
          break;

      // ── SCHEDULED: save to draft doc with schedule date ─────────────
        case 'scheduled':
          await _repo.saveDraft(_current);
          _isFromDraft = true;
          emit(MasterCmsDraftSaved(_current));
          break;

        default:
          await _repo.saveDraft(_current);
          _isFromDraft = true;
          emit(MasterCmsDraftSaved(_current));
      }
    } catch (e) {
      emit(MasterCmsError(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DISCARD DRAFT — deletes the draft doc (published stays untouched)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> discardDraft() async {
    try {
      await _repo.deleteDraft(gender: _activeGender);
      _isFromDraft = false;
      emit(MasterCmsDraftDeleted());
    } catch (e) {
      emit(MasterCmsError(e.toString()));
    }
  }
}