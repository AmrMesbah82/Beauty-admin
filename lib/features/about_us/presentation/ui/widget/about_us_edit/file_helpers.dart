part of '../../pages/about_us_edit.dart';

extension _AboutEditFileHelpers on _AboutEditPageMasterState {
  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      final fileName = file.name.toLowerCase();
      final fileType = file.type.toLowerCase();

      final isValidSvg =
          fileName.endsWith('.svg') || fileType == 'image/svg+xml';

      if (!isValidSvg) {
        completer.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          Uint8List? bytes;
          if (result is ByteBuffer) {
            bytes = Uint8List.view(result);
          } else if (result is Uint8List) {
            bytes = result;
          } else if (result is List<int>) {
            bytes = Uint8List.fromList(result);
          }

          if (bytes != null && !_isValidSvgContent(bytes)) {
            completer.complete(null);
            return;
          }

          completer.complete(bytes);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  bool _isValidSvgContent(Uint8List bytes) {
    if (bytes.length < 10) return false;
    try {
      final content =
          String.fromCharCodes(bytes.sublist(0, bytes.length.clamp(0, 500)));
      final trimmed = content.trimLeft();
      return trimmed.startsWith('<svg') ||
          trimmed.startsWith('<?xml') && trimmed.contains('<svg');
    } catch (e) {
      return false;
    }
  }

  Future<Uint8List> _cachedLoad(String url) {
    return _urlBytesCache.putIfAbsent(url, () => _loadSvg(url));
  }

  Future<Uint8List> _loadSvg(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: 'image/svg+xml',
      );
      if (response.status == 200 && response.response != null) {
        final bytes = (response.response as ByteBuffer).asUint8List();
        if (!_isValidSvgContent(bytes)) throw Exception('Invalid SVG content');
        return bytes;
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }
}
