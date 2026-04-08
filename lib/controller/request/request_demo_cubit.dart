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
    _c = _c.copyWith(header: _c.header.copyWith(title: BiText(en: en, ar: ar)));
  }

  Future<void> uploadHeaderSvg(Uint8List bytes) async {
    final url = await _repo.uploadImage(
        path: 'requestDemo/$_g/header',
        bytes: bytes,
        fileName: 'header_${DateTime.now().millisecondsSinceEpoch}.svg');
    _c = _c.copyWith(header: _c.header.copyWith(svgUrl: url));
  }

  void removeHeaderSvg() {
    _c = _c.copyWith(header: _c.header.copyWith(svgUrl: ''));
  }

  // ── QUESTIONS ──────────────────────────────────────────────────────────────
  void addQuestion() {
    final qs = List<DemoQuestionModel>.from(_c.demoQuestions.questions);
    qs.add(DemoQuestionModel(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}', order: qs.length));
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  void removeQuestion(String id) {
    final qs = _c.demoQuestions.questions.where((q) => q.id != id).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  void updateQuestionText(String id, {required String en, required String ar}) {
    final qs = _c.demoQuestions.questions.map((q) {
      if (q.id == id) return q.copyWith(question: BiText(en: en, ar: ar));
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  void updateQuestionType(String id, QuestionType type) {
    final qs = _c.demoQuestions.questions.map((q) {
      if (q.id == id) return q.copyWith(type: type);
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  void toggleQuestionRequired(String id) {
    final qs = _c.demoQuestions.questions.map((q) {
      if (q.id == id) return q.copyWith(required: !q.required);
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  // ── VALUES (for dropdown questions) ────────────────────────────────────────
  void addValue(String questionId) {
    final qs = _c.demoQuestions.questions.map((q) {
      if (q.id == questionId) {
        final vals = List<QuestionValueModel>.from(q.values);
        vals.add(QuestionValueModel(
            id: 'v_${DateTime.now().millisecondsSinceEpoch}'));
        return q.copyWith(values: vals);
      }
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  void removeValue(String questionId, String valueId) {
    final qs = _c.demoQuestions.questions.map((q) {
      if (q.id == questionId) {
        return q.copyWith(
            values: q.values.where((v) => v.id != valueId).toList());
      }
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  void updateValueLabel(String questionId, String valueId,
      {required String en, required String ar}) {
    final qs = _c.demoQuestions.questions.map((q) {
      if (q.id == questionId) {
        final vals = q.values.map((v) {
          if (v.id == valueId) return v.copyWith(label: BiText(en: en, ar: ar));
          return v;
        }).toList();
        return q.copyWith(values: vals);
      }
      return q;
    }).toList();
    _c = _c.copyWith(demoQuestions: _c.demoQuestions.copyWith(questions: qs));
  }

  // ── CONFIRM MESSAGE ────────────────────────────────────────────────────────
  void updateConfirmTitle({required String en, required String ar}) {
    _c = _c.copyWith(
        confirmMessage:
        _c.confirmMessage.copyWith(title: BiText(en: en, ar: ar)));
  }

  void updateConfirmDescription({required String en, required String ar}) {
    _c = _c.copyWith(
        confirmMessage:
        _c.confirmMessage.copyWith(description: BiText(en: en, ar: ar)));
  }

  Future<void> uploadConfirmSvg(Uint8List bytes) async {
    final url = await _repo.uploadImage(
        path: 'requestDemo/$_g/confirm',
        bytes: bytes,
        fileName: 'confirm_${DateTime.now().millisecondsSinceEpoch}.svg');
    _c = _c.copyWith(confirmMessage: _c.confirmMessage.copyWith(svgUrl: url));
  }

  void removeConfirmSvg() {
    _c = _c.copyWith(confirmMessage: _c.confirmMessage.copyWith(svgUrl: ''));
  }

  // ── SAVE ───────────────────────────────────────────────────────────────────
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