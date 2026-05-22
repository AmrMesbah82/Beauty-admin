part of '../../pages/request_edit.dart';

class _QLocal {
  final String id;
  final TextEditingController qEn, qAr;
  QuestionType type;
  bool required;
  final List<_VLocal> values;

  _QLocal({required this.id})
      : qEn = TextEditingController(),
        qAr = TextEditingController(),
        type = QuestionType.text,
        required = false,
        values = [];

  void dispose() {
    qEn.dispose();
    qAr.dispose();
    for (final v in values) v.dispose();
  }
}
