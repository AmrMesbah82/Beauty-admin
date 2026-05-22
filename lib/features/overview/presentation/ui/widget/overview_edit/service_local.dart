part of '../../pages/overview_edit.dart';

class _ServiceLocal {
  final String id;
  final TextEditingController nameEn;
  final TextEditingController nameAr;
  _PickedImage image;

  _ServiceLocal({required this.id})
      : nameEn = TextEditingController(),
        nameAr = TextEditingController(),
        image = const _PickedImage();

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

// ── Local gallery item ───────────────────────────────────────────────────────
