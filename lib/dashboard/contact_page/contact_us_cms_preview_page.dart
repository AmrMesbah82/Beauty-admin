// ******************* FILE INFO *******************
// File Name: contact_us_cms_preview_page.dart
// UPDATED: Complete rewrite to match new Figma design
//          - "Preview Contact Us Details" title
//          - Desktop / Tablet / Mobile preview tabs
//          - EN / AR language toggle buttons
//          - Header accordion (illustration + Contact Us title + subtitle)
//          - Client accordion (left description text + right form with Personal Info)
//          - Owner accordion (left description text + right form with Personal Info + Salon Info)
//          - Social icons section removed (not in new design)

// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:beauty_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:beauty_admin/core/widget/custom_dropdwon.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/theme/text.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_footer.dart';

import '../../model/contact_us/contact_model_location.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

const Color _kPink = Color(0xFFD16F9A);

class _PreviewConst {
  static const List<String> preferredLanguages = ['ar', 'en', 'other'];
  static const Map<String, String> preferredLanguageLabelsEn = {
    'ar': 'Arabic', 'en': 'English', 'other': 'Other',
  };
  static const Map<String, String> preferredLanguageLabelsAr = {
    'ar': 'العربية', 'en': 'الإنجليزية', 'other': 'أخرى',
  };

  static const List<String> targetAudienceEn = ['Female', 'Male', 'Both'];
  static const List<String> countriesEn = ['Egypt', 'Saudi Arabia', 'UAE', 'Kuwait', 'Qatar'];
  static const List<String> noBranchesEn = ['1', '2 To 4', '5 To 10', '+10'];
  static const List<String> servicesEn = ['Hair', 'Skin', 'Nails', 'Makeup', 'Spa'];
}

