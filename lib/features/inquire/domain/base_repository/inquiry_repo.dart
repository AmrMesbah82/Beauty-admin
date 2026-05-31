// ******************* FILE INFO *******************
// File Name: inquiry_repo.dart
// Description: Inquiry repository interface
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › domain › repo

// ═══════════════════════════════════════════════════════════════════
// FILE 2: inquiry_repo.dart
// Path: lib/repo/inquiry/inquiry_repo.dart
// ═══════════════════════════════════════════════════════════════════


import '../../data/models/inquire_model.dart';

abstract class InquiryRepo {
  Future<List<InquiryModel>> fetchAllInquiries();
  Future<InquiryModel?> fetchInquiryById(String id);
  Future<void> updateInquiry(InquiryModel inquiry);
  Future<void> updateStatus(String id, InquiryStatus status);
}