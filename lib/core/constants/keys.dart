// ******************* FILE INFO *******************
// File Name: keys.dart
// Description: API keys — loaded from environment variables
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › constant

class TwilioConstants {
  static String twilioAccountSid = String.fromEnvironment('TWILIO_ACCOUNT_SID');
  static String twilioAuthToken = String.fromEnvironment('TWILIO_AUTH_TOKEN');
  static String twilioVerifyServiceSid = 'VA3720a15fb71b4432f82f1ef11a92ba9b';
}
