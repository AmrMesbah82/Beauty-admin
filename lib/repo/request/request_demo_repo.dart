/// File Name: request_demo_repo.dart
import 'dart:typed_data';
import '../../model/request/request_demo_model.dart';

abstract class RequestDemoRepo {
  Future<RequestDemoPageModel> fetchPage({required String gender});
  Future<void> savePage(RequestDemoPageModel model);
  Future<String> uploadImage(
      {required String path, required Uint8List bytes, required String fileName});
  Future<void> deleteImage(String url);
}