// ******************* FILE INFO *******************
// File Name: about_edit_page.dart
// Screen 2 — About Us CMS: Edit all sections
// UPDATED: ALL image uploads are SVG-only

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/core/custom_dialog.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../model/about_us/about_us.dart';
import 'about_preview_page.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<AboutCubit>().load();
    _setupChangeListeners();
  }

  void _setupChangeListeners() {
    _titleEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _titleArCtrl.addListener(() => setState(() => _hasChanges = true));
    _navLabelTitleEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _navLabelTitleArCtrl.addListener(() => setState(() => _hasChanges = true));
    _visionSubEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _visionSubArCtrl.addListener(() => setState(() => _hasChanges = true));
    _visionDescEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _visionDescArCtrl.addListener(() => setState(() => _hasChanges = true));
    _missionSubEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _missionSubArCtrl.addListener(() => setState(() => _hasChanges = true));
    _missionDescEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _missionDescArCtrl.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _navLabelTitleEnCtrl.dispose();
    _navLabelTitleArCtrl.dispose();
    _visionSubEnCtrl.dispose();
    _visionSubArCtrl.dispose();
    _visionDescEnCtrl.dispose();
    _visionDescArCtrl.dispose();
    _missionSubEnCtrl.dispose();
    _missionSubArCtrl.dispose();
    _missionDescEnCtrl.dispose();
    _missionDescArCtrl.dispose();
    for (final v in _valueItems) {
      v.titleEnCtrl.dispose();
      v.titleArCtrl.dispose();
      v.shortDescEnCtrl.dispose();
      v.shortDescArCtrl.dispose();
    }
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STRICT SVG-ONLY PICKER - Only allows SVG files (for ALL uploads)
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

      bool isValidSvg = fileName.endsWith('.svg') || fileType == 'image/svg+xml';

      if (!isValidSvg) {
        // _showErrorSnackBar('❌ SVG files only! "${file.name}" is not an SVG file.');
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
            bytes = result.asUint8List();
          } else if (result is Uint8List) {
            bytes = result;
          }

          if (bytes != null && !_isValidSvgContent(bytes)) {
            // _showErrorSnackBar('❌ Invalid SVG file format. Please upload a valid SVG file.');
            completer.complete(null);
            return;
          }

          completer.complete(bytes);
        }
      });
      reader.onError.listen((_) {
        // _showErrorSnackBar('❌ Error reading SVG file.');
        completer.complete(null);
      });
    });

    input.click();
    return completer.future;
  }

  bool _isValidSvgContent(Uint8List bytes) {
    if (bytes.length < 10) return false;
    try {
      final content = String.fromCharCodes(bytes.sublist(0, bytes.length.clamp(0, 200)));
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
        if (!_isValidSvgContent(bytes)) {
          throw Exception('Invalid SVG content');
        }
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

  // ── Validate fields ──────────────────────────────────────────────────────
  bool _validate() {
    setState(() => _submitted = true);

    if (_titleEnCtrl.text.trim().isEmpty) return false;
    if (_titleArCtrl.text.trim().isEmpty) return false;
    if (_visionSubEnCtrl.text.trim().isEmpty) return false;
    if (_visionSubArCtrl.text.trim().isEmpty) return false;
    if (_visionDescEnCtrl.text.trim().isEmpty) return false;
    if (_visionDescArCtrl.text.trim().isEmpty) return false;
    if (_missionSubEnCtrl.text.trim().isEmpty) return false;
    if (_missionSubArCtrl.text.trim().isEmpty) return false;
    if (_missionDescEnCtrl.text.trim().isEmpty) return false;
    if (_missionDescArCtrl.text.trim().isEmpty) return false;

    for (final v in _valueItems) {
      if (v.titleEnCtrl.text.trim().isEmpty) return false;
      if (v.titleArCtrl.text.trim().isEmpty) return false;
      if (v.shortDescEnCtrl.text.trim().isEmpty) return false;
      if (v.shortDescArCtrl.text.trim().isEmpty) return false;
    }

    return true;
  }

  bool _validateSilent() {
    if (_titleEnCtrl.text.trim().isEmpty) return false;
    if (_titleArCtrl.text.trim().isEmpty) return false;
    if (_visionSubEnCtrl.text.trim().isEmpty) return false;
    if (_visionSubArCtrl.text.trim().isEmpty) return false;
    if (_visionDescEnCtrl.text.trim().isEmpty) return false;
    if (_visionDescArCtrl.text.trim().isEmpty) return false;
    if (_missionSubEnCtrl.text.trim().isEmpty) return false;
    if (_missionSubArCtrl.text.trim().isEmpty) return false;
    if (_missionDescEnCtrl.text.trim().isEmpty) return false;
    if (_missionDescArCtrl.text.trim().isEmpty) return false;

    for (final v in _valueItems) {
      if (v.titleEnCtrl.text.trim().isEmpty) return false;
      if (v.titleArCtrl.text.trim().isEmpty) return false;
      if (v.shortDescEnCtrl.text.trim().isEmpty) return false;
      if (v.shortDescArCtrl.text.trim().isEmpty) return false;
    }

    return true;
  }

  // ── Preview ────────────────────────────────────────────────────────────────
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
          child: AboutPreviewPageLast(model: model, imageUploads: uploads),
        ),
      ),
    );
  }

  // ── Save / Publish ─────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_validate()) return;

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('About Us saved successfully!'),
              backgroundColor: _kGreenSolid,
            ),
          );
          if (mounted) {
            Navigator.pop(context);
          }
        }
        if (state is AboutError) {
          setState(() => _isSaving = false);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Error: ${state.message}'),
          //     backgroundColor: _kRed,
          //   ),
          // );
        }
      },
      builder: (context, state) {
        final isLoading = state is AboutLoading || state is AboutInitial;
        final bool isFormValid = _validateSilent();
        final bool canPublish = isFormValid && _hasChanges && !_isSaving;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F2ED),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
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
              final b = await _pickSvgFile(); // CHANGED: SVG only
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
              final b = await _pickSvgFile(); // CHANGED: SVG only
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _kGreenSolid,
              borderRadius: isOpen
                  ? BorderRadius.vertical(top: Radius.circular(12.r))
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
            padding: EdgeInsets.symmetric(vertical: 16.h),
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
          label: 'Image',
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
          label: 'Image', // CHANGED: label
          bytes: _navLabelIconBytes,
          url: _navLabelIconUrl,
          onTap: () async {
            final b = await _pickSvgFile(); // CHANGED: SVG only
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
              label: 'Image', // CHANGED: label
              bytes: iconBytes,
              url: iconUrl,
              onTap: onPickIcon,
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'Image',
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
          maxLength: 200,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),

        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          fillColor: Colors.white,
          controller: subArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 200,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),

        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: descEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 800,
          showCharCount: true,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() => _hasChanges = true),
        ),

        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 100,
          fillColor: Colors.white,
          maxLines: 4,
          maxLength: 800,
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
                  'Point',
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
    final String itemLabel = isMain ? 'Main Image' : 'Image'; // CHANGED: label

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
                  final b = await _pickSvgFile(); // CHANGED: SVG only
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
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _fieldLabel('Title'),
          SizedBox(height: 8.h),
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
            maxLength: 200,
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
            maxLength: 200,
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
            Expanded(
              child: _btn(
                label: 'Preview',
                color: const Color(0xFFD16F9A).withOpacity(0.5),
                onTap: _onPreview,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label: 'Publish',
                color: canPublish ? _kGreenSolid : _kGreenSolid.withOpacity(0.5),
                onTap: canPublish
                    ? () {
                  if (!_validate()) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //       'Please fill in all required fields before publishing.',
                    //       style: StyleText.fontSize14Weight400
                    //           .copyWith(color: Colors.white),
                    //     ),
                    //     backgroundColor: Colors.red,
                    //     behavior: SnackBarBehavior.floating,
                    //   ),
                    // );
                    return;
                  }
                  showPublishConfirmDialog(
                    context: context,
                    onConfirm: () => _save('published'),
                  );
                }
                    : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: const Color(0xFF797979),
                onTap: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 15.sp),
            Expanded(child: Container())
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
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
                decoration: BoxDecoration(
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
    bool _isSvgBytes(Uint8List b) {
      if (b.length < 10) return false;
      try {
        final header = String.fromCharCodes(
          b.sublist(0, b.length.clamp(0, 200)),
        ).trimLeft();
        return header.startsWith('<svg') ||
            (header.startsWith('<?xml') && header.contains('<svg'));
      } catch (e) {
        return false;
      }
    }

    Widget _renderBytes(Uint8List b) {
      return Padding(
        padding: EdgeInsets.all(16.r),
        child: SvgPicture.memory(b, fit: BoxFit.contain),
      );
    }

    final Widget spinner = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: _kGreenSolid),
    );

    if (bytes != null) {
      return _renderBytes(bytes);
    }

    if (url.isNotEmpty) {
      return FutureBuilder<Uint8List>(
        future: _cachedLoad(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinner);
          }
          if (snapshot.hasData) {
            return _renderBytes(snapshot.data!);
          }
          return Icon(
            Icons.broken_image,
            color: Colors.red[300],
            size: 28.sp,
          );
        },
      );
    }

    return Icon(
      Icons.image_outlined,
      color: Colors.grey[500],
      size: 28.sp,
    );
  }

  // ── Shared form helpers ────────────────────────────────────────────────────
  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
    int maxLength = 200,
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
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
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
          borderRadius: BorderRadius.circular(10.r),
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
class _ValueItem {
  final String id;
  final int counter;
  final titleEnCtrl = TextEditingController();
  final titleArCtrl = TextEditingController();
  final shortDescEnCtrl = TextEditingController();
  final shortDescArCtrl = TextEditingController();
  Uint8List? iconBytes;
  String iconUrl = '';

  _ValueItem({required this.id, required this.counter});
}