// ******************* FILE INFO *******************
// File Name: contact_us_cms_edit_page.dart
// UPDATED: Complete rewrite to match new Figma design
//          - Headings (SVG upload, Title EN/AR, Short Description EN/AR)
//          - Client Description (Description EN/AR, dynamic Reasons with Required toggle)
//          - Owner Description (Description EN/AR, dynamic Reasons with Required toggle)
//          - Social Media Links (dropdown grid from footer links, + Link button)
//          - Buttons: Preview, Save, Discard

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:beauty_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:beauty_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/text.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../../core/widget/svg_image.dart' show CustomSvg;
import '../../controller/home/home_cubit.dart';
import '../../controller/home/home_state.dart';
import '../../core/custom_dialog.dart';
import '../../model/contact_us/contact_model_location.dart';
import '../../model/home/home_model.dart';
import 'contact_us_cms_preview_page.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;


String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}


const Color _kPink       = Color(0xFFD16F9A);
const Color _kRed        = Color(0xFFD32F2F);

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
  final _titleEnCtrl         = TextEditingController();
  final _titleArCtrl         = TextEditingController();
  final _shortDescEnCtrl     = TextEditingController();
  final _shortDescArCtrl     = TextEditingController();
  Uint8List? _headingSvgBytes;
  String     _headingSvgUrl = '';

  // ── Client Description ──
  final _clientDescEnCtrl = TextEditingController();
  final _clientDescArCtrl = TextEditingController();
  final List<_ReasonItem> _clientReasons = [];
  int _clientReasonCounter = 0;

  // ── Owner Description ──
  final _ownerDescEnCtrl = TextEditingController();
  final _ownerDescArCtrl = TextEditingController();
  final List<_ReasonItem> _ownerReasons = [];
  int _ownerReasonCounter = 0;

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

  ContactUsCmsModel? _pendingContactModel;
  List<SocialLinkModel> _footerSocialLinks = [];

  @override
  void initState() {
    super.initState();
    print('🟡 [ContactEdit] initState() → loading ContactUsCmsCubit + HomeCmsCubit');
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

  // ── Try to seed ───────────────────────────────────────────────────────────

  void _trySeed() {
    if (_seeded) {
      _rematchSocialLinks();
      return;
    }
    if (_pendingContactModel == null) {
      print('🟠 [ContactEdit] _trySeed: no contact model yet, waiting…');
      return;
    }
    if (_footerSocialLinks.isEmpty) {
      print('🟠 [ContactEdit] _trySeed: footer links empty, waiting…');
      return;
    }
    _seedFromModel(_pendingContactModel!);
  }

  void _rematchSocialLinks() {
    if (_footerSocialLinks.isEmpty || _pendingContactModel == null) return;

    final modelIcons = _pendingContactModel!.socialIcons;
    bool changed = false;

    for (var i = 0; i < _socialLinkItems.length && i < modelIcons.length; i++) {
      final item     = _socialLinkItems[i];
      final modelUrl = modelIcons[i].link;
      if (item.selectedIndex == null && modelUrl.isNotEmpty) {
        final idx = _footerSocialLinks.indexWhere((l) => l.url == modelUrl);
        if (idx >= 0) {
          item.selectedIndex = idx;
          changed = true;
          print('🟢 [ContactEdit] rematch: ${item.id} → idx=$idx');
        }
      }
    }

    if (changed) setState(() {});
  }

  // ── Seed from model ───────────────────────────────────────────────────────

  void _seedFromModel(ContactUsCmsModel m) {
    if (_seeded) return;
    _seeded = true;
    print('🟢 [ContactEdit] _seedFromModel START');

    // Headings
    _titleEnCtrl.text     = m.headings.title.en;
    _titleArCtrl.text     = m.headings.title.ar;
    _shortDescEnCtrl.text = m.headings.shortDescription.en;
    _shortDescArCtrl.text = m.headings.shortDescription.ar;
    _headingSvgUrl        = m.headings.svgUrl;

    // Client Description
    _clientDescEnCtrl.text = m.clientDescription.description.en;
    _clientDescArCtrl.text = m.clientDescription.description.ar;
    _clientReasons.clear();
    for (final r in m.clientDescription.reasons) {
      final item = _ReasonItem(id: r.id, counter: ++_clientReasonCounter);
      item.labelEnCtrl.text = r.label.en;
      item.labelArCtrl.text = r.label.ar;
      item.isRequired       = r.isRequired;
      _clientReasons.add(item);
    }

    // Owner Description
    _ownerDescEnCtrl.text = m.ownerDescription.description.en;
    _ownerDescArCtrl.text = m.ownerDescription.description.ar;
    _ownerReasons.clear();
    for (final r in m.ownerDescription.reasons) {
      final item = _ReasonItem(id: r.id, counter: ++_ownerReasonCounter);
      item.labelEnCtrl.text = r.label.en;
      item.labelArCtrl.text = r.label.ar;
      item.isRequired       = r.isRequired;
      _ownerReasons.add(item);
    }

    // Social Links
    _socialLinkItems.clear();
    for (final s in m.socialIcons) {
      final item = _SocialLinkItem(id: s.id, counter: ++_socialLinkCounter);
      final idx = _footerSocialLinks.indexWhere((l) => l.url == s.link);
      item.selectedIndex = idx >= 0 ? idx : null;
      item.iconUrl       = s.iconUrl;
      _socialLinkItems.add(item);
    }

    print('🟢 [ContactEdit] _seedFromModel DONE');
  }

  // ── SVG picker ────────────────────────────────────────────────────────────

  Future<Uint8List?> _pickSvgOnly() async {
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
      final isSvgExt  = file.name.toLowerCase().endsWith('.svg');
      final isSvgMime = file.type == 'image/svg+xml' || file.type.contains('svg');

      if (!isSvgExt && !isSvgMime) {
        completer.complete(null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Only SVG files are allowed'),
              backgroundColor: _kRed,
              duration: const Duration(seconds: 2),
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
          (trimmed.startsWith('<?xml') && trimmed.contains('<svg'));
    } catch (e) {
      return false;
    }
  }

  // ── Build model ───────────────────────────────────────────────────────────

  ContactUsCmsModel _buildModel(String status) {
    print('🔵 [ContactEdit] _buildModel(status=$status)');

    // Social icons
    final socialIcons = <ContactSocialIcon>[];
    for (final s in _socialLinkItems) {
      final hasSelection = s.selectedIndex != null &&
          s.selectedIndex! < _footerSocialLinks.length;
      final selectedLink = hasSelection
          ? _footerSocialLinks[s.selectedIndex!]
          : null;

      final url     = selectedLink?.url ?? '';
      final iconUrl = (selectedLink != null && selectedLink.iconUrl.isNotEmpty)
          ? selectedLink.iconUrl
          : s.iconUrl;

      socialIcons.add(ContactSocialIcon(
        id:      s.id,
        iconUrl: iconUrl,
        link:    url,
      ));
    }

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
        reasons: _clientReasons.map((r) => ContactReasonItem(
          id:         r.id,
          label:      ContactBilingualText(
            en: r.labelEnCtrl.text.trim(),
            ar: r.labelArCtrl.text.trim(),
          ),
          isRequired: r.isRequired,
        )).toList(),
      ),
      ownerDescription: ContactDescriptionSection(
        description: ContactBilingualText(
          en: _ownerDescEnCtrl.text.trim(),
          ar: _ownerDescArCtrl.text.trim(),
        ),
        reasons: _ownerReasons.map((r) => ContactReasonItem(
          id:         r.id,
          label:      ContactBilingualText(
            en: r.labelEnCtrl.text.trim(),
            ar: r.labelArCtrl.text.trim(),
          ),
          isRequired: r.isRequired,
        )).toList(),
      ),
      socialIcons: socialIcons,
    );
  }

  // ── Collect uploads ───────────────────────────────────────────────────────

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_headingSvgBytes != null) {
      uploads['contact_cms/headings/svg'] = _headingSvgBytes!;
    }
    print('🟡 [ContactEdit] _collectUploads → ${uploads.length} files');
    return uploads;
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validate() {
    setState(() => _submitted = true);

    if (_titleEnCtrl.text.trim().isEmpty)     { print('🔴 validate FAIL: titleEn'); return false; }
    if (_titleArCtrl.text.trim().isEmpty)     { print('🔴 validate FAIL: titleAr'); return false; }
    if (_shortDescEnCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: shortDescEn'); return false; }
    if (_shortDescArCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: shortDescAr'); return false; }
    if (_headingSvgBytes == null && _headingSvgUrl.isEmpty) {
      print('🔴 validate FAIL: heading SVG missing');
      return false;
    }

    if (_clientDescEnCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: clientDescEn'); return false; }
    if (_clientDescArCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: clientDescAr'); return false; }
    for (final r in _clientReasons) {
      if (r.labelEnCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: client reason ${r.id} en'); return false; }
      if (r.labelArCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: client reason ${r.id} ar'); return false; }
    }

    if (_ownerDescEnCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: ownerDescEn'); return false; }
    if (_ownerDescArCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: ownerDescAr'); return false; }
    for (final r in _ownerReasons) {
      if (r.labelEnCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: owner reason ${r.id} en'); return false; }
      if (r.labelArCtrl.text.trim().isEmpty) { print('🔴 validate FAIL: owner reason ${r.id} ar'); return false; }
    }

    print('🟢 validate PASS');
    return true;
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save(String status) async {
    print('🟡 [ContactEdit] _save(status=$status) START');
    final model   = _buildModel(status);
    final uploads = _collectUploads();

    await context.read<ContactUsCmsCubit>().save(
      model:        model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
    print('🟢 [ContactEdit] _save(status=$status) DONE');
  }

  Future<void> _onSaveTap() async {
    print('🟡 [ContactEdit] _onSaveTap');
    if (!_validate()) return;

    await showPublishConfirmDialog(
      context:  context,
      title:    'EDITING CONTACT US DETAILS',
      subtitle: 'Do you want to save the changes made to this Contact Us page?',
      onConfirm: () => _save('published'),
    );

    print('🟢 [ContactEdit] dialog finished → navigating back');
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── Add / remove helpers ──────────────────────────────────────────────────

  void _addClientReason() {
    setState(() {
      _clientReasons.add(_ReasonItem(
        id: 'reason_client_${DateTime.now().millisecondsSinceEpoch}',
        counter: ++_clientReasonCounter,
      ));
    });
  }

  void _removeClientReason(String id) =>
      setState(() => _clientReasons.removeWhere((r) => r.id == id));

  void _addOwnerReason() {
    setState(() {
      _ownerReasons.add(_ReasonItem(
        id: 'reason_owner_${DateTime.now().millisecondsSinceEpoch}',
        counter: ++_ownerReasonCounter,
      ));
    });
  }

  void _removeOwnerReason(String id) =>
      setState(() => _ownerReasons.removeWhere((r) => r.id == id));

  void _addSocialLink() {
    setState(() {
      _socialLinkItems.add(_SocialLinkItem(
        id: 'social_${DateTime.now().millisecondsSinceEpoch}',
        counter: ++_socialLinkCounter,
      ));
    });
  }

  void _removeSocialLink(String id) =>
      setState(() => _socialLinkItems.removeWhere((s) => s.id == id));

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
              _                          => <SocialLinkModel>[],
            };
            print('🟡 [ContactEdit] HomeCms state → footer links=${links.length}');
            if (links.isNotEmpty) {
              setState(() => _footerSocialLinks = links);
              _trySeed();
            }
          },
        ),
        BlocListener<ContactUsCmsCubit, ContactUsCmsState>(
          listener: (context, state) {
            print('🟡 [ContactEdit] ContactUsCms state → ${state.runtimeType}');
            if (state is ContactUsCmsLoaded) {
              _pendingContactModel = state.data;
              _trySeed();
            }
          },
        ),
      ],
      child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          final isLoading =
              state is ContactUsCmsLoading || state is ContactUsCmsInitial;
          final waitingForSeed = !_seeded && !isLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF1F2ED),
            body: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
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
                                child: CircularProgressIndicator(
                                    color: _kPink),
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

  // ── Form ──────────────────────────────────────────────────────────────────

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

        // ── Headings ──
        _accordion(
          title:    'Headings',
          isOpen:   _headingsOpen,
          onToggle: () => setState(() => _headingsOpen = !_headingsOpen),
          child:    _headingsSection(),
        ),
        SizedBox(height: 10.h),

        // ── Client Description ──
        _accordion(
          title:    'Client Description',
          isOpen:   _clientDescOpen,
          onToggle: () => setState(() => _clientDescOpen = !_clientDescOpen),
          child:    _descriptionSection(
            descEnCtrl: _clientDescEnCtrl,
            descArCtrl: _clientDescArCtrl,
            reasons:    _clientReasons,
            onAddReason:    _addClientReason,
            onRemoveReason: _removeClientReason,
          ),
        ),
        SizedBox(height: 10.h),

        // ── Owner Description ──
        _accordion(
          title:    'Owner Description',
          isOpen:   _ownerDescOpen,
          onToggle: () => setState(() => _ownerDescOpen = !_ownerDescOpen),
          child:    _descriptionSection(
            descEnCtrl: _ownerDescEnCtrl,
            descArCtrl: _ownerDescArCtrl,
            reasons:    _ownerReasons,
            onAddReason:    _addOwnerReason,
            onRemoveReason: _removeOwnerReason,
          ),
        ),
        SizedBox(height: 10.h),

        // ── Social Media Links ──
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

  // ── Headings Section ──────────────────────────────────────────────────────

  Widget _headingsSection() {
    final svgMissing = _submitted && _headingSvgBytes == null && _headingSvgUrl.isEmpty;

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
            child: Text('SVG is required',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: _kRed)),
          ),
        SizedBox(height: 16.h),

        // Title EN/AR
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
                    hint: 'Text Here', fillColor: Colors.white,
                    controller: _titleEnCtrl, height: 42, maxLines: 1,
                    maxLength: 200, submitted: _submitted,
                    textDirection: TextDirection.ltr, textAlign: TextAlign.start,
                    onChanged: (_) => setState(() {}),
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
                    hint: 'أدخل النص هنا', fillColor: Colors.white,
                    controller: _titleArCtrl, height: 42, maxLines: 1,
                    maxLength: 200, submitted: _submitted,
                    textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Short Description EN
        _fieldLabel('Short Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here', fillColor: Colors.white,
          controller: _shortDescEnCtrl, height: 42, maxLines: 1,
          maxLength: 300, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 12.h),

        // Short Description AR
        _fieldLabelAr('وصف مختصر'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا', fillColor: Colors.white,
          controller: _shortDescArCtrl, height: 42, maxLines: 1,
          maxLength: 300, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ── Description Section (shared by Client & Owner) ────────────────────────

  Widget _descriptionSection({
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required List<_ReasonItem> reasons,
    required VoidCallback onAddReason,
    required void Function(String) onRemoveReason,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        // Description EN
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here', fillColor: Colors.white,
          controller: descEnCtrl, height: 100, maxLines: 4,
          maxLength: 500, showCharCount: true, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.start,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 12.h),

        // Description AR
        _fieldLabelAr('الوصف'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا', fillColor: Colors.white,
          controller: descArCtrl, height: 100, maxLines: 4,
          maxLength: 500, showCharCount: true, submitted: _submitted,
          textDirection: TextDirection.rtl, textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        // Reasons
        ...reasons.map((r) => _reasonEditItem(r, onRemoveReason)),

        // + Reason button
        GestureDetector(
          onTap: onAddReason,
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
                Text('Reason',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 13.sp,
                      fontWeight: FontWeight.w600, color: Colors.white,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ── Reason Edit Item ──────────────────────────────────────────────────────

  Widget _reasonEditItem(_ReasonItem r, void Function(String) onRemove) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _fieldLabel('Reason'),
              SizedBox(width: 20.w),
              Text('Required',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                      fontWeight: FontWeight.w500, color: Colors.black87)),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => setState(() => r.isRequired = !r.isRequired),
                child: _toggleSwitch(r.isRequired),
              ),
              const Spacer(),
              // Remove button (shown as red dot if more than 1 reason)
              GestureDetector(
                onTap: () => onRemove(r.id),
                child: Container(
                  width: 18.w, height: 18.h,
                  decoration: const BoxDecoration(
                    color: _kRed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  hint: 'Text Here', fillColor: Colors.white,
                  controller: r.labelEnCtrl, height: 42, maxLines: 1,
                  maxLength: 200, submitted: _submitted,
                  textDirection: TextDirection.ltr, textAlign: TextAlign.start,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabelAr('السبب'),
                    SizedBox(height: 4.h),
                    CustomValidatedTextFieldMaster(
                      hint: 'أدخل النص هنا', fillColor: Colors.white,
                      controller: r.labelArCtrl, height: 42, maxLines: 1,
                      maxLength: 200, submitted: _submitted,
                      textDirection: TextDirection.rtl, textAlign: TextAlign.right,
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
      width: 40.w, height: 22.h,
      decoration: BoxDecoration(
        color: isOn ? _kPink : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18.w, height: 18.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // ── Social Links Section ──────────────────────────────────────────────────

  Widget _socialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        if (_socialLinkItems.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing:  12.h,
              mainAxisExtent:   70.sp,
            ),
            itemCount:   _socialLinkItems.length,
            itemBuilder: (context, index) =>
                _socialLinkDropdownWidget(_socialLinkItems[index]),
          ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _addSocialLink,
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
                Text('Link',
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 13.sp,
                      fontWeight: FontWeight.w600, color: Colors.white,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _socialLinkDropdownWidget(_SocialLinkItem s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SocialLinkDropdown(
          footerLinks:   _footerSocialLinks,
          selectedIndex: s.selectedIndex,
          onChanged:     (idx) {
            setState(() => s.selectedIndex = idx);
          },
          submitted: _submitted,
        ),
      ],
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

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
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _kPink,
              borderRadius: isOpen
                  ? BorderRadius.circular(8)
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 16.sp,
                      fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white, size: 22.sp,
                ),
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
            child: child,
          ),
      ],
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: _kPink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactUsCmsPreviewPage(),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label: 'Save',
                color: _kPink,
                onTap: _onSaveTap,
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
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

  Widget _imageUploadCircle({
    required String       label,
    required Uint8List?   bytes,
    required String       url,
    required VoidCallback onTap,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 13.sp,
              fontWeight: FontWeight.w600, color: Colors.black87,
            )),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w, height: 64.h,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url))
                    : Icon(Icons.description_outlined,
                    color: Colors.grey[600], size: 28.sp),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 25.w, height: 25.h,
                    decoration: const BoxDecoration(
                      color: _kPink,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomSvg(
                        assetPath: "assets/control/camera.svg",
                        width: 10.w, height: 10.h, fit: BoxFit.scaleDown,
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

  Future<Uint8List> _loadSvg(String url) async {
    final response = await html.HttpRequest.request(
        url, method: 'GET', responseType: 'arraybuffer');
    if (response.status != 200)
      throw Exception('Failed to load SVG: ${response.status}');
    return (response.response as ByteBuffer).asUint8List();
  }

  Widget _fieldLabel(String text) => Text(text,
      style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
          fontWeight: FontWeight.w600, color: Colors.black87));

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(text,
        style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
            fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _btn({
    required String       label,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 48.h,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10.r)),
        child: Center(
          child: Text(label,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp,
                  fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL LINK DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialLinkDropdown extends StatelessWidget {
  final List<SocialLinkModel> footerLinks;
  final int?                  selectedIndex;
  final ValueChanged<int?>    onChanged;
  final bool                  submitted;

  const _SocialLinkDropdown({
    required this.footerLinks,
    required this.selectedIndex,
    required this.onChanged,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    if (footerLinks.isEmpty) {
      return Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14.w, height: 14.w,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: _kPink),
            ),
            SizedBox(width: 10.w),
            Text('Loading footer social links...',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                    color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final items = footerLinks.asMap().entries.map((entry) {
      final index  = entry.key;
      final link   = entry.value;
      final hasUrl = link.url.isNotEmpty;
      return DropdownMenuItem<int>(
        value:   index,
        enabled: hasUrl,
        child: Row(
          children: [
            if (link.iconUrl.isNotEmpty)
              SvgPicture.network(link.iconUrl,
                width: 18.w, height: 18.w, fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  hasUrl ? _kPink : Colors.grey.shade400,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) => Icon(Icons.link,
                    size: 16.sp,
                    color: hasUrl ? _kPink : Colors.grey.shade400),
              )
            else
              Icon(Icons.link, size: 16.sp,
                  color: hasUrl ? _kPink : Colors.grey.shade400),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hasUrl ? _truncateUrl(link.url) : 'Social ${index + 1} — no URL',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                    color: hasUrl ? Colors.black87 : Colors.grey.shade400,
                    fontStyle: hasUrl ? FontStyle.normal : FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }).toList();

    final selectedLink = selectedIndex != null &&
        selectedIndex! < footerLinks.length
        ? footerLinks[selectedIndex!]
        : null;

    Widget selectedDisplay() {
      if (selectedLink == null) {
        return Row(children: [
          Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400),
          SizedBox(width: 8.w),
          Text('Insert Links',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                  color: Colors.grey.shade400)),
        ]);
      }
      return Row(children: [
        if (selectedLink.iconUrl.isNotEmpty)
          SvgPicture.network(selectedLink.iconUrl,
              width: 18.w, height: 18.w, fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(_kPink, BlendMode.srcIn),
              placeholderBuilder: (_) =>
                  Icon(Icons.link, size: 16.sp, color: _kPink))
        else
          Icon(Icons.link, size: 16.sp, color: _kPink),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            selectedLink.url.isNotEmpty
                ? _truncateUrl(selectedLink.url)
                : 'Insert Links',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                color: Colors.black87),
          ),
        ),
      ]);
    }

    final selectedItemWidgets =
    List.generate(footerLinks.length, (_) => selectedDisplay());

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 20.sp, color: Colors.grey.shade600),
          hint: Row(children: [
            Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400),
            SizedBox(width: 8.w),
            Text('Insert Links',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp,
                    color: Colors.grey.shade400)),
          ]),
          selectedItemBuilder: (_) => selectedItemWidgets,
          items: items,
          onChanged: (idx) {
            if (idx == null) return;
            if (footerLinks[idx].url.isEmpty) return;
            onChanged(idx);
          },
        ),
      ),
    );
  }

  String _truncateUrl(String url) {
    final clean = url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    return clean.length > 38 ? '${clean.substring(0, 38)}…' : clean;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════════════

class _ReasonItem {
  final String id;
  final int    counter;
  final labelEnCtrl = TextEditingController();
  final labelArCtrl = TextEditingController();
  bool isRequired = false;
  _ReasonItem({required this.id, required this.counter});
}

class _SocialLinkItem {
  final String id;
  final int    counter;
  int?       selectedIndex;
  String     iconUrl = '';
  _SocialLinkItem({required this.id, required this.counter});
}