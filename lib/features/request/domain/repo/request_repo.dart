/// File Name: demo_repo.dart
import 'dart:typed_data';
import '../../data/models/request_model.dart';

abstract class RequestDemoRepo {
  Future<RequestDemoPageModel> fetchPage({required String gender});
  Future<void> savePage(RequestDemoPageModel model);
  Future<String> uploadImage(
      {required String path, required Uint8List bytes, required String fileName});
  Future<void> deleteImage(String url);
}