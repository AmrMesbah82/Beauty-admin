part of '../../pages/request_edit.dart';

class _VLocal {
  final String id;
  final TextEditingController en, ar;
  _VLocal({required this.id})
      : en = TextEditingController(),
        ar = TextEditingController();
  void dispose() {
    en.dispose();
    ar.dispose();
  }
}
