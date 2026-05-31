// ******************* FILE INFO *******************
// File Name: sendgrid_repository.dart
// Description: SendGrid repository interface
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › domain › repo

import 'package:cloud_functions/cloud_functions.dart';

class SendGridRepository {
  Future<void> sendContactNotification({
    required String toEmail,
    required String submitterName,
    required String submitterEmail,
    required String submitterPhone,
    required String subject,
    required String message,
    required bool isArabic,
  }) async {


    // ADD THIS:

    final callable = FirebaseFunctions.instance
        .httpsCallable('sendContactEmail');

    final result = await callable.call({
      'toEmail': toEmail,
      'submitterName': submitterName,
      'submitterEmail': submitterEmail,
      'submitterPhone': submitterPhone,
      'subject': subject,
      'message': message,
      'isArabic': isArabic,
    });

  }
}