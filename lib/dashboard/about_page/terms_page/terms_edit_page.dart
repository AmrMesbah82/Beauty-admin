// ******************* FILE INFO *******************
// File Name: terms_edit_page.dart
// Screen 2 of 3 — Terms of Service CMS: Edit page
// FIX: _validate() now only checks visible fields (nav label section is commented out)
// UPDATE: Publish button disabled when: no changes / missing fields+SVGs / text errors

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../../core/widget/circle_progress.dart';
import '../../../model/about_us/about_us.dart';
import '../../../widgets/app_admin_navbar.dart';
import '../../main_page/home_main_page.dart';
import 'terms_preview_page.dart';

const Color _kGreen = Color(0xFFD16F9A);
const Color _kGreenSolid = Color(0xFFD16F9A);
const Color _kRed = Color(0xFFD32F2F);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBg = Color(0xFFF2F2F2);

// ── Local UI-only holder (never leaves this file) ─────────────────────────────
class _DocItem {
  Uint8List? bytes;
  String fileName;
  String existingUrl;

  _DocItem({this.bytes, this.fileName = '', this.existingUrl = ''});

  bool get hasFile => bytes != null || existingUrl.isNotEmpty;
  String get displayName =>
      bytes != null ? fileName : existingUrl.split('/').last.split('?').first;
}

// ═══════════════════════════════════════════════════════════════════════════════

class TermsEditPage extends StatefulWidget {
  const TermsEditPage({super.key});

  @override
  State<TermsEditPage> createState() => _TermsEditPageState();
}

class _TermsEditPageState extends State<TermsEditPage> {
  // Navigation Label
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  Uint8List? _navIconBytes;
  String _navIconUrl = '';

  // Terms and Conditions
  final _termsDescEnCtrl = TextEditingController();
  final _termsDescArCtrl = TextEditingController();
  Uint8List? _termsSvgBytes;
  String _termsSvgUrl = '';
  final _termsDocEn = _DocItem();
  final _termsDocAr = _DocItem();

  // Privacy Policy
  final _privacyDescEnCtrl = TextEditingController();
  final _privacyDescArCtrl = TextEditingController();
  Uint8List? _privacySvgBytes;
  String _privacySvgUrl = '';
  final _privacyDocEn = _DocItem();
  final _privacyDocAr = _DocItem();

  bool _navLabelOpen = true;
  bool _termsOpen = true;
  bool _privacyOpen = true;
  bool _submitted = false;

  // ── Snapshot of original seeded values (for dirty-check) ──────────────────
  String _origTermsDescEn = '';
  String _origTermsDescAr = '';
  String _origTermsSvgUrl = '';
  String _origTermsDocEnUrl = '';
  String _origTermsDocArUrl = '';

