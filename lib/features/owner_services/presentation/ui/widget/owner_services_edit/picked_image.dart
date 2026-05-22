part of '../../pages/owner_services_edit.dart';

class _PickedImage {
  final Uint8List? bytes;
  final String? url;
  const _PickedImage({this.bytes, this.url});

  factory _PickedImage.empty() => const _PickedImage();

  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

// ── Local mockup item for editing ────────────────────────────────────────────
