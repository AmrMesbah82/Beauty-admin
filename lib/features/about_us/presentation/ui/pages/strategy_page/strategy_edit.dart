// ******************* FILE INFO *******************
// File Name: strategy_edit.dart
// Screen 2 of 3 — Our Strategy CMS: Edit page
// UPDATED: Multi-device image support (Desktop, Tablet, Mobile) for both EN and AR
// UPDATED: Each device has separate upload button and preview
// UPDATED: Validation requires all 3 device images for each language on publish
// Created by: Amr Mesbah
// Last Update: 21/04/2026

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:beauty_admin/features/about_us/presentation/ui/pages/strategy_page/strategy_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widgets/button.dart';
import 'package:beauty_admin/core/widgets/textfield.dart';

import '../../../../../../core/custom_dialog.dart';
import '../../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../../core/theme/appcolors.dart';
import '../../../../../../core/theme/new_theme.dart';
import '../../../../../home/presentation/ui/pages/home_main.dart';
import '../../../../data/models/about_us_model.dart';
import '../../../controller/about_us_cubit.dart';
import '../../../controller/about_us_state.dart';
import 'strategy_preview.dart';

part '../../widgets/strategy_edit/nav_icon_upload_widget.dart';
part '../../widgets/strategy_edit/strategic_house_display_widget.dart';
part '../../widgets/strategy_edit/device_upload_row.dart';

const Color _kGreen      = Color(0xFFD16F9A);
const Color _kGreenSolid = Color(0xFFD16F9A);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kBg         = Color(0xFFF2F2F2);
const Color _kDraftBadge = Color(0xFFF59E0B);

// ── Device type enum for image uploads ────────────────────────────────────────
enum DeviceType { desktop, tablet, mobile }

extension DeviceTypeExtension on DeviceType {
  String get displayName {
    switch (this) {
      case DeviceType.desktop: return 'Desktop';
      case DeviceType.tablet: return 'Tablet';
      case DeviceType.mobile: return 'Mobile';
    }
  }

  String get storagePathSuffix {
    switch (this) {
      case DeviceType.desktop: return 'desktop';
      case DeviceType.tablet: return 'tablet';
      case DeviceType.mobile: return 'mobile';
    }
  }

  double get previewWidth {
    switch (this) {
      case DeviceType.desktop: return double.infinity;
      case DeviceType.tablet: return 600;
      case DeviceType.mobile: return 320;
    }
  }
}

