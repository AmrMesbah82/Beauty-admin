// ******************* FILE INFO *******************
// File Name: strategy_edit_page.dart
// Screen 2 of 3 — Our Strategy CMS: Edit page
// UPDATED: Added Strategic House - ENG and Strategic House - ARB accordions
// UPDATED: Added device preview tabs (Large Screen / Tablet / Mobile)
// UPDATED: SVG-only validation with publish restrictions
// UPDATED: Fixed SVG reload on text input
// UPDATED: Added publish confirmation dialog with validation
// UPDATED: Fixed text input causing SVG reload - optimized rebuilds
// UPDATED: Removed white backgrounds, changed padding to symmetric
// UPDATED: Dual-document draft system with validation-based publish button
// UPDATED: Added showPublishConfirmDialog and navigation to StrategyMainView
// Created by: Amr Mesbah
// Last Update: 21/04/2026

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:beauty_admin/dashboard/about_page/strategy_page/strategy_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/button.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';

import '../../../model/about_us/about_us.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../../main_page/home_main_page.dart';
import 'strategy_preview_page.dart';
import '../../../core/custom_dialog.dart';

const Color _kGreen      = Color(0xFFD16F9A);
const Color _kGreenSolid = Color(0xFFD16F9A);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kBg         = Color(0xFFF2F2F2);
const Color _kDraftBadge = Color(0xFFF59E0B);

// ── Device preview tab enum ─────────────────────────────────────────────────
enum DeviceTab { largeScreen, tablet, mobile }

// ═══════════════════════════════════════════════════════════════════════════════

class StrategyEditPage extends StatefulWidget {
  const StrategyEditPage({super.key});

  @override
  State<StrategyEditPage> createState() => _StrategyEditPageState();
}

class _StrategyEditPageState extends State<StrategyEditPage> {
  // ── Navigation Label ──
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  Uint8List? _navIconBytes;
  String _navIconUrl = '';
  bool _navIconIsSvg = false;

  // ── Strategic House — ENG ──
  Uint8List? _strategicHouseEnBytes;
  String _strategicHouseEnUrl = '';
  bool _strategicHouseEnIsSvg = false;

  // ── Strategic House — ARB ──
  Uint8List? _strategicHouseArBytes;
  String _strategicHouseArUrl = '';
  bool _strategicHouseArIsSvg = false;

  bool _navLabelOpen        = true;
  bool _strategicHouseEnOpen = true;
  bool _strategicHouseArOpen = true;

  bool _submitted = false;
  bool _seeded    = false;
  bool _isSaving  = false;

  /// Whether the data currently loaded came from a draft document.
  bool _isEditingDraft = false;

  // ── Validation errors ──
  String? _navIconError;
  String? _strategicHouseEnError;
  String? _strategicHouseArError;

  // ── Device preview tabs ──
  DeviceTab _strategicHouseEnTab = DeviceTab.largeScreen;
  DeviceTab _strategicHouseArTab = DeviceTab.largeScreen;

  // ── Cache for loaded SVG URLs to prevent reloading ──
  final Map<String, Uint8List> _svgCache = {};

  // ── Keys to prevent unnecessary rebuilds ──
  final _navIconKey = GlobalKey();
  final _strategicHouseEnKey = GlobalKey();
  final _strategicHouseArKey = GlobalKey();

