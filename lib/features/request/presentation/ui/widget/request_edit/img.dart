part of '../../pages/request_edit.dart';

class _Img {
  final Uint8List? bytes;
  final String? url;
  const _Img({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

const List<Map<String, String>> _kTypes = [
  {'key': 'text', 'value': 'Text'},
  {'key': 'dropdown', 'value': 'Dropdown'},
];
