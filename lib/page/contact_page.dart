// ******************* FILE INFO *******************
// File Name: contact_page.dart  (public-facing website page)
// Created by: Amr Mesbah
// UPDATED: Full redesign to match Figma — Client/Owner toggle,
//          illustration left panel, Personal Info + Salon Info sections,
//          pink selectable option cards, simplified success dialog.
//          PRIMARY COLOR: Fully dynamic from HomeCmsCubit branding.
//          OTP verification via Twilio before form submission.
//          SendGrid sends emails on submit.
//          Full AR / EN bilingual support with RTL/LTR.
//          All sizes normalized to match main.dart ScreenUtil design sizes:
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile (<768)   → 375×812

import 'dart:async';

import 'package:beauty_admin/controller/home/lang_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:beauty_admin/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:beauty_admin/controller/contact_us/contacu_us_location_state.dart';
import 'package:beauty_admin/controller/contact_us/contatc_us_cubit.dart';
import 'package:beauty_admin/controller/contact_us/contatc_us_state.dart';

import 'package:beauty_admin/core/widget/button.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/custom_dropdwon.dart';
import 'package:beauty_admin/core/widget/textfield.dart';

import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/theme/text.dart';
import 'package:beauty_admin/widgets/app_footer.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';

import 'package:beauty_admin/controller/contact_us/contact_otp_cubit.dart';
import 'package:beauty_admin/controller/contact_us/contact_otp_state.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../core/constant/constant.dart';
import '../core/custom_segmant_tab.dart';
import '../model/contact_us/contact_model_location.dart';
import '../model/contact_us/contact_us_model.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
}


// Fallback colors
const Color _kDefaultPink   = Color(0xFFBE6A7A);
const Color _kPinkLight     = Color(0xFFFDF2F4);
// Neutral loader background shown before Firebase responds
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM (kept from original)
// ═══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class _RevealCoordinator extends InheritedWidget {
  final _RevealCoordinatorState state;
  const _RevealCoordinator({required this.state, required super.child});
  static _RevealCoordinatorState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RevealCoordinator>()?.state;
  @override
  bool updateShouldNotify(_RevealCoordinator old) => false;
}

class _RevealCoordinatorWidget extends StatefulWidget {
  final Widget child;
  const _RevealCoordinatorWidget({required this.child});
  @override
  State<_RevealCoordinatorWidget> createState() => _RevealCoordinatorState();
}

class _RevealCoordinatorState extends State<_RevealCoordinatorWidget> {
  final List<_RevealState> _items = [];

  void register(_RevealState item) {
    _items.add(item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) item.onScroll();
      });
    });
  }

  void unregister(_RevealState item) => _items.remove(item);

  void notifyScroll() {
    for (final item in List.of(_items)) item.onScroll();
  }

  @override
  Widget build(BuildContext context) => _RevealCoordinator(
    state: this,
    child: NotificationListener<ScrollNotification>(
      onNotification: (_) {
        notifyScroll();
        return false;
      },
      child: widget.child,
    ),
  );
}

class _Reveal extends StatefulWidget {
  final Widget          child;
  final Duration        delay;
  final Duration        duration;
  final _SlideDirection direction;

  const _Reveal({
    required this.child,
    this.delay     = Duration.zero,
    this.duration  = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  late final Animation<Offset>   _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop    => const Offset(0, -0.18),
      _SlideDirection.fromLeft   => const Offset(-0.18, 0),
      _SlideDirection.fromRight  => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () => _checkAndTrigger());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        widget.delay + const Duration(milliseconds: 120),
            () => _checkAndTrigger(),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _RevealCoordinator.of(context)?.register(this);
  }

  @override
  void dispose() {
    _RevealCoordinator.of(context)?.unregister(this);
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos     = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH - 40) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

String _t(BuildContext context, {required String en, required String ar}) {
  final isAr = context.read<LanguageCubit>().state.isArabic;
  return (isAr && ar.isNotEmpty) ? ar : en;
}

String _bi(BuildContext context, ContactBilingualText text) =>
    _t(context, en: text.en, ar: text.ar);

const List<Map<String, String>> _phoneCodes = [
  {'key': '+20',  'value': '🇪🇬 +20'},
  {'key': '+234', 'value': '🇳🇬 +234'},
  {'key': '+212', 'value': '🇲🇦 +212'},
  {'key': '+213', 'value': '🇩🇿 +213'},
  {'key': '+216', 'value': '🇹🇳 +216'},
  {'key': '+249', 'value': '🇸🇩 +249'},
  {'key': '+251', 'value': '🇪🇹 +251'},
  {'key': '+254', 'value': '🇰🇪 +254'},
  {'key': '+27',  'value': '🇿🇦 +27'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+973', 'value': '🇧🇭 +973'},
  {'key': '+968', 'value': '🇴🇲 +968'},
  {'key': '+962', 'value': '🇯🇴 +962'},
  {'key': '+961', 'value': '🇱🇧 +961'},
  {'key': '+963', 'value': '🇸🇾 +963'},
  {'key': '+964', 'value': '🇮🇶 +964'},
  {'key': '+967', 'value': '🇾🇪 +967'},
  {'key': '+970', 'value': '🇵🇸 +970'},
  {'key': '+90',  'value': '🇹🇷 +90'},
  {'key': '+98',  'value': '🇮🇷 +98'},
  {'key': '+44',  'value': '🇬🇧 +44'},
  {'key': '+33',  'value': '🇫🇷 +33'},
  {'key': '+49',  'value': '🇩🇪 +49'},
  {'key': '+1',   'value': '🇺🇸 +1'},
  {'key': '+91',  'value': '🇮🇳 +91'},
  {'key': '+86',  'value': '🇨🇳 +86'},
  {'key': '+81',  'value': '🇯🇵 +81'},
  {'key': '+61',  'value': '🇦🇺 +61'},
  {'key': '+64',  'value': '🇳🇿 +64'},
];

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PRELOADER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadSvgImages(List<String> urls) async {
  final validUrls = urls
      .where((url) =>
  url.isNotEmpty &&
      (url.startsWith('http://') || url.startsWith('https://')))
      .toSet()
      .toList();

  await Future.wait(
    validUrls.map((url) async {
      try {
        final loader = SvgNetworkLoader(url);
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
              () => loader.loadBytes(null),
        );
      } catch (_) {}
    }),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PULSE LOADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color   backgroundColor;
  const _SvgPulseLoader({
    this.logoUrl,
    required this.backgroundColor,
  });

  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl =
    (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null) {
      setState(() => _resolvedUrl = widget.logoUrl);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SvgPicture.network(
            _resolvedUrl!,
            width:  88.w,
            height: 88.w,
            fit:    BoxFit.contain,
            placeholderBuilder: (_) =>
                SizedBox(width: 88.w, height: 88.w),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE ENTRY
// ═══════════════════════════════════════════════════════════════════════════════

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ContactCubit()),
        BlocProvider(create: (_) => ContactUsCmsCubit()..load()),
        BlocProvider(create: (_) => ContactOtpCubit()),
      ],
      child: const _ContactPageView(),
    );
  }
}

class _ContactPageView extends StatefulWidget {
  const _ContactPageView();
  @override
  State<_ContactPageView> createState() => _ContactPageViewState();
}

class _ContactPageViewState extends State<_ContactPageView> {
  // ── Controllers ──
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _salonNameCtrl  = TextEditingController();
  final _salonNameArCtrl = TextEditingController();
  final _subjectCtrl    = TextEditingController();
  final _messageCtrl    = TextEditingController();