  // ── Field change listener for reactive validation ──
  List<TextEditingController> get _allControllers => [
    _navTitleEnCtrl,
    _navTitleArCtrl,
  ];

  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }
    context.read<StrategyCubit>().load();
  }

  @override
  void dispose() {
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Validation helpers ────────────────────────────────────────────────────
  bool _isValidEnglish(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  bool _isValidArabic(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  // ── SVG validation helpers ────────────────────────────────────────────────
  bool _isSvgBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final checkLen = bytes.length > 200 ? 200 : bytes.length;
    final header = bytes.sublist(0, checkLen);
    final headerStr = String.fromCharCodes(header);
    return headerStr.contains('<svg') ||
        headerStr.contains('<?xml') && headerStr.contains('svg');
  }

  bool _isSvgUrl(String url) {
    if (url.isEmpty) return false;
    final decodedUrl = Uri.decodeFull(url).toLowerCase();
    return decodedUrl.contains('.svg') ||
        decodedUrl.contains('%2Esvg') ||
        decodedUrl.contains('image/svg+xml');
  }

  // ── File picker - SVG ONLY ────────────────────────────────────────────────
  Future<Uint8List?> _pickSvgImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/svg+xml,.svg';  // SVG ONLY

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }

      final file = files.first;

      // Validate file extension
      if (!file.name.toLowerCase().endsWith('.svg')) {
        c.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) {
          bytes = r.asUint8List();
        } else if (r is Uint8List) {
          bytes = r;
        }

        if (bytes != null) {
          // Validate that it's actually an SVG file by content
          if (!_isSvgBytes(bytes)) {
            c.complete(null);
            return;
          }

          print('✅ Valid SVG file loaded: ${file.name}, size: ${bytes.length} bytes');
          c.complete(bytes);
        } else {
          c.complete(null);
        }
      });

      reader.onError.listen((e) {
        print('Error reading file: $e');
        c.complete(null);
      });
    });

    input.click();
    return c.future;
  }

  // ── Seed ─────────────────────────────────────────────────────────────────
  void _seed(OurStrategyModel m, {bool isFromDraft = false}) {
    if (_seeded) return;
    _seeded = true;
    _isEditingDraft = isFromDraft;

    print('🔵 Seeding strategy data:');
    print('  - Nav icon URL: ${m.navigationLabel.iconUrl}');
    print('  - Strategic House EN URL: ${m.strategicHouseEnUrl}');
    print('  - Strategic House AR URL: ${m.strategicHouseArUrl}');
    print('  - Is from draft: $isFromDraft');

    // Remove listeners temporarily
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
    }

    _navTitleEnCtrl.text = m.navigationLabel.title.en;
    _navTitleArCtrl.text = m.navigationLabel.title.ar;
    _navIconUrl = m.navigationLabel.iconUrl;
    _navIconIsSvg = _isSvgUrl(m.navigationLabel.iconUrl);

    _strategicHouseEnUrl = m.strategicHouseEnUrl;
    _strategicHouseEnIsSvg = _isSvgUrl(m.strategicHouseEnUrl);

    _strategicHouseArUrl = m.strategicHouseArUrl;
    _strategicHouseArIsSvg = _isSvgUrl(m.strategicHouseArUrl);

    // Re-add listeners
    for (final ctrl in _allControllers) {
      ctrl.addListener(_onFieldChanged);
    }

    setState(() {});
  }

  // ── Build Model ───────────────────────────────────────────────────────────
  OurStrategyModel _buildModel(String status) => OurStrategyModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIconUrl,
      title: AboutBilingualText(
        en: _navTitleEnCtrl.text.trim(),
        ar: _navTitleArCtrl.text.trim(),
      ),
    ),
    strategicHouseEnUrl: _strategicHouseEnUrl,
    strategicHouseArUrl: _strategicHouseArUrl,
  );

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_navIconBytes != null && _navIconIsSvg)
      uploads['strategy_cms/navLabel/icon'] = _navIconBytes!;
    if (_strategicHouseEnBytes != null && _strategicHouseEnIsSvg)
      uploads['strategy_cms/strategicHouse/en'] = _strategicHouseEnBytes!;
    if (_strategicHouseArBytes != null && _strategicHouseArIsSvg)
      uploads['strategy_cms/strategicHouse/ar'] = _strategicHouseArBytes!;
    return uploads;
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate({bool forPublish = false}) {
    bool isValid = true;

    // Clear previous errors
    setState(() {
      _navIconError = null;
      _strategicHouseEnError = null;
      _strategicHouseArError = null;
    });

    // Validate text fields
    if (!_isValidEnglish(_navTitleEnCtrl.text)) {
      isValid = false;
    }
    if (!_isValidArabic(_navTitleArCtrl.text)) {
      isValid = false;
    }

    // Validate Navigation Icon
    final hasNavIcon = _navIconBytes != null || _navIconUrl.isNotEmpty;
    if (!hasNavIcon) {
      setState(() => _navIconError = 'Navigation icon is required');
      isValid = false;
    } else {
      final isSvg = _navIconBytes != null ? _navIconIsSvg : _isSvgUrl(_navIconUrl);
      if (!isSvg) {
        setState(() => _navIconError = 'Navigation icon must be an SVG file');
        isValid = false;
      }
    }

    // For publish, Strategic House images are REQUIRED
    if (forPublish) {
      // Validate Strategic House EN
      final hasEnImage = _strategicHouseEnBytes != null || _strategicHouseEnUrl.isNotEmpty;
      if (!hasEnImage) {
        setState(() => _strategicHouseEnError = 'Strategic House (ENG) image is required for publishing');
        isValid = false;
      } else {
        final isSvg = _strategicHouseEnBytes != null ? _strategicHouseEnIsSvg : _isSvgUrl(_strategicHouseEnUrl);
        if (!isSvg) {
          setState(() => _strategicHouseEnError = 'Strategic House (ENG) must be an SVG file');
          isValid = false;
        }
      }

      // Validate Strategic House AR
      final hasArImage = _strategicHouseArBytes != null || _strategicHouseArUrl.isNotEmpty;
      if (!hasArImage) {
        setState(() => _strategicHouseArError = 'Strategic House (ARB) image is required for publishing');
        isValid = false;
      } else {
        final isSvg = _strategicHouseArBytes != null ? _strategicHouseArIsSvg : _isSvgUrl(_strategicHouseArUrl);
        if (!isSvg) {
          setState(() => _strategicHouseArError = 'Strategic House (ARB) must be an SVG file');
          isValid = false;
        }
      }
    }

    return isValid;
  }

  // ── Check if form is valid for publishing ────────────────────────────────
  bool get _isFormValid {
    // Check text fields
    if (!_isValidEnglish(_navTitleEnCtrl.text)) return false;
    if (!_isValidArabic(_navTitleArCtrl.text)) return false;

    // Check navigation icon
    final hasNavIcon = _navIconBytes != null || _navIconUrl.isNotEmpty;
    if (!hasNavIcon) return false;
    final navIconSvg = _navIconBytes != null ? _navIconIsSvg : _isSvgUrl(_navIconUrl);
    if (!navIconSvg) return false;

    // Check strategic house EN
    final hasEnImage = _strategicHouseEnBytes != null || _strategicHouseEnUrl.isNotEmpty;
    if (!hasEnImage) return false;
    final enSvg = _strategicHouseEnBytes != null ? _strategicHouseEnIsSvg : _isSvgUrl(_strategicHouseEnUrl);
    if (!enSvg) return false;

    // Check strategic house AR
    final hasArImage = _strategicHouseArBytes != null || _strategicHouseArUrl.isNotEmpty;
    if (!hasArImage) return false;
    final arSvg = _strategicHouseArBytes != null ? _strategicHouseArIsSvg : _isSvgUrl(_strategicHouseArUrl);
    if (!arSvg) return false;

    // Check for validation errors
    if (_navIconError != null) return false;
    if (_strategicHouseEnError != null) return false;
    if (_strategicHouseArError != null) return false;

    return true;
  }

  // ── Get missing fields for error dialog ──────────────────────────────────
  List<String> _getMissingFields() {
    final missing = <String>[];

    if (_navTitleEnCtrl.text.trim().isEmpty) {
      missing.add('Navigation Title (EN)');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_navTitleEnCtrl.text)) {
      missing.add('Navigation Title (EN) - contains Arabic characters');
    }
    if (_navTitleArCtrl.text.trim().isEmpty) {
      missing.add('Navigation Title (AR)');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_navTitleArCtrl.text)) {
      missing.add('Navigation Title (AR) - contains English characters');
    }

    final hasNavIcon = _navIconBytes != null || _navIconUrl.isNotEmpty;
    if (!hasNavIcon) {
      missing.add('Navigation Icon (SVG required)');
    } else {
      final isSvg = _navIconBytes != null ? _navIconIsSvg : _isSvgUrl(_navIconUrl);
      if (!isSvg) {
        missing.add('Navigation Icon must be SVG format');
      }
    }

    final hasEnImage = _strategicHouseEnBytes != null || _strategicHouseEnUrl.isNotEmpty;
    if (!hasEnImage) {
      missing.add('Strategic House (ENG) image (SVG required)');
    } else {
      final isSvg = _strategicHouseEnBytes != null ? _strategicHouseEnIsSvg : _isSvgUrl(_strategicHouseEnUrl);
      if (!isSvg) {
        missing.add('Strategic House (ENG) must be SVG format');
      }
    }

    final hasArImage = _strategicHouseArBytes != null || _strategicHouseArUrl.isNotEmpty;
    if (!hasArImage) {
      missing.add('Strategic House (ARB) image (SVG required)');
    } else {
      final isSvg = _strategicHouseArBytes != null ? _strategicHouseArIsSvg : _isSvgUrl(_strategicHouseArUrl);
      if (!isSvg) {
        missing.add('Strategic House (ARB) must be SVG format');
      }
    }

    return missing;
  }

  // ── Show validation error dialog ──────────────────────────────────────────
  void _showValidationError() {
    final missing = _getMissingFields();
    if (missing.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: _kRed, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Validation Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please fill all required fields correctly:'),
            const SizedBox(height: 12),
            ...missing.map((field) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: _kRed)),
                  Expanded(child: Text(field)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_validate(forPublish: false)) return;

    final cubit   = context.read<StrategyCubit>();
    final model   = _buildModel('draft');
    final uploads = _collectUploads();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StrategyPreviewPage(model: model, imageUploads: uploads),
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    // Only validate fully for 'published' — drafts can be partial
    if (status == 'published') {
      setState(() => _submitted = true);
      if (!_validate(forPublish: true)) {
        _showValidationError();
        return;
      }
    }

    setState(() => _isSaving = true);

    final model = _buildModel(status);
    final uploads = _collectUploads();

    print('🔵 Saving strategy:');
    print('  - Status: $status');
    print('  - Nav icon SVG: $_navIconIsSvg');
    print('  - Strategic House EN SVG: $_strategicHouseEnIsSvg');
    print('  - Strategic House AR SVG: $_strategicHouseArIsSvg');

    await context.read<StrategyCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Device preview width helper ───────────────────────────────────────────
  double _previewWidth(DeviceTab tab) {
    switch (tab) {
      case DeviceTab.largeScreen:
        return double.infinity;
      case DeviceTab.tablet:
        return 600.w;
      case DeviceTab.mobile:
        return 320.w;
    }
  }

  // ── Load SVG from URL with caching ────────────────────────────────────────
  Future<Uint8List> _loadSvgBytes(String url) async {
    // Check cache first
    if (_svgCache.containsKey(url)) {
      print('🟢 Using cached SVG: $url');
      return _svgCache[url]!;
    }

    try {
      print('🟡 Loading SVG from URL: $url');
      final res = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (res.status != 200) {
        throw Exception('Failed to load SVG: ${res.status}');
      }
      final bytes = (res.response as ByteBuffer).asUint8List();
      print('✅ SVG loaded successfully, size: ${bytes.length} bytes');

      // Store in cache
      _svgCache[url] = bytes;
      return bytes;
    } catch (e) {
      print('❌ Error loading SVG: $e');
      rethrow;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyCubit, StrategyState>(
      listener: (context, state) {
        print('[StrategyEditPage] 👂 listener: ${state.runtimeType}');

        if (state is StrategyLoaded) {
          _seed(state.data, );
        }

        // ── Published successfully ────────────────────────────────────
        if (state is StrategySaved) {
          setState(() => _isSaving = false);

          setState(() {
            _navIconUrl = state.data.navigationLabel.iconUrl;
            _navIconIsSvg = _isSvgUrl(state.data.navigationLabel.iconUrl);

            _strategicHouseEnUrl = state.data.strategicHouseEnUrl;
            _strategicHouseEnIsSvg = _isSvgUrl(state.data.strategicHouseEnUrl);

            _strategicHouseArUrl = state.data.strategicHouseArUrl;
            _strategicHouseArIsSvg = _isSvgUrl(state.data.strategicHouseArUrl);

            print('🟢 URLs updated after save:');
            print('  - Nav Icon URL: $_navIconUrl (SVG: $_navIconIsSvg)');
            print('  - EN URL: $_strategicHouseEnUrl (SVG: $_strategicHouseEnIsSvg)');
            print('  - AR URL: $_strategicHouseArUrl (SVG: $_strategicHouseArIsSvg)');

            // Clear bytes after successful upload
            _navIconBytes = null;
            _strategicHouseEnBytes = null;
            _strategicHouseArBytes = null;

            // Clear cache for updated URLs
            _svgCache.remove(_navIconUrl);
            _svgCache.remove(_strategicHouseEnUrl);
            _svgCache.remove(_strategicHouseArUrl);
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<StrategyCubit>(),
                    child: const StrategyMainView(),
                  ),
                ),
                    (route) => false,
              );
            }
          });
        }

        // // ── Draft saved successfully ──────────────────────────────────
        // if (state is StrategyDraftSaved) {
        //   setState(() => _isSaving = false);
        //
        //   if (mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //       content: Text(
        //         'Draft saved! Published version is still live.',
        //         style: StyleText.fontSize14Weight400.copyWith(color: Colors.white),
        //       ),
        //       backgroundColor: _kDraftBadge,
        //       behavior: SnackBarBehavior.floating,
        //     ));
        //   }
        //
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) {
        //       Navigator.of(context).pushAndRemoveUntil(
        //         MaterialPageRoute(
        //           builder: (context) => BlocProvider.value(
        //             value: context.read<StrategyCubit>(),
        //             child: const StrategyMainView(),
        //           ),
        //         ),
        //             (route) => false,
        //       );
        //     }
        //   });
        // }

        // // ── Draft deleted (discard) ───────────────────────────────────
        // if (state is StrategyDraftDeleted) {
        //   setState(() => _isSaving = false);
        //
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) {
        //       Navigator.of(context).pushAndRemoveUntil(
        //         MaterialPageRoute(
        //           builder: (context) => BlocProvider.value(
        //             value: context.read<StrategyCubit>(),
        //             child: const StrategyMainView(),
        //           ),
        //         ),
        //             (route) => false,
        //       );
        //     }
        //   });
        // }

        if (state is StrategyError) {
          setState(() => _isSaving = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.message}',
                  style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      },
      builder: (context, state) {
        final loading = state is StrategyLoading || state is StrategyInitial;
        final canPublish = _isFormValid;

        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 1000.w,
                        child: Column(
                          children: [
                            AppAdminNavbar(
                              activeLabel: 'Web Page',
                              homePage: HomeMainPage(),
                              webPage: HomeMainPage(),
                              jobListingPage: HomeMainPage(),
                            ),
                            SizedBox(height: 20.h),
                            const AdminSubNavBar(activeIndex: 5),
                            SizedBox(height: 20.h),
                            loading
                                ? const Center(
                                child: CircularProgressIndicator(
                                    color: _kGreenSolid))
                                : _buildForm(canPublish),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSaving) _savingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm(bool canPublish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title row with draft badge ─────────────────────────────────────
        Row(
          children: [
            Text('Editing Our Strategy',
                style: StyleText.fontSize45Weight600.copyWith(
                    color: _kGreen, fontWeight: FontWeight.w700)),
            if (_isEditingDraft) ...[
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _kDraftBadge.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'EDITING DRAFT',
                  style: StyleText.fontSize12Weight600.copyWith(
                    color: _kDraftBadge,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_isEditingDraft)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'You are editing a saved draft. The published version is still live.',
              style: StyleText.fontSize12Weight400.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        SizedBox(height: 24.h),

        // ── Navigation Label ──────────────────────────────────────────────
        _accordion(
          title: 'Navigation Label',
          isOpen: _navLabelOpen,
          onToggle: () =>
              setState(() => _navLabelOpen = !_navLabelOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NavIconUploadWidget(
                key: _navIconKey,
                bytes: _navIconBytes,
                url: _navIconUrl,
                isSvg: _navIconIsSvg,
                errorText: _navIconError,
                loadSvgBytes: _loadSvgBytes,
                onTap: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _navIconBytes = b;
                      _navIconIsSvg = true;
                      _navIconError = null;
                    });
                  }
                },
                onRemove: (_navIconBytes != null || _navIconUrl.isNotEmpty)
                    ? () => setState(() {
                  _navIconBytes = null;
                  _navIconUrl = '';
                  _navIconIsSvg = false;
                })
                    : null,
              ),
              SizedBox(height: 16.h),
              _fieldLabel('Title'),
              SizedBox(height: 8.h),
              _bilingualRow(
                  enCtrl: _navTitleEnCtrl,
                  arCtrl: _navTitleArCtrl,
                  enHint: 'Text Here',
                  arHint: 'أدخل النص هنا'),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ENG ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ENG',
          isOpen: _strategicHouseEnOpen,
          onToggle: () =>
              setState(() => _strategicHouseEnOpen = !_strategicHouseEnOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width : 300.w,
                child: _deviceTabBar(
                  selected: _strategicHouseEnTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseEnTab = tab),
                ),
              ),
              SizedBox(height: 16.h),
              _StrategicHouseImageWidget(
                key: _strategicHouseEnKey,
                bytes: _strategicHouseEnBytes,
                url: _strategicHouseEnUrl,
                isSvg: _strategicHouseEnIsSvg,
                errorText: _strategicHouseEnError,
                previewWidth: _previewWidth(_strategicHouseEnTab),
                loadSvgBytes: _loadSvgBytes,
                onTap: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseEnBytes = b;
                      _strategicHouseEnIsSvg = true;
                      _strategicHouseEnError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseEnBytes != null ||
                    _strategicHouseEnUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseEnBytes = null;
                  _strategicHouseEnUrl   = '';
                  _strategicHouseEnIsSvg = false;
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ARB ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ARB',
          isOpen: _strategicHouseArOpen,
          onToggle: () =>
              setState(() => _strategicHouseArOpen = !_strategicHouseArOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width : 300.w,
                child: _deviceTabBar(
                  selected: _strategicHouseArTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseArTab = tab),
                ),
              ),
              SizedBox(height: 16.h),
              _StrategicHouseImageWidget(
                key: _strategicHouseArKey,
                bytes: _strategicHouseArBytes,
                url: _strategicHouseArUrl,
                isSvg: _strategicHouseArIsSvg,
                errorText: _strategicHouseArError,
                previewWidth: _previewWidth(_strategicHouseArTab),
                loadSvgBytes: _loadSvgBytes,
                onTap: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseArBytes = b;
                      _strategicHouseArIsSvg = true;
                      _strategicHouseArError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseArBytes != null ||
                    _strategicHouseArUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseArBytes = null;
                  _strategicHouseArUrl   = '';
                  _strategicHouseArIsSvg = false;
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        // ── Action buttons ────────────────────────────────────────────────
        _actionRow(canPublish),
        SizedBox(height: 12.h),
        _secondaryRow(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Action Buttons Row ────────────────────────────────────────────────────
  Widget _actionRow(bool canPublish) {
    return Row(children: [
      Expanded(
        child: _btn(
          label: 'Preview',
          color: const Color(0xFFD16F9A).withOpacity(.5),
          onTap: _onPreview,
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: AbsorbPointer(
          absorbing: !canPublish,
          child: Opacity(
            opacity: canPublish ? 1.0 : 0.6,
            child: _btn(
              label: 'Publish',
              color: canPublish ? _kGreenSolid : _kGreenSolid.withOpacity(0.35),
              onTap: () {
                if (!canPublish) {
                  setState(() => _submitted = true);
                  _showValidationError();
                  return;
                }

                // Show publish confirmation dialog
                showPublishConfirmDialog(
                  context: context,
                  title: 'PUBLISHING STRATEGY',
                  subtitle: 'Do you want to publish this strategy?',
                  onConfirm: () async => _save('published'),
                );
              },
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Secondary Buttons Row ─────────────────────────────────────────────────
  Widget _secondaryRow() {
    return Row(children: [
      // ── Discard button ────────────────────────────────────────────────
      Expanded(
        child: _btn(
          label: 'Discard',
          color: const Color(0xFF9E9E9E),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StrategyMainView()));
            }
          },
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(child: Column())
    ]);
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding:
          EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _kGreenSolid,
            borderRadius: isOpen
                ? BorderRadius.vertical(top: Radius.circular(12.r))
                : BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp),
            ],
          ),
        ),
      ),
      if (isOpen)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: child,
        ),
    ]);
  }

  // ── Device Tab Bar ────────────────────────────────────────────────────────
  Widget _deviceTabBar({
    required DeviceTab selected,
    required ValueChanged<DeviceTab> onChanged,
  }) {
    Widget tab(String label, DeviceTab value) {
      final isActive = selected == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isActive ? _kGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          tab('Large Screen', DeviceTab.largeScreen),
          SizedBox(width: 4.w),
          tab('Tablet', DeviceTab.tablet),
          SizedBox(width: 4.w),
          tab('Mobile', DeviceTab.mobile),
        ],
      ),
    );
  }

  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            fillColor: Colors.white,
            maxLength: 200,
            submitted: _submitted,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) {
              // Validation handled by listener
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint,
            controller: arCtrl,
            height: 42,
            fillColor: Colors.white,
            maxLines: 1,
            maxLength: 200,
            submitted: _submitted,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) {
              // Validation handled by listener
            },
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w,
        height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _kGreenSolid),
            SizedBox(height: 12.h),
            Text('Saving...',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEPARATE WIDGET CLASSES TO PREVENT REBUILDS
// ═══════════════════════════════════════════════════════════════════════════════

/// Separate widget for Navigation Icon to prevent rebuilds when text fields change
class _NavIconUploadWidget extends StatelessWidget {
  final Uint8List? bytes;
  final String url;
  final bool isSvg;
  final String? errorText;
  final Future<Uint8List> Function(String) loadSvgBytes;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _NavIconUploadWidget({
    super.key,
    required this.bytes,
    required this.url,
    required this.isSvg,
    this.errorText,
    required this.loadSvgBytes,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEEEEEE),
                      border: errorText != null
                          ? Border.all(color: _kRed, width: 2)
                          : null,
                    ),
                    child: hasImage
                        ? ClipOval(
                      child: Builder(
                        builder: (context) {
                          if (bytes != null && isSvg) {
                            return SvgPicture.memory(
                              bytes!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (url.isNotEmpty && isSvg) {
                            return FutureBuilder<Uint8List>(
                              key: ValueKey(url),
                              future: loadSvgBytes(url),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasData) {
                                  return SvgPicture.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[400],
                                  size: 28.sp,
                                );
                              },
                            );
                          }

                          return Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 28.sp,
                          );
                        },
                      ),
                    )
                        : Icon(Icons.add,
                        color: errorText != null ? _kRed : Colors.grey[600],
                        size: 28.sp),
                  ),
                  if (hasImage && onRemove != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kRed,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  if (!hasImage)
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kGreenSolid),
                        child: Icon(Icons.edit,
                            color: Colors.white, size: 13.sp),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: _kRed,
            ),
          ),
        ],
      ],
    );
  }
}

