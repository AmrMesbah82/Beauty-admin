/// ******************* FILE INFO *******************
/// File Name: overview_cubit.dart
/// Description: Cubit for the Overview CMS module.
///              Manages: Headings, Services (add/remove/update/upload),
///              Gallery (add/remove/upload), Client Comments (add/remove/update/upload),
///              Download Applications, Publish Schedule.
/// Created by: Amr Mesbah
/// Last Update: 09/04/2026

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/overview/overview_model.dart';
import '../../repo/overview/overview_repo.dart';
import 'overview_state.dart';

class OverviewCmsCubit extends Cubit<OverviewCmsState> {
  final OverviewRepo _repo;

  OverviewCmsCubit(this._repo) : super(OverviewCmsInitial());

  OverviewPageModel _current = const OverviewPageModel();
  OverviewPageModel get current => _current;

  String _activeGender = 'female';
  String get activeGender => _activeGender;

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load({String gender = 'female'}) async {
    print('🟡 [OverviewCmsCubit] load: gender=$gender');
    _activeGender = gender;
    emit(OverviewCmsLoading());
    try {
      _current = await _repo.fetchOverviewPage(gender: gender);
      print('🟢 [OverviewCmsCubit] load: ✅');
      emit(OverviewCmsLoaded(_current));
    } catch (e) {
      print('🔴 [OverviewCmsCubit] load: ERROR $e');
      emit(OverviewCmsError(e.toString()));
    }
  }

  Future<void> switchGender(String gender) async {
    if (gender == _activeGender) return;
    await load(gender: gender);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADINGS
  // ═══════════════════════════════════════════════════════════════════════════
  void updateHeadingsTitle({required String en, required String ar}) {
    _current = _current.copyWith(
      headings: _current.headings.copyWith(title: BiText(en: en, ar: ar)),
    );
  }

  void updateHeadingsDescription({required String en, required String ar}) {
    _current = _current.copyWith(
      headings:
      _current.headings.copyWith(description: BiText(en: en, ar: ar)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════
  void updateServicesTitle({required String en, required String ar}) {
    _current = _current.copyWith(
      services: _current.services.copyWith(title: BiText(en: en, ar: ar)),
    );
  }

// SERVICES
  void addServiceItem() {
    final items = List<OverviewServiceItemModel>.from(_current.services.items);
    items.add(OverviewServiceItemModel(
      id: 'svc_${DateTime.now().millisecondsSinceEpoch}_${items.length}',  // ← unique
      order: items.length,
    ));
    _current = _current.copyWith(services: _current.services.copyWith(items: items));
  }

  void removeServiceItem(String id) {
    final items = _current.services.items.where((e) => e.id != id).toList();
    _current =
        _current.copyWith(services: _current.services.copyWith(items: items));
  }

  void updateServiceItemName(String id,
      {required String en, required String ar}) {
    final items = _current.services.items.map((e) {
      if (e.id == id) return e.copyWith(name: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current =
        _current.copyWith(services: _current.services.copyWith(items: items));
  }

  /// Patches an existing URL back onto a service item (no upload needed).
  void updateServiceItemImageUrl(String id, String url) {
    final items = _current.services.items.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current =
        _current.copyWith(services: _current.services.copyWith(items: items));
  }

  Future<void> uploadServiceItemImage(String id, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'overviewPages/$_activeGender/services',
      bytes: bytes,
      fileName: '${id}_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    final items = _current.services.items.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current =
        _current.copyWith(services: _current.services.copyWith(items: items));
  }

  void addGallerySlot() {
    final images = List<OverviewGalleryImageModel>.from(_current.gallery.images);
    images.add(OverviewGalleryImageModel(
      id: 'gal_${DateTime.now().millisecondsSinceEpoch}_${images.length}',  // ← unique
      order: images.length,
    ));
    _current = _current.copyWith(gallery: _current.gallery.copyWith(images: images));
  }

  void removeGalleryImage(String id) {
    final images =
    _current.gallery.images.where((e) => e.id != id).toList();
    _current = _current.copyWith(
        gallery: _current.gallery.copyWith(images: images));
  }

  /// Patches an existing URL back onto a gallery slot (no upload needed).
  void updateGalleryImageUrl(String id, String url) {
    final images = _current.gallery.images.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current = _current.copyWith(
        gallery: _current.gallery.copyWith(images: images));
  }

  Future<void> uploadGalleryImage(String id, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'overviewPages/$_activeGender/gallery',
      bytes: bytes,
      fileName: '${id}_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    final images = _current.gallery.images.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current = _current.copyWith(
        gallery: _current.gallery.copyWith(images: images));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLIENT COMMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  void updateClientCommentsTitle({required String en, required String ar}) {
    _current = _current.copyWith(
      clientComments:
      _current.clientComments.copyWith(title: BiText(en: en, ar: ar)),
    );
  }

  void addClientComment() {
    final comments = List<OverviewClientCommentModel>.from(_current.clientComments.comments);
    comments.add(OverviewClientCommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}_${comments.length}',  // ← unique
      order: comments.length,
    ));
    _current = _current.copyWith(
      clientComments: _current.clientComments.copyWith(comments: comments),
    );
  }

  void removeClientComment(String id) {
    final comments =
    _current.clientComments.comments.where((e) => e.id != id).toList();
    _current = _current.copyWith(
        clientComments:
        _current.clientComments.copyWith(comments: comments));
  }

  void updateClientCommentFirstName(String id,
      {required String en, required String ar}) {
    final comments = _current.clientComments.comments.map((e) {
      if (e.id == id) return e.copyWith(firstName: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current = _current.copyWith(
        clientComments:
        _current.clientComments.copyWith(comments: comments));
  }

  void updateClientCommentLastName(String id,
      {required String en, required String ar}) {
    final comments = _current.clientComments.comments.map((e) {
      if (e.id == id) return e.copyWith(lastName: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current = _current.copyWith(
        clientComments:
        _current.clientComments.copyWith(comments: comments));
  }

  void updateClientCommentFeedback(String id,
      {required String en, required String ar}) {
    final comments = _current.clientComments.comments.map((e) {
      if (e.id == id) return e.copyWith(feedback: BiText(en: en, ar: ar));
      return e;
    }).toList();
    _current = _current.copyWith(
        clientComments:
        _current.clientComments.copyWith(comments: comments));
  }

  /// Patches an existing URL back onto a comment item (no upload needed).
  void updateClientCommentImageUrl(String id, String url) {
    final comments = _current.clientComments.comments.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current = _current.copyWith(
        clientComments:
        _current.clientComments.copyWith(comments: comments));
  }

  Future<void> uploadClientCommentImage(String id, Uint8List bytes) async {
    final url = await _repo.uploadImage(
      path: 'overviewPages/$_activeGender/comments',
      bytes: bytes,
      fileName: '${id}_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    final comments = _current.clientComments.comments.map((e) {
      if (e.id == id) return e.copyWith(imageUrl: url);
      return e;
    }).toList();
    _current = _current.copyWith(
        clientComments:
        _current.clientComments.copyWith(comments: comments));
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
    print('🟡 [OverviewCmsCubit] save: status=$publishStatus');
    try {
      _current = _current.copyWith(
        status: publishStatus,
        lastUpdated: DateTime.now(),
      );
      await _repo.saveOverviewPage(_current);
      print('🟢 [OverviewCmsCubit] save: ✅ DONE');
      emit(OverviewCmsSaved(_current));
    } catch (e) {
      print('🔴 [OverviewCmsCubit] save: ERROR $e');
      emit(OverviewCmsError(e.toString()));
    }
  }
}