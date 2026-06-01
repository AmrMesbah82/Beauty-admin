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

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';
import '../../../../../core/widgets/textfield.dart';
import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../data/models/contact_us_model_location.dart';
import '../../controller/contact_us_location_cubit.dart';
import '../../controller/contact_us_location_state.dart';
import 'contact_us_preview.dart';
import 'dart:convert';
import 'dart:ui_web' as ui_web;
import 'package:beauty_admin/core/constants/color.dart';

part '../widgets/contact_us_edit/social_link_dropdown.dart';
part '../widgets/contact_us_edit/reason_item.dart';
part '../widgets/contact_us_edit/social_link_item.dart';
part '../widgets/contact_us_edit/logic_helpers.dart';
part '../widgets/contact_us_edit/form_sections.dart';
part '../widgets/contact_us_edit/ui_helpers.dart';

String _svgBytesToDataUrl(Uint8List bytes) {
  final base64 = base64Encode(bytes);
  return 'data:image/svg+xml;base64,$base64';
}


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
              setState(() => _footerSocialLinks = links);
              _trySeed();
            }
          },
        ),
        BlocListener<ContactUsCmsCubit, ContactUsCmsState>(
          listener: (context, state) {
            if (state is ContactUsCmsLoaded) {
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
            backgroundColor: ColorPick.background,
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
                                    padding:
                                        EdgeInsets.symmetric(vertical: 100.h),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: ColorPick.primary),
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
            color:      ColorPick.primary,
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL LINK DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════
