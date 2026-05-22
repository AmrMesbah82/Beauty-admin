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

import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/model/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';
import 'about_us_edit.dart';
import 'about_us_preview.dart';
import 'strategy_page/strategy_main.dart';
import 'strategy_page/strategy_preview.dart';

part '../widget/about_us_main/c.dart';

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

  Widget _renderBytes(
      Uint8List b, {
        bool isSvg = false,
        BoxFit fit = BoxFit.cover,
      }) {
    if (isSvg || _isSvgBytes(b)) {
      return SvgPicture.memory(b, fit: fit);
    }
    return Image.memory(b, fit: fit);
  }

  Widget _networkImage({
    required String url,
    bool isSvg = false,
    BoxFit fit = BoxFit.cover,
    double iconSize = 24,
  }) {
    if (url.isEmpty) {
      return Icon(
        isSvg ? Icons.description_outlined : Icons.image_outlined,
        color: Colors.grey[500],
        size: iconSize.sp,
      );
    }

    final viewId = 'svg-about-main-${url.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      return img;
    });

    return HtmlElementView(viewType: viewId);
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
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        // ── Extract model — fall back to empty() on first open ────────────
        final AboutPageModel model = switch (state) {
          AboutLoaded s => s.data,
          AboutSaved s => s.data,
          _ => AboutPageModel.empty(),
        };

        return Scaffold(
          backgroundColor: _C.back,
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
                color: _C.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _onPreviewTap(model),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _C.primary,
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
          BlocProvider.value(value: _termsCubit, child: const TermsMainView()),

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
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive ? _C.primary : _C.hintText,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: isActive ? _C.primary : Colors.transparent,
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

        // ── NEW: Navigation Label Section ─────────────────────────────────
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
                      color: _C.hintText,
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

  Widget _sectionReadView({
    required String iconUrl,
    required String svgUrl,
    required String subDescEn,
    required String subDescAr,
    required String descEn,
    required String descAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconPreviewCircle(label: 'Icon', url: iconUrl),
            SizedBox(width: 24.w),
            _iconPreviewCircle(label: 'SVG', url: svgUrl, isSvg: true),
          ],
        ),
        SizedBox(height: 16.h),
        _readField(
          'Sub Description',
          subDescEn.isEmpty ? 'Text Here' : subDescEn,
          height: 80,
        ),
        SizedBox(height: 15.h),
        _readFieldRtl('وصف فرعي', subDescAr, height: 80),
        SizedBox(height: 10.h),
        _readField(
          'Description',
          descEn.isEmpty ? 'Text Here' : descEn,
          height: 80,
        ),
        SizedBox(height: 15.h),
        _readFieldRtl('الوصف', descAr, height: 80),
      ],
    );
  }

  Widget _iconPreviewCircle({
    required String label,
    required String url,
    bool isSvg = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
        ),
        SizedBox(height: 6.h),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: url.isNotEmpty
              ? ClipOval(
            child: SizedBox(
              width: 56.w,
              height: 56.w,
              child: _networkImage(
                url: url,
                isSvg: isSvg,
                fit: BoxFit.contain,
                iconSize: 24,
              ),
            ),
          )
              : Center(
            child: Icon(
              isSvg ? Icons.description_outlined : Icons.image_outlined,
              color: Colors.grey[500],
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _valuesGrid(List<AboutValueItem> items) {
    final rows = <List<AboutValueItem>>[];
    for (int i = 0; i < items.length; i += 4) {
      rows.add(items.skip(i).take(4).toList());
    }
    return Column(
      children: rows
          .map(
            (row) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...row.map(
                    (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _valueMiniCard(item),
                  ),
                ),
              ),
              ...List.generate(
                4 - row.length,
                    (_) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _valueMiniCard(AboutValueItem item) {
    return Container(
      height: 140.h,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: _networkImage(
                url: item.iconUrl,
                isSvg: false,
                fit: BoxFit.contain,
                iconSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: StyleText.fontSize12Weight600.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: Text(
              item.shortDescription.en.isNotEmpty
                  ? item.shortDescription.en
                  : 'Short Description',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryBlack,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastUpdatedRow({
    required VoidCallback onEdit,
    DateTime? lastUpdated,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'Last Updated On ${_fmtDate(lastUpdated)}',
            style: StyleText.fontSize13Weight500.copyWith(color: _C.primary),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 130.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Details',
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  CustomSvg(
                    assetPath: "assets/control/edit_icon_pick.svg",
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.scaleDown,
                    color: _C.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _readField(String label, String value, {double height = 36}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
      ),
      SizedBox(height: 4.h),
      Container(
        width: double.infinity,
        height: height.h,
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: height > 36 ? 8.h : 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
        child: Text(
          value,
          style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
          maxLines: height > 36 ? 5 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _readFieldRtl(
      String label,
      String value, {
        double height = 36,
      }) => Directionality(
    textDirection: TextDirection.rtl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: height.h,
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: height > 36 ? 8.h : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: height > 36 ? Alignment.topRight : Alignment.centerRight,
          child: Text(
            value.isEmpty ? 'أكتب هنا' : value,
            style: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
            textDirection: TextDirection.rtl,
            maxLines: height > 36 ? 5 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
