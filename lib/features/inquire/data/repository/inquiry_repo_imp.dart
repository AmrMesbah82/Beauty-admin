// ******************* FILE INFO *******************
// File Name: inquiry_repo_imp.dart
// Description: Inquiry repository implementation
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › data › repo_imp

// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_repo_imp.dart (FULLY UPDATED)
// Path: lib/repo/inquiry/inquiry_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/base_repository/inquiry_repo.dart';
import '../models/inquire_model.dart';



class InquiryRepoImp implements InquiryRepo {
  final FirebaseFirestore _firestore;

  InquiryRepoImp({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('contact_submissions');

  // ═══════════════════════════════════════════════════════════════════
  //  FETCH ALL
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<List<InquiryModel>> fetchAllInquiries() async {
    try {

      // ✅ NO orderBy — field name mismatch was causing only 6/23 to return
      final snapshot = await _collection
          .get(const GetOptions(source: Source.server));


      // 🔍 Print ALL raw keys from first doc so we can verify field names
      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first;
      }

      final list = <InquiryModel>[];
      for (final doc in snapshot.docs) {
        try {
          final model = InquiryModel.fromMap(doc.id, doc.data());
          list.add(model);
        } catch (e) {
        }
      }

      // ✅ Sort in Dart after fetch (avoids orderBy field-name issues)
      list.sort((a, b) =>
          (b.submissionDate ?? DateTime(0))
              .compareTo(a.submissionDate ?? DateTime(0)));

      return list;

    } catch (e) {
      try {
        final snapshot = await _collection
            .get(const GetOptions(source: Source.cache));


        final list = snapshot.docs
            .map((doc) => InquiryModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) =>
              (b.submissionDate ?? DateTime(0))
                  .compareTo(a.submissionDate ?? DateTime(0)));

        return list;
      } catch (cacheError) {
        rethrow;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  FETCH BY ID
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<InquiryModel?> fetchInquiryById(String id) async {
    try {

      final doc = await _collection
          .doc(id)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists || doc.data() == null) {
        return null;
      }


      final model = InquiryModel.fromMap(doc.id, doc.data()!);
      return model;

    } catch (e) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  UPDATE FULL INQUIRY
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> updateInquiry(InquiryModel inquiry) async {
    try {

      await _collection.doc(inquiry.id).update(inquiry.toMap());

    } catch (e) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  UPDATE STATUS ONLY
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> updateStatus(String id, InquiryStatus status) async {
    try {

      await _collection.doc(id).update({'status': status.label});

    } catch (e) {
      rethrow;
    }
  }
}