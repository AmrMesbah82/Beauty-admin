/// ******************* FILE INFO *******************
/// File Name: client_services_repo.dart
/// Description: Abstract repository for Client Services CMS module.
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import 'dart:typed_data';
import '../../model/client_services/client_services_model.dart';

abstract class ClientServicesRepo {
  Future<ClientServicesPageModel> fetchPage({required String gender});
  Future<void> savePage(ClientServicesPageModel model);
  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String fileName,
  });
  Future<void> deleteImage(String url);
}