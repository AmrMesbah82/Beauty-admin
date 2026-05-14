// ******************* FILE INFO *******************
// File Name: contact_us_cms_preview_page.dart
// Updated: Rewritten to match OverviewPreviewPage pattern
//   - Desktop / Tablet / Mobile device frames with Transform.scale
//   - CustomSegmentedTabs for EN / AR toggle
//   - Back + Publish buttons
//   - _BrowserChrome bar
//   - All preview content moved into _PreviewContent widget

// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:beauty_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:beauty_admin/core/custom_dialog.dart';
import 'package:beauty_admin/core/custom_segmant_tab.dart';
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

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color border    = Color(0xFFE0E0E0);
}

class _PreviewConst {
  static const List<String> preferredLanguages = ['ar', 'en', 'other'];
  static const Map<String, String> preferredLanguageLabelsEn = {
    'ar': 'Arabic', 'en': 'English', 'other': 'Other',
  };

  static const List<String> targetAudienceEn = ['Female', 'Male', 'Both'];
  static const List<String> countriesEn      = ['Egypt', 'Saudi Arabia', 'UAE', 'Kuwait', 'Qatar'];
  static const List<String> noBranchesEn     = ['1', '2 To 4', '5 To 10', '+10'];
  static const List<String> servicesEn       = ['Hair', 'Skin', 'Nails', 'Makeup', 'Spa'];
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

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  900.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1100.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  900.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;

enum _PreviewDevice { desktop, tablet, mobile }

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
      backgroundColor: _C.back,
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
  _PreviewDevice _device      = _PreviewDevice.desktop;
  bool           _isEnglish   = true;
  bool           _isPublishing = false;

// In _PreviewBodyState class, update the _publish method:

