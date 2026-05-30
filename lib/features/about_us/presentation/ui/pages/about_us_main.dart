// ******************* FILE INFO *******************
// File Name: about_us_main.dart
// Screen 1 — About Us CMS: Main view page
// Sub-tabs: About Us | Our Strategy | Terms of Service
// FIXED: Dynamic last-updated date (from model.lastUpdatedAt)
// FIXED: Tab bar restyled to match ServicesMainPageMaster pattern
// FIXED: Show empty model on first open instead of "No data found"
// UPDATED: Added Navigation Label section display

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:beauty_admin/features/about_us/presentation/ui/pages/terms_page/terms_main.dart';
import 'package:beauty_admin/features/about_us/presentation/ui/pages/terms_page/terms_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/core/widget/navigator.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';
import 'about_us_edit.dart';
import 'about_us_preview.dart';
import 'strategy_page/strategy_main.dart';
import 'strategy_page/strategy_preview.dart';

part '../widget/about_us_main/c.dart';
part '../widget/about_us_main/widgets.dart';

class AboutMainPageMasterDashboard extends StatefulWidget {
  const AboutMainPageMasterDashboard({super.key});

  @override
  State<AboutMainPageMasterDashboard> createState() =>
      _AboutMainPageMasterDashboardState();
}

class _AboutMainPageMasterDashboardState
    extends State<AboutMainPageMasterDashboard> {
  int _tabIndex = 0;
  final List<String> _tabLabels = [
    'About Us',
    'Our Strategy',
    'Terms of Service',
  ];

  final Map<String, bool> _open = {
    'headings': true,
    'navigationLabel': true,
    'vision': true,
    'mission': true,
    'values': true,
  };

  final Map<String, Future<Uint8List>> _urlBytesCache = {};

  late final StrategyCubit _strategyCubit;
  late final TermsCubit _termsCubit;

  @override
  void initState() {
    super.initState();
    _strategyCubit = StrategyCubit();
    _termsCubit = TermsCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AboutCubit>().load();
    });
  }

  @override
  void dispose() {
    _strategyCubit.close();
    _termsCubit.close();
    super.dispose();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  Future<Uint8List> _cachedLoad(String url, {bool isSvg = false}) {
    return _urlBytesCache.putIfAbsent(
      url,
      () => isSvg ? _loadSvg(url) : _loadImageBytes(url),
    );
  }

  Future<Uint8List> _loadImageBytes(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
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
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  bool _isSvgBytes(Uint8List b) {
    if (b.length < 5) return false;
    final header = String.fromCharCodes(
      b.sublist(0, b.length.clamp(0, 100)),
    ).trimLeft();
    return header.startsWith('<svg') || header.startsWith('<?xml');
  }

  void _onPreviewTap(AboutPageModel aboutModel) {
    switch (_tabIndex) {
      case 0:
        final cubit = context.read<AboutCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: AboutPreviewPage(
                previewModel: aboutModel,
                onPublish: () async {
                  // Optional: handle publish from preview
                },
              ),
            ),
          ),
        );
        break;

      case 1:
        final strategyState = _strategyCubit.state;
        final OurStrategyModel? sm = switch (strategyState) {
          StrategyLoaded s => s.data,
          StrategySaved s => s.data,
          _ => null,
        };
        if (sm == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Strategy data not loaded yet.')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: _strategyCubit,
              child: StrategyPreviewPage(model: sm, imageUploads: const {}),
            ),
          ),
        );
        break;

      case 2:
        final termsState = _termsCubit.state;
        final TermsOfServiceModel? tm = switch (termsState) {
          TermsLoaded s => s.data,
          TermsSaved s => s.data,
          _ => null,
        };
        if (tm == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terms data not loaded yet.')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: _termsCubit,
              child: TermsPreviewPage(model: tm, imageUploads: const {}),
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AboutCubit, AboutState>(
      builder: (context, state) {
        // ── Show loading spinner ──────────────────────────────────────────
        if (state is AboutLoading || state is AboutInitial) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(
                child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        // ── Extract model — fall back to empty() on first open ────────────
        final AboutPageModel model = switch (state) {
          AboutLoaded s => s.data,
          AboutSaved s => s.data,
          _ => AboutPageModel.empty(),
        };

        return Scaffold(
          backgroundColor: ColorPick.background,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  SizedBox(height: 20.h),
                  SizedBox(width: 1000.w, child: _body(model)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(AboutPageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'About Us',
              style: StyleText.fontSize45Weight600.copyWith(
                color: ColorPick.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _onPreviewTap(model),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: ColorPick.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Preview Screen',
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        _buildTabBar(),
        SizedBox(height: 12.h),

        if (_tabIndex == 0) _aboutUsTab(model),
        if (_tabIndex == 1)
          BlocProvider.value(
            value: _strategyCubit,
            child: const StrategyMainView(),
          ),
        if (_tabIndex == 2)
          BlocProvider.value(
              value: _termsCubit, child: const TermsMainView()),

        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: List.generate(_tabLabels.length, (i) {
        final isActive = _tabIndex == i;
        return Padding(
          padding: EdgeInsets.only(right: 24.w),
          child: GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      _tabLabels[i],
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? ColorPick.primary
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color:
                        isActive ? ColorPick.primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _aboutUsTab(AboutPageModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lastUpdatedRow(
          lastUpdated: model.lastUpdatedAt,
          onEdit: () => navigateTo(context, AboutEditPageMaster()),
        ),
        SizedBox(height: 16.h),

        _accordion(
          key: 'headings',
          title: 'Headings',
          children: [
            Row(
              children: [
                Expanded(
                  child: _readField(
                    'Title',
                    model.title.en.isEmpty ? 'Text Here' : model.title.en,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(child: _readFieldRtl('العنوان', model.title.ar)),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── Navigation Label Section ──────────────────────────────────────
        _accordion(
          key: 'navigationLabel',
          title: 'Navigation Label',
          children: [
            Row(
              children: [
                _iconPreviewCircle(
                  label: 'Icon',
                  url: model.navigationLabel.iconUrl,
                  isSvg: true,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _readField(
                    'Title',
                    model.navigationLabel.title.en.isEmpty
                        ? 'Text Here'
                        : model.navigationLabel.title.en,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _readFieldRtl(
                    'العنوان',
                    model.navigationLabel.title.ar.isEmpty
                        ? 'أكتب هنا'
                        : model.navigationLabel.title.ar,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        _accordion(
          key: 'vision',
          title: 'Vision',
          children: [
            _sectionReadView(
              iconUrl: model.vision.iconUrl,
              svgUrl: model.vision.svgUrl,
              subDescEn: model.vision.subDescription.en,
              subDescAr: model.vision.subDescription.ar,
              descEn: model.vision.description.en,
              descAr: model.vision.description.ar,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        _accordion(
          key: 'mission',
          title: 'Mission',
          children: [
            _sectionReadView(
              iconUrl: model.mission.iconUrl,
              svgUrl: model.mission.svgUrl,
              subDescEn: model.mission.subDescription.en,
              subDescAr: model.mission.subDescription.ar,
              descEn: model.mission.description.en,
              descAr: model.mission.description.ar,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        _accordion(
          key: 'values',
          title: 'Values',
          children: [
            if (model.values.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No values yet.',
                    style: StyleText.fontSize13Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              )
            else
              _valuesGrid(model.values),
          ],
        ),
      ],
    );
  }
}
