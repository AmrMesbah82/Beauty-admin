/// File Name: request_demo_cubit.dart
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/request/request_demo_model.dart';
import '../../repo/request/request_demo_repo.dart';
import 'request_demo_state.dart';

class RequestDemoCmsCubit extends Cubit<RequestDemoCmsState> {
  final RequestDemoRepo _repo;
  RequestDemoCmsCubit(this._repo) : super(RequestDemoCmsInitial());

  RequestDemoPageModel _c = const RequestDemoPageModel();
  RequestDemoPageModel get current => _c;
  String _g = 'female';
  String get activeGender => _g;

  Future<void> load({String gender = 'female'}) async {
    _g = gender;
    emit(RequestDemoCmsLoading());
    try {
      _c = await _repo.fetchPage(gender: gender);
      emit(RequestDemoCmsLoaded(_c));
    } catch (e) {
      emit(RequestDemoCmsError(e.toString()));
    }
  }

  Future<void> switchGender(String g) async {
    if (g == _g) return;
    await load(gender: g);
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  void updateHeaderTitle({required String en, required String ar}) {
    _c = _c.copyWith(headerTitle: BiText(en: en, ar: ar));
  }

  void updateHeaderSvgUrl(String url) {
    _c = _c.copyWith(headerSvgUrl: url);
  }

  void removeHeaderSvg() {
    _c = _c.copyWith(headerSvgUrl: '');
  }

  // ── QUESTIONS ──────────────────────────────────────────────────────────────
  void addQuestion() {
    final qs = List<DemoQuestionModel>.from(_c.demoQuestions);
    qs.add(DemoQuestionModel(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}', order: qs.length));
    _c = _c.copyWith(demoQuestions: qs);
  }

  void removeQuestion(String id) {
    final qs = _c.demoQuestions.where((q) => q.id != id).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  void updateQuestionText(String id, {required String en, required String ar}) {
    final qs = _c.demoQuestions.map((q) {
      if (q.id == id) return q.copyWith(question: BiText(en: en, ar: ar));
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  void updateQuestionType(String id, QuestionType type) {
    final qs = _c.demoQuestions.map((q) {
      if (q.id == id) return q.copyWith(type: type);
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  void toggleQuestionRequired(String id) {
    final qs = _c.demoQuestions.map((q) {
      if (q.id == id) return q.copyWith(required: !q.required);
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  // ── VALUES (for dropdown questions) ────────────────────────────────────────
  void addValue(String questionId) {
    final qs = _c.demoQuestions.map((q) {
      if (q.id == questionId) {
        final vals = List<QuestionValueModel>.from(q.values);
        vals.add(QuestionValueModel(
            id: 'v_${DateTime.now().millisecondsSinceEpoch}'));
        return q.copyWith(values: vals);
      }
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  void removeValue(String questionId, String valueId) {
    final qs = _c.demoQuestions.map((q) {
      if (q.id == questionId) {
        return q.copyWith(
            values: q.values.where((v) => v.id != valueId).toList());
      }
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  void updateValueLabel(String questionId, String valueId,
      {required String en, required String ar}) {
    final qs = _c.demoQuestions.map((q) {
      if (q.id == questionId) {
        final vals = q.values.map((v) {
          if (v.id == valueId) return v.copyWith(label: BiText(en: en, ar: ar));
          return v;
        }).toList();
        return q.copyWith(values: vals);
      }
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: qs);
  }

  // ── CONFIRM MESSAGE ────────────────────────────────────────────────────────
  void updateConfirmTitle({required String en, required String ar}) {
    _c = _c.copyWith(confirmTitle: BiText(en: en, ar: ar));
  }

  void updateConfirmDescription({required String en, required String ar}) {
    _c = _c.copyWith(confirmDescription: BiText(en: en, ar: ar));
  }

  void updateConfirmSvgUrl(String url) {
    _c = _c.copyWith(confirmSvgUrl: url);
  }

  void removeConfirmSvg() {
    _c = _c.copyWith(confirmSvgUrl: '');
  }

  // ── UPLOAD HELPERS (return URL for edit page) ──────────────────────────────
  Future<String> uploadHeaderSvg(Uint8List bytes) async {
    final url = await _repo.uploadImage(
        path: 'requestDemo/$_g/header',
        bytes: bytes,
        fileName: 'header_${DateTime.now().millisecondsSinceEpoch}.svg');
    _c = _c.copyWith(headerSvgUrl: url);
    return url;
  }

  Future<String> uploadConfirmSvg(Uint8List bytes) async {
    final url = await _repo.uploadImage(
        path: 'requestDemo/$_g/confirm',
        bytes: bytes,
        fileName: 'confirm_${DateTime.now().millisecondsSinceEpoch}.svg');
    _c = _c.copyWith(confirmSvgUrl: url);
    return url;
  }

  // ── SAVE MODEL (used by edit page with flat model) ─────────────────────────
  Future<void> saveModel(RequestDemoPageModel model) async {
    try {
      _c = model;
      await _repo.savePage(_c);
      emit(RequestDemoCmsSaved(_c));
    } catch (e) {
      emit(RequestDemoCmsError(e.toString()));
    }
  }

  // ── SAVE (legacy) ──────────────────────────────────────────────────────────
  Future<void> save({String publishStatus = 'published'}) async {
    try {
      _c = _c.copyWith(status: publishStatus, lastUpdated: DateTime.now());
      await _repo.savePage(_c);
      emit(RequestDemoCmsSaved(_c));
    } catch (e) {
      emit(RequestDemoCmsError(e.toString()));
    }
  }
}