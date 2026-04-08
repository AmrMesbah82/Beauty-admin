/// ******************* FILE INFO *******************
/// File Name: overview_repo.dart
/// Description: Abstract repository for the Overview CMS module.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import 'dart:typed_data';
import '../../model/overview/overview_model.dart';

abstract class OverviewRepo {
  Future<OverviewPageModel> fetchOverviewPage({required String gender});
  Future<void> saveOverviewPage(OverviewPageModel model);
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  });
  Future<void> deleteImage(String url);
}