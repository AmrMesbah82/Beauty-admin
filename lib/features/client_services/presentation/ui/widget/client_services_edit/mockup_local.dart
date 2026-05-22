part of '../../pages/client_services_edit.dart';

class _MockupLocal {
  final String id;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  _PickedImage svg;
  MockupLayout layout;

  _MockupLocal({required this.id})
    : titleEn = TextEditingController(),
      titleAr = TextEditingController(),
      descEn = TextEditingController(),
      descAr = TextEditingController(),
      svg = _PickedImage.empty(),
      layout = MockupLayout.left;

  void dispose() {
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
  }
}
