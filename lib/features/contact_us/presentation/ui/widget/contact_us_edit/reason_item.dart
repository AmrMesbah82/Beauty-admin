part of '../../pages/contact_us_edit.dart';

class _ReasonItem {
  final String id;
  final int    counter;
  final labelEnCtrl = TextEditingController();
  final labelArCtrl = TextEditingController();
  // isRequired REMOVED — lives at section level now
  _ReasonItem({required this.id, required this.counter});
}
