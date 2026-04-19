/// ******************* FILE INFO *******************
/// File Name: owner_services_preview_page.dart
/// Description: Preview page for Owner Services CMS.
///              Toggles: Desktop / Tablet / Mobile, EN / AR.
///              Renders: Header section with SVG + text,
///              Download section with store badges,
///              Mockups with phone image + text based on alignment.
///              Buttons: Back / Save (with confirm dialog).
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';



import '../../../core/custom_dialog.dart';
import '../../controller/owner_services/owner_services_cubit.dart';
import '../../controller/owner_services/owner_services_state.dart';
import '../../core/widget/circle_progress.dart';
import '../../model/owner_services/owner_services_model.dart';
import '../../theme/new_theme.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFFDF5F8);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
  static const Color addBtn    = Color(0xFF797979);
}

class OwnerServicesPreviewPage extends StatefulWidget {
  const OwnerServicesPreviewPage({super.key});

  @override
  State<OwnerServicesPreviewPage> createState() =>
      _OwnerServicesPreviewPageState();
}

class _OwnerServicesPreviewPageState
    extends State<OwnerServicesPreviewPage> {
  String _device = 'Desktop'; // Desktop / Tablet / Mobile
  String _lang = 'en'; // en / ar

  // ── Accordion ─────────────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'view': true,
  };

  double get _previewWidth {
    switch (_device) {
      case 'Mobile':
        return 375.w;
      case 'Tablet':
        return 600.w;
      default:
        return 900.w;
    }
  }

  bool get _isAr => _lang == 'ar';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      builder: (context, state) {
        final cubit = context.read<OwnerServicesCmsCubit>();
        final data = cubit.current;

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
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preview Owner Services Details',
                              style: StyleText.fontSize45Weight600
                                  .copyWith(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 12.h),

                          // ── Device + Language toggles ──────────
                          Row(children: [
                            _deviceToggle(),
                            const Spacer(),
                            _langToggle(),
                          ]),
                          SizedBox(height: 16.h),

                          // ── View accordion ─────────────────────
                          _accordionWrap('view', 'View', [
                            _previewContent(data),
                          ]),
                          SizedBox(height: 20.h),

                          // ── Action buttons ─────────────────────
                          _actionRow(cubit),
                          SizedBox(height: 40.h),
                        ],
                      ),
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

  // ── Device toggle ─────────────────────────────────────────────────────────
  Widget _deviceToggle() => Row(
    children: ['Desktop', 'Tablet', 'Mobile']
        .map((d) => Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => setState(() => _device = d),
        child: Text(d,
            style: StyleText.fontSize14Weight600.copyWith(
                color: d == _device
                    ? _C.primary
                    : _C.hintText)),
      ),
    ))
        .toList(),
  );

  // ── Language toggle ───────────────────────────────────────────────────────
  Widget _langToggle() => Row(children: [
    _langPill('EN', 'en'),
    SizedBox(width: 6.w),
    _langPill('ع', 'ar'),
  ]);

  Widget _langPill(String label, String code) => GestureDetector(
    onTap: () => setState(() => _lang = code),
    child: Container(
      width: 32.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: _lang == code ? _C.primary : Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
            color: _lang == code ? _C.primary : _C.border),
      ),
      child: Center(
          child: Text(label,
              style: StyleText.fontSize10Weight400.copyWith(
                  color: _lang == code
                      ? Colors.white
                      : _C.labelText))),
    ),
  );

  // ── Accordion wrapper ─────────────────────────────────────────────────────
  Widget _accordionWrap(
      String key, String title, List<Widget> children) {
    final isOpen = _open[key] ?? true;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp),
              ]),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PREVIEW CONTENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _previewContent(OwnerServicesPageModel data) {
    return Directionality(
      textDirection: _isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Center(
        child: Container(
          width: _previewWidth,
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(6.r),
              bottomRight: Radius.circular(6.r),
            ),
          ),
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header section ──────────────────────────────
                _previewHeader(data),
                SizedBox(height: 24.h),

                // ── Download section ────────────────────────────
                _previewDownload(data),
                SizedBox(height: 24.h),

                // ── Mockups ─────────────────────────────────────
                ...List.generate(
                    data.mockups.items.length,
                        (i) => Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: _previewMockupItem(
                          data.mockups.items[i]),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Preview Header ────────────────────────────────────────────────────────
  Widget _previewHeader(OwnerServicesPageModel data) {
    final title = _isAr
        ? data.header.title.ar
        : data.header.title.en;
    final desc = _isAr
        ? data.header.description.ar
        : data.header.description.en;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(title,
                      style: StyleText.fontSize24Weight600
                          .copyWith(color: _C.primary)),
                if (desc.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(desc,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: _C.labelText)),
                ],
              ]),
        ),
        SizedBox(width: 16.w),
        if (data.header.imageUrl.isNotEmpty)
          Expanded(
            flex: 2,
            child: SvgPicture.network(
              data.header.imageUrl,
              height: 120.h,
              fit: BoxFit.contain,
              placeholderBuilder: (_) =>
              const CircleProgressMaster(),
            ),
          ),
      ]),
    );
  }

  // ── Preview Download ──────────────────────────────────────────────────────
  Widget _previewDownload(OwnerServicesPageModel data) {
    final hasLinks = data.download.appStoreLink.isNotEmpty ||
        data.download.googlePlayLink.isNotEmpty;
    if (!hasLinks) return const SizedBox.shrink();

    return Center(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (data.download.googlePlayLink.isNotEmpty)
          GestureDetector(
            onTap: () => html.window
                .open(data.download.googlePlayLink, '_blank'),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.play_arrow,
                    color: Colors.white, size: 20.sp),
                SizedBox(width: 6.w),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('GET IT ON',
                          style: StyleText.fontSize8Weight400
                              .copyWith(color: Colors.white)),
                      Text('Google Play',
                          style: StyleText.fontSize12Weight600
                              .copyWith(color: Colors.white)),
                    ]),
              ]),
            ),
          ),
        if (data.download.googlePlayLink.isNotEmpty &&
            data.download.appStoreLink.isNotEmpty)
          SizedBox(width: 12.w),
        if (data.download.appStoreLink.isNotEmpty)
          GestureDetector(
            onTap: () => html.window
                .open(data.download.appStoreLink, '_blank'),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.apple,
                    color: Colors.white, size: 20.sp),
                SizedBox(width: 6.w),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Available on the',
                          style: StyleText.fontSize8Weight400
                              .copyWith(color: Colors.white)),
                      Text('App Store',
                          style: StyleText.fontSize12Weight600
                              .copyWith(color: Colors.white)),
                    ]),
              ]),
            ),
          ),
      ]),
    );
  }

  // ── Preview Mockup Item ───────────────────────────────────────────────────
  Widget _previewMockupItem(OwnerServicesMockupItemModel item) {
    final title = _isAr ? item.title.ar : item.title.en;
    final desc = _isAr ? item.description.ar : item.description.en;

    final textWidget = Expanded(
      flex: 3,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(title,
                  style: StyleText.fontSize18Weight500
                      .copyWith(color: _C.labelText)),
            if (desc.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(desc,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.labelText)),
            ],
          ]),
    );

    final imageWidget = item.imageUrl.isNotEmpty
        ? Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _C.border, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SvgPicture.network(
            item.imageUrl,
            height: 200.h,
            fit: BoxFit.contain,
            placeholderBuilder: (_) =>
            const CircleProgressMaster(),
          ),
        ),
      ),
    )
        : const SizedBox.shrink();

    // Layout based on alignment
    switch (item.alignment) {
      case 'right':
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _C.sectionBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(children: [
            textWidget,
            SizedBox(width: 16.w),
            imageWidget,
          ]),
        );
      case 'centered':
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _C.sectionBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(children: [
            if (item.imageUrl.isNotEmpty)
              SvgPicture.network(
                item.imageUrl,
                height: 200.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                const CircleProgressMaster(),
              ),
            SizedBox(height: 12.h),
            if (title.isNotEmpty)
              Text(title,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize18Weight500
                      .copyWith(color: _C.labelText)),
            if (desc.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(desc,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.labelText)),
            ],
          ]),
        );
      case 'left':
      default:
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _C.sectionBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(children: [
            imageWidget,
            SizedBox(width: 16.w),
            textWidget,
          ]),
        );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _actionRow(OwnerServicesCmsCubit cubit) => Row(children: [
    Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
              color: _C.addBtn,
              borderRadius: BorderRadius.circular(6.r)),
          child: Center(
              child: Text('Back',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white))),
        ),
      ),
    ),
    SizedBox(width: 16.w),
    Expanded(
      child: GestureDetector(
        onTap: () => showPublishConfirmDialog(
          context: context,
          onConfirm: () async {
            await cubit.save(publishStatus: 'published');
            Get.forceAppUpdate();
            html.window.location.reload();
          },
        ),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(6.r)),
          child: Center(
              child: Text('Save',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white))),
        ),
      ),
    ),
  ]);
}