  Future<void> _publish() async {
    setState(() => _isPublishing = true);
    try {
      await context.read<ContactUsCmsCubit>().save(model: widget.data);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _C.back,
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1000.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    AdminSubNavBar(activeIndex: 6),
                    SizedBox(height: 16.h),

                    Text(
                      'Preview Contact Us Details',
                      style: StyleText.fontSize45Weight600.copyWith(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Device tabs + Language toggle ──────────────────
                    Row(
                      children: [
                        _tab('Desktop', _PreviewDevice.desktop),
                        SizedBox(width: 24.w),
                        _tab('Tablet',  _PreviewDevice.tablet),
                        SizedBox(width: 24.w),
                        _tab('Mobile',  _PreviewDevice.mobile),
                        const Spacer(),
                        SizedBox(
                          width: 95.w,
                          height: 36.h,
                          child: CustomSegmentedTabs(
                            tabs: const ['ENG', 'AR'],
                            selectedIndex: _isEnglish ? 0 : 1,
                            onTabSelected: (i) =>
                                setState(() => _isEnglish = i == 0),
                            selectedColor:      _C.primary,
                            unselectedColor:    Colors.white,
                            selectedTextColor:  Colors.white,
                            unselectedTextColor: _C.labelText,
                            equalWidth: false,
                            containerPadding: EdgeInsets.symmetric(
                                horizontal: 8.sp, vertical: 4.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ── Preview frame ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: LayoutBuilder(
                        builder: (ctx, box) => _buildFrame(box.maxWidth),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Back + Publish ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF797979),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: Text('Back',
                                    style: StyleText.fontSize14Weight600
                                        .copyWith(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 300.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isPublishing
                                ? null
                                : () => showPublishConfirmDialog(
                              title:    'PUBLISHING CONTACT US',
                              subtitle: 'Do you want to publish this Contact Us page?',
                              context:  context,
                              onConfirm: _publish,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _isPublishing
                                    ? _C.primary.withOpacity(0.5)
                                    : _C.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: _isPublishing
                                    ? SizedBox(
                                  width: 18.w, height: 18.h,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                                    : Text('Publish',
                                    style: StyleText.fontSize14Weight600
                                        .copyWith(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isPublishing)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: const Center(
                child: CircularProgressIndicator(color: _C.primary)),
          ),
      ],
    );
  }

  // ── Tab widget ─────────────────────────────────────────────────────────────
  Widget _tab(String label, _PreviewDevice device) {
    final active = _device == device;
    return GestureDetector(
      onTap: () => setState(() => _device = device),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? _C.primary : _C.hintText,
                )),
          ),
          Container(
            height: 2,
            width: label.length * 8.0,
            color: active ? _C.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Frame dispatcher ───────────────────────────────────────────────────────
  Widget _buildFrame(double containerW) {
    switch (_device) {
      case _PreviewDevice.desktop:
        return _DesktopFrame(
            containerWidth: containerW,
            data: widget.data,
            isEnglish: _isEnglish);
      case _PreviewDevice.tablet:
        return _TabletFrame(
            containerWidth: containerW,
            data: widget.data,
            isEnglish: _isEnglish);
      case _PreviewDevice.mobile:
        return _MobileFrame(
            containerWidth: containerW,
            data: widget.data,
            isEnglish: _isEnglish);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP FRAME
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopFrame extends StatelessWidget {
  final double           containerWidth;
  final ContactUsCmsModel data;
  final bool             isEnglish;
  const _DesktopFrame({required this.containerWidth, required this.data, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final scale  = _safeScale(containerWidth / _kDesktopW);
    final frameH = _kDesktopH * scale;

    return Container(
      width: containerWidth,
      height: frameH + 28,
      decoration: BoxDecoration(color: _C.back),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            const _BrowserChrome(),
            SizedBox(
              width: containerWidth,
              height: frameH,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: _kDesktopW,
                  maxHeight: _kDesktopH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _kDesktopW,
                      child: _PreviewContent(
                        fakeWidth: _kDesktopW,
                        fakeHeight: _kDesktopH,
                        data: data,
                        isEnglish: isEnglish,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET FRAME
// ═══════════════════════════════════════════════════════════════════════════════

class _TabletFrame extends StatelessWidget {
  final double           containerWidth;
  final ContactUsCmsModel data;
  final bool             isEnglish;
  const _TabletFrame({required this.containerWidth, required this.data, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.55).clamp(280, 500);
    final double scale    = _safeScale(displayW / _kTabletW);
    final double displayH = _kTabletH * scale;

    return Column(
      children: [
        Center(
          child: Container(
            width:  displayW + 4,
            height: displayH + 28 + 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border, width: 2),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _BrowserChrome(compact: true),
                SizedBox(
                  width:  displayW,
                  height: displayH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kTabletW,
                      maxHeight: _kTabletH,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topLeft,
                        child: _PreviewContent(
                          fakeWidth:  _kTabletW,
                          fakeHeight: _kTabletH,
                          data:       data,
                          isEnglish:  isEnglish,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE FRAME
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileFrame extends StatelessWidget {
  final double           containerWidth;
  final ContactUsCmsModel data;
  final bool             isEnglish;
  const _MobileFrame({required this.containerWidth, required this.data, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final double displayW = (containerWidth * 0.35).clamp(200, 280);
    final double scale    = _safeScale(displayW / _kMobileW);
    final double displayH = _kMobileH * scale;

    return Column(
      children: [
        Center(
          child: Container(
            width:  displayW + 4,
            height: displayH + 24 + 12 + 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // ── Notch ────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width: displayW * 0.3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),

                // ── Content ──────────────────────────────────────────
                SizedBox(
                  width:  displayW,
                  height: displayH,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth:  _kMobileW,
                      maxHeight: _kMobileH,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topLeft,
                        child: _PreviewContent(
                          fakeWidth:  _kMobileW,
                          fakeHeight: _kMobileH,
                          data:       data,
                          isEnglish:  isEnglish,
                          isMobile:   true,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Home indicator ────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width: displayW * 0.3,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW CONTENT
// ═══════════════════════════════════════════════════════════════════════════════

class _PreviewContent extends StatefulWidget {
  final double           fakeWidth;
  final double           fakeHeight;
  final ContactUsCmsModel data;
  final bool             isEnglish;
  final bool             isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.data,
    required this.isEnglish,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  // ── Accordion open/close ──
  bool _headerOpen = true;
  bool _clientOpen = true;
  bool _ownerOpen  = true;

  // ── Form controllers ──
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _salonNameCtrl   = TextEditingController();
  final _salonNameArCtrl = TextEditingController();
  final _subjectCtrl     = TextEditingController();
  final _messageCtrl     = TextEditingController();

  String  _phoneCode         = '+20';
  String  _preferredLanguage = 'ar';
  String? _selectedTargetAudience;
  String? _selectedSalonCountry;
  String? _selectedNoBranches;
  String? _selectedServices;
  String? _selectedClientReason;
  String? _selectedOwnerReason;

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

  double get _hPad => widget.isMobile ? 16.0 : 30.0;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:        Size(widget.fakeWidth, widget.fakeHeight),
        padding:     EdgeInsets.zero,
        viewInsets:  EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color: _C.back,
          width: widget.fakeWidth,
          height: widget.fakeHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _headerSection(),
                const SizedBox(height: 16),
                _clientSection(),
                const SizedBox(height: 16),
                _ownerSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
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
            padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 12),
            decoration: BoxDecoration(
              color: _kPink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 15,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white, size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isOpen) child,
      ],
    );
  }

  // ── Header Section ─────────────────────────────────────────────────────────

  Widget _headerSection() {
    final data     = widget.data;
    final isEn     = widget.isEnglish;
    final title    = isEn
        ? (data.headings.title.en.isNotEmpty ? data.headings.title.en : 'Contact Us')
        : (data.headings.title.ar.isNotEmpty ? data.headings.title.ar : 'تواصل معنا');
    final subtitle = isEn
        ? (data.headings.shortDescription.en.isNotEmpty
        ? data.headings.shortDescription.en
        : 'Your Feedback Shapes Our Success!')
        : (data.headings.shortDescription.ar.isNotEmpty
        ? data.headings.shortDescription.ar
        : 'ملاحظاتك تشكل نجاحنا!');

    return _accordion(
      title:    'Header',
      isOpen:   _headerOpen,
      onToggle: () => setState(() => _headerOpen = !_headerOpen),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 24),
        decoration: const BoxDecoration(

          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: widget.isMobile ? 80 : 160,
              child: data.headings.svgUrl.isNotEmpty
                  ? SvgPicture.network(data.headings.svgUrl,
                  width: widget.isMobile ? 80 : 160,
                  height: widget.isMobile ? 70 : 140,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) =>
                      Icon(Icons.image_outlined, size: 60, color: _kPink))
                  : SvgPicture.asset('assets/spa_core.svg',
                  width: widget.isMobile ? 80 : 160,
                  height: widget.isMobile ? 70 : 140,
                  fit: BoxFit.contain),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: widget.isMobile ? 18 : 24,
                          fontWeight: FontWeight.w900,
                          color: _kPink)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: widget.isMobile ? 11 : 13,
                          color: Colors.black87,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Client Section ─────────────────────────────────────────────────────────

  Widget _clientSection() {
    final data      = widget.data;
    final isEn      = widget.isEnglish;
    final desc      = isEn
        ? data.clientDescription.description.en
        : data.clientDescription.description.ar;
    final reasons   = data.clientDescription.reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map((r) => {'key': r.id, 'value': isEn ? r.label.en : r.label.ar})
        .toList();

    return _accordion(
      title:    'Client',
      isOpen:   _clientOpen,
      onToggle: () => setState(() => _clientOpen = !_clientOpen),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric( vertical: 24),
        decoration: const BoxDecoration(

          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: widget.isMobile
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(desc,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black87, height: 1.7)),
              ),
            _clientFormCard(reasons),
          ],
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                desc.isNotEmpty ? desc :
                'At Beauty, we firmly believe that feedback is the lifeblood of our success.',
                style: const TextStyle(
                    fontSize: 12, color: Colors.black87, height: 1.7),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: _clientFormCard(reasons)),
          ],
        ),
      ),
    );
  }

  Widget _clientFormCard(List<Map<String, String>> reasons) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: widget.isEnglish ? 'Preferred Language' : 'اللغة المفضلة'),
          const SizedBox(height: 6),
          _langRadioRow(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _previewField('First Name *', _firstNameCtrl, iconPath: 'assets/contact/name.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('Last Name *',  _lastNameCtrl,  iconPath: 'assets/contact/name.svg')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewField('Enter Your Email *', _emailCtrl, iconPath: 'assets/contact/sms.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewPhoneField()),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewDropdown('Gender',
                  _PreviewConst.targetAudienceEn.map((t) => {'key': t, 'value': t}).toList(),
                  null, (_) {}, iconPath: 'assets/contact/Target audience of salon .svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewDropdown('Country',
                  _PreviewConst.countriesEn.map((c) => {'key': c, 'value': c}).toList(),
                  null, (_) {}, iconPath: 'assets/contact/Country of salon.svg')),
            ],
          ),
          _previewField('Subject *', _subjectCtrl, iconPath: 'assets/contact/Subject .svg'),
          if (reasons.isNotEmpty)
            _previewDropdown('Reason', reasons, _selectedClientReason,
                    (v) => setState(() => _selectedClientReason = v),
                iconPath: 'assets/contact/Reason.svg'),
          _previewField('Message *', _messageCtrl,
              iconPath: 'assets/contact/Message.svg', maxLines: 3, fieldHeight: 72),
          const SizedBox(height: 8),
          _sendButton(),
        ],
      ),
    );
  }

  // ── Owner Section ──────────────────────────────────────────────────────────

  Widget _ownerSection() {
    final data    = widget.data;
    final isEn    = widget.isEnglish;
    final desc    = isEn
        ? data.ownerDescription.description.en
        : data.ownerDescription.description.ar;
    final reasons = data.ownerDescription.reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map((r) => {'key': r.id, 'value': isEn ? r.label.en : r.label.ar})
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _hPad),
      child: _accordion(
        title:    'Owner',
        isOpen:   _ownerOpen,
        onToggle: () => setState(() => _ownerOpen = !_ownerOpen),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric( vertical: 24),
          decoration: const BoxDecoration(

            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: widget.isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (desc.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(desc,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87, height: 1.7)),
                ),
              _ownerFormCard(reasons),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  desc.isNotEmpty ? desc :
                  'At Beauty, we firmly believe that feedback is the lifeblood of our success.',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black87, height: 1.7),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _ownerFormCard(reasons)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ownerFormCard(List<Map<String, String>> reasons) {
    final targetItems  = _PreviewConst.targetAudienceEn.map((t) => {'key': t, 'value': t}).toList();
    final countryItems = _PreviewConst.countriesEn.map((c) => {'key': c, 'value': c}).toList();
    final branchItems  = _PreviewConst.noBranchesEn.map((b) => {'key': b, 'value': b}).toList();
    final serviceItems = _PreviewConst.servicesEn.map((s) => {'key': s, 'value': s}).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Personal Info'),
          const SizedBox(height: 6),
          const _FormLabel('Preferred Language'),
          const SizedBox(height: 6),
          _langRadioRow(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _previewField('First Name *', _firstNameCtrl, iconPath: 'assets/contact/name.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('Last Name *',  _lastNameCtrl,  iconPath: 'assets/contact/name.svg')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewField('Enter Your Email *', _emailCtrl, iconPath: 'assets/contact/sms.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewPhoneField()),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'Salon Info'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _previewField('Salon Name *',    _salonNameCtrl,   iconPath: 'assets/contact/salon_name.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('اسم الصالون *',   _salonNameArCtrl, iconPath: 'assets/contact/salon_name.svg',
                  textDirection: TextDirection.rtl, textAlign: TextAlign.right)),
            ],
          ),
          _previewDropdown('Target audience of salon *', targetItems,
              _selectedTargetAudience, (v) => setState(() => _selectedTargetAudience = v),
              iconPath: 'assets/contact/Target audience of salon .svg'),
          Row(
            children: [
              Expanded(child: _previewDropdown('Country of salon', countryItems,
                  _selectedSalonCountry, (v) => setState(() => _selectedSalonCountry = v),
                  iconPath: 'assets/contact/Country of salon.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('City of salon', TextEditingController(),
                  iconPath: 'assets/contact/City of salon.svg')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewDropdown('No.Branches', branchItems,
                  _selectedNoBranches, (v) => setState(() => _selectedNoBranches = v),
                  iconPath: 'assets/contact/No.Branches.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewDropdown('Services', serviceItems,
                  _selectedServices, (v) => setState(() => _selectedServices = v),
                  iconPath: 'assets/contact/Services.svg')),
            ],
          ),
          _previewField('Subject *', _subjectCtrl, iconPath: 'assets/contact/Subject .svg'),
          if (reasons.isNotEmpty)
            _previewDropdown('Reason', reasons, _selectedOwnerReason,
                    (v) => setState(() => _selectedOwnerReason = v),
                iconPath: 'assets/contact/Reason.svg'),
          _previewField('Message *', _messageCtrl,
              iconPath: 'assets/contact/Message.svg', maxLines: 3, fieldHeight: 72),
          const SizedBox(height: 8),
          _sendButton(),
        ],
      ),
    );
  }

  // ── Shared widgets ─────────────────────────────────────────────────────────

  Widget _langRadioRow() {
    return Row(
      children: _PreviewConst.preferredLanguages.map((lang) {
        final bool selected = _preferredLanguage == lang;
        final lbl = _PreviewConst.preferredLanguageLabelsEn[lang] ?? lang;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 20),
          child: GestureDetector(
            onTap: () => setState(() => _preferredLanguage = lang),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _kPink : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _kPink),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 5),
                Text(lbl,
                    style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.black87 : Colors.black54)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _previewField(String label, TextEditingController controller, {
    String? iconPath,
    TextDirection textDirection = TextDirection.ltr,
    TextAlign textAlign         = TextAlign.start,
    int maxLines                = 1,
    double fieldHeight          = 32,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w500, color: Color(0xFF333333))),
        const SizedBox(height: 3),
        Container(
          height: fieldHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (iconPath != null)
                Padding(
                  padding: EdgeInsets.only(left: 8, top: maxLines > 1 ? 8 : 0),
                  child: SvgPicture.asset(iconPath,
                      width: 14, height: 14,
                      colorFilter: ColorFilter.mode(
                          Colors.grey.shade400, BlendMode.srcIn),
                      placeholderBuilder: (_) =>
                          Icon(Icons.edit_outlined, size: 14, color: Colors.grey.shade400)),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines:   maxLines,
                  textDirection: textDirection,
                  textAlign:  textAlign,
                  cursorColor: _kPink,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Text Here',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 6, vertical: maxLines > 1 ? 8 : 0),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _previewDropdown(String label, List<Map<String, String>> items,
      String? value, ValueChanged<String?> onChanged, {String? iconPath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 3),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items:         items,
          onChanged:     onChanged,
          width:         double.infinity,
          height:        32,
          borderRadius:  4,
          widthIcon:     14,
          heightIcon:    14,
          iconPath:      iconPath,
          primaryColor:  _kPink,
          hint: Text('Select',
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  color: Colors.grey.shade400)),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _previewPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone Number *',
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w500, color: Color(0xFF333333))),
        const SizedBox(height: 3),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    end: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: CustomDropdownFormFieldInvMaster(
                  selectedValue: _phoneCode,
                  items:         _phoneCodes,
                  onChanged:     (v) => setState(() => _phoneCode = v ?? _phoneCode),
                  widthIcon:     14,
                  heightIcon:    14,
                  width:         100,
                  height:        32,
                  borderRadius:  0,
                  primaryColor:  _kPink,
                  hint: Text('Code',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ),
              ),
              Expanded(
                child: TextField(
                  controller:      _phoneCtrl,
                  keyboardType:    TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor:     _kPink,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  decoration: InputDecoration(
                    hintText:  'Phone Number',
                    hintStyle: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _sendButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: _kPink,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        child: const Text('SEND',
            style: TextStyle(
                color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w600, letterSpacing: 1.2)),
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
      style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 13,
          fontWeight: FontWeight.w700, color: _kPink));
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 12,
          fontWeight: FontWeight.w500, color: Color(0xFF333333)));
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _BrowserChrome extends StatelessWidget {
  final bool compact;
  const _BrowserChrome({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double h = compact ? 22 : 28;
    return Container(
      height: h,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 4),
          _dot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 4),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: compact ? 10 : 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}