/// ******************* FILE INFO *******************
/// File Name: owner_services_repo.dart
/// Description: Abstract repository for the Owner Services CMS module.
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

import 'dart:typed_data';
import '../../model/owner_services/owner_services_model.dart';

abstract class OwnerServicesRepo {
  Future<OwnerServicesPageModel> fetchOwnerServicesPage(
      {required String gender});
  Future<void> saveOwnerServicesPage(OwnerServicesPageModel model);
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  });
  Future<void> deleteImage(String url);
}