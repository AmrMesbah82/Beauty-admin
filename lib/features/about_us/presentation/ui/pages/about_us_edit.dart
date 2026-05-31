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
import 'package:beauty_admin/core/widgets/textfield.dart';

import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';
import 'about_us_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widgets/about_us_edit/value_item.dart';
part '../widgets/about_us_edit/validation.dart';
part '../widgets/about_us_edit/file_helpers.dart';
part '../widgets/about_us_edit/logic_helpers.dart';
part '../widgets/about_us_edit/form_sections.dart';
part '../widgets/about_us_edit/ui_helpers.dart';

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
    return !RegExp(r'[؀-ۿ]').hasMatch(text);
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
  bool get _isFormValid {
    if (!_isValidEn(_titleEnCtrl.text)) return false;
    if (!_isValidAr(_titleArCtrl.text)) return false;
    if (!_isValidEn(_navLabelTitleEnCtrl.text)) return false;
    if (!_isValidAr(_navLabelTitleArCtrl.text)) return false;
    if (!_isValidEn(_visionSubEnCtrl.text)) return false;
    if (!_isValidAr(_visionSubArCtrl.text)) return false;
    if (!_isValidEn(_visionDescEnCtrl.text)) return false;
    if (!_isValidAr(_visionDescArCtrl.text)) return false;
    if (!_isValidEn(_missionSubEnCtrl.text)) return false;
    if (!_isValidAr(_missionSubArCtrl.text)) return false;
    if (!_isValidEn(_missionDescEnCtrl.text)) return false;
    if (!_isValidAr(_missionDescArCtrl.text)) return false;
    for (final v in _valueItems) {
      if (!_isValidEn(v.titleEnCtrl.text)) return false;
      if (!_isValidAr(v.titleArCtrl.text)) return false;
      if (!_isValidEn(v.shortDescEnCtrl.text)) return false;
      if (!_isValidAr(v.shortDescArCtrl.text)) return false;
    }
    return true;
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
          child: AboutPreviewPage(
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
            context.read<AboutCubit>().load();
            Navigator.pop(context);
          }
        }
        if (state is AboutError) {
          setState(() => _isSaving = false);
        }
      },
      builder: (context, state) {
        final isLoading = state is AboutLoading || state is AboutInitial;
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
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: Colors.white),
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
}

// ── Value item helper class ────────────────────────────────────────────────────
