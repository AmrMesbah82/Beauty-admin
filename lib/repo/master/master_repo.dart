/// ******************* FILE INFO *******************
/// File Name: master_repo.dart
/// Description: Abstract repository for the Master CMS module.
/// Created by: Amr Mesbah
/// Last Update: 07/04/2026

import 'dart:typed_data';
import '../../model/master/master_model.dart';

abstract class MasterRepo {
  /// Fetch the master page document by gender
  Future<MasterPageModel> fetchMasterPage({required String gender});

  /// Save / update the full master page document
  Future<void> saveMasterPage(MasterPageModel model);

  /// Upload an image (section image, icon, etc.) and return the download URL
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  });

  /// Delete a stored image by its storage path or download URL
  Future<void> deleteImage(String url);
}