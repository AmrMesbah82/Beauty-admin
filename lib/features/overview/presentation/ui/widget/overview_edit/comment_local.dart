part of '../../pages/overview_edit.dart';

class _CommentLocal {
  final String id;
  final TextEditingController firstNameEn;
  final TextEditingController firstNameAr;
  final TextEditingController lastNameEn;
  final TextEditingController lastNameAr;
  final TextEditingController feedbackEn;
  final TextEditingController feedbackAr;
  _PickedImage image;

  _CommentLocal({required this.id})
      : firstNameEn = TextEditingController(),
        firstNameAr = TextEditingController(),
        lastNameEn  = TextEditingController(),
        lastNameAr  = TextEditingController(),
        feedbackEn  = TextEditingController(),
        feedbackAr  = TextEditingController(),
        image = const _PickedImage();

  void dispose() {
    firstNameEn.dispose();
    firstNameAr.dispose();
    lastNameEn.dispose();
    lastNameAr.dispose();
    feedbackEn.dispose();
    feedbackAr.dispose();
  }
}
