// ******************* FILE INFO *******************
// File Name: contact_us_edit.dart
// UPDATED: isRequired moved to section level — ONE toggle per section
//          Toggle only appears on reason index 0 (first reason row)
//          All other reasons show NO toggle
//          _ReasonItem no longer carries isRequired
//          Social links: explicit SizedBox(height) fix for Flutter Web rendering
//          Full debug prints retained

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/theme/text.dart';
import '../../../../../core/widget/textfield.dart';
import '../../../../home/data/model/home_model.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../data/model/contact_us_model_location.dart';
import '../../controller/contact_us_location_cubit.dart';
import '../../controller/contact_us_location_state.dart';
import 'contact_us_preview.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;

part '../widget/contact_us_edit/social_link_dropdown.dart';
part '../widget/contact_us_edit/reason_item.dart';
part '../widget/contact_us_edit/social_link_item.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}

const Color _kPink = Color(0xFFD16F9A);
const Color _kRed  = Color(0xFFD32F2F);

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ContactUsCmsEditPage extends StatefulWidget {
  const ContactUsCmsEditPage({super.key});

  @override
  State<ContactUsCmsEditPage> createState() => _ContactUsCmsEditPageState();
}

class _ContactUsCmsEditPageState extends State<ContactUsCmsEditPage> {
  // ── Headings ──
  final _titleEnCtrl     = TextEditingController();
  final _titleArCtrl     = TextEditingController();
  final _shortDescEnCtrl = TextEditingController();
  final _shortDescArCtrl = TextEditingController();
  Uint8List? _headingSvgBytes;
  String     _headingSvgUrl = '';

  // ── Client Description ──
  final _clientDescEnCtrl = TextEditingController();
  final _clientDescArCtrl = TextEditingController();
  final List<_ReasonItem> _clientReasons = [];
  int  _clientReasonCounter = 0;
  bool _clientIsRequired    = false;

  // ── Owner Description ──
  final _ownerDescEnCtrl = TextEditingController();
  final _ownerDescArCtrl = TextEditingController();
  final List<_ReasonItem> _ownerReasons = [];
  int  _ownerReasonCounter = 0;
  bool _ownerIsRequired    = false;

  // ── Social Media Links ──
  final List<_SocialLinkItem> _socialLinkItems = [];
  int _socialLinkCounter = 0;

  // ── Accordion open/close ──
  bool _headingsOpen   = true;
  bool _clientDescOpen = true;
  bool _ownerDescOpen  = true;
  bool _socialOpen     = true;

  bool _submitted = false;
  bool _seeded    = false;

