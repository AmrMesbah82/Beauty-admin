// ═══════════════════════════════════════════════════════════════════
// FILE: inquiry_repo_imp.dart (FULLY UPDATED)
// Path: lib/repo/inquiry/inquiry_repo_imp.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repo/inquiry_repo.dart';
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
      print('🟡 [InquiryRepoImp] fetchAllInquiries() — hitting Firestore...');

      // ✅ NO orderBy — field name mismatch was causing only 6/23 to return
      final snapshot = await _collection
          .get(const GetOptions(source: Source.server));

      print('🟢 [InquiryRepoImp] Raw docs count: ${snapshot.docs.length}');

      // 🔍 Print ALL raw keys from first doc so we can verify field names
      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first;
        print('🔍 [InquiryRepoImp] First doc ID: ${firstDoc.id}');
        print('🔍 [InquiryRepoImp] First doc KEYS: ${firstDoc.data().keys.toList()}');
        print('🔍 [InquiryRepoImp] First doc DATA: ${firstDoc.data()}');
      }

      final list = <InquiryModel>[];
      for (final doc in snapshot.docs) {
        try {
          final model = InquiryModel.fromMap(doc.id, doc.data());
          list.add(model);
          print(
            '✅ [doc ${doc.id}] '
                'name="${model.firstName} ${model.lastName}" '
                'email="${model.email}" '
                'phone="${model.phone}" '
                'country="${model.country}" '
                'gender="${model.gender}" '
                'status="${model.status.label}" '
                'date="${model.submissionDate}"',
          );
        } catch (e) {
          print('⚠️  [doc ${doc.id}] fromMap() threw: $e');
          print('⚠️  [doc ${doc.id}] raw data: ${doc.data()}');
        }
      }

      // ✅ Sort in Dart after fetch (avoids orderBy field-name issues)
      list.sort((a, b) =>
          (b.submissionDate ?? DateTime(0))
              .compareTo(a.submissionDate ?? DateTime(0)));

      print('🟢 [InquiryRepoImp] fetchAllInquiries() DONE — ${list.length} models built');
      return list;

    } catch (e) {
      print('🔴 [InquiryRepoImp] fetchAllInquiries() SERVER ERROR: $e');
      print('🟡 [InquiryRepoImp] Falling back to CACHE...');
      try {
        final snapshot = await _collection
            .get(const GetOptions(source: Source.cache));

        print('🟢 [InquiryRepoImp] Cache docs count: ${snapshot.docs.length}');

        final list = snapshot.docs
            .map((doc) => InquiryModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) =>
              (b.submissionDate ?? DateTime(0))
                  .compareTo(a.submissionDate ?? DateTime(0)));

        print('🟢 [InquiryRepoImp] Cache fallback — ${list.length} models');
        return list;
      } catch (cacheError) {
        print('🔴 [InquiryRepoImp] Cache fallback ALSO failed: $cacheError');
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
      print('🟡 [InquiryRepoImp] fetchInquiryById($id)...');

      final doc = await _collection
          .doc(id)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists || doc.data() == null) {
        print('⚠️  [InquiryRepoImp] fetchInquiryById($id) — doc does not exist');
        return null;
      }

      print('🔍 [InquiryRepoImp] fetchInquiryById($id) KEYS: ${doc.data()!.keys.toList()}');
      print('🔍 [InquiryRepoImp] fetchInquiryById($id) DATA: ${doc.data()}');

      final model = InquiryModel.fromMap(doc.id, doc.data()!);
      print('🟢 [InquiryRepoImp] fetchInquiryById($id) — built: ${model.firstName} ${model.lastName}');
      return model;

    } catch (e) {
      print('🔴 [InquiryRepoImp] fetchInquiryById($id) ERROR: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  UPDATE FULL INQUIRY
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> updateInquiry(InquiryModel inquiry) async {
    try {
      print('🟡 [InquiryRepoImp] updateInquiry(${inquiry.id})...');
      print('🔍 [InquiryRepoImp] updateInquiry payload: ${inquiry.toMap()}');

      await _collection.doc(inquiry.id).update(inquiry.toMap());

      print('🟢 [InquiryRepoImp] updateInquiry(${inquiry.id}) — done');
    } catch (e) {
      print('🔴 [InquiryRepoImp] updateInquiry(${inquiry.id}) ERROR: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  UPDATE STATUS ONLY
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> updateStatus(String id, InquiryStatus status) async {
    try {
      print('🟡 [InquiryRepoImp] updateStatus($id → "${status.label}")...');

      await _collection.doc(id).update({'status': status.label});

      print('🟢 [InquiryRepoImp] updateStatus($id) — done');
    } catch (e) {
      print('🔴 [InquiryRepoImp] updateStatus($id) ERROR: $e');
      rethrow;
    }
  }
}