  String _origPrivacyDescEn = '';
  String _origPrivacyDescAr = '';
  String _origPrivacySvgUrl = '';
  String _origPrivacyDocEnUrl = '';
  String _origPrivacyDocArUrl = '';

  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    context.read<TermsCubit>().load();
  }

  @override
  void dispose() {
    _navTitleEnCtrl.dispose();
    _navTitleArCtrl.dispose();
    _termsDescEnCtrl.dispose();
    _termsDescArCtrl.dispose();
    _privacyDescEnCtrl.dispose();
    _privacyDescArCtrl.dispose();
    super.dispose();
  }

  // ── File pickers ──────────────────────────────────────────────────────────
  Future<Uint8List?> _pickImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }
      final reader = html.FileReader()..readAsArrayBuffer(files.first);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (r is ByteBuffer)
          c.complete(r.asUint8List());
        else if (r is Uint8List)
          c.complete(r);
        else
          c.complete(null);
      });
      reader.onError.listen((_) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  Future<Uint8List?> _pickSvg() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement();
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ SVG files only! Selected: ${file.name}'),
            backgroundColor: _kRed,
          ),
        );
        c.complete(null);
        return;
      }
      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        if (r is ByteBuffer)
          c.complete(r.asUint8List());
        else if (r is Uint8List)
          c.complete(r);
        else
          c.complete(null);
      });
      reader.onError.listen((_) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  Future<void> _pickDoc(_DocItem docItem) async {
    final c = Completer<void>();
    final input = html.FileUploadInputElement()..accept = '.pdf,.doc,.docx';
    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete();
        return;
      }
      final file = files.first;
      final reader = html.FileReader()..readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer)
          bytes = r.asUint8List();
        else if (r is Uint8List)
          bytes = r;
        if (bytes != null) {
          setState(() {
            docItem.bytes = bytes;
            docItem.fileName = file.name;
          });
        }
        c.complete();
      });
      reader.onError.listen((_) => c.complete());
    });
    input.click();
    return c.future;
  }

  // ── Seed ─────────────────────────────────────────────────────────────────
  void _seed(TermsOfServiceModel m) {
    setState(() {
      _navTitleEnCtrl.text = m.navigationLabel.title.en;
      _navTitleArCtrl.text = m.navigationLabel.title.ar;
      _navIconUrl = m.navigationLabel.iconUrl;
      _navIconBytes = null;

      _termsSvgUrl = m.termsAndConditions.svgUrl;
      _termsSvgBytes = null;
      _termsDescEnCtrl.text = m.termsAndConditions.description.en;
      _termsDescArCtrl.text = m.termsAndConditions.description.ar;
      _termsDocEn.bytes = null;
      _termsDocEn.fileName = '';
      _termsDocEn.existingUrl = m.termsAndConditions.attachEnUrl;
      _termsDocAr.bytes = null;
      _termsDocAr.fileName = '';
      _termsDocAr.existingUrl = m.termsAndConditions.attachArUrl;

      _privacySvgUrl = m.privacyPolicy.svgUrl;
      _privacySvgBytes = null;
      _privacyDescEnCtrl.text = m.privacyPolicy.description.en;
      _privacyDescArCtrl.text = m.privacyPolicy.description.ar;
      _privacyDocEn.bytes = null;
      _privacyDocEn.fileName = '';
      _privacyDocEn.existingUrl = m.privacyPolicy.attachEnUrl;
      _privacyDocAr.bytes = null;
      _privacyDocAr.fileName = '';
      _privacyDocAr.existingUrl = m.privacyPolicy.attachArUrl;

      // ── Snapshot original values ──────────────────────────────────────
      _origTermsDescEn = m.termsAndConditions.description.en;
      _origTermsDescAr = m.termsAndConditions.description.ar;
      _origTermsSvgUrl = m.termsAndConditions.svgUrl;
      _origTermsDocEnUrl = m.termsAndConditions.attachEnUrl;
      _origTermsDocArUrl = m.termsAndConditions.attachArUrl;

      _origPrivacyDescEn = m.privacyPolicy.description.en;
      _origPrivacyDescAr = m.privacyPolicy.description.ar;
      _origPrivacySvgUrl = m.privacyPolicy.svgUrl;
      _origPrivacyDocEnUrl = m.privacyPolicy.attachEnUrl;
      _origPrivacyDocArUrl = m.privacyPolicy.attachArUrl;

      _seeded = true;
    });
  }

  // ── Build model ───────────────────────────────────────────────────────────
  TermsOfServiceModel _buildModel(String status) => TermsOfServiceModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIconUrl,
      title: AboutBilingualText(
        en: _navTitleEnCtrl.text.trim(),
        ar: _navTitleArCtrl.text.trim(),
      ),
    ),
    termsAndConditions: TermsSection(
      svgUrl: _termsSvgUrl,
      description: AboutBilingualText(
        en: _termsDescEnCtrl.text.trim(),
        ar: _termsDescArCtrl.text.trim(),
      ),
      attachEnUrl: _termsDocEn.existingUrl,
      attachArUrl: _termsDocAr.existingUrl,
    ),
    privacyPolicy: TermsSection(
      svgUrl: _privacySvgUrl,
      description: AboutBilingualText(
        en: _privacyDescEnCtrl.text.trim(),
        ar: _privacyDescArCtrl.text.trim(),
      ),
      attachEnUrl: _privacyDocEn.existingUrl,
      attachArUrl: _privacyDocAr.existingUrl,
    ),
  );

  // ── Collect uploads ───────────────────────────────────────────────────────
  Map<String, Uint8List> _collectImageUploads() {
    final u = <String, Uint8List>{};
    if (_navIconBytes != null) u['terms_cms/navLabel/icon'] = _navIconBytes!;
    if (_termsSvgBytes != null) u['terms_cms/terms/svg'] = _termsSvgBytes!;
    if (_privacySvgBytes != null)
      u['terms_cms/privacy/svg'] = _privacySvgBytes!;
    return u;
  }

  Map<String, DocUpload> _collectDocUploads() {
    final u = <String, DocUpload>{};
    if (_termsDocEn.bytes != null)
      u['terms_cms/terms/en'] = DocUpload(
        bytes: _termsDocEn.bytes!,
        fileName: _termsDocEn.fileName,
      );
    if (_termsDocAr.bytes != null)
      u['terms_cms/terms/ar'] = DocUpload(
        bytes: _termsDocAr.bytes!,
        fileName: _termsDocAr.fileName,
      );
    if (_privacyDocEn.bytes != null)
      u['terms_cms/privacy/en'] = DocUpload(
        bytes: _privacyDocEn.bytes!,
        fileName: _privacyDocEn.fileName,
      );
    if (_privacyDocAr.bytes != null)
      u['terms_cms/privacy/ar'] = DocUpload(
        bytes: _privacyDocAr.bytes!,
        fileName: _privacyDocAr.fileName,
      );
    return u;
  }

  // ── Dirty check: true if user changed anything from seeded data ───────────
  bool get _isDirty {
    if (!_seeded) return false;

    // Text fields changed
    if (_termsDescEnCtrl.text.trim() != _origTermsDescEn.trim()) return true;
    if (_termsDescArCtrl.text.trim() != _origTermsDescAr.trim()) return true;
    if (_privacyDescEnCtrl.text.trim() != _origPrivacyDescEn.trim())
      return true;
    if (_privacyDescArCtrl.text.trim() != _origPrivacyDescAr.trim())
      return true;

    // SVG changed (new bytes picked)
    if (_termsSvgBytes != null) return true;
    if (_privacySvgBytes != null) return true;

    // Doc files changed (new bytes picked or removed)
    if (_termsDocEn.bytes != null) return true;
    if (_termsDocAr.bytes != null) return true;
    if (_privacyDocEn.bytes != null) return true;
    if (_privacyDocAr.bytes != null) return true;

    // Doc removed (existingUrl was cleared)
    if (_termsDocEn.existingUrl != _origTermsDocEnUrl) return true;
    if (_termsDocAr.existingUrl != _origTermsDocArUrl) return true;
    if (_privacyDocEn.existingUrl != _origPrivacyDocEnUrl) return true;
    if (_privacyDocAr.existingUrl != _origPrivacyDocArUrl) return true;

    return false;
  }

  // ── All fields filled (descriptions + SVGs) ──────────────────────────────
  bool get _allFieldsFilled {
    // All 4 description fields must be non-empty
    if (_termsDescEnCtrl.text.trim().isEmpty) return false;
    if (_termsDescArCtrl.text.trim().isEmpty) return false;
    if (_privacyDescEnCtrl.text.trim().isEmpty) return false;
    if (_privacyDescArCtrl.text.trim().isEmpty) return false;

    // Both SVGs must exist (new bytes OR existing url)
    final hasTermsSvg = _termsSvgBytes != null || _termsSvgUrl.isNotEmpty;
    final hasPrivacySvg = _privacySvgBytes != null || _privacySvgUrl.isNotEmpty;
    if (!hasTermsSvg) return false;
    if (!hasPrivacySvg) return false;

    return true;
  }

  // ── Check text field errors (language mismatch) ───────────────────────────
  bool _hasFieldError(TextEditingController ctrl, TextDirection dir) {
    final text = ctrl.text;
    if (text.trim().isEmpty)
      return false; // empty is handled by _allFieldsFilled
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    if (dir == TextDirection.ltr && hasArabic) return true;
    if (dir == TextDirection.rtl && hasEnglish) return true;
    return false;
  }

  bool get _hasAnyTextError {
    if (_hasFieldError(_termsDescEnCtrl, TextDirection.ltr)) return true;
    if (_hasFieldError(_termsDescArCtrl, TextDirection.rtl)) return true;
    if (_hasFieldError(_privacyDescEnCtrl, TextDirection.ltr)) return true;
    if (_hasFieldError(_privacyDescArCtrl, TextDirection.rtl)) return true;
    return false;
  }

  // ── Combined: publish allowed ─────────────────────────────────────────────
  bool get _canPublish => _allFieldsFilled && !_hasAnyTextError;

  // ── FIX: Only validate the fields that are actually visible on screen ─────
  bool _validate() => [
    _termsDescEnCtrl,
    _termsDescArCtrl,
    _privacyDescEnCtrl,
    _privacyDescArCtrl,
  ].every((c) => c.text.trim().isNotEmpty);

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields before previewing.'),
          backgroundColor: _kRed,
        ),
      );
      return;
    }
    final cubit = context.read<TermsCubit>();
    final model = _buildModel('draft');
    final imgUploads = _collectImageUploads();
    final docUps = _collectDocUploads();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TermsPreviewPage(
            model: model,
            imageUploads: imgUploads,
            docUploads: docUps,
          ),
        ),
      ),
    );
  }

  // ── Save (called from dialog — dialog handles loading UI) ─────────────
  Future<void> _save(String status) async {
    final imgs = _collectImageUploads();
    final docs = _collectDocUploads();
    await context.read<TermsCubit>().save(
      model: _buildModel(status),
      imageUploads: imgs.isEmpty ? null : imgs,
      docUploads: docs.isEmpty ? null : docs,
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TermsCubit, TermsState>(
      listener: (context, state) {
        if (state is TermsLoaded) _seed(state.data);

        if (state is TermsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terms of Service saved!'),
              backgroundColor: _kGreenSolid,
            ),
          );
          Navigator.pop(context);
        }
        if (state is TermsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: _kRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is TermsLoading || state is TermsInitial;
        return Scaffold(
          backgroundColor: Color(0xFFF1F2ED),
          body: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Container(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppAdminNavbar(
                          activeLabel: 'Web Page',
                          homePage: HomeMainPage(),
                          webPage: HomeMainPage(),
                          jobListingPage: HomeMainPage(),
                        ),
                        SizedBox(width: 20.w),
                        SizedBox(height: 20.h),
                        AdminSubNavBar(activeIndex: 5),
                        SizedBox(height: 25.h),
                        SizedBox(
                          width: 1000.w,
                          child: loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: _kGreenSolid,
                                  ),
                                )
                              : _buildForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    final bool publishEnabled = _canPublish;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Terms of Service Details',
          style: StyleText.fontSize45Weight600.copyWith(
            color: _kGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title: 'Terms and Conditions',
          isOpen: _termsOpen,
          onToggle: () => setState(() => _termsOpen = !_termsOpen),
          child: _sectionEditor(
            svgBytes: _termsSvgBytes,
            svgUrl: _termsSvgUrl,
            onPickSvg: () async {
              final b = await _pickSvg();
              if (b != null) setState(() => _termsSvgBytes = b);
            },
            descEnCtrl: _termsDescEnCtrl,
            descArCtrl: _termsDescArCtrl,
            docEn: _termsDocEn,
            docAr: _termsDocAr,
            onPickDocEn: () => _pickDoc(_termsDocEn),
            onPickDocAr: () => _pickDoc(_termsDocAr),
          ),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title: 'Privacy Policy',
          isOpen: _privacyOpen,
          onToggle: () => setState(() => _privacyOpen = !_privacyOpen),
          child: _sectionEditor(
            svgBytes: _privacySvgBytes,
            svgUrl: _privacySvgUrl,
            onPickSvg: () async {
              final b = await _pickSvg();
              if (b != null) setState(() => _privacySvgBytes = b);
            },
            descEnCtrl: _privacyDescEnCtrl,
            descArCtrl: _privacyDescArCtrl,
            docEn: _privacyDocEn,
            docAr: _privacyDocAr,
            onPickDocEn: () => _pickDoc(_privacyDocEn),
            onPickDocAr: () => _pickDoc(_privacyDocAr),
          ),
        ),
        SizedBox(height: 32.h),

        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: const Color(0xFFD16F9A),
                onTap: _onPreview,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label: 'Publish',
                color: publishEnabled ? _kGreenSolid : const Color(0xFFBDBDBD),
                onTap: publishEnabled
                    ? () {
                        showPublishConfirmDialog(
                          context: context,
                          title: 'EDITING TERMS OF SERVICE',
                          subtitle:
                              'Do you want to save the changes made to Terms of Service?',
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
                color: const Color(0xFF9E9E9E),
                onTap: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(child: Column()),
          ],
        ),
        SizedBox(height: 48.h),
      ],
    );
  }

  Widget _sectionEditor({
    required Uint8List? svgBytes,
    required String svgUrl,
    required VoidCallback onPickSvg,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required _DocItem docEn,
    required _DocItem docAr,
    required VoidCallback onPickDocEn,
    required VoidCallback onPickDocAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        _fieldLabel('SVG'),
        SizedBox(height: 8.h),
        _svgBox(bytes: svgBytes, url: svgUrl, onPick: onPickSvg),
        SizedBox(height: 16.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          fillColor: Colors.white,
          hint: 'Text Here',
          controller: descEnCtrl,
          height: 120,
          maxLines: 5,
          maxLength: 10000,
          showCharCount: false,
          submitted: _submitted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          fillColor: Colors.white,
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 120,
          maxLines: 5,
          maxLength: 10000,
          showCharCount: false,
          submitted: _submitted,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _docUploadField(
                label: 'Attach Eng Document',
                docItem: docEn,
                onPick: onPickDocEn,
                onRemove: () => setState(() {
                  docEn.bytes = null;
                  docEn.fileName = '';
                  docEn.existingUrl = '';
                }),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _docUploadField(
                label: 'Attach Ar Document',
                docItem: docAr,
                onPick: onPickDocAr,
                onRemove: () => setState(() {
                  docAr.bytes = null;
                  docAr.fileName = '';
                  docAr.existingUrl = '';
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _docUploadField({
    required String label,
    required _DocItem docItem,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(height: 8.h),
        docItem.hasFile
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD16F9A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 18.sp, color: _kRed),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        docItem.displayName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 22.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: _kRed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: onPick,
                child: Container(
                  width: double.infinity,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _kGreenSolid,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, color: Colors.white, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Attach Document',
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

  // ── Shared helpers ────────────────────────────────────────────────────────
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

  Widget _svgBox({
    required Uint8List? bytes,
    required String url,
    required VoidCallback onPick,
  }) {
    Widget content;
    if (bytes != null) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                bytes,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.scaleDown,
                placeholderBuilder: (_) => _placeholderCircle(),
              ),
            ),
          ),
        ),
      );
    } else if (url.isNotEmpty) {
      content = Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                url,
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    } else {
      content = _placeholderCircle();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(onTap: onPick, child: content),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: _kGreenSolid,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: 'assets/control/camera.svg',
                  width: 12.w,
                  height: 12.h,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderCircle() => Container(
    width: 70.w,
    height: 70.h,
    decoration: const BoxDecoration(
      color: Color(0xFFEEEEEE),
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.description_outlined,
      color: Colors.grey[600],
      size: 28.sp,
    ),
  );

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
            fillColor: Colors.white,
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            fillColor: Colors.white,
            hint: arHint,
            controller: arCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Text(
    t,
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _fieldLabelAr(String t) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      t,
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
  }) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: onTap == null ? 0.5 : 1.0,
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
    ),
  );
}
