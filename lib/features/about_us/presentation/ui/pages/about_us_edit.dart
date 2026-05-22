// ******************* FILE INFO *******************
// File Name: about_us_edit.dart
// Screen 2 — About Us CMS: Edit all sections
// UPDATED:
//   - ALL image uploads are SVG-only
//   - Publish button disabled until ALL required fields pass validation
//     (same pattern as overview_edit.dart)
//   - _isFormValid getter for silent validation
//   - _getMissingFields() for error dialog
//   - No "Save For Later" logic (not needed for About Us)

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beauty_admin/core/custom_dialog.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/textfield.dart';

import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/model/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';
import 'about_us_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widget/about_us_edit/value_item.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

const Color _kGreen = Color(0xFFD16F9A);
const Color _kGreenSolid = Color(0xFFD16F9A);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kRed = Color(0xFFD32F2F);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBg = Color(0xFFF2F2F2);

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class AboutEditPageMaster extends StatefulWidget {
  const AboutEditPageMaster({super.key});

  @override
  State<AboutEditPageMaster> createState() => _AboutEditPageMasterState();
}

class _AboutEditPageMasterState extends State<AboutEditPageMaster> {
  bool _submitted = false;
  bool _hasChanges = false;
  bool _seeded = false;
  bool _isSaving = false;
  int? _seededModelHash;

  // ── Headings ──
  final _titleEnCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  Uint8List? _headingsSvgBytes;
  String _headingsSvgUrl = '';

  // ── Navigation Label ──
  final _navLabelTitleEnCtrl = TextEditingController();
  final _navLabelTitleArCtrl = TextEditingController();
  Uint8List? _navLabelIconBytes;
  String _navLabelIconUrl = '';

  // ── Vision ──
  final _visionSubEnCtrl = TextEditingController();
  final _visionSubArCtrl = TextEditingController();
  final _visionDescEnCtrl = TextEditingController();
  final _visionDescArCtrl = TextEditingController();
  Uint8List? _visionIconBytes;
  Uint8List? _visionSvgBytes;
  String _visionIconUrl = '';
  String _visionSvgUrl = '';

  // ── Mission ──
  final _missionSubEnCtrl = TextEditingController();
  final _missionSubArCtrl = TextEditingController();
  final _missionDescEnCtrl = TextEditingController();
  final _missionDescArCtrl = TextEditingController();
  Uint8List? _missionIconBytes;
  Uint8List? _missionSvgBytes;
  String _missionIconUrl = '';
  String _missionSvgUrl = '';

  // ── Values ──
  final List<_ValueItem> _valueItems = [];
  int _valueCounter = 0;

  // ── Accordion open/close ──
  bool _headingsOpen = true;
  bool _navLabelOpen = true;
  bool _visionOpen = true;
  bool _missionOpen = true;
  bool _valuesOpen = true;

