/// ******************* FILE INFO *******************
/// File Name: client_services_main_page.dart
/// Description: Main read-only view for Client Services CMS.
///              Sections: Header, Download Applications, Mockups.
///              Published/Scheduled/Draft tabs, Female/Male toggle.
/// Created by: Amr Mesbah
/// Last Update: 08/04/2026

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';

import '../../controller/client_services/client_services_cubit.dart';
import '../../controller/client_services/client_services_state.dart';
import '../../model/client_services/client_services_model.dart';
import 'client_services_edit_page.dart';
import 'client_services_preview_page.dart';

class _C {
  static const Color primary     = Color(0xFFD16F9A);
  static const Color sectionBg   = Color(0xFFF5F5F5);
  static const Color cardBg      = Color(0xFFFFFFFF);
  static const Color border      = Color(0xFFE0E0E0);
  static const Color labelText   = Color(0xFF333333);
  static const Color hintText    = Color(0xFFAAAAAA);
  static const Color back        = Color(0xFFF1F2ED);
  static const Color tabActive   = Color(0xFFD16F9A);
  static const Color tabInactive = Color(0xFF999999);
}

class ClientServicesMainPage extends StatefulWidget {
  const ClientServicesMainPage({super.key});

  @override
  State<ClientServicesMainPage> createState() => _ClientServicesMainPageState();
}

class _ClientServicesMainPageState extends State<ClientServicesMainPage> {
  int _statusTab = 0;
  String _gender = 'female';
  final List<String> _statusLabels = ['Published', 'Scheduled', 'Draft'];

  final Map<String, bool> _open = {
    'header': true,
    'download': true,
    'mockups': true,
  };