  // ── Form state ──
  String _userType           = ContactFormConstants.userTypeClient;
  String _phoneCode          = '+20';
  String _preferredLanguage  = 'ar';
  String? _selectedTargetAudience;
  String? _selectedSalonCountry;
  String? _selectedSalonCity;
  String? _selectedNoBranches;
  String? _selectedServices;
  String? _selectedAtLocation;
  String? _selectedReason;

  bool   _submitted      = false;
  bool   _showLoader     = true;
  bool   _preloadStarted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
    });
  }

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

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required ContactUsCmsModel? cmsData,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    final List<String> allUrls = [
      if (logoUrl.isNotEmpty) logoUrl,
      if (cmsData != null)
        for (final icon in cmsData.socialIcons)
          if (icon.iconUrl.isNotEmpty) icon.iconUrl,
    ];

    await _preloadSvgImages(allUrls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLoader = false);
  }

  bool get _isOwner => _userType == ContactFormConstants.userTypeOwner;

  void _onSend() {
    setState(() => _submitted = true);

    // ── Validate personal info (always required) ──
    final personalFilled = [
      _firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl,
      _subjectCtrl, _messageCtrl,
    ].every((c) => c.text.trim().isNotEmpty);

    final reasonFilled = _selectedReason != null;

    if (!personalFilled || !reasonFilled) return;

    // ── Validate salon info (only for Owner) ──
    if (_isOwner) {
      final salonFilled =
          _salonNameCtrl.text.trim().isNotEmpty &&
              _selectedTargetAudience != null &&
              _selectedSalonCountry != null &&
              _selectedNoBranches != null &&
              _selectedServices != null;
      if (!salonFilled) return;
    }

    String phoneNumber = _phoneCtrl.text.trim();
    if (phoneNumber.startsWith('0')) phoneNumber = phoneNumber.substring(1);

    final fullPhone = '$_phoneCode$phoneNumber';
    final locale    = _preferredLanguage == 'ar' ? 'ar' : 'en';

    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: fullPhone,
      locale:      locale,
    );
  }

  void _submitContactForm() async {
    final submission = ContactSubmission(
      id:                '',
      userType:          _userType,
      firstName:         _firstNameCtrl.text.trim(),
      lastName:          _lastNameCtrl.text.trim(),
      email:             _emailCtrl.text.trim(),
      countryCode:       _phoneCode,
      phoneNumber:       _phoneCtrl.text.trim(),
      preferredLanguage: _preferredLanguage,
      salonNameEn:       _salonNameCtrl.text.trim(),
      salonNameAr:       _salonNameArCtrl.text.trim(),
      targetAudience:    _selectedTargetAudience ?? '',
      salonCountry:      _selectedSalonCountry ?? '',
      salonCity:         _selectedSalonCity ?? '',
      noBranches:        _selectedNoBranches ?? '',
      services:          _selectedServices ?? '',
      atLocation:        _selectedAtLocation ?? '',
      subject:           _subjectCtrl.text.trim(),
      reason:            _selectedReason != null && _selectedReason!.isNotEmpty
          ? [_selectedReason!]
          : [],
      message:           _messageCtrl.text.trim(),
      submissionDate:    DateTime.now(),
    );

    context.read<ContactCubit>().submitContact(submission);
  }

  void _resetForm() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _salonNameCtrl.clear();
    _salonNameArCtrl.clear();
    _subjectCtrl.clear();
    _messageCtrl.clear();
    setState(() {
      _submitted              = false;
      _userType               = ContactFormConstants.userTypeClient;
      _preferredLanguage      = 'ar';
      _selectedTargetAudience = null;
      _selectedSalonCountry   = null;
      _selectedSalonCity      = null;
      _selectedNoBranches     = null;
      _selectedServices       = null;
      _selectedAtLocation     = null;
      _selectedReason         = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final String logoUrl = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };

        final Color primaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.primaryColor,
              fallback: _kDefaultPink),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.primaryColor,
              fallback: _kDefaultPink),
          _ => _kDefaultPink,
        };

        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          _ => AppColors.background,
        };

        final Color loaderBg = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          _ => _kLoaderNeutral,
        };

        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        if (homeState is HomeCmsError &&
            homeState.lastData == null &&
            _showLoader &&
            !_preloadStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showLoader = false);
          });
        }

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final isRtl = langState.isArabic;

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ContactOtpCubit, ContactOtpState>(
                    listener: (context, otpState) {
                      if (otpState is OtpSent) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ContactOtpCubit>(),
                            child: _OtpDialog(
                              phoneNumber:  otpState.phoneNumber,
                              isRtl:        isRtl,
                              primaryColor: primaryColor,
                              onVerified: () {
                                Navigator.of(context).pop();
                                _submitContactForm();
                              },
                            ),
                          ),
                        );
                      }
                      if (otpState is OtpError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:         Text('OTP Error: ${otpState.message}'),
                            backgroundColor: Colors.red,
                            duration:        const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                  BlocListener<ContactCubit, ContactState>(
                    listener: (context, state) {
                      if (state is ContactSubmitted) {
                        _resetForm();
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => _SuccessDialog(
                            isRtl:        isRtl,
                            primaryColor: primaryColor,
                          ),
                        );
                      }
                      if (state is ContactError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:         Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                            duration:        const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
                  builder: (context, cmsState) {
                    final bool cmsReady = cmsState is ContactUsCmsLoaded ||
                        cmsState is ContactUsCmsError;

                    ContactUsCmsModel? cmsData;
                    if (cmsState is ContactUsCmsLoaded) {
                      cmsData = cmsState.data;
                    }

                    if (homeReady && cmsReady && !_preloadStarted) {
                      _preloadAndReveal(
                          logoUrl: logoUrl, cmsData: cmsData);
                    }

                    if (_showLoader || !cmsReady || !homeReady) {
                      return _SvgPulseLoader(
                        logoUrl:         logoUrl.isEmpty ? null : logoUrl,
                        backgroundColor: loaderBg,
                      );
                    }

                    return BlocBuilder<ContactCubit, ContactState>(
                      builder: (context, contactState) {
                        final isSending = contactState is ContactSubmitting;
                        final isMobile  = MediaQuery.of(context).size.width < _BP.mobile;

                        return Scaffold(
                          backgroundColor: backgroundColor,
                          body: Stack(children: [
                            _RevealCoordinatorWidget(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 80.h),

                                    // ── MAIN CONTENT ──
                                    _Reveal(
                                      delay:     const Duration(milliseconds: 80),
                                      direction: _SlideDirection.fromLeft,
                                      duration:  const Duration(milliseconds: 650),
                                      child: isMobile
                                          ? _MobileBody(
                                        firstNameCtrl:         _firstNameCtrl,
                                        lastNameCtrl:          _lastNameCtrl,
                                        emailCtrl:             _emailCtrl,
                                        phoneCtrl:             _phoneCtrl,
                                        salonNameCtrl:         _salonNameCtrl,
                                        salonNameArCtrl:       _salonNameArCtrl,
                                        subjectCtrl:           _subjectCtrl,
                                        messageCtrl:           _messageCtrl,
                                        submitted:             _submitted,
                                        userType:              _userType,
                                        phoneCode:             _phoneCode,
                                        preferredLanguage:     _preferredLanguage,
                                        selectedTargetAudience: _selectedTargetAudience,
                                        selectedSalonCountry:  _selectedSalonCountry,
                                        selectedSalonCity:     _selectedSalonCity,
                                        selectedNoBranches:    _selectedNoBranches,
                                        selectedServices:      _selectedServices,
                                        selectedAtLocation:    _selectedAtLocation,
                                        selectedReason:        _selectedReason,
                                        isRtl:                 isRtl,
                                        primaryColor:          primaryColor,
                                        onUserTypeChanged:     (v) => setState(() => _userType = v),
                                        onCodeChanged:         (v) => setState(() => _phoneCode = v ?? _phoneCode),
                                        onLanguageChanged:     (v) => setState(() => _preferredLanguage = v),
                                        onTargetAudienceChanged: (v) => setState(() => _selectedTargetAudience = v),
                                        onSalonCountryChanged: (v) => setState(() => _selectedSalonCountry = v),
                                        onSalonCityChanged:    (v) => setState(() => _selectedSalonCity = v),
                                        onNoBranchesChanged:   (v) => setState(() => _selectedNoBranches = v),
                                        onServicesChanged:     (v) => setState(() => _selectedServices = v),
                                        onAtLocationChanged:   (v) => setState(() => _selectedAtLocation = v),
                                        onReasonChanged:       (v) => setState(() => _selectedReason = v),
                                        onSend:                _onSend,
                                        cmsData:               cmsData,
                                      )
                                          : _DesktopBody(
                                        firstNameCtrl:         _firstNameCtrl,
                                        lastNameCtrl:          _lastNameCtrl,
                                        emailCtrl:             _emailCtrl,
                                        phoneCtrl:             _phoneCtrl,
                                        salonNameCtrl:         _salonNameCtrl,
                                        salonNameArCtrl:       _salonNameArCtrl,
                                        subjectCtrl:           _subjectCtrl,
                                        messageCtrl:           _messageCtrl,
                                        submitted:             _submitted,
                                        userType:              _userType,
                                        phoneCode:             _phoneCode,
                                        preferredLanguage:     _preferredLanguage,
                                        selectedTargetAudience: _selectedTargetAudience,
                                        selectedSalonCountry:  _selectedSalonCountry,
                                        selectedSalonCity:     _selectedSalonCity,
                                        selectedNoBranches:    _selectedNoBranches,
                                        selectedServices:      _selectedServices,
                                        selectedAtLocation:    _selectedAtLocation,
                                        selectedReason:        _selectedReason,
                                        isRtl:                 isRtl,
                                        primaryColor:          primaryColor,
                                        onUserTypeChanged:     (v) => setState(() => _userType = v),
                                        onCodeChanged:         (v) => setState(() => _phoneCode = v ?? _phoneCode),
                                        onLanguageChanged:     (v) => setState(() => _preferredLanguage = v),
                                        onTargetAudienceChanged: (v) => setState(() => _selectedTargetAudience = v),
                                        onSalonCountryChanged: (v) => setState(() => _selectedSalonCountry = v),
                                        onSalonCityChanged:    (v) => setState(() => _selectedSalonCity = v),
                                        onNoBranchesChanged:   (v) => setState(() => _selectedNoBranches = v),
                                        onServicesChanged:     (v) => setState(() => _selectedServices = v),
                                        onAtLocationChanged:   (v) => setState(() => _selectedAtLocation = v),
                                        onReasonChanged:       (v) => setState(() => _selectedReason = v),
                                        onSend:                _onSend,
                                        cmsData:               cmsData,
                                      ),
                                    ),

                                    // ── SOCIAL MEDIA SECTION ──
                                    _Reveal(
                                      delay:     const Duration(milliseconds: 120),
                                      direction: _SlideDirection.fromBottom,
                                      duration:  const Duration(milliseconds: 600),
                                      child: _SocialMediaSection(
                                        cmsData:      cmsData,
                                        primaryColor: primaryColor,
                                        isMobile:     isMobile,
                                        isRtl:        isRtl,
                                      ),
                                    ),

                                    // ── FOOTER ──
                                    _Reveal(
                                      delay:     const Duration(milliseconds: 140),
                                      direction: _SlideDirection.fromBottom,
                                      duration:  const Duration(milliseconds: 600),
                                      child: const AppFooter(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ── NAVBAR ──
                            Positioned(
                              top: 0, left: 0, right: 0,
                              child: Material(
                                color:     backgroundColor,
                                elevation: 0,
                                child: AppNavbar(currentRoute: '/contactus'),
                              ),
                            ),

                            // ── SENDING OVERLAY ──
                            if (isSending)
                              Container(
                                color: Colors.black45,
                                child: Center(
                                  child: Container(
                                    width: isMobile ? double.infinity : 600.w,
                                    padding: EdgeInsets.all(24.r),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.r)),
                                    child: Column(
                                      mainAxisSize:      MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleProgressMaster(),
                                        SizedBox(height: 8.h),
                                        Text(
                                          isRtl
                                              ? 'جاري ارسال البيانات...'
                                              : 'Sending your information…',
                                          style: StyleText.fontSize13Weight400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OTP DIALOG (kept from original — unchanged logic)
// ═══════════════════════════════════════════════════════════════════════════════

class _OtpDialog extends StatefulWidget {
  final String       phoneNumber;
  final bool         isRtl;
  final Color        primaryColor;
  final VoidCallback onVerified;

  const _OtpDialog({
    required this.phoneNumber,
    required this.isRtl,
    required this.primaryColor,
    required this.onVerified,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final List<TextEditingController> _digitCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool   _submitted   = false;
  bool   _hasError     = false;
  int    _countdown    = 30;
  bool   _canResend    = false;
  StreamSubscription? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _countdown = 30; _canResend = false; });
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .take(30)
        .listen((_) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digitCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _digitCtrls.map((c) => c.text).join();

  void _verifyOtp() {
    setState(() { _submitted = true; _hasError = false; });
    final code = _otpCode.trim();
    if (code.length < 6) return;
    context.read<ContactOtpCubit>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      code:        code,
    );
  }

  void _resendOtp() {
    for (final c in _digitCtrls) c.clear();
    setState(() { _submitted = false; _hasError = false; });
    _timer?.cancel();
    _startTimer();
    final locale = widget.isRtl ? 'ar' : 'en';
    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: widget.phoneNumber,
      locale:      locale,
    );
  }

  void _onDigitChanged(String value, int index) {
    setState(() => _hasError = false);
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.length == 1 && index == 5 && _otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _onDigitKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitCtrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s Sec';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    final String title    = widget.isRtl ? 'رمز التحقق'          : 'VERIFICATION CODE';
    final String desc     = widget.isRtl
        ? 'لقد أرسلنا رمز التحقق إلى هاتفك لإتمام عملية التحقق'
        : 'We have sent the OTP code to your Phone For the verification process';
    final String verifyBtn = widget.isRtl ? 'تحقق الآن'          : 'Verify Now';
    final String resendBtn = widget.isRtl ? 'إعادة إرسال الرمز'  : 'Resend Code';
    final String errorMsg  = widget.isRtl
        ? 'رمز غير صحيح، يرجى التحقق والمحاولة مرة أخرى'
        : 'Incorrect code, please check and try again';

    return Directionality(
      textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<ContactOtpCubit, ContactOtpState>(
        listener: (context, state) {
          if (state is OtpVerified) widget.onVerified();
          if (state is OtpError) setState(() => _hasError = true);
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 16.r)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 36.w,
            vertical:   isMobile ? 40 : 36.h,
          ),
          child: SizedBox(
            width: isMobile ? double.infinity : 480.w,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32.w,
                vertical:   isMobile ? 28 : 32.h,
              ),
              child: BlocBuilder<ContactOtpCubit, ContactOtpState>(
                builder: (context, state) {
                  final isVerifying = state is OtpVerifying;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/mobile_code_dialog.svg',
                        width:  isMobile ? 120 : 140.w,
                        height: isMobile ? 100 : 120.h,
                        fit:    BoxFit.contain,
                      ),
                      SizedBox(height: isMobile ? 20 : 24.h),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize22Weight700.copyWith(
                              fontSize: isMobile ? 18.0 : 20.sp,
                              color: Colors.black, letterSpacing: 1.0)),
                      SizedBox(height: isMobile ? 8 : 10.h),
                      Text(desc,
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize13Weight400.copyWith(
                              fontSize: isMobile ? 12.0 : 13.sp,
                              color: Colors.grey.shade600, height: 1.5)),
                      SizedBox(height: isMobile ? 24 : 28.h),

                      // ── 6-Digit OTP Boxes ──
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            final bool filled = _digitCtrls[i].text.isNotEmpty;
                            return Container(
                              width:  isMobile ? 44 : 48.w,
                              height: isMobile ? 50 : 54.h,
                              margin: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4.w),
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) => _onDigitKey(i, e),
                                child: TextField(
                                  controller:   _digitCtrls[i],
                                  focusNode:    _focusNodes[i],
                                  keyboardType: TextInputType.number,
                                  textAlign:    TextAlign.center,
                                  maxLength:    1,
                                  style: StyleText.fontSize22Weight700.copyWith(
                                    fontSize: isMobile ? 18.0 : 20.sp,
                                    color:    _hasError ? Colors.red : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled:      true,
                                    fillColor: _hasError
                                        ? Colors.red.withOpacity(0.05)
                                        : filled
                                        ? widget.primaryColor.withOpacity(0.05)
                                        : Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: isMobile ? 12 : 14.h),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                          color: _hasError ? Colors.red : Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                          color: _hasError ? Colors.red
                                              : filled ? widget.primaryColor
                                              : Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                          color: _hasError ? Colors.red : widget.primaryColor,
                                          width: 1.5),
                                    ),
                                  ),
                                  onChanged: (v) => _onDigitChanged(v, i),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: isMobile ? 14 : 16.h),

                      if (_hasError)
                        Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 8 : 10.h),
                          child: Text(errorMsg,
                              textAlign: TextAlign.center,
                              style: StyleText.fontSize12Weight400.copyWith(
                                  color: Colors.red, fontSize: isMobile ? 11.0 : 12.sp)),
                        ),

                      if (!_canResend)
                        Text(_formatTime(_countdown),
                            style: StyleText.fontSize13Weight400.copyWith(
                                color: widget.primaryColor,
                                fontSize: isMobile ? 13.0 : 14.sp,
                                fontWeight: FontWeight.w600)),
                      SizedBox(height: isMobile ? 18 : 20.h),

                      SizedBox(
                        width: double.infinity, height: isMobile ? 46 : 44.h,
                        child: _canResend
                            ? ElevatedButton(
                          onPressed: _resendOtp,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0),
                          child: Text(resendBtn,
                              style: StyleText.fontSize16Weight600.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 14.0 : 15.sp)),
                        )
                            : ElevatedButton(
                          onPressed: isVerifying ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              disabledBackgroundColor:
                              widget.primaryColor.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0),
                          child: isVerifying
                              ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white)),
                          )
                              : Text(verifyBtn,
                              style: StyleText.fontSize16Weight600.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 14.0 : 15.sp)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUCCESS DIALOG — Simplified to match Figma
// ═══════════════════════════════════════════════════════════════════════════════

class _SuccessDialog extends StatelessWidget {
  final bool  isRtl;
  final Color primaryColor;
  const _SuccessDialog({required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    final String title = isRtl
        ? 'تم الإرسال بنجاح !'
        : 'Send Successfully !';
    final String desc = isRtl
        ? 'تم إرسال طلبك بنجاح. شكراً لتواصلك معنا.'
        : 'Your request was sent successfully. Thank you for contact with us.';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 14 : 16.r)),
        insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 36.w,
            vertical:   isMobile ? 56 : 36.h),
        child: SizedBox(
          width: isMobile ? double.infinity : 500.w,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 36.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Placeholder image (matches Figma pink box) ──
                Container(
                  width:  isMobile ? 100 : 120.w,
                  height: isMobile ? 100 : 120.w,
                  decoration: BoxDecoration(
                    color:        primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.check_circle_outline_rounded,
                      size: isMobile ? 50 : 60.w, color: primaryColor),
                ),
                SizedBox(height: isMobile ? 20 : 24.h),
                Text(title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize22Weight700.copyWith(
                        fontSize: isMobile ? 18.0 : 22.sp,
                        color: primaryColor)),
                SizedBox(height: isMobile ? 10 : 14.h),
                Text(desc,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize13Weight400.copyWith(
                        fontSize: isMobile ? 12.0 : 14.sp,
                        height: 1.7, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY — Figma: Illustration left + Form right
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopBody extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, salonNameCtrl, salonNameArCtrl, subjectCtrl, messageCtrl;
  final bool   submitted, isRtl;
  final String userType, phoneCode, preferredLanguage;
  final String? selectedTargetAudience, selectedSalonCountry, selectedSalonCity,
      selectedNoBranches, selectedServices, selectedAtLocation, selectedReason;
  final Color primaryColor;
  final ValueChanged<String>   onUserTypeChanged, onLanguageChanged;
  final ValueChanged<String?>  onCodeChanged, onTargetAudienceChanged,
      onSalonCountryChanged, onSalonCityChanged, onNoBranchesChanged,
      onServicesChanged, onAtLocationChanged, onReasonChanged;
  final VoidCallback           onSend;
  final ContactUsCmsModel?     cmsData;

  const _DesktopBody({
    required this.firstNameCtrl,      required this.lastNameCtrl,
    required this.emailCtrl,          required this.phoneCtrl,
    required this.salonNameCtrl,      required this.salonNameArCtrl,
    required this.subjectCtrl,        required this.messageCtrl,
    required this.submitted,          required this.userType,
    required this.phoneCode,          required this.preferredLanguage,
    required this.selectedTargetAudience,  required this.selectedSalonCountry,
    required this.selectedSalonCity,       required this.selectedNoBranches,
    required this.selectedServices,        required this.selectedAtLocation,
    required this.selectedReason,
    required this.isRtl,              required this.primaryColor,
    required this.onUserTypeChanged,  required this.onCodeChanged,
    required this.onLanguageChanged,  required this.onTargetAudienceChanged,
    required this.onSalonCountryChanged, required this.onSalonCityChanged,
    required this.onNoBranchesChanged, required this.onServicesChanged,
    required this.onAtLocationChanged, required this.onReasonChanged,
    required this.onSend,             this.cmsData,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = 1000.w;
    final double hPad     = ((screenW - contentW) / 2).clamp(16.0, double.infinity);

    final String pageTitle = _t(context, en: 'Contact Us', ar: 'تواصل معنا');
    final String pageSubtitle = _t(context,
        en: 'Your Feedback Shapes Our Success: Join Us in Building a Better Experience!',
        ar: 'ملاحظاتك تشكل نجاحنا: انضم إلينا في بناء تجربة أفضل!');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),



          // ── Two-column layout: Illustration + Form ──
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT: Illustration + Description text ──
                Expanded(
                  flex: 2,
                  child: _LeftIllustrationPanel(
                    isRtl:        isRtl,
                    primaryColor: primaryColor,
                  ),
                ),
                SizedBox(width: 20.w),

                // ── RIGHT: Form ──
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [

                      // ── Title + Subtitle ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pageTitle,
                                  style: StyleText.fontSize45Weight600.copyWith(
                                      fontSize: 32.sp, color: primaryColor,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Text(pageSubtitle,
                                      style: StyleText.fontSize16Weight600.copyWith(
                                          fontSize: 14.sp, color: Colors.black87,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),


                      _FormCard(
                        firstNameCtrl:         firstNameCtrl,
                        lastNameCtrl:          lastNameCtrl,
                        emailCtrl:             emailCtrl,
                        phoneCtrl:             phoneCtrl,
                        salonNameCtrl:         salonNameCtrl,
                        salonNameArCtrl:       salonNameArCtrl,
                        subjectCtrl:           subjectCtrl,
                        messageCtrl:           messageCtrl,
                        submitted:             submitted,
                        userType:              userType,
                        phoneCode:             phoneCode,
                        preferredLanguage:     preferredLanguage,
                        selectedTargetAudience: selectedTargetAudience,
                        selectedSalonCountry:  selectedSalonCountry,
                        selectedSalonCity:     selectedSalonCity,
                        selectedNoBranches:    selectedNoBranches,
                        selectedServices:      selectedServices,
                        selectedAtLocation:    selectedAtLocation,
                        selectedReason:        selectedReason,
                        isRtl:                 isRtl,
                        primaryColor:          primaryColor,
                        onUserTypeChanged:     onUserTypeChanged,
                        onCodeChanged:         onCodeChanged,
                        onLanguageChanged:     onLanguageChanged,
                        onTargetAudienceChanged: onTargetAudienceChanged,
                        onSalonCountryChanged: onSalonCountryChanged,
                        onSalonCityChanged:    onSalonCityChanged,
                        onNoBranchesChanged:   onNoBranchesChanged,
                        onServicesChanged:     onServicesChanged,
                        onAtLocationChanged:   onAtLocationChanged,
                        onReasonChanged:       onReasonChanged,
                        onSend:                onSend,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEFT ILLUSTRATION PANEL (Figma: image + two paragraphs)
// ═══════════════════════════════════════════════════════════════════════════════

class _LeftIllustrationPanel extends StatelessWidget {
  final bool  isRtl;
  final Color primaryColor;
  const _LeftIllustrationPanel({required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String para1 = _t(context,
        en: 'At Beauty, we firmly believe that feedback is the lifeblood of our success. We value your thoughts, opinions, and suggestions as they shape our products, services, and overall customer experience. Your voice matters, and we are committed to creating a platform that truly meets your needs.',
        ar: 'في بيوتي، نؤمن بشدة أن الملاحظات هي شريان حياة نجاحنا. نحن نقدر أفكارك وآراءك واقتراحاتك لأنها تشكل منتجاتنا وخدماتنا وتجربة العملاء بشكل عام. صوتك مهم، ونحن ملتزمون بإنشاء منصة تلبي احتياجاتك حقًا.');
    final String para2 = _t(context,
        en: 'By sharing your experiences, you become an integral part of our growth journey. Your feedback helps us identify pain points, eliminate barriers, and create seamless experiences that exceed your expectations. We listen attentively, analyze your input meticulously, and implement changes that address your concerns and amplify your satisfaction.',
        ar: 'من خلال مشاركة تجاربك، تصبح جزءًا لا يتجزأ من رحلة نمونا. تساعدنا ملاحظاتك في تحديد نقاط الضعف والقضاء على العوائق وإنشاء تجارب سلسة تفوق توقعاتك. نستمع بانتباه، ونحلل مدخلاتك بدقة، وننفذ التغييرات التي تعالج مخاوفك وتعزز رضاك.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Illustration SVG ──
        Center(
          child: SvgPicture.asset(
            'assets/images/dashboard_image.svg',
            width:  220.w,
            height: 200.h,
            fit:    BoxFit.contain,
          ),
        ),
        SizedBox(height: 24.h),

        // ── Paragraph 1 ──
        Text(para1,
            style: StyleText.fontSize13Weight400.copyWith(
                fontSize: 12.sp, color: Colors.black87, height: 1.7)),
        SizedBox(height: 16.h),

        // ── Paragraph 2 ──
        Text(para2,
            style: StyleText.fontSize13Weight400.copyWith(
                fontSize: 12.sp, color: Colors.black87, height: 1.7)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileBody extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, salonNameCtrl, salonNameArCtrl, subjectCtrl, messageCtrl;
  final bool   submitted, isRtl;
  final String userType, phoneCode, preferredLanguage;
  final String? selectedTargetAudience, selectedSalonCountry, selectedSalonCity,
      selectedNoBranches, selectedServices, selectedAtLocation, selectedReason;
  final Color primaryColor;
  final ValueChanged<String>   onUserTypeChanged, onLanguageChanged;
  final ValueChanged<String?>  onCodeChanged, onTargetAudienceChanged,
      onSalonCountryChanged, onSalonCityChanged, onNoBranchesChanged,
      onServicesChanged, onAtLocationChanged, onReasonChanged;
  final VoidCallback           onSend;
  final ContactUsCmsModel?     cmsData;

  const _MobileBody({
    required this.firstNameCtrl,      required this.lastNameCtrl,
    required this.emailCtrl,          required this.phoneCtrl,
    required this.salonNameCtrl,      required this.salonNameArCtrl,
    required this.subjectCtrl,        required this.messageCtrl,
    required this.submitted,          required this.userType,
    required this.phoneCode,          required this.preferredLanguage,
    required this.selectedTargetAudience,  required this.selectedSalonCountry,
    required this.selectedSalonCity,       required this.selectedNoBranches,
    required this.selectedServices,        required this.selectedAtLocation,
    required this.selectedReason,
    required this.isRtl,              required this.primaryColor,
    required this.onUserTypeChanged,  required this.onCodeChanged,
    required this.onLanguageChanged,  required this.onTargetAudienceChanged,
    required this.onSalonCountryChanged, required this.onSalonCityChanged,
    required this.onNoBranchesChanged, required this.onServicesChanged,
    required this.onAtLocationChanged, required this.onReasonChanged,
    required this.onSend,             this.cmsData,
  });

  @override
  Widget build(BuildContext context) {
    final String pageTitle = _t(context, en: 'Contact Us', ar: 'تواصل معنا');
    final String pageSubtitle = _t(context,
        en: 'Your Feedback Shapes Our Success: Join Us in Building a Better Experience!',
        ar: 'ملاحظاتك تشكل نجاحنا: انضم إلينا في بناء تجربة أفضل!');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(pageTitle,
              style: StyleText.fontSize45Weight600.copyWith(
                  fontSize: 24.sp, color: primaryColor,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 6.h),
          Text(pageSubtitle,
              style: StyleText.fontSize13Weight400.copyWith(
                  fontSize: 12.sp, color: Colors.black87)),
          SizedBox(height: 16.h),

          // ── Illustration ──
          _Reveal(
            delay: const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/dashboard_image.svg',
                width:  200.w,
                height: 160.h,
                fit:    BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Form ──
          _Reveal(
            delay: const Duration(milliseconds: 150),
            direction: _SlideDirection.fromBottom,
            child: _FormCard(
              firstNameCtrl:         firstNameCtrl,
              lastNameCtrl:          lastNameCtrl,
              emailCtrl:             emailCtrl,
              phoneCtrl:             phoneCtrl,
              salonNameCtrl:         salonNameCtrl,
              salonNameArCtrl:       salonNameArCtrl,
              subjectCtrl:           subjectCtrl,
              messageCtrl:           messageCtrl,
              submitted:             submitted,
              userType:              userType,
              phoneCode:             phoneCode,
              preferredLanguage:     preferredLanguage,
              selectedTargetAudience: selectedTargetAudience,
              selectedSalonCountry:  selectedSalonCountry,
              selectedSalonCity:     selectedSalonCity,
              selectedNoBranches:    selectedNoBranches,
              selectedServices:      selectedServices,
              selectedAtLocation:    selectedAtLocation,
              selectedReason:        selectedReason,
              isRtl:                 isRtl,
              primaryColor:          primaryColor,
              isMobile:              true,
              onUserTypeChanged:     onUserTypeChanged,
              onCodeChanged:         onCodeChanged,
              onLanguageChanged:     onLanguageChanged,
              onTargetAudienceChanged: onTargetAudienceChanged,
              onSalonCountryChanged: onSalonCountryChanged,
              onSalonCityChanged:    onSalonCityChanged,
              onNoBranchesChanged:   onNoBranchesChanged,
              onServicesChanged:     onServicesChanged,
              onAtLocationChanged:   onAtLocationChanged,
              onReasonChanged:       onReasonChanged,
              onSend:                onSend,
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM CARD — Client/Owner toggle + Personal Info + Salon Info
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// UPDATED SECTION: Client/Owner toggle now appears OUTSIDE and ABOVE the form card
// Uses CustomSegmentedTabs with SVG icons from assets/beauty/contact_us/
// ═══════════════════════════════════════════════════════════════════════════════

// Replace the _FormCard widget completely with this updated version:

class _FormCard extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, salonNameCtrl, salonNameArCtrl, subjectCtrl, messageCtrl;
  final bool   submitted, isMobile, isRtl;
  final String userType, phoneCode, preferredLanguage;
  final String? selectedTargetAudience, selectedSalonCountry, selectedSalonCity,
      selectedNoBranches, selectedServices, selectedAtLocation, selectedReason;
  final Color primaryColor;
  final ValueChanged<String>   onUserTypeChanged, onLanguageChanged;
  final ValueChanged<String?>  onCodeChanged, onTargetAudienceChanged,
      onSalonCountryChanged, onSalonCityChanged, onNoBranchesChanged,
      onServicesChanged, onAtLocationChanged, onReasonChanged;
  final VoidCallback           onSend;

  const _FormCard({
    required this.firstNameCtrl,      required this.lastNameCtrl,
    required this.emailCtrl,          required this.phoneCtrl,
    required this.salonNameCtrl,      required this.salonNameArCtrl,
    required this.subjectCtrl,        required this.messageCtrl,
    required this.submitted,          required this.userType,
    required this.phoneCode,          required this.preferredLanguage,
    required this.selectedTargetAudience,  required this.selectedSalonCountry,
    required this.selectedSalonCity,       required this.selectedNoBranches,
    required this.selectedServices,        required this.selectedAtLocation,
    required this.selectedReason,
    required this.isRtl,              required this.primaryColor,
    required this.onUserTypeChanged,  required this.onCodeChanged,
    required this.onLanguageChanged,  required this.onTargetAudienceChanged,
    required this.onSalonCountryChanged, required this.onSalonCityChanged,
    required this.onNoBranchesChanged, required this.onServicesChanged,
    required this.onAtLocationChanged, required this.onReasonChanged,
    required this.onSend,             this.isMobile = false,
  });

  bool get _isOwner => userType == ContactFormConstants.userTypeOwner;

  @override
  Widget build(BuildContext context) {
    final TextDirection dir   = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final TextAlign     align = isRtl ? TextAlign.right   : TextAlign.left;

    // ── Labels ──
    final String clientLabel  = _t(context, en: 'Client',  ar: 'عميل');
    final String ownerLabel   = _t(context, en: 'Owner',   ar: 'مالك');
    final String personalInfo = _t(context, en: 'Personal Info', ar: 'المعلومات الشخصية');
    final String salonInfo    = _t(context, en: 'Salon Info',    ar: 'معلومات الصالون');
    final String prefLangLabel     = _t(context, en: 'Preferred Language', ar: 'اللغة المفضلة');
    final String firstNameLabel    = _t(context, en: 'First Name',         ar: 'الاسم الأول');
    final String lastNameLabel     = _t(context, en: 'Last Name',          ar: 'اسم العائلة');
    final String emailLabel        = _t(context, en: 'Enter Your Email',   ar: 'أدخل بريدك الإلكتروني');
    final String phoneLabel        = _t(context, en: 'Phone Number',       ar: 'رقم الهاتف');
    final String salonNameLabel    = _t(context, en: 'Salon Name',         ar: 'اسم الصالون');
    final String salonNameArLabel  = _t(context, en: 'اسم الصالون',        ar: 'اسم الصالون');
    final String targetLabel       = _t(context, en: 'Target audience of salon', ar: 'الجمهور المستهدف للصالون');
    final String countryLabel      = _t(context, en: 'Country of salon',   ar: 'دولة الصالون');
    final String cityLabel         = _t(context, en: 'City of salon',      ar: 'مدينة الصالون');
    final String branchesLabel     = _t(context, en: 'No.Branches',        ar: 'عدد الفروع');
    final String servicesLabel     = _t(context, en: 'Services',           ar: 'الخدمات');
    final String subjectLabel      = _t(context, en: 'Subject',            ar: 'الموضوع');
    final String reasonLabel       = _t(context, en: 'Reason',             ar: 'السبب');
    final String msgLabel          = _t(context, en: 'Message',            ar: 'الرسالة');
    final String hint              = _t(context, en: 'Text Here',          ar: 'اكتب هنا');
    final String sendLabel         = _t(context, en: 'SEND',               ar: 'إرسال');
    final String selectHint        = _t(context, en: 'Select',             ar: 'اختر');

    // ── Language radio labels ──
    final langLabels = isRtl
        ? ContactFormConstants.preferredLanguageLabelsAr
        : ContactFormConstants.preferredLanguageLabelsEn;

    // ── Dropdown items ──
    final targetItems = (isRtl
        ? ContactFormConstants.targetAudienceAr
        : ContactFormConstants.targetAudienceEn)
        .map((t) => {'key': t, 'value': t}).toList();

    final countryItems = (isRtl
        ? ContactFormConstants.countriesAr
        : ContactFormConstants.countriesEn)
        .map((c) => {'key': c, 'value': c}).toList();

    final branchItems = (isRtl
        ? ContactFormConstants.noBranchesAr
        : ContactFormConstants.noBranchesEn)
        .map((b) => {'key': b, 'value': b}).toList();

    final serviceItems = (isRtl
        ? ContactFormConstants.servicesAr
        : ContactFormConstants.servicesEn)
        .map((s) => {'key': s, 'value': s}).toList();

    final reasonItems = (isRtl
        ? ContactFormConstants.reasonsAr
        : ContactFormConstants.reasonsEn)
        .map((r) => {'key': r, 'value': r}).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════════
        // CLIENT / OWNER TOGGLE — MOVED OUTSIDE CARD
        // ═══════════════════════════════════════════════════
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 210.w,
              height: isMobile ? 38.h : 36.h,
              child: CustomSegmentedTabs(
                tabs: [clientLabel, ownerLabel],
                tabIcons: const [
                  'assets/beauty/contact_us/client.svg',
                  'assets/beauty/contact_us/owner.svg',
                ],
                selectedIndex: userType == ContactFormConstants.userTypeClient ? 0 : 1,
                onTabSelected: (index) {
                  onUserTypeChanged(
                    index == 0
                        ? ContactFormConstants.userTypeClient
                        : ContactFormConstants.userTypeOwner,
                  );
                },
                selectedColor: primaryColor,
                unselectedColor: Colors.grey.shade100,
                selectedTextColor: Colors.red,
                unselectedTextColor: Colors.red,
                equalWidth: true,
                spacing: isMobile ? 6.w : 8.w,
                iconSize: isMobile ? 14.sp : 16.sp,
                iconSpacing: isMobile ? 4.w : 6.w,
                tabHorizontalPadding: isMobile ? 12.w : 16.w,
                tabVerticalPadding: isMobile ? 8.h : 8.h,
                borderRadius: 8.r,
                containerPadding: EdgeInsets.all(3.r),
              ),
            ),
          ],
        ),


        SizedBox(height: isMobile ? 16.h : 85.h),

        // ═══════════════════════════════════════════════════
        // FORM CARD (white container with all form fields)
        // ═══════════════════════════════════════════════════
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14.w : 20.w,
              vertical:   isMobile ? 14.h : 16.h),
          decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ═══════════════════════════════════════════════════
              // PERSONAL INFO SECTION
              // ═══════════════════════════════════════════════════
              _SectionHeader(title: personalInfo, primaryColor: primaryColor),
              SizedBox(height: 8.h),

              // ── Preferred Language ──
              _FormLabel(label: prefLangLabel),
              SizedBox(height: 6.h),
              Row(
                children: ContactFormConstants.preferredLanguages.map((lang) {
                  final bool selected = preferredLanguage == lang;
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: isMobile ? 16.w : 20.w),
                    child: GestureDetector(
                      onTap: () => onLanguageChanged(lang),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18.w, height: 18.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? primaryColor : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? Center(child: Container(
                                width: 10.w, height: 10.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: primaryColor),
                              ))
                                  : null,
                            ),
                            SizedBox(width: 6.w),
                            Text(langLabels[lang] ?? lang,
                                style: StyleText.fontSize13Weight400.copyWith(
                                    color: selected ? Colors.black87 : Colors.black54,
                                    fontSize: isMobile ? 12.sp : 13.sp)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: isMobile ? 10.h : 12.h),

              // ── First Name / Last Name ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: CustomValidatedTextFieldMaster(
                    label: firstNameLabel, hint: hint, controller: firstNameCtrl,
                    submitted: submitted, height: 32, primaryColor: primaryColor,
                    textDirection: dir, textAlign: align,
                  )),
                  SizedBox(width: isMobile ? 8.w : 12.w),
                  Expanded(child: CustomValidatedTextFieldMaster(
                    label: lastNameLabel, hint: hint, controller: lastNameCtrl,
                    submitted: submitted, height: 32, primaryColor: primaryColor,
                    textDirection: dir, textAlign: align,
                  )),
                ],
              ),

              // ── Email / Phone ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: CustomValidatedTextFieldMaster(
                    label: emailLabel, primaryColor: primaryColor,
                    hint: _t(context, en: 'Enter your email', ar: 'أدخل بريدك الإلكتروني'),
                    controller: emailCtrl, submitted: submitted, height: 32,
                    textDirection: dir, textAlign: align,
                  )),
                  SizedBox(width: isMobile ? 8.w : 12.w),
                  Expanded(child: _PhoneField(
                    label: phoneLabel, controller: phoneCtrl, submitted: submitted,
                    isMobile: isMobile, selectedCode: phoneCode,
                    onCodeChanged: onCodeChanged, isRtl: isRtl, primaryColor: primaryColor,
                  )),
                ],
              ),

              // ═══════════════════════════════════════════════════
              // SALON INFO SECTION (Owner only)
              // ═══════════════════════════════════════════════════
              if (_isOwner) ...[
                SizedBox(height: isMobile ? 12.h : 16.h),
                _SectionHeader(title: salonInfo, primaryColor: primaryColor),
                SizedBox(height: 8.h),

                // ── Salon Name EN / Salon Name AR ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CustomValidatedTextFieldMaster(
                      label: salonNameLabel, hint: hint, controller: salonNameCtrl,
                      submitted: submitted, height: 32, primaryColor: primaryColor,
                      textDirection: dir, textAlign: align,
                    )),
                    SizedBox(width: isMobile ? 8.w : 12.w),
                    Expanded(child: CustomValidatedTextFieldMaster(
                      label: salonNameArLabel, hint: hint, controller: salonNameArCtrl,
                      submitted: false, // AR name optional
                      height: 32, primaryColor: primaryColor,
                      textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                    )),
                  ],
                ),

                // ── Target audience (full width) ──
                _DropdownField(
                  label: targetLabel, hint: selectHint, value: selectedTargetAudience,
                  items: targetItems, onChanged: onTargetAudienceChanged,
                  submitted: submitted, isRtl: isRtl, isMobile: isMobile,
                  primaryColor: primaryColor,
                ),

                // ── Country / City ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _DropdownField(
                      label: countryLabel, hint: selectHint, value: selectedSalonCountry,
                      items: countryItems, onChanged: onSalonCountryChanged,
                      submitted: submitted, isRtl: isRtl, isMobile: isMobile,
                      primaryColor: primaryColor, isSearchable: true,
                    )),
                    SizedBox(width: isMobile ? 8.w : 12.w),
                    Expanded(child: CustomValidatedTextFieldMaster(
                      label: cityLabel, hint: hint,
                      controller: TextEditingController(text: selectedSalonCity ?? ''),
                      submitted: false, height: 32, primaryColor: primaryColor,
                      textDirection: dir, textAlign: align,
                    )),
                  ],
                ),

                // ── No.Branches / Services ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _DropdownField(
                      label: branchesLabel, hint: selectHint, value: selectedNoBranches,
                      items: branchItems, onChanged: onNoBranchesChanged,
                      submitted: submitted, isRtl: isRtl, isMobile: isMobile,
                      primaryColor: primaryColor,
                    )),
                    SizedBox(width: isMobile ? 8.w : 12.w),
                    Expanded(child: _DropdownField(
                      label: servicesLabel, hint: selectHint, value: selectedServices,
                      items: serviceItems, onChanged: onServicesChanged,
                      submitted: submitted, isRtl: isRtl, isMobile: isMobile,
                      primaryColor: primaryColor,
                    )),
                  ],
                ),
              ],

              SizedBox(height: _isOwner ? 8.h : 4.h),

              // ═══════════════════════════════════════════════════
              // SUBJECT + REASON + MESSAGE
              // ═══════════════════════════════════════════════════
              CustomValidatedTextFieldMaster(
                primaryColor: primaryColor, label: subjectLabel, hint: hint,
                controller: subjectCtrl, submitted: submitted, height: 32,
                minLength: 5, textDirection: dir, textAlign: align,
              ),

              _DropdownField(
                label: reasonLabel, hint: selectHint, value: selectedReason,
                items: reasonItems, onChanged: onReasonChanged,
                submitted: submitted, isRtl: isRtl, isMobile: isMobile,
                primaryColor: primaryColor,
              ),

              CustomValidatedTextFieldMaster(
                primaryColor: primaryColor, label: msgLabel, hint: hint,
                controller: messageCtrl, submitted: submitted, height: 72,
                maxLines: 3, minLength: 10, textDirection: dir, textAlign: align,
              ),

              SizedBox(height: 8.h),

              // ── SEND Button ──
              SizedBox(
                width: double.infinity, height: isMobile ? 42.h : 38.h,
                child: ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      elevation: 0),
                  child: Text(sendLabel,
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: Colors.white, fontSize: 14.sp,
                          letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════════
// CLIENT / OWNER TOGGLE — Pill-style (matches Figma)
// ═══════════════════════════════════════════════════════════════════════════════

class _UserTypeToggle extends StatelessWidget {
  final String currentType;
  final Color  primaryColor;
  final bool   isMobile;
  final String clientLabel, ownerLabel;
  final ValueChanged<String> onChanged;

  const _UserTypeToggle({
    required this.currentType,
    required this.primaryColor,
    required this.isMobile,
    required this.clientLabel,
    required this.ownerLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClient = currentType == ContactFormConstants.userTypeClient;

    return Container(
      decoration: BoxDecoration(
        color:        Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.all(3.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(
            label:    clientLabel,
            icon:     Icons.person_outline,
            active:   isClient,
            onTap:    () => onChanged(ContactFormConstants.userTypeClient),
          ),
          _toggleButton(
            label:    ownerLabel,
            icon:     Icons.store_outlined,
            active:   !isClient,
            onTap:    () => onChanged(ContactFormConstants.userTypeOwner),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20.w : 24.w,
            vertical:   isMobile ? 8.h  : 8.h,
          ),
          decoration: BoxDecoration(
            color:        active ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size:  isMobile ? 16 : 16.sp,
                  color: active ? Colors.white : Colors.black54),
              SizedBox(width: 6.w),
              Text(label,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color:      active ? Colors.white : Colors.black54,
                    fontSize:   isMobile ? 12.sp : 13.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color  primaryColor;
  const _SectionHeader({required this.title, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: StyleText.fontSize16Weight600.copyWith(
            color: primaryColor, fontSize: 14.sp));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.text, fontSize: 14.sp));
}

class _DropdownField extends StatelessWidget {
  final String  label, hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool submitted, isRtl, isMobile;
  final Color primaryColor;
  final bool isSearchable;

   _DropdownField({
    required this.label,     required this.hint,
    required this.value,     required this.items,
    required this.onChanged, required this.submitted,
    required this.isRtl,     required this.isMobile,
    required this.primaryColor,
    this.isSearchable = false,
  });

  final _primaryColor      = TextEditingController(text: '#008037');

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && (value == null || value!.isEmpty);
    final String requiredMsg = _t(context,
        en: 'This field is required', ar: 'هذا الحقل مطلوب');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label: label),
        SizedBox(height: 3.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          primaryColor: _resolvedPrimaryColor,

          items:         items,
          onChanged:     onChanged,
          width:         double.infinity,
          height:        32,
          borderRadius:  4,
          widthIcon:     16,
          heightIcon:    16,
          hint: Text(hint,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryBlack)),
        ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Text(requiredMsg,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: Colors.red, fontSize: 11.sp)),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }
}

// ─── Phone Field ──────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool   submitted, isMobile, isRtl;
  final String selectedCode, label;
  final ValueChanged<String?> onCodeChanged;
  final Color  primaryColor;

   _PhoneField({
    required this.controller,  required this.submitted,
    required this.selectedCode, required this.onCodeChanged,
    required this.isRtl,       required this.label,
    required this.primaryColor, this.isMobile = false,
  });


  final _primaryColor      = TextEditingController(text: '#008037');

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }
  @override
  Widget build(BuildContext context) {
    final Widget dropdown = CustomDropdownFormFieldInvMaster(
      selectedValue: selectedCode,
      items:         _phoneCodes,
      primaryColor: _resolvedPrimaryColor,

      onChanged:     onCodeChanged,
      widthIcon: 16, heightIcon: 16,
      width: isMobile ? 100.w : 110.w, height: 32, borderRadius: 4,
      hint: Text(isRtl ? 'أدخل رقم هاتفك' : 'Enter your number',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryBlack)),
    );

    final Widget input = Expanded(
      child: CustomValidatedTextFieldMaster(
        hint: isRtl ? 'أدخل رقم هاتفك' : 'Enter your number',
        controller: controller, submitted: submitted,
        primaryColor: primaryColor, height: 32, onlyDigits: true,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign:     isRtl ? TextAlign.right   : TextAlign.left,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.text, fontSize: 14.sp)),
        SizedBox(height: 3.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [dropdown, SizedBox(width: 6.w), input],
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL MEDIA SECTION (below form, above footer)
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialMediaSection extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final Color primaryColor;
  final bool  isMobile, isRtl;

  const _SocialMediaSection({
    this.cmsData,
    required this.primaryColor,
    required this.isMobile,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _t(context, en: 'Social Media', ar: 'وسائل التواصل الاجتماعي');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.w : 0,
        vertical:   24.h,
      ),
      child: Center(
        child: Column(
          children: [
            Text(title,
                style: StyleText.fontSize22Weight700.copyWith(
                    color: primaryColor, fontSize: isMobile ? 18.sp : 20.sp)),
            SizedBox(height: 14.h),
            _SocialRow(
                cmsData:      cmsData,
                primaryColor: primaryColor),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL ICONS
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialRow extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final Color primaryColor;
  const _SocialRow({this.cmsData, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final rawIcons = (cmsData?.socialIcons ?? [])
        .where((i) => i.iconUrl.isNotEmpty || i.link.isNotEmpty)
        .toList();

    if (rawIcons.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: rawIcons
            .map((i) => Padding(
          padding: EdgeInsetsDirectional.only(end: 10.w),
          child: _SocialIconWidget(
              iconUrl: i.iconUrl, link: i.link,
              primaryColor: primaryColor),
        ))
            .toList(),
      );
    }

    // Fallback: local SVG assets
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SocialIconWidget(svgPath: 'assets/images/instegrm.svg', primaryColor: primaryColor),
        SizedBox(width: 10.w),
        _SocialIconWidget(svgPath: 'assets/images/twitter.svg',  primaryColor: primaryColor),
        SizedBox(width: 10.w),
        _SocialIconWidget(svgPath: 'assets/images/linkedin.svg', primaryColor: primaryColor),
      ],
    );
  }
}

class _SocialIconWidget extends StatelessWidget {
  final String? svgPath, iconUrl, link;
  final Color   primaryColor;
  const _SocialIconWidget({
    this.svgPath, this.iconUrl, this.link, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: (link?.isNotEmpty ?? false)
        ? () async {
      String raw = link!.trim();
      if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
        raw = 'https://$raw';
      }
      final uri = Uri.tryParse(raw);
      if (uri == null || !uri.hasAuthority) return;
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank');
      }
    }
        : null,
    child: MouseRegion(
      cursor: (link?.isNotEmpty ?? false)
          ? SystemMouseCursors.click : MouseCursor.defer,
      child: Container(
        width: 42.w, height: 42.w,
        decoration: BoxDecoration(
            border:       Border.all(color: primaryColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8.r)),
        child: Center(
          child: iconUrl != null && iconUrl!.isNotEmpty
              ? SvgPicture.network(iconUrl!,
              width: 22.w, height: 22.w, fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn))
              : SvgPicture.asset(
              svgPath ?? 'assets/images/instegrm.svg',
              width: 22.w, height: 22.w, fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
        ),
      ),
    ),
  );
}