  // ── URL → bytes cache ──
  final Map<String, Future<Uint8List>> _urlBytesCache = {};

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// EN field: non-empty AND no Arabic characters
  bool _isValidEn(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// AR field: non-empty AND no English letters
  bool _isValidAr(String text) {
    if (text.trim().isEmpty) return false;
    return !RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Silent validation — used to gate the Publish button.
  /// Checks BOTH emptiness AND language mixing (same rules as the text field widget).
  bool get _isFormValid {
    // Headings
    if (!_isValidEn(_titleEnCtrl.text)) return false;
    if (!_isValidAr(_titleArCtrl.text)) return false;
    // Nav label
    if (!_isValidEn(_navLabelTitleEnCtrl.text)) return false;
    if (!_isValidAr(_navLabelTitleArCtrl.text)) return false;
    // Vision
    if (!_isValidEn(_visionSubEnCtrl.text)) return false;
    if (!_isValidAr(_visionSubArCtrl.text)) return false;
    if (!_isValidEn(_visionDescEnCtrl.text)) return false;
    if (!_isValidAr(_visionDescArCtrl.text)) return false;
    // Mission
    if (!_isValidEn(_missionSubEnCtrl.text)) return false;
    if (!_isValidAr(_missionSubArCtrl.text)) return false;
    if (!_isValidEn(_missionDescEnCtrl.text)) return false;
    if (!_isValidAr(_missionDescArCtrl.text)) return false;
    // Values
    for (final v in _valueItems) {
      if (!_isValidEn(v.titleEnCtrl.text)) return false;
      if (!_isValidAr(v.titleArCtrl.text)) return false;
      if (!_isValidEn(v.shortDescEnCtrl.text)) return false;
      if (!_isValidAr(v.shortDescArCtrl.text)) return false;
    }
    return true;
  }

  /// Returns a list of human-readable missing/invalid field names.
  List<String> _getMissingFields() {
    final missing = <String>[];

    void checkEn(String text, String label) {
      if (text.trim().isEmpty) {
        missing.add('$label — required');
      } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
        missing.add('$label — English characters only');
      }
    }

    void checkAr(String text, String label) {
      if (text.trim().isEmpty) {
        missing.add('$label — required');
      } else if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
        missing.add('$label — Arabic characters only');
      }
    }

    checkEn(_titleEnCtrl.text, 'Heading Title (EN)');
    checkAr(_titleArCtrl.text, 'Heading Title (AR)');
    checkEn(_navLabelTitleEnCtrl.text, 'Navigation Label Title (EN)');
    checkAr(_navLabelTitleArCtrl.text, 'Navigation Label Title (AR)');
    checkEn(_visionSubEnCtrl.text, 'Vision Sub Description (EN)');
    checkAr(_visionSubArCtrl.text, 'Vision Sub Description (AR)');
    checkEn(_visionDescEnCtrl.text, 'Vision Description (EN)');
    checkAr(_visionDescArCtrl.text, 'Vision Description (AR)');
    checkEn(_missionSubEnCtrl.text, 'Mission Sub Description (EN)');
    checkAr(_missionSubArCtrl.text, 'Mission Sub Description (AR)');
    checkEn(_missionDescEnCtrl.text, 'Mission Description (EN)');
    checkAr(_missionDescArCtrl.text, 'Mission Description (AR)');

    for (var i = 0; i < _valueItems.length; i++) {
      final v = _valueItems[i];
      checkEn(v.titleEnCtrl.text,       'Value ${i + 1} Title (EN)');
      checkAr(v.titleArCtrl.text,       'Value ${i + 1} Title (AR)');
      checkEn(v.shortDescEnCtrl.text,   'Value ${i + 1} Short Description (EN)');
      checkAr(v.shortDescArCtrl.text,   'Value ${i + 1} Short Description (AR)');
    }

    return missing;
  }

  void _showValidationError() {
    final missing = _getMissingFields();
    if (missing.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: _kRed, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Validation Error',
              style: StyleText.fontSize14Weight600.copyWith(color: Colors.black87),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please fill all required fields:',
              style: StyleText.fontSize12Weight400.copyWith(color: Colors.black54),
            ),
            SizedBox(height: 12.h),
            ...missing.map(
                  (field) => Padding(
                padding: EdgeInsets.only(left: 8.w, top: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: _kRed)),
                    Expanded(
                      child: Text(
                        field,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: StyleText.fontSize13Weight500.copyWith(color: _kGreenSolid),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<AboutCubit>().load();
    _setupChangeListeners();
  }

  void _setupChangeListeners() {
    for (final ctrl in _allTextControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _hasChanges = true);
      });
    }
  }

  List<TextEditingController> get _allTextControllers => [
    _titleEnCtrl,
    _titleArCtrl,
    _navLabelTitleEnCtrl,
    _navLabelTitleArCtrl,
    _visionSubEnCtrl,
    _visionSubArCtrl,
    _visionDescEnCtrl,
    _visionDescArCtrl,
    _missionSubEnCtrl,
    _missionSubArCtrl,
    _missionDescEnCtrl,
    _missionDescArCtrl,
  ];

