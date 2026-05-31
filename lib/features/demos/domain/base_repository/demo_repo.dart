// ******************* FILE INFO *******************
// File Name: demo_repo.dart
// Description: Demo repository interface
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › demos › domain › repo

// ═══════════════════════════════════════════════════════════════════
// FILE: demo_repo.dart
// Path: lib/features/demos/domain/base_repository/demo_repo.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/demo_model.dart';

class RequestDemoRepo {
  final FirebaseFirestore _db;

  RequestDemoRepo({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Submissions collection ────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _submissions =>
      _db.collection('requestDemo');

  // ── Page config collection ────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _pageConfigs =>
      _db.collection('requestDemoPages');

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH ALL SUBMISSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<RequestDemoModel>> fetchAll() async {

    try {
      // ✅ FIXED: field is 'Created_At' in Firestore, not 'submissionDate'
      final snap = await _submissions
          .orderBy('Created_At', descending: true)
          .get();


      if (snap.docs.isEmpty) {

        // ── Fallback: try without orderBy to isolate the issue ──────────────
        final fallbackSnap = await _submissions.get();

        if (fallbackSnap.docs.isNotEmpty) {

          // Return fallback results (unsorted)
          return fallbackSnap.docs.map((d) {
            try {
              final model = RequestDemoModel.fromFirestore(d);
              return model;
            } catch (e) {
              rethrow;
            }
          }).toList();
        } else {
          return [];
        }
      }

      // ── Parse documents ──────────────────────────────────────────────────
      final results = snap.docs.map((d) {
        try {
          final model = RequestDemoModel.fromFirestore(d);
          return model;
        } catch (e) {
          rethrow;
        }
      }).toList();

      return results;

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH SINGLE SUBMISSION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<RequestDemoModel?> fetchById(String id) async {

    try {
      final doc = await _submissions.doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final model = RequestDemoModel.fromFirestore(doc);
      return model;

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  UPDATE STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateStatus(String id, DemoStatus status) async {

    try {
      // ✅ FIXED: field is 'Status' (capital S) in Firestore
      await _submissions.doc(id).update({'Status': status.label});
    } catch (e) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  UPDATE ADMIN COMMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateComments({
    required String id,
    required String note,
    DemoPriority?       priority,
    DemoRelevance?      relevance,
    DemoRequiredAction? action,
  }) async {

    try {
      // ✅ FIXED: match exact Firestore field names (Capital_Snake_Case)
      await _submissions.doc(id).update({
        'Note':              note,
        'Inquiry_Priority':  priority?.label,
        'Inquiry_Relevance': relevance?.label,
        'Required_Action':   action?.label,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH PAGE CONFIGS  (requestDemoPages collection)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<RequestDemoPageConfig>> fetchPageConfigs() async {

    try {
      final snap = await _pageConfigs.get();

      if (snap.docs.isEmpty) {
      }

      final results = snap.docs.map((d) {
        return RequestDemoPageConfig.fromFirestore(d);
      }).toList();

      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<RequestDemoPageConfig?> fetchPageConfig(String id) async {

    try {
      final doc = await _pageConfigs.doc(id).get();
      if (!doc.exists) {
        return null;
      }

      return RequestDemoPageConfig.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }
}