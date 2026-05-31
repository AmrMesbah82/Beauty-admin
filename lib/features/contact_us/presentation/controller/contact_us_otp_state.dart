// ******************* FILE INFO *******************
// File Name: contact_us_otp_state.dart
// Description: ContactUs OTP Cubit states
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › controller

abstract class ContactOtpState {
  const ContactOtpState();
}

/// Initial state - no OTP action taken yet
class OtpInitial extends ContactOtpState {}

/// Sending OTP to the phone number
class OtpSending extends ContactOtpState {}

/// OTP sent successfully
class OtpSent extends ContactOtpState {
  final String phoneNumber;
  const OtpSent({required this.phoneNumber});
}

/// Verifying the OTP code
class OtpVerifying extends ContactOtpState {}

/// OTP verified successfully
class OtpVerified extends ContactOtpState {}

/// Error occurred during OTP send or verification
class OtpError extends ContactOtpState {
  final String message;
  const OtpError({required this.message});
}