  @override
  void dispose() {
    for (final ctrl in _allTextControllers) {
      ctrl.removeListener(_onFieldChanged);
      ctrl.dispose();
    }
    for (final v in _valueItems) {
      v.titleEnCtrl.dispose();
      v.titleArCtrl.dispose();
      v.shortDescEnCtrl.dispose();
      v.shortDescArCtrl.dispose();
    }
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STRICT SVG-ONLY PICKER
  // ══════════════════════════════════════════════════════════════════════════

  Future<Uint8List?> _pickSvgFile() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      final fileName = file.name.toLowerCase();
      final fileType = file.type.toLowerCase();

      final isValidSvg =
          fileName.endsWith('.svg') || fileType == 'image/svg+xml';

      if (!isValidSvg) {
        completer.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          Uint8List? bytes;
          if (result is ByteBuffer) {
            bytes = Uint8List.view(result);
          } else if (result is Uint8List) {
            bytes = result;
          } else if (result is List<int>) {
            bytes = Uint8List.fromList(result);
          }

          if (bytes != null && !_isValidSvgContent(bytes)) {
            completer.complete(null);
            return;
          }

          completer.complete(bytes);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });

    input.click();
    return completer.future;
  }

  bool _isValidSvgContent(Uint8List bytes) {
    if (bytes.length < 10) return false;
    try {
      final content = String.fromCharCodes(
          bytes.sublist(0, bytes.length.clamp(0, 500)));
      final trimmed = content.trimLeft();
      return trimmed.startsWith('<svg') ||
          trimmed.startsWith('<?xml') && trimmed.contains('<svg');
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // URL loaders
  // ══════════════════════════════════════════════════════════════════════════

  Future<Uint8List> _cachedLoad(String url) {
    return _urlBytesCache.putIfAbsent(url, () => _loadSvg(url));
  }

  Future<Uint8List> _loadSvg(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: 'image/svg+xml',
      );
      if (response.status == 200 && response.response != null) {
        final bytes = (response.response as ByteBuffer).asUint8List();
        if (!_isValidSvgContent(bytes)) throw Exception('Invalid SVG content');
        return bytes;
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  // ── Seed from loaded model ─────────────────────────────────────────────────
  void _seedFromModel(AboutPageModel m) {
    final modelHash = Object.hashAll([
      m.title.en,
      m.title.ar,
      m.svgUrl,
      m.navigationLabel.iconUrl,
      m.navigationLabel.title.en,
      m.navigationLabel.title.ar,
      m.vision.iconUrl,
      m.vision.svgUrl,
      m.vision.subDescription.en,
      m.vision.subDescription.ar,
      m.vision.description.en,
      m.vision.description.ar,
      m.mission.iconUrl,
      m.mission.svgUrl,
      m.mission.subDescription.en,
      m.mission.subDescription.ar,
      m.mission.description.en,
      m.mission.description.ar,
      m.values.length,
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    // Remove listeners while seeding to avoid spurious _hasChanges flips
    for (final ctrl in _allTextControllers) {
      ctrl.removeListener(_onFieldChanged);
    }

    _titleEnCtrl.text = m.title.en;
    _titleArCtrl.text = m.title.ar;
    _headingsSvgUrl = m.svgUrl;

    _navLabelIconUrl = m.navigationLabel.iconUrl;
    _navLabelTitleEnCtrl.text = m.navigationLabel.title.en;
    _navLabelTitleArCtrl.text = m.navigationLabel.title.ar;

    _visionSubEnCtrl.text = m.vision.subDescription.en;
    _visionSubArCtrl.text = m.vision.subDescription.ar;
    _visionDescEnCtrl.text = m.vision.description.en;
    _visionDescArCtrl.text = m.vision.description.ar;
    _visionIconUrl = m.vision.iconUrl;
    _visionSvgUrl = m.vision.svgUrl;

    _missionSubEnCtrl.text = m.mission.subDescription.en;
    _missionSubArCtrl.text = m.mission.subDescription.ar;
    _missionDescEnCtrl.text = m.mission.description.en;
    _missionDescArCtrl.text = m.mission.description.ar;
    _missionIconUrl = m.mission.iconUrl;
    _missionSvgUrl = m.mission.svgUrl;

    _valueItems.clear();
    for (final v in m.values) {
      final item = _ValueItem(id: v.id, counter: ++_valueCounter);
      item.titleEnCtrl.text = v.title.en;
      item.titleArCtrl.text = v.title.ar;
      item.shortDescEnCtrl.text = v.shortDescription.en;
      item.shortDescArCtrl.text = v.shortDescription.ar;
      item.iconUrl = v.iconUrl;
      _valueItems.add(item);
    }

    _hasChanges = false;
    _seeded = true;

    // Re-attach listeners
    for (final ctrl in _allTextControllers) {
      ctrl.addListener(_onFieldChanged);
    }
  }

  // ── Build model from current state ────────────────────────────────────────
  AboutPageModel _buildModel(String status) {
    return AboutPageModel(
      publishStatus: status,
      title: AboutBilingualText(
        en: _titleEnCtrl.text.trim(),
        ar: _titleArCtrl.text.trim(),
      ),
      svgUrl: _headingsSvgUrl,
      navigationLabel: AboutNavigationLabel(
        iconUrl: _navLabelIconUrl,
        title: AboutBilingualText(
          en: _navLabelTitleEnCtrl.text.trim(),
          ar: _navLabelTitleArCtrl.text.trim(),
        ),
      ),
      vision: AboutSection(
        iconUrl: _visionIconUrl,
        svgUrl: _visionSvgUrl,
        subDescription: AboutBilingualText(
          en: _visionSubEnCtrl.text.trim(),
          ar: _visionSubArCtrl.text.trim(),
        ),
        description: AboutBilingualText(
          en: _visionDescEnCtrl.text.trim(),
          ar: _visionDescArCtrl.text.trim(),
        ),
      ),
      mission: AboutSection(
        iconUrl: _missionIconUrl,
        svgUrl: _missionSvgUrl,
        subDescription: AboutBilingualText(
          en: _missionSubEnCtrl.text.trim(),
          ar: _missionSubArCtrl.text.trim(),
        ),
        description: AboutBilingualText(
          en: _missionDescEnCtrl.text.trim(),
          ar: _missionDescArCtrl.text.trim(),
        ),
      ),
      values: _valueItems
          .map(
            (v) => AboutValueItem(
          id: v.id,
          iconUrl: v.iconUrl,
          title: AboutBilingualText(
            en: v.titleEnCtrl.text.trim(),
            ar: v.titleArCtrl.text.trim(),
          ),
          shortDescription: AboutBilingualText(
            en: v.shortDescEnCtrl.text.trim(),
            ar: v.shortDescArCtrl.text.trim(),
          ),
        ),
      )
          .toList(),
    );
  }

  // ── Collect SVG uploads ──────────────────────────────────────────────────
  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};

    if (_headingsSvgBytes != null)
      uploads['about_cms/headings/svg'] = _headingsSvgBytes!;
    if (_navLabelIconBytes != null)
      uploads['about_cms/navLabel/icon'] = _navLabelIconBytes!;
    if (_visionIconBytes != null)
      uploads['about_cms/vision/icon'] = _visionIconBytes!;
    if (_visionSvgBytes != null)
      uploads['about_cms/vision/svg'] = _visionSvgBytes!;
    if (_missionIconBytes != null)
      uploads['about_cms/mission/icon'] = _missionIconBytes!;
    if (_missionSvgBytes != null)
      uploads['about_cms/mission/svg'] = _missionSvgBytes!;
    for (final v in _valueItems) {
      if (v.iconBytes != null)
        uploads['about_cms/values/${v.id}/icon'] = v.iconBytes!;
    }
    return uploads;
  }

  // ── Validate (with UI feedback) ──────────────────────────────────────────
  bool _validate() {
    setState(() => _submitted = true);
    return _isFormValid;
  }

  void _onPreview() {
    if (!_validate()) return;
    final model = _buildModel('draft');
    final uploads = _collectUploads();
    final cubit = context.read<AboutCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AboutPreviewPage(  // Change from AboutPreviewPageLast to AboutPreviewPage
            previewModel: model,
            onPublish: () => _save('published'),
          ),
        ),
      ),
    );
  }

  // ── Save / Publish ─────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_isFormValid) return;

    setState(() => _isSaving = true);
    final model = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<AboutCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Add / remove value item ────────────────────────────────────────────────
  void _addValueItem() {
    setState(() {
      _valueItems.add(
        _ValueItem(
          id: 'val_${DateTime.now().millisecondsSinceEpoch}',
          counter: ++_valueCounter,
        ),
      );
      _hasChanges = true;
    });
  }

  void _removeValueItem(String id) {
    setState(() {
      _valueItems.removeWhere((v) => v.id == id);
      _hasChanges = true;
    });
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AboutCubit, AboutState>(
      listener: (context, state) {
        if (state is AboutLoaded) _seedFromModel(state.data);
        if (state is AboutSaved) {
          setState(() => _isSaving = false);
          if (mounted) {
            context.read<AboutCubit>().load(); // ← reload before popping
            Navigator.pop(context);
          }
        }
        if (state is AboutError) {
          setState(() => _isSaving = false);
        }
      },
      builder: (context, state) {
        final isLoading = state is AboutLoading || state is AboutInitial;

        // Gate: form must be valid AND there must be changes AND not currently saving
        final bool canPublish = _isFormValid && _hasChanges && !_isSaving;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F2ED),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      AppAdminNavbar(
                        activeLabel: 'Web Page',
                        homePage: HomeMainPage(),
                        webPage: HomeMainPage(),
                        jobListingPage: HomeMainPage(),
                      ),
                      SizedBox(height: 20.h),
                      AdminSubNavBar(activeIndex: 5),
                      SizedBox(
                        width: 1000.w,
                        child: isLoading
                            ? const Center(
                          child: CircularProgressIndicator(
                            color: _kGreenSolid,
                          ),
                        )
                            : _buildForm(canPublish),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSaving) _buildSavingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Form ───────────────────────────────────────────────────────────────────
  Widget _buildForm(bool canPublish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Text(
          'Editing About Us',
          style: StyleText.fontSize45Weight600.copyWith(
            color: _kGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title: 'Headings',
          isOpen: _headingsOpen,
          onToggle: () => setState(() => _headingsOpen = !_headingsOpen),
          child: _headingsSection(),
        ),

        _accordion(
          title: 'Navigation Label',
          isOpen: _navLabelOpen,
          onToggle: () => setState(() => _navLabelOpen = !_navLabelOpen),
          child: _navigationLabelSection(),
        ),

        _accordion(
          title: 'Vision',
          isOpen: _visionOpen,
          onToggle: () => setState(() => _visionOpen = !_visionOpen),
          child: _sectionEditor(
            iconBytes: _visionIconBytes,
            svgBytes: _visionSvgBytes,
            iconUrl: _visionIconUrl,
            svgUrl: _visionSvgUrl,
            onPickIcon: () async {
              final b = await _pickSvgFile();
              if (b != null) {
                setState(() => _visionIconBytes = b);
                _hasChanges = true;
              }
            },
            onPickSvg: () async {
              final b = await _pickSvgFile();
              if (b != null) {
                setState(() => _visionSvgBytes = b);
                _hasChanges = true;
              }
            },
            subEnCtrl: _visionSubEnCtrl,
            subArCtrl: _visionSubArCtrl,
            descEnCtrl: _visionDescEnCtrl,
            descArCtrl: _visionDescArCtrl,
          ),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Mission',
          isOpen: _missionOpen,
          onToggle: () => setState(() => _missionOpen = !_missionOpen),
          child: _sectionEditor(
            iconBytes: _missionIconBytes,
            svgBytes: _missionSvgBytes,
            iconUrl: _missionIconUrl,
            svgUrl: _missionSvgUrl,
            onPickIcon: () async {
              final b = await _pickSvgFile();
              if (b != null) {
                setState(() => _missionIconBytes = b);
                _hasChanges = true;
              }
            },
            onPickSvg: () async {
              final b = await _pickSvgFile();
              if (b != null) {
                setState(() => _missionSvgBytes = b);
                _hasChanges = true;
              }
            },
            subEnCtrl: _missionSubEnCtrl,
            subArCtrl: _missionSubArCtrl,
            descEnCtrl: _missionDescEnCtrl,
            descArCtrl: _missionDescArCtrl,
          ),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Values',
          isOpen: _valuesOpen,
          onToggle: () => setState(() => _valuesOpen = !_valuesOpen),
          child: _valuesSection(),
        ),
        SizedBox(height: 32.h),

        _actionButtons(canPublish),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _kGreenSolid,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: Colors.white
                  )
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12.r),
              ),
            ),
            child: child,
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Headings section
  // ══════════════════════════════════════════════════════════════════════════

  Widget _headingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageUploadCircle(
          label: 'Icon',
          bytes: _headingsSvgBytes,
          url: _headingsSvgUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) {
              setState(() => _headingsSvgBytes = b);
              _hasChanges = true;
            }
          },
        ),
        SizedBox(height: 20.h),

        _fieldLabel('Title'),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _titleEnCtrl,
          arCtrl: _titleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Navigation Label section
  // ══════════════════════════════════════════════════════════════════════════

  Widget _navigationLabelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageUploadCircle(
          label: 'Icon',
          bytes: _navLabelIconBytes,
          url: _navLabelIconUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) {
              setState(() => _navLabelIconBytes = b);
              _hasChanges = true;
            }
          },
        ),
        SizedBox(height: 20.h),

        _fieldLabel('Title'),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _navLabelTitleEnCtrl,
          arCtrl: _navLabelTitleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ── Vision / Mission section editor ───────────────────────────────────────
  Widget _sectionEditor({
    required Uint8List? iconBytes,
    required Uint8List? svgBytes,
    required String iconUrl,
    required String svgUrl,
    required VoidCallback onPickIcon,
    required VoidCallback onPickSvg,
    required TextEditingController subEnCtrl,
    required TextEditingController subArCtrl,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _imageUploadCircle(
              label: 'Icon',
              bytes: iconBytes,
              url: iconUrl,
              onTap: onPickIcon,
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'Icon',
              bytes: svgBytes,
              url: svgUrl,
              onTap: onPickSvg,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: subEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
        SizedBox(height: 10.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          fillColor: Colors.white,
          controller: subArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
        SizedBox(height: 10.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: descEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
        SizedBox(height: 10.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 100,
          fillColor: Colors.white,
          maxLines: 4,
          maxLength: 500,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALUES SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _valuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_valueItems.length, (index) {
          final v = _valueItems[index];
          final bool isMain = index == 0;
          return _valueItemWidget(v, isMain: isMain);
        }),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addValueItem,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Value',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueItemWidget(_ValueItem v, {required bool isMain}) {
    final String itemLabel = isMain ? 'Main Icon' : 'Icon';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: itemLabel,
                bytes: v.iconBytes,
                url: v.iconUrl,
                onTap: () async {
                  final b = await _pickSvgFile();
                  if (b != null) {
                    setState(() => v.iconBytes = b);
                    _hasChanges = true;
                  }
                },
              ),
              GestureDetector(
                onTap: () => _removeValueItem(v.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: StyleText.fontSize12Weight400.copyWith(color: Colors.white)
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // _fieldLabel('Title'),
          // SizedBox(height: 8.h),
          _bilingualRow(
            enCtrl: v.titleEnCtrl,
            arCtrl: v.titleArCtrl,
            enHint: 'Text Here',
            arHint: 'أدخل النص هنا',
          ),

          _fieldLabel('Short Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: v.shortDescEnCtrl,
            height: 100,
            fillColor: Colors.white,
            maxLines: 4,
            maxLength: 500,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
          SizedBox(height: 8.h),
          _fieldLabelAr('وصف مختصر'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: v.shortDescArCtrl,
            fillColor: Colors.white,
            height: 100,
            maxLines: 4,
            maxLength: 500,
            showCharCount: true,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons(bool canPublish) {
    return Column(
      children: [
        Row(
          children: [
            // ── Preview ──────────────────────────────────────────────────
            Expanded(
              child: _btn(
                label: 'Preview',
                color: const Color(0xFF8A5C70),
                onTap: _onPreview,
              ),
            ),
            SizedBox(width: 300.w),

            // ── Publish ───────────────────────────────────────────────────
            Expanded(
              child: AbsorbPointer(
                absorbing: !canPublish,
                child: Opacity(
                  opacity: canPublish ? 1.0 : 0.5,
                  child: _btn(
                    label: 'Publish',
                    color: _kGreenSolid,
                    onTap: () {
                      if (!canPublish) {
                        setState(() => _submitted = true);
                        _showValidationError();
                        return;
                      }
                      showPublishConfirmDialog(
                        title: 'EDITING ABOUT US DETAILS',
                        subtitle:
                        'Do you want to save the changes made to this ABOUT US?',
                        context: context,
                        onConfirm: () => _save('published'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── Discard ───────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: const Color(0xFF797979),
                onTap: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ── Saving overlay ─────────────────────────────────────────────────────────
  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 180.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _kGreenSolid),
              SizedBox(height: 12.h),
              Text(
                'Saving...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Shared image helpers
  // ══════════════════════════════════════════════════════════════════════════

  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize16Weight400.copyWith(
            color: AppColors.text
          )
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url))
                    : Icon(
                  Icons.add,
                  color: Colors.grey[600],
                  size: 28.sp,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 25.w,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD16F9A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: CustomSvg(
                        assetPath: "assets/control/camera.svg",
                        width: 10.w,
                        height: 10.h,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(Uint8List? bytes, String url) {
    if (bytes != null) {
      final dataUrl = _svgBytesToDataUrl(bytes);
      final viewId = 'svg-about-bytes-${bytes.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return SizedBox(
        width: 64.w,
        height: 64.h,
        child: HtmlElementView(viewType: viewId),
      );
    }

    if (url.isNotEmpty) {
      final viewId = 'svg-about-url-${url.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return SizedBox(
        width: 64.w,
        height: 64.h,
        child: HtmlElementView(viewType: viewId),
      );
    }

    return Icon(Icons.image_outlined, color: Colors.grey[500], size: 28.sp);
  }

  // ── Shared form helpers ────────────────────────────────────────────────────
  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
    int maxLength = 500,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint,
            controller: enCtrl,
            fillColor: Colors.white,
            height: 42,
            maxLines: 1,
            maxLength: maxLength,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() => _hasChanges = true),
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
            maxLength: maxLength,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
      style: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.text
      )
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: StyleText.fontSize14Weight600.copyWith(
        color: AppColors.text
      )
    ),
  );

  Widget _btn({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Value item helper class ────────────────────────────────────────────────────