  ContactUsCmsModel?    _pendingContactModel;
  List<SocialLinkModel> _footerSocialLinks = [];

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    print('🟣 [EditPage] initState — loading cubits');
    context.read<ContactUsCmsCubit>().load();
    context.read<HomeCmsCubit>().load();
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _shortDescEnCtrl.dispose();
    _shortDescArCtrl.dispose();
    _clientDescEnCtrl.dispose();
    _clientDescArCtrl.dispose();
    _ownerDescEnCtrl.dispose();
    _ownerDescArCtrl.dispose();
    for (final r in _clientReasons) {
      r.labelEnCtrl.dispose();
      r.labelArCtrl.dispose();
    }
    for (final r in _ownerReasons) {
      r.labelEnCtrl.dispose();
      r.labelArCtrl.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEED
  // ─────────────────────────────────────────────────────────────────────────

  void _trySeed() {
    print('🔍 [_trySeed] _seeded=$_seeded  pendingModel=${_pendingContactModel != null}  footerLinks=${_footerSocialLinks.length}');
    if (_seeded) {
      print('   → already seeded, skipping');
      return;
    }
    if (_pendingContactModel == null) {
      print('   → no contact model yet, waiting');
      return;
    }
    if (_footerSocialLinks.isEmpty) {
      print('   → footer links not loaded yet, waiting');
      return;
    }
    _seedFromModel(_pendingContactModel!);
  }

  void _seedFromModel(ContactUsCmsModel m) {
    if (_seeded) return;
    _seeded = true;
    print('🌱 [_seedFromModel] seeding from model');

    // Headings
    _titleEnCtrl.text     = m.headings.title.en;
    _titleArCtrl.text     = m.headings.title.ar;
    _shortDescEnCtrl.text = m.headings.shortDescription.en;
    _shortDescArCtrl.text = m.headings.shortDescription.ar;
    _headingSvgUrl        = m.headings.svgUrl;
    print('   headings seeded: title.en=${m.headings.title.en}');

    // Client Description
    _clientDescEnCtrl.text = m.clientDescription.description.en;
    _clientDescArCtrl.text = m.clientDescription.description.ar;
    _clientIsRequired      = m.clientDescription.isRequired;
    _clientReasons.clear();
    for (final r in m.clientDescription.reasons) {
      final item = _ReasonItem(id: r.id, counter: ++_clientReasonCounter);
      item.labelEnCtrl.text = r.label.en;
      item.labelArCtrl.text = r.label.ar;
      _clientReasons.add(item);
    }
    print('   client reasons seeded: ${_clientReasons.length}  isRequired=$_clientIsRequired');

    // Owner Description
    _ownerDescEnCtrl.text = m.ownerDescription.description.en;
    _ownerDescArCtrl.text = m.ownerDescription.description.ar;
    _ownerIsRequired      = m.ownerDescription.isRequired;
    _ownerReasons.clear();
    for (final r in m.ownerDescription.reasons) {
      final item = _ReasonItem(id: r.id, counter: ++_ownerReasonCounter);
      item.labelEnCtrl.text = r.label.en;
      item.labelArCtrl.text = r.label.ar;
      _ownerReasons.add(item);
    }
    print('   owner reasons seeded: ${_ownerReasons.length}  isRequired=$_ownerIsRequired');

    // ✅ Social Links — intentionally NOT seeded.
    // User must add links manually via the + Link button.
    _socialLinkItems.clear();
    print('   socialLinkItems intentionally cleared (user adds manually)');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SVG PICKER
  // ─────────────────────────────────────────────────────────────────────────

  Future<Uint8List?> _pickSvgOnly() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file      = files.first;
      final isSvgExt  = file.name.toLowerCase().endsWith('.svg');
      final isSvgMime = file.type == 'image/svg+xml' || file.type.contains('svg');

      if (!isSvgExt && !isSvgMime) {
        completer.complete(null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:         Text('Only SVG files are allowed'),
              backgroundColor: _kRed,
              duration:        Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.readyState == html.FileReader.DONE) {
          final result = reader.result;
          Uint8List? bytes;
          if (result is ByteBuffer)    bytes = Uint8List.view(result);
          else if (result is Uint8List) bytes = result;
          else if (result is List<int>) bytes = Uint8List.fromList(result);

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
          (trimmed.startsWith('<?xml') && trimmed.contains('<svg'));
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD MODEL
  // ─────────────────────────────────────────────────────────────────────────

  ContactUsCmsModel _buildModel(String status) {
    print('🔵 [_buildModel] _socialLinkItems.length = ${_socialLinkItems.length}');
    print('🔵 [_buildModel] _footerSocialLinks.length = ${_footerSocialLinks.length}');

    final socialIcons = <ContactSocialIcon>[];
    for (var i = 0; i < _socialLinkItems.length; i++) {
      final s = _socialLinkItems[i];
      print('🔵 [_buildModel] item[$i] id=${s.id} selectedIndex=${s.selectedIndex} iconUrl=${s.iconUrl}');

      final hasSelection =
          s.selectedIndex != null &&
              s.selectedIndex! < _footerSocialLinks.length;
      print('   hasSelection=$hasSelection');

      final selectedLink = hasSelection ? _footerSocialLinks[s.selectedIndex!] : null;
      print('   selectedLink?.url=${selectedLink?.url}');
      print('   selectedLink?.iconUrl=${selectedLink?.iconUrl}');

      final url     = selectedLink?.url ?? '';
      final iconUrl = (selectedLink != null && selectedLink.iconUrl.isNotEmpty)
          ? selectedLink.iconUrl
          : s.iconUrl;
      print('   → saving url=$url  iconUrl=$iconUrl');

      socialIcons.add(ContactSocialIcon(id: s.id, iconUrl: iconUrl, link: url));
    }

    print('🟢 [_buildModel] socialIcons built: ${socialIcons.map((e) => e.link).toList()}');

    return ContactUsCmsModel(
      publishStatus: status,
      headings: ContactHeadings(
        svgUrl: _headingSvgUrl,
        title: ContactBilingualText(
          en: _titleEnCtrl.text.trim(),
          ar: _titleArCtrl.text.trim(),
        ),
        shortDescription: ContactBilingualText(
          en: _shortDescEnCtrl.text.trim(),
          ar: _shortDescArCtrl.text.trim(),
        ),
      ),
      clientDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: _clientDescEnCtrl.text.trim(),
          ar: _clientDescArCtrl.text.trim(),
        ),
        isRequired: _clientIsRequired,
        reasons: _clientReasons
            .map((r) => ContactReasonItem(
          id:    r.id,
          label: ContactBilingualText(
            en: r.labelEnCtrl.text.trim(),
            ar: r.labelArCtrl.text.trim(),
          ),
        ))
            .toList(),
      ),
      ownerDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: _ownerDescEnCtrl.text.trim(),
          ar: _ownerDescArCtrl.text.trim(),
        ),
        isRequired: _ownerIsRequired,
        reasons: _ownerReasons
            .map((r) => ContactReasonItem(
          id:    r.id,
          label: ContactBilingualText(
            en: r.labelEnCtrl.text.trim(),
            ar: r.labelArCtrl.text.trim(),
          ),
        ))
            .toList(),
      ),
      socialIcons: socialIcons,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPLOADS
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_headingSvgBytes != null) {
      uploads['contact_cms/headings/svg'] = _headingSvgBytes!;
    }
    return uploads;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────────────────────────────────

  bool _validate() {
    setState(() => _submitted = true);

    if (_titleEnCtrl.text.trim().isEmpty)     return false;
    if (_titleArCtrl.text.trim().isEmpty)     return false;
    if (_shortDescEnCtrl.text.trim().isEmpty) return false;
    if (_shortDescArCtrl.text.trim().isEmpty) return false;
    if (_headingSvgBytes == null && _headingSvgUrl.isEmpty) return false;

    if (_clientDescEnCtrl.text.trim().isEmpty) return false;
    if (_clientDescArCtrl.text.trim().isEmpty) return false;
    for (final r in _clientReasons) {
      if (r.labelEnCtrl.text.trim().isEmpty) return false;
      if (r.labelArCtrl.text.trim().isEmpty) return false;
    }

    if (_ownerDescEnCtrl.text.trim().isEmpty) return false;
    if (_ownerDescArCtrl.text.trim().isEmpty) return false;
    for (final r in _ownerReasons) {
      if (r.labelEnCtrl.text.trim().isEmpty) return false;
      if (r.labelArCtrl.text.trim().isEmpty) return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _save(String status) async {
    final model   = _buildModel(status);
    final uploads = _collectUploads();
    await context.read<ContactUsCmsCubit>().save(
      model:        model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  Future<void> _onSaveTap() async {
    print('💾 [_onSaveTap] _socialLinkItems=${_socialLinkItems.map((s) => "id=${s.id} idx=${s.selectedIndex}").toList()}');
    print('💾 [_onSaveTap] _footerSocialLinks=${_footerSocialLinks.map((l) => l.url).toList()}');

    if (!_validate()) {
      print('❌ [_onSaveTap] validation failed');
      return;
    }

    await showPublishConfirmDialog(
      context:  context,
      title:    'EDITING CONTACT US DETAILS',
      subtitle: 'Do you want to save the changes made to this Contact Us page?',
      onConfirm: () => _save('published'),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADD / REMOVE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void _addClientReason() => setState(() {
    _clientReasons.add(_ReasonItem(
      id:      'reason_client_${DateTime.now().millisecondsSinceEpoch}',
      counter: ++_clientReasonCounter,
    ));
  });

  void _removeClientReason(String id) =>
      setState(() => _clientReasons.removeWhere((r) => r.id == id));

  void _addOwnerReason() => setState(() {
    _ownerReasons.add(_ReasonItem(
      id:      'reason_owner_${DateTime.now().millisecondsSinceEpoch}',
      counter: ++_ownerReasonCounter,
    ));
  });

  void _removeOwnerReason(String id) =>
      setState(() => _ownerReasons.removeWhere((r) => r.id == id));

  void _addSocialLink() {
    final newItem = _SocialLinkItem(
      id:      'social_${DateTime.now().millisecondsSinceEpoch}',
      counter: ++_socialLinkCounter,
    );
    print('➕ [_addSocialLink] adding id=${newItem.id}  currentTotal=${_socialLinkItems.length}');
    setState(() => _socialLinkItems.add(newItem));
    print('➕ [_addSocialLink] after add total=${_socialLinkItems.length}');
  }

  void _removeSocialLink(String id) {
    print('🗑️ [_removeSocialLink] removing id=$id  beforeCount=${_socialLinkItems.length}');
    setState(() => _socialLinkItems.removeWhere((s) => s.id == id));
    print('🗑️ [_removeSocialLink] after remove total=${_socialLinkItems.length}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCmsCubit, HomeCmsState>(
          listener: (context, homeState) {
            final links = switch (homeState) {
              HomeCmsLoaded(:final data) => data.socialLinks,
              HomeCmsSaved(:final data)  => data.socialLinks,
              _ => <SocialLinkModel>[],
            };
            if (links.isNotEmpty) {
              print('🏠 [HomeCubit] socialLinks loaded: ${links.length}  urls=${links.map((l) => l.url).toList()}');
              setState(() => _footerSocialLinks = links);
              _trySeed();
            }
          },
        ),
        BlocListener<ContactUsCmsCubit, ContactUsCmsState>(
          listener: (context, state) {
            if (state is ContactUsCmsLoaded) {
              print('📋 [ContactCubit] ContactUsCmsLoaded received');
              _pendingContactModel = state.data;
              _trySeed();
            }
          },
        ),
      ],
      child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          final isLoading    = state is ContactUsCmsLoading || state is ContactUsCmsInitial;
          final waitingForSeed = !_seeded && !isLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF1F2ED),
            body: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 25.h),
                          AdminSubNavBar(activeIndex: 6),
                          SizedBox(height: 25.h),
                          SizedBox(
                            width: 1000.w,
                            child: (isLoading || waitingForSeed)
                                ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 100.h),
                              child: const Center(
                                child: CircularProgressIndicator(color: _kPink),
                              ),
                            )
                                : _buildForm(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORM
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Contact Us',
          style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
            fontSize:   36.sp,
            color:      _kPink,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title:    'Headings',
          isOpen:   _headingsOpen,
          onToggle: () => setState(() => _headingsOpen = !_headingsOpen),
          child:    _headingsSection(),
        ),
        SizedBox(height: 10.h),

        _accordion(
          title:    'Client Description',
          isOpen:   _clientDescOpen,
          onToggle: () => setState(() => _clientDescOpen = !_clientDescOpen),
          child: _descriptionSection(
            descEnCtrl:       _clientDescEnCtrl,
            descArCtrl:       _clientDescArCtrl,
            reasons:          _clientReasons,
            isRequired:       _clientIsRequired,
            onToggleRequired: (v) => setState(() => _clientIsRequired = v),
            onAddReason:      _addClientReason,
            onRemoveReason:   _removeClientReason,
          ),
        ),
        SizedBox(height: 10.h),

        _accordion(
          title:    'Owner Description',
          isOpen:   _ownerDescOpen,
          onToggle: () => setState(() => _ownerDescOpen = !_ownerDescOpen),
          child: _descriptionSection(
            descEnCtrl:       _ownerDescEnCtrl,
            descArCtrl:       _ownerDescArCtrl,
            reasons:          _ownerReasons,
            isRequired:       _ownerIsRequired,
            onToggleRequired: (v) => setState(() => _ownerIsRequired = v),
            onAddReason:      _addOwnerReason,
            onRemoveReason:   _removeOwnerReason,
          ),
        ),
        SizedBox(height: 10.h),

        _accordion(
          title:    'Social Media Links',
          isOpen:   _socialOpen,
          onToggle: () => setState(() => _socialOpen = !_socialOpen),
          child:    _socialLinksSection(),
        ),
        SizedBox(height: 32.h),

        _actionButtons(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADINGS SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _headingsSection() {
    final svgMissing =
        _submitted && _headingSvgBytes == null && _headingSvgUrl.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _imageUploadCircle(
          label: 'SVG',
          bytes: _headingSvgBytes,
          url:   _headingSvgUrl,
          onTap: () async {
            final b = await _pickSvgOnly();
            if (b != null) setState(() => _headingSvgBytes = b);
          },
        ),
        if (svgMissing)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'SVG is required',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: _kRed),
            ),
          ),
        SizedBox(height: 16.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'Text Here',
                    fillColor:     Colors.white,
                    controller:    _titleEnCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign:     TextAlign.start,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _fieldLabelAr('العنوان'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'أدخل النص هنا',
                    fillColor:     Colors.white,
                    controller:    _titleArCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign:     TextAlign.right,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _fieldLabel('Short Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'Text Here',
          fillColor:     Colors.white,
          controller:    _shortDescEnCtrl,
          height:        42,
          maxLines:      1,
          maxLength:     300,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.start,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 12.h),

        _fieldLabelAr('وصف مختصر'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'أدخل النص هنا',
          fillColor:     Colors.white,
          controller:    _shortDescArCtrl,
          height:        42,
          maxLines:      1,
          maxLength:     300,
          submitted:     _submitted,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESCRIPTION SECTION (Client / Owner)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _descriptionSection({
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required List<_ReasonItem>     reasons,
    required bool                  isRequired,
    required ValueChanged<bool>    onToggleRequired,
    required VoidCallback          onAddReason,
    required void Function(String) onRemoveReason,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'Text Here',
          fillColor:     Colors.white,
          controller:    descEnCtrl,
          height:        100,
          maxLines:      4,
          maxLength:     500,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.start,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 12.h),

        _fieldLabelAr('الوصف'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'أدخل النص هنا',
          fillColor:     Colors.white,
          controller:    descArCtrl,
          height:        100,
          maxLines:      4,
          maxLength:     500,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        // ── Reason rows ──
        ...reasons.asMap().entries.map(
              (e) => _reasonEditItem(
            e.value,
            e.key,
            onRemoveReason,
            sectionIsRequired: isRequired,
            onToggleRequired:  e.key == 0 ? onToggleRequired : null,
          ),
        ),

        // ── + Reason button ──
        GestureDetector(
          onTap: onAddReason,
          child: Container(
            width:  110.w,
            height: 30.h,
            decoration: BoxDecoration(
              color:        const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Reason',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REASON EDIT ITEM
  // ─────────────────────────────────────────────────────────────────────────

  Widget _reasonEditItem(
      _ReasonItem r,
      int index,
      void Function(String) onRemove, {
        required bool sectionIsRequired,
        ValueChanged<bool>? onToggleRequired,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── EN field ──────────────────────────────────────────
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  hint: 'Text Here',
                  label: 'Reason',
                  labelTrailing: Row(
                    children: [
                      if (onToggleRequired != null) ...[
                        Text(
                          'Required',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => onToggleRequired(!sectionIsRequired),
                          child: _toggleSwitch(sectionIsRequired),
                        ),
                      ],
                      // ── Remove button (hidden for index 0) ────────
                      if (index > 0) ...[
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => onRemove(r.id),
                          child: Container(
                            width: 18.w,
                            height: 18.h,
                            decoration: const BoxDecoration(
                              color: _kRed,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  fillColor: Colors.white,
                  controller: r.labelEnCtrl,
                  height: 42,
                  maxLines: 1,
                  maxLength: 200,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 16.w),

              // ── AR field ──────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _fieldLabelAr('السبب'),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    CustomValidatedTextFieldMaster(
                      hint: 'أدخل النص هنا',
                      fillColor: Colors.white,
                      controller: r.labelArCtrl,
                      height: 42,
                      maxLines: 1,
                      maxLength: 200,
                      submitted: _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleSwitch(bool isOn) {
    return Container(
      width:  40.w,
      height: 22.h,
      decoration: BoxDecoration(
        color:        isOn ? _kPink : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: AnimatedAlign(
        duration:  const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width:  18.w,
          height: 18.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCIAL LINKS SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _socialLinksSection() {
    print('🎨 [_socialLinksSection] building — items=${_socialLinkItems.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        // ── 2-per-row grid with explicit height per row ────────────────
        if (_socialLinkItems.isNotEmpty) ..._buildSocialLinksGrid(),

        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addSocialLink,
          child: Container(
            width:  90.w,
            height: 30.h,
            decoration: BoxDecoration(
              color:        const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Link',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ── 2-per-row manual grid — SizedBox(height) fixes Flutter Web collapse ──
  List<Widget> _buildSocialLinksGrid() {
    print('🔲 [_buildSocialLinksGrid] building ${_socialLinkItems.length} items');
    final rows = <Widget>[];
    for (var i = 0; i < _socialLinkItems.length; i += 2) {
      final left  = _socialLinkItems[i];
      final right = (i + 1) < _socialLinkItems.length
          ? _socialLinkItems[i + 1]
          : null;
      print('   row ${i ~/ 2}: left=${left.id}  right=${right?.id ?? "empty"}');

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SizedBox(
            height: 38.h, // ← explicit height — prevents Flutter Web zero-height collapse
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _socialLinkDropdownWidget(left)),
                SizedBox(width: 16.w),
                right != null
                    ? Expanded(child: _socialLinkDropdownWidget(right))
                    : const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );
    }
    print('   total rows built: ${rows.length}');
    return rows;
  }

  Widget _socialLinkDropdownWidget(_SocialLinkItem s) {
    print('🔧 [_socialLinkDropdownWidget] rendering id=${s.id} selectedIndex=${s.selectedIndex}');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _SocialLinkDropdown(
            key:           ValueKey(s.id), // stable key per item
            footerLinks:   _footerSocialLinks,
            selectedIndex: s.selectedIndex,
            onChanged: (idx) {
              print('✅ [onChanged] s.id=${s.id} new idx=$idx  url=${idx != null && idx < _footerSocialLinks.length ? _footerSocialLinks[idx].url : "OUT_OF_RANGE"}');
              setState(() => s.selectedIndex = idx);
              print('✅ [onChanged] after setState s.selectedIndex=${s.selectedIndex}');
            },
            submitted: _submitted,
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => _removeSocialLink(s.id),
          child: Container(
            width:  20.w,
            height: 20.w, // square
            decoration: const BoxDecoration(
                color: _kRed, shape: BoxShape.circle),
            child: Icon(Icons.remove, color: Colors.white, size: 12.sp),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCORDION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _accordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width:   double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color:        _kPink,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: Colors.white
                    )

                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size:  22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width:      double.infinity,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            child: child,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: const Color(0xFF8A5C70),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ContactUsCmsPreviewPage()),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: _btn(label: 'Save', color: _kPink, onTap: _onSaveTap),
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
            SizedBox(width: 300.sp),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _imageUploadCircle({
    required String    label,
    required Uint8List? bytes,
    required String    url,
    required VoidCallback onTap,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily:  'Cairo',
              fontSize:    13.sp,
              fontWeight:  FontWeight.w600,
              color:       Colors.black87,
            )),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:  64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url))
                    : Icon(Icons.description_outlined,
                    color: Colors.grey[600], size: 28.sp),
              ),
              Positioned(
                bottom: 0,
                right:  0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width:  25.w,
                    height: 25.h,
                    decoration: const BoxDecoration(
                        color: _kPink, shape: BoxShape.circle),
                    child: Center(
                      child: CustomSvg(
                        assetPath: 'assets/control/camera.svg',
                        width:     10.w,
                        height:    10.h,
                        fit:       BoxFit.scaleDown,
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
      final viewId  = 'svg-about-bytes-${bytes.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src             = dataUrl
          ..style.width     = '100%'
          ..style.height    = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      return SizedBox(
          width: 64.w, height: 64.h, child: HtmlElementView(viewType: viewId));
    }
    if (url.isNotEmpty) {
      final viewId = 'svg-about-url-${url.hashCode}';
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src             = url
          ..style.width     = '100%'
          ..style.height    = '100%'
          ..style.objectFit = 'contain';
        return img;
      });
      return SizedBox(
          width: 64.w, height: 64.h, child: HtmlElementView(viewType: viewId));
    }
    return Icon(Icons.image_outlined, color: Colors.grey[500], size: 28.sp);
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
    ),
  );

  Widget _btn({
    required String       label,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize14Weight600.copyWith(
              color: Colors.white
            )
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL LINK DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════
