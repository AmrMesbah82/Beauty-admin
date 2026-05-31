// ******************* FILE INFO *******************
// File Name: request_repo.dart
// Description: Request repository interface
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › request › domain › repo

/// File Name: request_repo.dart
import 'dart:typed_data';
import '../../data/models/request_model.dart';

abstract class RequestDemoRepo {
  Future<RequestDemoPageModel> fetchPage({required String gender});
  Future<void> savePage(RequestDemoPageModel model);
  Future<String> uploadImage(
      {required String path, required Uint8List bytes, required String fileName});
  Future<void> deleteImage(String url);
}