// ── Device preview tab enum for display ───────────────────────────────────────
enum DisplayDeviceTab { largeScreen, tablet, mobile }

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

  // ── Strategic House — ENG (3 devices) ──
  // Desktop
  Uint8List? _strategicHouseEnDesktopBytes;
  String _strategicHouseEnDesktopUrl = '';
  bool _strategicHouseEnDesktopIsSvg = false;

  // Tablet
  Uint8List? _strategicHouseEnTabletBytes;
  String _strategicHouseEnTabletUrl = '';
  bool _strategicHouseEnTabletIsSvg = false;

  // Mobile
  Uint8List? _strategicHouseEnMobileBytes;
  String _strategicHouseEnMobileUrl = '';
  bool _strategicHouseEnMobileIsSvg = false;

  // ── Strategic House — ARB (3 devices) ──
  // Desktop
  Uint8List? _strategicHouseArDesktopBytes;
  String _strategicHouseArDesktopUrl = '';
  bool _strategicHouseArDesktopIsSvg = false;

  // Tablet
  Uint8List? _strategicHouseArTabletBytes;
  String _strategicHouseArTabletUrl = '';
  bool _strategicHouseArTabletIsSvg = false;

  // Mobile
  Uint8List? _strategicHouseArMobileBytes;
  String _strategicHouseArMobileUrl = '';
  bool _strategicHouseArMobileIsSvg = false;

  bool _navLabelOpen        = true;
  bool _strategicHouseEnOpen = true;
  bool _strategicHouseArOpen = true;

  bool _submitted = false;
  bool _seeded    = false;
  bool _isSaving  = false;

  /// Whether the data currently loaded came from a draft document.
  bool _isEditingDraft = false;

  // ── Validation errors per device ──
  String? _navIconError;

  // EN device errors
  String? _strategicHouseEnDesktopError;
  String? _strategicHouseEnTabletError;
  String? _strategicHouseEnMobileError;

  // AR device errors
  String? _strategicHouseArDesktopError;
  String? _strategicHouseArTabletError;
  String? _strategicHouseArMobileError;

  // ── Display preview tabs for each section ──
  DisplayDeviceTab _strategicHouseEnDisplayTab = DisplayDeviceTab.largeScreen;
  DisplayDeviceTab _strategicHouseArDisplayTab = DisplayDeviceTab.largeScreen;

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

          c.complete(bytes);
        } else {
          c.complete(null);
        }
      });

      reader.onError.listen((e) {
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


    // Remove listeners temporarily
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_onFieldChanged);
    }

    _navTitleEnCtrl.text = m.navigationLabel.title.en;
    _navTitleArCtrl.text = m.navigationLabel.title.ar;
    _navIconUrl = m.navigationLabel.iconUrl;
    _navIconIsSvg = _isSvgUrl(m.navigationLabel.iconUrl);

    // EN device URLs
    _strategicHouseEnDesktopUrl = m.strategicHouseEnDesktopUrl;
    _strategicHouseEnDesktopIsSvg = _isSvgUrl(m.strategicHouseEnDesktopUrl);

    _strategicHouseEnTabletUrl = m.strategicHouseEnTabletUrl;
    _strategicHouseEnTabletIsSvg = _isSvgUrl(m.strategicHouseEnTabletUrl);

    _strategicHouseEnMobileUrl = m.strategicHouseEnMobileUrl;
    _strategicHouseEnMobileIsSvg = _isSvgUrl(m.strategicHouseEnMobileUrl);

    // AR device URLs
    _strategicHouseArDesktopUrl = m.strategicHouseArDesktopUrl;
    _strategicHouseArDesktopIsSvg = _isSvgUrl(m.strategicHouseArDesktopUrl);

    _strategicHouseArTabletUrl = m.strategicHouseArTabletUrl;
    _strategicHouseArTabletIsSvg = _isSvgUrl(m.strategicHouseArTabletUrl);

    _strategicHouseArMobileUrl = m.strategicHouseArMobileUrl;
    _strategicHouseArMobileIsSvg = _isSvgUrl(m.strategicHouseArMobileUrl);

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
    strategicHouseEnDesktopUrl: _strategicHouseEnDesktopUrl,
    strategicHouseEnTabletUrl: _strategicHouseEnTabletUrl,
    strategicHouseEnMobileUrl: _strategicHouseEnMobileUrl,
    strategicHouseArDesktopUrl: _strategicHouseArDesktopUrl,
    strategicHouseArTabletUrl: _strategicHouseArTabletUrl,
    strategicHouseArMobileUrl: _strategicHouseArMobileUrl,
  );

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};

    // Navigation icon
    if (_navIconBytes != null && _navIconIsSvg)
      uploads['strategy_cms/navLabel/icon'] = _navIconBytes!;

    // EN device uploads
    if (_strategicHouseEnDesktopBytes != null && _strategicHouseEnDesktopIsSvg)
      uploads['strategy_cms/strategicHouse/en/desktop'] = _strategicHouseEnDesktopBytes!;

    if (_strategicHouseEnTabletBytes != null && _strategicHouseEnTabletIsSvg)
      uploads['strategy_cms/strategicHouse/en/tablet'] = _strategicHouseEnTabletBytes!;

    if (_strategicHouseEnMobileBytes != null && _strategicHouseEnMobileIsSvg)
      uploads['strategy_cms/strategicHouse/en/mobile'] = _strategicHouseEnMobileBytes!;

    // AR device uploads
    if (_strategicHouseArDesktopBytes != null && _strategicHouseArDesktopIsSvg)
      uploads['strategy_cms/strategicHouse/ar/desktop'] = _strategicHouseArDesktopBytes!;

    if (_strategicHouseArTabletBytes != null && _strategicHouseArTabletIsSvg)
      uploads['strategy_cms/strategicHouse/ar/tablet'] = _strategicHouseArTabletBytes!;

    if (_strategicHouseArMobileBytes != null && _strategicHouseArMobileIsSvg)
      uploads['strategy_cms/strategicHouse/ar/mobile'] = _strategicHouseArMobileBytes!;

    return uploads;
  }

  // ── Check if a device image is present ─────────────────────────────────────
  bool _hasEnDeviceImage(DeviceType device) {
    switch (device) {
      case DeviceType.desktop:
        return _strategicHouseEnDesktopBytes != null || _strategicHouseEnDesktopUrl.isNotEmpty;
      case DeviceType.tablet:
        return _strategicHouseEnTabletBytes != null || _strategicHouseEnTabletUrl.isNotEmpty;
      case DeviceType.mobile:
        return _strategicHouseEnMobileBytes != null || _strategicHouseEnMobileUrl.isNotEmpty;
    }
  }

  bool _hasArDeviceImage(DeviceType device) {
    switch (device) {
      case DeviceType.desktop:
        return _strategicHouseArDesktopBytes != null || _strategicHouseArDesktopUrl.isNotEmpty;
      case DeviceType.tablet:
        return _strategicHouseArTabletBytes != null || _strategicHouseArTabletUrl.isNotEmpty;
      case DeviceType.mobile:
        return _strategicHouseArMobileBytes != null || _strategicHouseArMobileUrl.isNotEmpty;
    }
  }

  bool _isEnDeviceImageSvg(DeviceType device) {
    switch (device) {
      case DeviceType.desktop:
        return _strategicHouseEnDesktopBytes != null ? _strategicHouseEnDesktopIsSvg : _isSvgUrl(_strategicHouseEnDesktopUrl);
      case DeviceType.tablet:
        return _strategicHouseEnTabletBytes != null ? _strategicHouseEnTabletIsSvg : _isSvgUrl(_strategicHouseEnTabletUrl);
      case DeviceType.mobile:
        return _strategicHouseEnMobileBytes != null ? _strategicHouseEnMobileIsSvg : _isSvgUrl(_strategicHouseEnMobileUrl);
    }
  }

  bool _isArDeviceImageSvg(DeviceType device) {
    switch (device) {
      case DeviceType.desktop:
        return _strategicHouseArDesktopBytes != null ? _strategicHouseArDesktopIsSvg : _isSvgUrl(_strategicHouseArDesktopUrl);
      case DeviceType.tablet:
        return _strategicHouseArTabletBytes != null ? _strategicHouseArTabletIsSvg : _isSvgUrl(_strategicHouseArTabletUrl);
      case DeviceType.mobile:
        return _strategicHouseArMobileBytes != null ? _strategicHouseArMobileIsSvg : _isSvgUrl(_strategicHouseArMobileUrl);
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate({bool forPublish = false}) {
    bool isValid = true;

    // Clear previous errors
    setState(() {
      _navIconError = null;
      _strategicHouseEnDesktopError = null;
      _strategicHouseEnTabletError = null;
      _strategicHouseEnMobileError = null;
      _strategicHouseArDesktopError = null;
      _strategicHouseArTabletError = null;
      _strategicHouseArMobileError = null;
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

    // For publish, ALL 6 Strategic House images are REQUIRED (EN & AR x 3 devices)
    if (forPublish) {
      // Validate EN Desktop
      if (!_hasEnDeviceImage(DeviceType.desktop)) {
        setState(() => _strategicHouseEnDesktopError = 'Strategic House (ENG) Desktop image is required for publishing');
        isValid = false;
      } else if (!_isEnDeviceImageSvg(DeviceType.desktop)) {
        setState(() => _strategicHouseEnDesktopError = 'Strategic House (ENG) Desktop must be an SVG file');
        isValid = false;
      }

      // Validate EN Tablet
      if (!_hasEnDeviceImage(DeviceType.tablet)) {
        setState(() => _strategicHouseEnTabletError = 'Strategic House (ENG) Tablet image is required for publishing');
        isValid = false;
      } else if (!_isEnDeviceImageSvg(DeviceType.tablet)) {
        setState(() => _strategicHouseEnTabletError = 'Strategic House (ENG) Tablet must be an SVG file');
        isValid = false;
      }

      // Validate EN Mobile
      if (!_hasEnDeviceImage(DeviceType.mobile)) {
        setState(() => _strategicHouseEnMobileError = 'Strategic House (ENG) Mobile image is required for publishing');
        isValid = false;
      } else if (!_isEnDeviceImageSvg(DeviceType.mobile)) {
        setState(() => _strategicHouseEnMobileError = 'Strategic House (ENG) Mobile must be an SVG file');
        isValid = false;
      }

      // Validate AR Desktop
      if (!_hasArDeviceImage(DeviceType.desktop)) {
        setState(() => _strategicHouseArDesktopError = 'Strategic House (ARB) Desktop image is required for publishing');
        isValid = false;
      } else if (!_isArDeviceImageSvg(DeviceType.desktop)) {
        setState(() => _strategicHouseArDesktopError = 'Strategic House (ARB) Desktop must be an SVG file');
        isValid = false;
      }

      // Validate AR Tablet
      if (!_hasArDeviceImage(DeviceType.tablet)) {
        setState(() => _strategicHouseArTabletError = 'Strategic House (ARB) Tablet image is required for publishing');
        isValid = false;
      } else if (!_isArDeviceImageSvg(DeviceType.tablet)) {
        setState(() => _strategicHouseArTabletError = 'Strategic House (ARB) Tablet must be an SVG file');
        isValid = false;
      }

      // Validate AR Mobile
      if (!_hasArDeviceImage(DeviceType.mobile)) {
        setState(() => _strategicHouseArMobileError = 'Strategic House (ARB) Mobile image is required for publishing');
        isValid = false;
      } else if (!_isArDeviceImageSvg(DeviceType.mobile)) {
        setState(() => _strategicHouseArMobileError = 'Strategic House (ARB) Mobile must be an SVG file');
        isValid = false;
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

    // Check all 6 strategic house images
    // EN
    if (!_hasEnDeviceImage(DeviceType.desktop)) return false;
    if (!_isEnDeviceImageSvg(DeviceType.desktop)) return false;

    if (!_hasEnDeviceImage(DeviceType.tablet)) return false;
    if (!_isEnDeviceImageSvg(DeviceType.tablet)) return false;

    if (!_hasEnDeviceImage(DeviceType.mobile)) return false;
    if (!_isEnDeviceImageSvg(DeviceType.mobile)) return false;

    // AR
    if (!_hasArDeviceImage(DeviceType.desktop)) return false;
    if (!_isArDeviceImageSvg(DeviceType.desktop)) return false;

    if (!_hasArDeviceImage(DeviceType.tablet)) return false;
    if (!_isArDeviceImageSvg(DeviceType.tablet)) return false;

    if (!_hasArDeviceImage(DeviceType.mobile)) return false;
    if (!_isArDeviceImageSvg(DeviceType.mobile)) return false;

    // Check for validation errors
    if (_navIconError != null) return false;
    if (_strategicHouseEnDesktopError != null) return false;
    if (_strategicHouseEnTabletError != null) return false;
    if (_strategicHouseEnMobileError != null) return false;
    if (_strategicHouseArDesktopError != null) return false;
    if (_strategicHouseArTabletError != null) return false;
    if (_strategicHouseArMobileError != null) return false;

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

    // EN devices
    if (!_hasEnDeviceImage(DeviceType.desktop)) {
      missing.add('Strategic House (ENG) Desktop image (SVG required)');
    } else if (!_isEnDeviceImageSvg(DeviceType.desktop)) {
      missing.add('Strategic House (ENG) Desktop must be SVG format');
    }

    if (!_hasEnDeviceImage(DeviceType.tablet)) {
      missing.add('Strategic House (ENG) Tablet image (SVG required)');
    } else if (!_isEnDeviceImageSvg(DeviceType.tablet)) {
      missing.add('Strategic House (ENG) Tablet must be SVG format');
    }

    if (!_hasEnDeviceImage(DeviceType.mobile)) {
      missing.add('Strategic House (ENG) Mobile image (SVG required)');
    } else if (!_isEnDeviceImageSvg(DeviceType.mobile)) {
      missing.add('Strategic House (ENG) Mobile must be SVG format');
    }

    // AR devices
    if (!_hasArDeviceImage(DeviceType.desktop)) {
      missing.add('Strategic House (ARB) Desktop image (SVG required)');
    } else if (!_isArDeviceImageSvg(DeviceType.desktop)) {
      missing.add('Strategic House (ARB) Desktop must be SVG format');
    }

    if (!_hasArDeviceImage(DeviceType.tablet)) {
      missing.add('Strategic House (ARB) Tablet image (SVG required)');
    } else if (!_isArDeviceImageSvg(DeviceType.tablet)) {
      missing.add('Strategic House (ARB) Tablet must be SVG format');
    }

    if (!_hasArDeviceImage(DeviceType.mobile)) {
      missing.add('Strategic House (ARB) Mobile image (SVG required)');
    } else if (!_isArDeviceImageSvg(DeviceType.mobile)) {
      missing.add('Strategic House (ARB) Mobile must be SVG format');
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
    // For publish, validate all 6 images are present
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


    await context.read<StrategyCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Get display preview width ─────────────────────────────────────────────
  double _getDisplayPreviewWidth(DisplayDeviceTab tab) {
    switch (tab) {
      case DisplayDeviceTab.largeScreen:
        return double.infinity;
      case DisplayDeviceTab.tablet:
        return 600.w;
      case DisplayDeviceTab.mobile:
        return 320.w;
    }
  }

  // ── Load SVG from URL with caching ────────────────────────────────────────
  Future<Uint8List> _loadSvgBytes(String url) async {
    if (_svgCache.containsKey(url)) {
      return _svgCache[url]!;
    }

    try {
      final res = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (res.status != 200) {
        throw Exception('Failed to load SVG: ${res.status}');
      }
      final bytes = (res.response as ByteBuffer).asUint8List();

      _svgCache[url] = bytes;
      return bytes;
    } catch (e) {
      rethrow;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyCubit, StrategyState>(
      listener: (context, state) {

        if (state is StrategyLoaded) {
          _seed(state.data);
        }

        if (state is StrategySaved) {
          setState(() => _isSaving = false);

          setState(() {
            _navIconUrl = state.data.navigationLabel.iconUrl;
            _navIconIsSvg = _isSvgUrl(state.data.navigationLabel.iconUrl);

            // EN device URLs
            _strategicHouseEnDesktopUrl = state.data.strategicHouseEnDesktopUrl;
            _strategicHouseEnDesktopIsSvg = _isSvgUrl(state.data.strategicHouseEnDesktopUrl);

            _strategicHouseEnTabletUrl = state.data.strategicHouseEnTabletUrl;
            _strategicHouseEnTabletIsSvg = _isSvgUrl(state.data.strategicHouseEnTabletUrl);

            _strategicHouseEnMobileUrl = state.data.strategicHouseEnMobileUrl;
            _strategicHouseEnMobileIsSvg = _isSvgUrl(state.data.strategicHouseEnMobileUrl);

            // AR device URLs
            _strategicHouseArDesktopUrl = state.data.strategicHouseArDesktopUrl;
            _strategicHouseArDesktopIsSvg = _isSvgUrl(state.data.strategicHouseArDesktopUrl);

            _strategicHouseArTabletUrl = state.data.strategicHouseArTabletUrl;
            _strategicHouseArTabletIsSvg = _isSvgUrl(state.data.strategicHouseArTabletUrl);

            _strategicHouseArMobileUrl = state.data.strategicHouseArMobileUrl;
            _strategicHouseArMobileIsSvg = _isSvgUrl(state.data.strategicHouseArMobileUrl);

            // Clear bytes after successful upload
            _navIconBytes = null;
            _strategicHouseEnDesktopBytes = null;
            _strategicHouseEnTabletBytes = null;
            _strategicHouseEnMobileBytes = null;
            _strategicHouseArDesktopBytes = null;
            _strategicHouseArTabletBytes = null;
            _strategicHouseArMobileBytes = null;

            // Clear cache for updated URLs
            _svgCache.remove(_navIconUrl);
            _svgCache.remove(_strategicHouseEnDesktopUrl);
            _svgCache.remove(_strategicHouseEnTabletUrl);
            _svgCache.remove(_strategicHouseEnMobileUrl);
            _svgCache.remove(_strategicHouseArDesktopUrl);
            _svgCache.remove(_strategicHouseArTabletUrl);
            _svgCache.remove(_strategicHouseArMobileUrl);
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
                  color: _kDraftBadge.withValues(alpha: 0.15),
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

        // ── Strategic House — ENG (3 devices) ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ENG (Desktop, Tablet, Mobile)',
          isOpen: _strategicHouseEnOpen,
          onToggle: () =>
              setState(() => _strategicHouseEnOpen = !_strategicHouseEnOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display preview selector
              Container(
                width: 300.w,
                child: _deviceDisplayTabBar(
                  selected: _strategicHouseEnDisplayTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseEnDisplayTab = tab),
                ),
              ),
              SizedBox(height: 16.h),

              // Current display preview
              _StrategicHouseDisplayWidget(
                displayTab: _strategicHouseEnDisplayTab,
                desktopBytes: _strategicHouseEnDesktopBytes,
                desktopUrl: _strategicHouseEnDesktopUrl,
                desktopIsSvg: _strategicHouseEnDesktopIsSvg,
                tabletBytes: _strategicHouseEnTabletBytes,
                tabletUrl: _strategicHouseEnTabletUrl,
                tabletIsSvg: _strategicHouseEnTabletIsSvg,
                mobileBytes: _strategicHouseEnMobileBytes,
                mobileUrl: _strategicHouseEnMobileUrl,
                mobileIsSvg: _strategicHouseEnMobileIsSvg,
                loadSvgBytes: _loadSvgBytes,
              ),
              SizedBox(height: 16.h),

              // Upload buttons for all 3 devices
              Text('Upload Images for Each Device:',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),

              // Desktop upload
              _DeviceUploadRow(
                title: 'Desktop',
                hasImage: _strategicHouseEnDesktopBytes != null || _strategicHouseEnDesktopUrl.isNotEmpty,
                errorText: _strategicHouseEnDesktopError,
                onUpload: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseEnDesktopBytes = b;
                      _strategicHouseEnDesktopIsSvg = true;
                      _strategicHouseEnDesktopError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseEnDesktopBytes != null || _strategicHouseEnDesktopUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseEnDesktopBytes = null;
                  _strategicHouseEnDesktopUrl = '';
                  _strategicHouseEnDesktopIsSvg = false;
                })
                    : null,
              ),
              SizedBox(height: 12.h),

              // Tablet upload
              _DeviceUploadRow(
                title: 'Tablet',
                hasImage: _strategicHouseEnTabletBytes != null || _strategicHouseEnTabletUrl.isNotEmpty,
                errorText: _strategicHouseEnTabletError,
                onUpload: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseEnTabletBytes = b;
                      _strategicHouseEnTabletIsSvg = true;
                      _strategicHouseEnTabletError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseEnTabletBytes != null || _strategicHouseEnTabletUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseEnTabletBytes = null;
                  _strategicHouseEnTabletUrl = '';
                  _strategicHouseEnTabletIsSvg = false;
                })
                    : null,
              ),
              SizedBox(height: 12.h),

              // Mobile upload
              _DeviceUploadRow(
                title: 'Mobile',
                hasImage: _strategicHouseEnMobileBytes != null || _strategicHouseEnMobileUrl.isNotEmpty,
                errorText: _strategicHouseEnMobileError,
                onUpload: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseEnMobileBytes = b;
                      _strategicHouseEnMobileIsSvg = true;
                      _strategicHouseEnMobileError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseEnMobileBytes != null || _strategicHouseEnMobileUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseEnMobileBytes = null;
                  _strategicHouseEnMobileUrl = '';
                  _strategicHouseEnMobileIsSvg = false;
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ARB (3 devices) ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ARB (Desktop, Tablet, Mobile)',
          isOpen: _strategicHouseArOpen,
          onToggle: () =>
              setState(() => _strategicHouseArOpen = !_strategicHouseArOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display preview selector
              Container(
                width: 300.w,
                child: _deviceDisplayTabBar(
                  selected: _strategicHouseArDisplayTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseArDisplayTab = tab),
                ),
              ),
              SizedBox(height: 16.h),

              // Current display preview
              _StrategicHouseDisplayWidget(
                displayTab: _strategicHouseArDisplayTab,
                desktopBytes: _strategicHouseArDesktopBytes,
                desktopUrl: _strategicHouseArDesktopUrl,
                desktopIsSvg: _strategicHouseArDesktopIsSvg,
                tabletBytes: _strategicHouseArTabletBytes,
                tabletUrl: _strategicHouseArTabletUrl,
                tabletIsSvg: _strategicHouseArTabletIsSvg,
                mobileBytes: _strategicHouseArMobileBytes,
                mobileUrl: _strategicHouseArMobileUrl,
                mobileIsSvg: _strategicHouseArMobileIsSvg,
                loadSvgBytes: _loadSvgBytes,
              ),
              SizedBox(height: 16.h),

              // Upload buttons for all 3 devices
              Text('Upload Images for Each Device:',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),

              // Desktop upload
              _DeviceUploadRow(
                title: 'Desktop',
                hasImage: _strategicHouseArDesktopBytes != null || _strategicHouseArDesktopUrl.isNotEmpty,
                errorText: _strategicHouseArDesktopError,
                onUpload: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseArDesktopBytes = b;
                      _strategicHouseArDesktopIsSvg = true;
                      _strategicHouseArDesktopError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseArDesktopBytes != null || _strategicHouseArDesktopUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseArDesktopBytes = null;
                  _strategicHouseArDesktopUrl = '';
                  _strategicHouseArDesktopIsSvg = false;
                })
                    : null,
              ),
              SizedBox(height: 12.h),

              // Tablet upload
              _DeviceUploadRow(
                title: 'Tablet',
                hasImage: _strategicHouseArTabletBytes != null || _strategicHouseArTabletUrl.isNotEmpty,
                errorText: _strategicHouseArTabletError,
                onUpload: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseArTabletBytes = b;
                      _strategicHouseArTabletIsSvg = true;
                      _strategicHouseArTabletError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseArTabletBytes != null || _strategicHouseArTabletUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseArTabletBytes = null;
                  _strategicHouseArTabletUrl = '';
                  _strategicHouseArTabletIsSvg = false;
                })
                    : null,
              ),
              SizedBox(height: 12.h),

              // Mobile upload
              _DeviceUploadRow(
                title: 'Mobile',
                hasImage: _strategicHouseArMobileBytes != null || _strategicHouseArMobileUrl.isNotEmpty,
                errorText: _strategicHouseArMobileError,
                onUpload: () async {
                  final b = await _pickSvgImage();
                  if (b != null) {
                    setState(() {
                      _strategicHouseArMobileBytes = b;
                      _strategicHouseArMobileIsSvg = true;
                      _strategicHouseArMobileError = null;
                    });
                  }
                },
                onRemove: (_strategicHouseArMobileBytes != null || _strategicHouseArMobileUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseArMobileBytes = null;
                  _strategicHouseArMobileUrl = '';
                  _strategicHouseArMobileIsSvg = false;
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
          color: const Color(0xFFD16F9A).withValues(alpha: .5),
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
              color: canPublish ? _kGreenSolid : _kGreenSolid.withValues(alpha: 0.35),
              onTap: () {
                if (!canPublish) {
                  setState(() => _submitted = true);
                  _showValidationError();
                  return;
                }

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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: _kGreenSolid,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: StyleText.fontSize14Weight500.copyWith(
                      color: Colors.white
                  )),
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: child,
        ),
    ]);
  }

  // ── Device Display Tab Bar ────────────────────────────────────────────────
  Widget _deviceDisplayTabBar({
    required DisplayDeviceTab selected,
    required ValueChanged<DisplayDeviceTab> onChanged,
  }) {
    Widget tab(String label, DisplayDeviceTab value) {
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
          tab('Desktop', DisplayDeviceTab.largeScreen),
          SizedBox(width: 4.w),
          tab('Tablet', DisplayDeviceTab.tablet),
          SizedBox(width: 4.w),
          tab('Mobile', DisplayDeviceTab.mobile),
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
            onChanged: (_) {},
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
            onChanged: (_) {},
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

/// Separate widget for Navigation Icon
