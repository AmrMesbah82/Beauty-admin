// ═══════════════════════════════════════════════════════════════════
// FILE: demo_repo.dart
// Path: lib/repo/request_demo/demo_repo.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/model/demo_model.dart';

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
    print('🔵 [REPO] fetchAll() started');
    print('🔵 [REPO] Collection path: ${_submissions.path}');

    try {
      // ✅ FIXED: field is 'Created_At' in Firestore, not 'submissionDate'
      print('🔵 [REPO] Running query: orderBy(Created_At, descending: true)');
      final snap = await _submissions
          .orderBy('Created_At', descending: true)
          .get();

      print('🔵 [REPO] Query executed successfully');
      print('🔵 [REPO] Documents count: ${snap.docs.length}');

      if (snap.docs.isEmpty) {
        print('⚠️ [REPO] WARNING: No documents found!');
        print('⚠️ [REPO] Possible reasons:');
        print('⚠️ [REPO]   1. No index for Created_At — create it in Firebase Console → Indexes');
        print('⚠️ [REPO]   2. Firestore rules blocking read — check Rules tab');
        print('⚠️ [REPO]   3. Wrong Firebase project in google-services.json');

        // ── Fallback: try without orderBy to isolate the issue ──────────────
        print('🔵 [REPO] Trying fallback query WITHOUT orderBy...');
        final fallbackSnap = await _submissions.get();
        print('🔵 [REPO] Fallback documents count: ${fallbackSnap.docs.length}');

        if (fallbackSnap.docs.isNotEmpty) {
          print('✅ [REPO] Fallback SUCCESS — orderBy is the problem!');
          print('✅ [REPO] Fix: create index for Created_At in Firebase Console');
          print('🔵 [REPO] First doc raw data: ${fallbackSnap.docs.first.data()}');

          // Return fallback results (unsorted)
          return fallbackSnap.docs.map((d) {
            try {
              final model = RequestDemoModel.fromFirestore(d);
              print('✅ [REPO] Parsed fallback doc: ${d.id}');
              return model;
            } catch (e) {
              print('❌ [REPO] Error parsing fallback doc ${d.id}: $e');
              print('❌ [REPO] Raw data: ${d.data()}');
              rethrow;
            }
          }).toList();
        } else {
          print('❌ [REPO] Fallback also empty — rules or project mismatch!');
          return [];
        }
      }

      // ── Parse documents ──────────────────────────────────────────────────
      final results = snap.docs.map((d) {
        print('🔵 [REPO] Processing doc ID: ${d.id}');
        print('🔵 [REPO] Raw keys: ${d.data().keys.toList()}');
        try {
          final model = RequestDemoModel.fromFirestore(d);
          print('✅ [REPO] Parsed → salonName: ${model.salonName}, city: ${model.city}, status: ${model.status.label}');
          return model;
        } catch (e) {
          print('❌ [REPO] Error parsing doc ${d.id}: $e');
          print('❌ [REPO] Raw data: ${d.data()}');
          rethrow;
        }
      }).toList();

      print('✅ [REPO] fetchAll() completed with ${results.length} items');
      return results;

    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR in fetchAll(): $e');
      print('❌ [REPO] StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH SINGLE SUBMISSION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<RequestDemoModel?> fetchById(String id) async {
    print('🔵 [REPO] fetchById() started for ID: $id');

    try {
      final doc = await _submissions.doc(id).get();

      if (!doc.exists) {
        print('⚠️ [REPO] Document not found: $id');
        return null;
      }

      print('✅ [REPO] Document found: $id');
      print('🔵 [REPO] Raw keys: ${doc.data()?.keys.toList()}');
      final model = RequestDemoModel.fromFirestore(doc);
      print('✅ [REPO] fetchById() completed → salonName: ${model.salonName}');
      return model;

    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR in fetchById($id): $e');
      print('❌ [REPO] StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  UPDATE STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateStatus(String id, DemoStatus status) async {
    print('🔵 [REPO] updateStatus() - ID: $id, Status: ${status.label}');

    try {
      // ✅ FIXED: field is 'Status' (capital S) in Firestore
      await _submissions.doc(id).update({'Status': status.label});
      print('✅ [REPO] Status updated successfully');
    } catch (e) {
      print('❌ [REPO] ERROR updating status: $e');
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
    print('🔵 [REPO] updateComments() - ID: $id');
    print('🔵 [REPO] Note: $note, Priority: ${priority?.label}, Relevance: ${relevance?.label}, Action: ${action?.label}');

    try {
      // ✅ FIXED: match exact Firestore field names (Capital_Snake_Case)
      await _submissions.doc(id).update({
        'Note':              note,
        'Inquiry_Priority':  priority?.label,
        'Inquiry_Relevance': relevance?.label,
        'Required_Action':   action?.label,
      });
      print('✅ [REPO] Comments updated successfully');
    } catch (e) {
      print('❌ [REPO] ERROR updating comments: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH PAGE CONFIGS  (requestDemoPages collection)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<RequestDemoPageConfig>> fetchPageConfigs() async {
    print('🔵 [REPO] fetchPageConfigs() started');

    try {
      final snap = await _pageConfigs.get();
      print('🔵 [REPO] Page configs count: ${snap.docs.length}');

      if (snap.docs.isEmpty) {
        print('⚠️ [REPO] No page configs found in requestDemoPages');
      }

      final results = snap.docs.map((d) {
        print('🔵 [REPO] Parsing page config: ${d.id}');
        return RequestDemoPageConfig.fromFirestore(d);
      }).toList();

      print('✅ [REPO] fetchPageConfigs() completed with ${results.length} configs');
      return results;
    } catch (e) {
      print('❌ [REPO] ERROR in fetchPageConfigs(): $e');
      rethrow;
    }
  }

  Future<RequestDemoPageConfig?> fetchPageConfig(String id) async {
    print('🔵 [REPO] fetchPageConfig() - ID: $id');

    try {
      final doc = await _pageConfigs.doc(id).get();
      if (!doc.exists) {
        print('⚠️ [REPO] Page config not found: $id');
        return null;
      }

      print('✅ [REPO] Page config found: $id');
      return RequestDemoPageConfig.fromFirestore(doc);
    } catch (e) {
      print('❌ [REPO] ERROR in fetchPageConfig($id): $e');
      rethrow;
    }
  }
}