/// Separate widget for Strategic House Images to prevent rebuilds
class _StrategicHouseImageWidget extends StatelessWidget {
  final Uint8List? bytes;
  final String url;
  final bool isSvg;
  final String? errorText;
  final double previewWidth;
  final Future<Uint8List> Function(String) loadSvgBytes;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _StrategicHouseImageWidget({
    super.key,
    required this.bytes,
    required this.url,
    required this.isSvg,
    this.errorText,
    required this.previewWidth,
    required this.loadSvgBytes,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── image area ──
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: previewWidth,
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: errorText != null
                  ? Border.all(color: _kRed, width: 2)
                  : null,
            ),
            child: hasImage
                ? Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Builder(
                    builder: (context) {
                      if (bytes != null && isSvg) {
                        return SvgPicture.memory(
                          bytes!,
                          width: previewWidth,
                          height: 220.h,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (url.isNotEmpty && isSvg) {
                        return FutureBuilder<Uint8List>(
                          key: ValueKey(url),
                          future: loadSvgBytes(url),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasData) {
                              return SvgPicture.memory(
                                snapshot.data!,
                                width: previewWidth,
                                height: 220.h,
                                fit: BoxFit.contain,
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                      size: 48.sp,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Failed to load SVG',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                  assetPath: "assets/images/upload-image.svg",
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Drop your SVG image here',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: errorText != null ? _kRed : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              errorText!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: _kRed,
              ),
            ),
          ),
        ],
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtonWithImage(
              title: 'Upload SVG Image',
              function: onTap,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white
              ),
              height: 38.h,
              space: 8.sp,
              width: 250.w,
              radius: 8.r,
              color: _kGreenSolid,
              image: "",
              widthImage: 16.w,
              heightImage: 16.h,
              colorBorder: Colors.transparent,
            ),
          ],
        )
      ],
    );
  }
}