const List<Map<String, String>> _phoneCodes = [
  {'key': '+20',  'value': '🇪🇬 +20'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+44',  'value': '🇬🇧 +44'},
  {'key': '+1',   'value': '🇺🇸 +1'},
];

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY
// ═══════════════════════════════════════════════════════════════════════════════

class ContactUsCmsPreviewPage extends StatelessWidget {
  const ContactUsCmsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactUsCmsCubit()..load(),
      child: const _PreviewView(),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          if (state is ContactUsCmsLoading || state is ContactUsCmsInitial) {
            return const Center(child: CircularProgressIndicator(color: _kPink));
          }
          if (state is ContactUsCmsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ContactUsCmsCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is ContactUsCmsLoaded) {
            return _PreviewBody(data: state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _PreviewBody extends StatefulWidget {
  final ContactUsCmsModel data;
  const _PreviewBody({required this.data});

  @override
  State<_PreviewBody> createState() => _PreviewBodyState();
}

class _PreviewBodyState extends State<_PreviewBody> {
  // ── Preview mode tabs ──
  int _previewTab = 0; // 0=Desktop, 1=Tablet, 2=Mobile
  bool _isEnglish = true;

  // ── Accordion open/close ──
  bool _headerOpen = true;
  bool _clientOpen = true;
  bool _ownerOpen  = true;

  // ── Form controllers (preview only) ──
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _salonNameCtrl  = TextEditingController();
  final _salonNameArCtrl = TextEditingController();
  final _subjectCtrl    = TextEditingController();
  final _messageCtrl    = TextEditingController();

  String _phoneCode          = '+20';
  String _preferredLanguage  = 'ar';
  String? _selectedTargetAudience;
  String? _selectedSalonCountry;
  String? _selectedSalonCity;
  String? _selectedNoBranches;
  String? _selectedServices;
  String? _selectedReason;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _salonNameCtrl.dispose();
    _salonNameArCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          AdminSubNavBar(activeIndex: 6),
          SizedBox(height: 20.h),

          // ── Title + controls ──
          Container(
            width: 1000.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview Contact Us Details',
                    style: StyleText.fontSize45Weight600.copyWith(
                        fontSize: 32.sp, color: _kPink,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 16.h),

                // ── Preview tabs + language toggle ──
                Row(
                  children: [
                    _previewTabButton('Desktop', 0),
                    SizedBox(width: 12.w),
                    _previewTabButton('Tablet', 1),
                    SizedBox(width: 12.w),
                    _previewTabButton('Mobile', 2),
                    const Spacer(),
                    _langToggle('En', true),
                    SizedBox(width: 8.w),
                    _langToggle('Ar', false),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),

          // ── Preview content ──
          Container(
            width: 1000.w,
            child: Column(
              children: [
                // ── Header Accordion ──
                _accordion(
                  title:  'Header',
                  isOpen: _headerOpen,
                  onToggle: () => setState(() => _headerOpen = !_headerOpen),
                  child: _headerSection(),
                ),
                SizedBox(height: 20.h),

                // ── Client Accordion ──
                _accordion(
                  title:  'Client',
                  isOpen: _clientOpen,
                  onToggle: () => setState(() => _clientOpen = !_clientOpen),
                  child: _clientSection(),
                ),
                SizedBox(height: 20.h),

                // ── Owner Accordion ──
                _accordion(
                  title:  'Owner',
                  isOpen: _ownerOpen,
                  onToggle: () => setState(() => _ownerOpen = !_ownerOpen),
                  child: _ownerSection(),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),

          const AppFooter(),
        ],
      ),
    );
  }

  // ── Preview Tab Button ────────────────────────────────────────────────────

  Widget _previewTabButton(String label, int index) {
    final isSelected = _previewTab == index;
    return GestureDetector(
      onTap: () => setState(() => _previewTab = index),
      child: Text(label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: isSelected ? _kPink : Colors.grey.shade500,
            decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
            decorationColor: _kPink,
          )),
    );
  }

  Widget _langToggle(String label, bool isEn) {
    final isSelected = _isEnglish == isEn;
    return GestureDetector(
      onTap: () => setState(() => _isEnglish = isEn),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? _kPink : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(label,
            style: TextStyle(
              fontFamily: 'Cairo', fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            )),
      ),
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
                  ? BorderRadius.vertical(top: Radius.circular(8.r))
                  : BorderRadius.circular(8.r),
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
        if (isOpen) child,
      ],
    );
  }

  // ── Header Section ────────────────────────────────────────────────────────

  Widget _headerSection() {
    final data = widget.data;
    final title = _isEnglish
        ? (data.headings.title.en.isNotEmpty ? data.headings.title.en : 'Contact Us')
        : (data.headings.title.ar.isNotEmpty ? data.headings.title.ar : 'تواصل معنا');
    final subtitle = _isEnglish
        ? (data.headings.shortDescription.en.isNotEmpty
        ? data.headings.shortDescription.en
        : 'Your Feedback Shapes Our Success: Join Us in Building a Better Experience!')
        : (data.headings.shortDescription.ar.isNotEmpty
        ? data.headings.shortDescription.ar
        : 'ملاحظاتك تشكل نجاحنا: انضم إلينا في بناء تجربة أفضل!');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left illustration
          SizedBox(
            width: 200.w,
            child: data.headings.svgUrl.isNotEmpty
                ? SvgPicture.network(data.headings.svgUrl,
                width: 200.w, height: 180.h, fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                    Icon(Icons.image_outlined, size: 80.w, color: _kPink))
                : SvgPicture.asset('assets/spa_core.svg',
                width: 200.w, height: 180.h, fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                    Icon(Icons.image_outlined, size: 80.w, color: _kPink)),
          ),
          SizedBox(width: 30.w),

          // Right text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: StyleText.fontSize45Weight600.copyWith(
                        fontSize: 28.sp, color: _kPink,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 8.h),
                Text(subtitle,
                    style: StyleText.fontSize16Weight600.copyWith(
                        fontSize: 14.sp, color: Colors.black87,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Client Section ────────────────────────────────────────────────────────

  Widget _clientSection() {
    final data = widget.data;
    final desc = _isEnglish
        ? data.clientDescription.description.en
        : data.clientDescription.description.ar;
    final defaultDesc = _isEnglish
        ? 'At Beauty, we firmly believe that feedback is the lifeblood of our success. '
        'We value your thoughts, opinions, and suggestions as they shape our products, '
        'services, and overall customer experience. Your voice matters, and we are committed '
        'to creating a platform that truly meets your needs.'
        : '';

    // Build reason items for dropdown
    final reasons = data.clientDescription.reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map((r) => {
      'key':   r.id,
      'value': _isEnglish ? r.label.en : r.label.ar,
    }).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left description text
          Expanded(
            flex: 2,
            child: Text(
              desc.isNotEmpty ? desc : defaultDesc,
              style: StyleText.fontSize13Weight400.copyWith(
                  fontSize: 12.sp, color: Colors.black87, height: 1.7),
            ),
          ),
          SizedBox(width: 24.w),

          // Right form card
          Expanded(
            flex: 3,
            child: _clientFormCard(reasons),
          ),
        ],
      ),
    );
  }

  Widget _clientFormCard(List<Map<String, String>> reasons) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferred Language
          _SectionHeader(title: _isEnglish ? 'Preferred Language' : 'اللغة المفضلة'),
          SizedBox(height: 6.h),
          Row(
            children: _PreviewConst.preferredLanguages.map((lang) {
              final bool selected = _preferredLanguage == lang;
              final lbl = _PreviewConst.preferredLanguageLabelsEn[lang] ?? lang;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 20.w),
                child: GestureDetector(
                  onTap: () => setState(() => _preferredLanguage = lang),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18.w, height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? _kPink : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? Center(child: Container(
                          width: 10.w, height: 10.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _kPink),
                        ))
                            : null,
                      ),
                      SizedBox(width: 6.w),
                      Text(lbl,
                          style: StyleText.fontSize13Weight400.copyWith(
                              color: selected ? Colors.black87 : Colors.black54,
                              fontSize: 13.sp)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),

          // First + Last name
          Row(
            children: [
              Expanded(child: _previewField('First Name *', _firstNameCtrl,
                  iconPath: 'assets/contact/name.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewField('Last Name *', _lastNameCtrl,
                  iconPath: 'assets/contact/name.svg')),
            ],
          ),

          // Email + Phone
          Row(
            children: [
              Expanded(child: _previewField('Enter Your Email *', _emailCtrl,
                  iconPath: 'assets/contact/sms.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewPhoneField()),
            ],
          ),

          // Gender + Country (client has these simpler fields)
          Row(
            children: [
              Expanded(child: _previewDropdown('Gender',
                  _PreviewConst.targetAudienceEn.map((t) => {'key': t, 'value': t}).toList(),
                  null, (_) {},
                  iconPath: 'assets/contact/Target audience of salon .svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewDropdown('Country',
                  _PreviewConst.countriesEn.map((c) => {'key': c, 'value': c}).toList(),
                  null, (_) {},
                  iconPath: 'assets/contact/Country of salon.svg')),
            ],
          ),

          // Subject
          _previewField('Subject *', _subjectCtrl,
              iconPath: 'assets/contact/Subject .svg'),

          // Reason
          if (reasons.isNotEmpty)
            _previewDropdown('Reason', reasons, _selectedReason,
                    (v) => setState(() => _selectedReason = v),
                iconPath: 'assets/contact/Reason.svg'),

          // Message
          _previewField('Message *', _messageCtrl,
              iconPath: 'assets/contact/Message.svg',
              maxLines: 3, fieldHeight: 72),

          SizedBox(height: 8.h),
          _sendButton(),
        ],
      ),
    );
  }

  // ── Owner Section ─────────────────────────────────────────────────────────

  Widget _ownerSection() {
    final data = widget.data;
    final desc = _isEnglish
        ? data.ownerDescription.description.en
        : data.ownerDescription.description.ar;
    final defaultDesc = _isEnglish
        ? 'At Beauty, we firmly believe that feedback is the lifeblood of our success. '
        'We value your thoughts, opinions, and suggestions as they shape our products, '
        'services, and overall customer experience. Your voice matters, and we are committed '
        'to creating a platform that truly meets your needs.'
        : '';

    final reasons = data.ownerDescription.reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map((r) => {
      'key':   r.id,
      'value': _isEnglish ? r.label.en : r.label.ar,
    }).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left description text
          Expanded(
            flex: 2,
            child: Text(
              desc.isNotEmpty ? desc : defaultDesc,
              style: StyleText.fontSize13Weight400.copyWith(
                  fontSize: 12.sp, color: Colors.black87, height: 1.7),
            ),
          ),
          SizedBox(width: 24.w),

          // Right form card
          Expanded(
            flex: 3,
            child: _ownerFormCard(reasons),
          ),
        ],
      ),
    );
  }

  Widget _ownerFormCard(List<Map<String, String>> reasons) {
    final targetItems = _PreviewConst.targetAudienceEn
        .map((t) => {'key': t, 'value': t}).toList();
    final countryItems = _PreviewConst.countriesEn
        .map((c) => {'key': c, 'value': c}).toList();
    final branchItems = _PreviewConst.noBranchesEn
        .map((b) => {'key': b, 'value': b}).toList();
    final serviceItems = _PreviewConst.servicesEn
        .map((s) => {'key': s, 'value': s}).toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Personal Info'),
          SizedBox(height: 6.h),

          // Preferred Language
          _FormLabel('Preferred Language'),
          SizedBox(height: 6.h),
          Row(
            children: _PreviewConst.preferredLanguages.map((lang) {
              final bool selected = _preferredLanguage == lang;
              final lbl = _PreviewConst.preferredLanguageLabelsEn[lang] ?? lang;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 20.w),
                child: GestureDetector(
                  onTap: () => setState(() => _preferredLanguage = lang),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18.w, height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? _kPink : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? Center(child: Container(
                          width: 10.w, height: 10.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _kPink),
                        ))
                            : null,
                      ),
                      SizedBox(width: 6.w),
                      Text(lbl,
                          style: StyleText.fontSize13Weight400.copyWith(
                              color: selected ? Colors.black87 : Colors.black54,
                              fontSize: 13.sp)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),

          // First + Last name
          Row(
            children: [
              Expanded(child: _previewField('First Name *', _firstNameCtrl,
                  iconPath: 'assets/contact/name.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewField('Last Name *', _lastNameCtrl,
                  iconPath: 'assets/contact/name.svg')),
            ],
          ),

          // Email + Phone
          Row(
            children: [
              Expanded(child: _previewField('Enter Your Email *', _emailCtrl,
                  iconPath: 'assets/contact/sms.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewPhoneField()),
            ],
          ),

          SizedBox(height: 16.h),
          _SectionHeader(title: 'Salon Info'),
          SizedBox(height: 8.h),

          // Salon Name EN + AR
          Row(
            children: [
              Expanded(child: _previewField('Salon Name *', _salonNameCtrl,
                  iconPath: 'assets/contact/salon_name.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewField('اسم الصالون *', _salonNameArCtrl,
                  iconPath: 'assets/contact/salon_name.svg',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right)),
            ],
          ),

          // Target audience
          _previewDropdown('Target audience of salon *', targetItems,
              _selectedTargetAudience, (v) => setState(() => _selectedTargetAudience = v),
              iconPath: 'assets/contact/Target audience of salon .svg'),

          // Country + City
          Row(
            children: [
              Expanded(child: _previewDropdown('Country of salon', countryItems,
                  _selectedSalonCountry, (v) => setState(() => _selectedSalonCountry = v),
                  iconPath: 'assets/contact/Country of salon.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewField('City of salon', TextEditingController(),
                  iconPath: 'assets/contact/City of salon.svg')),
            ],
          ),

          // Branches + Services
          Row(
            children: [
              Expanded(child: _previewDropdown('No.Branches', branchItems,
                  _selectedNoBranches, (v) => setState(() => _selectedNoBranches = v),
                  iconPath: 'assets/contact/No.Branches.svg')),
              SizedBox(width: 12.w),
              Expanded(child: _previewDropdown('Services', serviceItems,
                  _selectedServices, (v) => setState(() => _selectedServices = v),
                  iconPath: 'assets/contact/Services.svg')),
            ],
          ),

          // Subject
          _previewField('Subject *', _subjectCtrl,
              iconPath: 'assets/contact/Subject .svg'),

          // Reason
          if (reasons.isNotEmpty)
            _previewDropdown('Reason', reasons, _selectedReason,
                    (v) => setState(() => _selectedReason = v),
                iconPath: 'assets/contact/Reason.svg'),

          // Message
          _previewField('Message *', _messageCtrl,
              iconPath: 'assets/contact/Message.svg',
              maxLines: 3, fieldHeight: 72),

          SizedBox(height: 8.h),
          _sendButton(),
        ],
      ),
    );
  }

  // ── Shared preview form widgets ───────────────────────────────────────────

  Widget _previewField(String label, TextEditingController controller, {
    String? iconPath,
    TextDirection textDirection = TextDirection.ltr,
    TextAlign textAlign = TextAlign.start,
    int maxLines = 1,
    double fieldHeight = 32,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.text, fontSize: 14.sp)),
        SizedBox(height: 3.h),
        Container(
          height: fieldHeight.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (iconPath != null)
                Padding(
                  padding: EdgeInsets.only(left: 10.w, top: maxLines > 1 ? 10.h : 0),
                  child: SvgPicture.asset(iconPath,
                      width: 16.w, height: 16.w,
                      colorFilter: ColorFilter.mode(
                          Colors.grey.shade400, BlendMode.srcIn),
                      placeholderBuilder: (_) =>
                          Icon(Icons.edit_outlined, size: 16.w, color: Colors.grey.shade400)),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  textDirection: textDirection,
                  textAlign: textAlign,
                  cursorColor: _kPink,
                  style: StyleText.fontSize13Weight400.copyWith(
                      color: Colors.black87, fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'Text Here',
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryBlack, fontSize: 12.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: maxLines > 1 ? 10.h : 0),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _previewDropdown(String label, List<Map<String, String>> items,
      String? value, ValueChanged<String?> onChanged, {String? iconPath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        SizedBox(height: 3.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items:         items,
          onChanged:     onChanged,
          width:         double.infinity,
          height:        32,
          borderRadius:  4,
          widthIcon:     16,
          heightIcon:    16,
          iconPath:      iconPath,
          primaryColor:  _kPink,
          hint: Text('Select',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryBlack)),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _previewPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number *',
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.text, fontSize: 14.sp)),
        SizedBox(height: 3.h),
        Container(
          height: 32.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              Container(
                height: 32.h,
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    end: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: CustomDropdownFormFieldInvMaster(
                  selectedValue: _phoneCode,
                  items:         _phoneCodes,
                  onChanged:     (v) => setState(() => _phoneCode = v ?? _phoneCode),
                  widthIcon:     16,
                  heightIcon:    16,
                  width:         110.w,
                  height:        32,
                  borderRadius:  0,
                  primaryColor:  _kPink,
                  hint: Text('Code',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryBlack)),
                ),
              ),
              Expanded(
                child: TextField(
                  controller:      _phoneCtrl,
                  keyboardType:    TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor:     _kPink,
                  style: StyleText.fontSize13Weight400.copyWith(
                      color: Colors.black87, fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText:  'Phone Number',
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryBlack, fontSize: 12.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _sendButton() {
    return SizedBox(
      width: double.infinity,
      height: 38.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: _kPink,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
            elevation: 0),
        child: Text('SEND',
            style: StyleText.fontSize16Weight600.copyWith(
                color: Colors.white, fontSize: 14.sp,
                letterSpacing: 1.2)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: StyleText.fontSize16Weight600.copyWith(
          color: _kPink, fontSize: 14.sp));
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.text, fontSize: 14.sp));
}