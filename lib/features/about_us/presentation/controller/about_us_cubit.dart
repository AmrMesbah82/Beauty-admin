// ******************* FILE INFO *******************
// File Name: about_cubit.dart  (3 cubits in one file)
// Created by: Amr Mesbah
// UPDATED: Multi-device support for Strategic House images (Desktop, Tablet, Mobile)

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';



import '../../data/models/about_us_model.dart';
import '../../data/repo_imp/about_us_repo_imp.dart';
import '../../domain/repo/about_us_repo.dart';
import 'about_us_state.dart';

// ── Safe emit — never throws "Cannot emit after close" ────────────────────────
extension _SafeEmit<S> on Cubit<S> {
  void safeEmit(S state) {
    if (!isClosed) emit(state);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ABOUT US CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class AboutCubit extends Cubit<AboutState> {
  final AboutRepo _repo;

  AboutCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(AboutInitial());

  // Add current getter
  AboutPageModel get current {
    final state = this.state;
    if (state is AboutLoaded) return state.data;
    if (state is AboutSaved) return state.data;
    return AboutPageModel.empty();
  }

  Future<void> load() async {
    print('🟡 [AboutCubit] load()');
    safeEmit(AboutLoading());
    try {
      safeEmit(AboutLoaded(await _repo.fetchAboutPage()));
    } catch (e) {
      safeEmit(AboutError(e.toString()));
    }
  }

  Future<void> save({
    required AboutPageModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    print('🟡 [AboutCubit] save()');
    try {
      var updated = model;

      if (imageUploads != null && imageUploads.isNotEmpty) {
        for (final entry in imageUploads.entries) {
          final url = await _repo.uploadImage(
              bytes: entry.value, storagePath: entry.key);

          if (entry.key.contains('headings/svg')) {
            updated = updated.copyWith(svgUrl: url);
          } else if (entry.key.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
          } else if (entry.key.contains('vision/icon')) {
            updated = updated.copyWith(
                vision: updated.vision.copyWith(iconUrl: url));
          } else if (entry.key.contains('vision/svg')) {
            updated = updated.copyWith(
                vision: updated.vision.copyWith(svgUrl: url));
          } else if (entry.key.contains('mission/icon')) {
            updated = updated.copyWith(
                mission: updated.mission.copyWith(iconUrl: url));
          } else if (entry.key.contains('mission/svg')) {
            updated = updated.copyWith(
                mission: updated.mission.copyWith(svgUrl: url));
          } else if (entry.key.contains('values/')) {
            final parts = entry.key.split('/');
            final itemId = parts.length >= 3 ? parts[2] : null;
            if (itemId != null) {
              final newValues = updated.values.map((v) {
                if (v.id == itemId) return v.copyWith(iconUrl: url);
                return v;
              }).toList();
              updated = updated.copyWith(values: newValues);
            }
          }
        }
      }

      await _repo.saveAboutPage(updated);
      print('🟢 [AboutCubit] save OK');
      safeEmit(AboutSaved(updated));
    } catch (e) {
      print('🔴 [AboutCubit] save ERROR: $e');
      safeEmit(AboutError(e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OUR STRATEGY CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class StrategyCubit extends Cubit<StrategyState> {
  final AboutRepo _repo;

  StrategyCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(StrategyInitial());

  Future<void> load() async {
    print('🟡 [StrategyCubit] load()');
    safeEmit(StrategyLoading());
    try {
      final data = await _repo.fetchStrategy();
      print('🟢 [StrategyCubit] load OK');
      print('  - EN Desktop: ${data.strategicHouseEnDesktopUrl}');
      print('  - EN Tablet: ${data.strategicHouseEnTabletUrl}');
      print('  - EN Mobile: ${data.strategicHouseEnMobileUrl}');
      print('  - AR Desktop: ${data.strategicHouseArDesktopUrl}');
      print('  - AR Tablet: ${data.strategicHouseArTabletUrl}');
      print('  - AR Mobile: ${data.strategicHouseArMobileUrl}');
      safeEmit(StrategyLoaded(data));
    } catch (e) {
      print('🔴 [StrategyCubit] load ERROR: $e');
      safeEmit(StrategyError(e.toString()));
    }
  }

  Future<void> save({
    required OurStrategyModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    print('🟡 [StrategyCubit] save()');
    print('  - Image uploads: ${imageUploads?.keys}');

    try {
      var updated = model;

      if (imageUploads != null && imageUploads.isNotEmpty) {
        print('🔵 [StrategyCubit] Uploading ${imageUploads.length} images...');

        for (final entry in imageUploads.entries) {
          final path = entry.key;
          final bytes = entry.value;

          print('  - Uploading: $path');
          final url = await _repo.uploadImage(
              bytes: bytes, storagePath: path);
          print('  - Uploaded to: $url');

          if (path.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
            print('  ✓ Updated navLabel icon URL');
          }
          // Strategic House EN - Desktop
          else if (path.contains('strategicHouse/en/desktop')) {
            updated = updated.copyWith(strategicHouseEnDesktopUrl: url);
            print('  ✓ Updated strategicHouse EN Desktop URL');
          }
          // Strategic House EN - Tablet
          else if (path.contains('strategicHouse/en/tablet')) {
            updated = updated.copyWith(strategicHouseEnTabletUrl: url);
            print('  ✓ Updated strategicHouse EN Tablet URL');
          }
          // Strategic House EN - Mobile
          else if (path.contains('strategicHouse/en/mobile')) {
            updated = updated.copyWith(strategicHouseEnMobileUrl: url);
            print('  ✓ Updated strategicHouse EN Mobile URL');
          }
          // Strategic House AR - Desktop
          else if (path.contains('strategicHouse/ar/desktop')) {
            updated = updated.copyWith(strategicHouseArDesktopUrl: url);
            print('  ✓ Updated strategicHouse AR Desktop URL');
          }
          // Strategic House AR - Tablet
          else if (path.contains('strategicHouse/ar/tablet')) {
            updated = updated.copyWith(strategicHouseArTabletUrl: url);
            print('  ✓ Updated strategicHouse AR Tablet URL');
          }
          // Strategic House AR - Mobile
          else if (path.contains('strategicHouse/ar/mobile')) {
            updated = updated.copyWith(strategicHouseArMobileUrl: url);
            print('  ✓ Updated strategicHouse AR Mobile URL');
          }
          else if (path.contains('vision/svg')) {
            // updated = updated.copyWith(
            //     vision: updated.vision.copyWith(svgUrl: url));
            print('  ✓ Updated vision SVG URL');
          }
        }
      }

      print('🔵 [StrategyCubit] Saving to Firestore...');
      print('  - EN Desktop: ${updated.strategicHouseEnDesktopUrl}');
      print('  - EN Tablet: ${updated.strategicHouseEnTabletUrl}');
      print('  - EN Mobile: ${updated.strategicHouseEnMobileUrl}');
      print('  - AR Desktop: ${updated.strategicHouseArDesktopUrl}');
      print('  - AR Tablet: ${updated.strategicHouseArTabletUrl}');
      print('  - AR Mobile: ${updated.strategicHouseArMobileUrl}');

      await _repo.saveStrategy(updated);
      print('🟢 [StrategyCubit] save OK');
      safeEmit(StrategySaved(updated));
    } catch (e) {
      print('🔴 [StrategyCubit] save ERROR: $e');
      safeEmit(StrategyError(e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TERMS OF SERVICE CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class TermsCubit extends Cubit<TermsState> {
  final AboutRepo _repo;

  TermsCubit({AboutRepo? repo})
      : _repo = repo ?? AboutRepoImpl(),
        super(TermsInitial());

  Future<void> load() async {
    print('🟡 [TermsCubit] load()');
    safeEmit(TermsLoading());
    try {
      safeEmit(TermsLoaded(await _repo.fetchTerms()));
    } catch (e) {
      safeEmit(TermsError(e.toString()));
    }
  }

  Future<void> save({
    required TermsOfServiceModel model,
    Map<String, Uint8List>? imageUploads,
    Map<String, DocUpload>? docUploads,
  }) async {
    print('🟡 [TermsCubit] save()');
    try {
      var updated = model;

      // ── image / svg uploads ───────────────────────────────────────────────
      if (imageUploads != null && imageUploads.isNotEmpty) {
        for (final entry in imageUploads.entries) {
          final url = await _repo.uploadImage(
              bytes: entry.value, storagePath: entry.key);

          if (entry.key.contains('navLabel/icon')) {
            updated = updated.copyWith(
                navigationLabel:
                updated.navigationLabel.copyWith(iconUrl: url));
          } else if (entry.key.contains('terms/svg')) {
            updated = updated.copyWith(
                termsAndConditions:
                updated.termsAndConditions.copyWith(svgUrl: url));
          } else if (entry.key.contains('privacy/svg')) {
            updated = updated.copyWith(
                privacyPolicy:
                updated.privacyPolicy.copyWith(svgUrl: url));
          }
        }
      }

      // ── document uploads ──────────────────────────────────────────────────
      if (docUploads != null && docUploads.isNotEmpty) {
        for (final entry in docUploads.entries) {
          final url = await _repo.uploadDocument(
            bytes: entry.value.bytes,
            storagePath: entry.key,
            fileName: entry.value.fileName,
          );
          if (entry.key.contains('terms/en')) {
            updated = updated.copyWith(
                termsAndConditions:
                updated.termsAndConditions.copyWith(attachEnUrl: url));
          } else if (entry.key.contains('terms/ar')) {
            updated = updated.copyWith(
                termsAndConditions:
                updated.termsAndConditions.copyWith(attachArUrl: url));
          } else if (entry.key.contains('privacy/en')) {
            updated = updated.copyWith(
                privacyPolicy:
                updated.privacyPolicy.copyWith(attachEnUrl: url));
          } else if (entry.key.contains('privacy/ar')) {
            updated = updated.copyWith(
                privacyPolicy:
                updated.privacyPolicy.copyWith(attachArUrl: url));
          }
        }
      }

      await _repo.saveTerms(updated);
      print('🟢 [TermsCubit] save OK');
      safeEmit(TermsSaved(updated));
    } catch (e) {
      print('🔴 [TermsCubit] save ERROR: $e');
      safeEmit(TermsError(e.toString()));
    }
  }
}

// NOTE: DocUpload class lives in model/about_us_model.dart — do NOT redeclare it here.