  @override
  void initState() {
    super.initState();
    context.read<ClientServicesCmsCubit>().load(gender: _gender);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientServicesCmsCubit, ClientServicesCmsState>(
      listener: (context, state) {
        if (state is ClientServicesCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400.copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is ClientServicesCmsInitial || state is ClientServicesCmsLoading) {
          return const Scaffold(
              backgroundColor: _C.back,
              body: Center(child: CircularProgressIndicator(color: _C.primary)));
        }

        ClientServicesPageModel? model;
        if (state is ClientServicesCmsLoaded) model = state.data;
        if (state is ClientServicesCmsSaved) model = state.data;
        model ??= context.read<ClientServicesCmsCubit>().current;

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 1000.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 20.w),
                        const AdminSubNavBar(activeIndex: 3),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Title + Preview ─────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Client Services Details',
                                      style: StyleText.fontSize45Weight600
                                          .copyWith(color: _C.primary, fontWeight: FontWeight.w700)),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const ClientServicesPreviewPage())),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                          color: _C.primary, borderRadius: BorderRadius.circular(6.r)),
                                      child: Text('Preview Screen',
                                          style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // ── Gender + Last Updated + Edit ───────────
                              Row(
                                children: [
                                  _genderChip('Female', 'female'),
                                  SizedBox(width: 8.w),
                                  _genderChip('Male', 'male'),
                                  const Spacer(),
                                  if (model.lastUpdated != null)
                                    Text(
                                      'Last Updated On ${DateFormat('dd MMM yyyy').format(model.lastUpdated!)}',
                                      style: StyleText.fontSize12Weight400.copyWith(color: _C.tabActive),
                                    ),
                                  SizedBox(width: 16.w),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const ClientServicesEditPage())),
                                    child: Row(children: [
                                      Text('Edit Client View',
                                          style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
                                      SizedBox(width: 4.w),
                                      Icon(Icons.edit_outlined, size: 14.sp, color: _C.labelText),
                                    ]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // ── Header ─────────────────────────────────
                              _headerSection(model),
                              SizedBox(height: 10.h),

                              // ── Download ───────────────────────────────
                              _downloadSection(model),
                              SizedBox(height: 10.h),

                              // ── Mockups ────────────────────────────────
                              _mockupsSection(model),
                              SizedBox(height: 40.h),
                            ],
                          ),
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
    );
  }

  Widget _genderChip(String label, String value) {
    final isActive = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() => _gender = value);
        context.read<ClientServicesCmsCubit>().switchGender(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? _C.primary : Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: isActive ? _C.primary : _C.border),
        ),
        child: Text(label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: isActive ? Colors.white : _C.labelText)),
      ),
    );
  }

  Widget _accordion({required String key, required String title, required List<Widget> children}) {
    final isOpen = _open[key] ?? true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _open[key] = !isOpen),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: isOpen
                ? BorderRadius.only(topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r))
                : BorderRadius.circular(6.r),
          ),
          child: Row(children: [
            Expanded(child: Text(title, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
            Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 20.sp),
          ]),
        ),
      ),
      if (isOpen)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(6.r), bottomRight: Radius.circular(6.r)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
    ]);
  }

  Widget _headerSection(ClientServicesPageModel m) => _accordion(
    key: 'header',
    title: 'Header',
    children: [
      _readOnlyLabel('SVG'),
      SizedBox(height: 6.h),
      _readOnlyImageCircle(m.header.svgUrl),
      SizedBox(height: 14.h),
      _readOnlyBiRow('Title', 'العنوان', m.header.title.en, m.header.title.ar),
      SizedBox(height: 10.h),
      _readOnlyLabel('Description'),
      SizedBox(height: 6.h),
      _readOnlyBox(m.header.description.en, maxLines: 4),
      SizedBox(height: 8.h),
      Align(
          alignment: Alignment.centerRight,
          child: Text('الوصف', style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text))),
      SizedBox(height: 6.h),
      _readOnlyBox(m.header.description.ar, maxLines: 4, textDirection: ui.TextDirection.rtl),
    ],
  );

  Widget _downloadSection(ClientServicesPageModel m) => _accordion(
    key: 'download',
    title: 'Download Applications',
    children: [
      _readOnlyBiRow('Title', 'العنوان', m.download.title.en, m.download.title.ar),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Apple Store Link', style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          _readOnlyBox(m.download.appStoreLink),
        ])),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Android Link', style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          _readOnlyBox(m.download.googlePlayLink),
        ])),
      ]),
    ],
  );

  Widget _mockupsSection(ClientServicesPageModel m) => _accordion(
    key: 'mockups',
    title: 'Mockups',
    children: [
      ...m.mockups.items.map((item) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _readOnlyLabel('SVG'),
            const Spacer(),
            _layoutChips(item.layout),
          ]),
          SizedBox(height: 6.h),
          _readOnlyImageCircle(item.svgUrl),
          SizedBox(height: 10.h),
          _readOnlyBiRow('Title', 'العنوان', item.title.en, item.title.ar),
          SizedBox(height: 8.h),
          _readOnlyLabel('Description'),
          SizedBox(height: 6.h),
          _readOnlyBox(item.description.en, maxLines: 4),
          SizedBox(height: 8.h),
          Align(
              alignment: Alignment.centerRight,
              child: Text('الوصف', style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text))),
          SizedBox(height: 6.h),
          _readOnlyBox(item.description.ar, maxLines: 4, textDirection: ui.TextDirection.rtl),
          SizedBox(height: 8.h),
          Divider(color: _C.border),
        ]),
      )),
    ],
  );

  Widget _layoutChips(MockupLayout layout) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (final l in MockupLayout.values)
        Container(
          margin: EdgeInsets.only(left: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: layout == l ? _C.primary : Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: layout == l ? _C.primary : _C.border),
          ),
          child: Text(l.name[0].toUpperCase() + l.name.substring(1),
              style: StyleText.fontSize11Weight400
                  .copyWith(color: layout == l ? Colors.white : _C.labelText)),
        ),
    ]);
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _readOnlyLabel(String t) =>
      Text(t, style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _readOnlyBiRow(String enL, String arL, String enV, String arV) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(enL, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          _readOnlyBox(enV),
        ])),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(arL, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          _readOnlyBox(arV, textDirection: ui.TextDirection.rtl),
        ])),
      ]);

  Widget _readOnlyBox(String text,
      {int maxLines = 1, ui.TextDirection textDirection = ui.TextDirection.ltr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      constraints: maxLines > 1 ? BoxConstraints(minHeight: 80.h) : null,
      decoration: BoxDecoration(color: _C.sectionBg, borderRadius: BorderRadius.circular(4.r)),
      child: Text(text.isEmpty ? 'Text Here' : text,
          textDirection: textDirection,
          style: StyleText.fontSize12Weight400
              .copyWith(color: text.isEmpty ? _C.hintText : _C.labelText),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _readOnlyImageCircle(String url) {
    if (url.isNotEmpty) {
      return Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(child: ClipOval(child: Padding(
            padding: EdgeInsets.all(10.w),
            child: SvgPicture.network(url, width: 30.w, height: 30.h,
                fit: BoxFit.contain, placeholderBuilder: (_) => const CircleProgressMaster())))),
      );
    }
    return Container(
      width: 70.w, height: 70.h,
      decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
      child: Center(child: Icon(Icons.add_circle_outline, size: 24.sp, color: _C.hintText)),
    );
  }
}