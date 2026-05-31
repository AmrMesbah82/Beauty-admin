// ******************* FILE INFO *******************
// File Name: contact_us_main.dart
// UPDATED: Complete rewrite to match new Figma design
//          - Headings section (SVG, Title EN/AR, Short Description EN/AR)
//          - Client Description (Description EN/AR, Reasons with Required toggle)
//          - Owner Description (Description EN/AR, Reasons with Required toggle)
//          - Social Media Links (dropdown grid 2 per row)
//          - Removed old: Info, Office Locations, Confirm Message

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../home/presentation/ui/pages/home_main.dart';
import '../../../data/models/contact_us_model_location.dart';
import '../../controller/contact_us_location_cubit.dart';
import '../../controller/contact_us_location_state.dart';
import 'contact_us_edit.dart';
import 'contact_us_preview.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

part '../widgets/contact_us_main/c.dart';

class ContactUsMainPage extends StatefulWidget {
  const ContactUsMainPage({super.key});

  @override
  State<ContactUsMainPage> createState() => _ContactUsMainPageState();
}

class _ContactUsMainPageState extends State<ContactUsMainPage> {
  final Map<String, bool> _open = {
    'headings':    true,
    'clientDesc':  true,
    'ownerDesc':   true,
    'socialLinks': true,
  };

  // ── Date formatter ─────────────────────────────────────────────────────────
  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
      builder: (context, state) {
        if (state is ContactUsCmsInitial || state is ContactUsCmsLoading) {
          return const Scaffold(
            backgroundColor: ColorPick.background,
            body: Center(child: CircularProgressIndicator(color: ColorPick.primary)),
          );
        }

        ContactUsCmsModel? data;
        if (state is ContactUsCmsLoaded) data = state.data;
        if (state is ContactUsCmsSaved)  data = state.data;

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
                  SizedBox(height: 20.h),
                  AdminSubNavBar(activeIndex: 6),
                  SizedBox(height: 20.h),
                  Container(
                    width: 1000.w,
                    child: data == null
                        ? const Center(
                        child: CircularProgressIndicator(color: ColorPick.primary))
                        : _body(data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _body(ContactUsCmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + Preview Screen ─────────────────────────────────────────
        Row(
          children: [
            Text(
              'Contact Us',
              style: StyleText.fontSize45Weight600.copyWith(
                color: ColorPick.primary, fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactUsCmsPreviewPage(),
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: ColorPick.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('Preview Screen',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // ── Last Updated + Edit ────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorPick.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'Last Updated On ${_fmtDate(data.lastUpdatedAt)}',
                style: StyleText.fontSize13Weight500
                    .copyWith(color: ColorPick.primary),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactUsCmsEditPage(),
                ),
              ),
              child: Container(
                width: 150.w, height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Edit Contact Us',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: Colors.black)),
                    SizedBox(width: 6.w),
                    CustomSvg(
                        assetPath: "assets/control/edit_icon_pick.svg",
                        width: 20.w, height: 20.h,
                        fit: BoxFit.scaleDown, color: ColorPick.primary),
                  ]),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // ── Headings Section ───────────────────────────────────────────────
        _accordion(
          key:   'headings',
          title: 'Headings',
          children: [
            SizedBox(height: 15.h),
            _svgLabel('SVG'),
            SizedBox(height: 6.h),
            _imgCircle(data.headings.svgUrl, isSvg: true),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _readField('Title', data.headings.title.en)),
                SizedBox(width: 16.w),
                Expanded(child: _readFieldRtl('العنوان', data.headings.title.ar)),
              ],
            ),
            SizedBox(height: 10.h),
            _readField('Short Description', data.headings.shortDescription.en),
            SizedBox(height: 10.h),
            _readFieldRtl('وصف مختصر', data.headings.shortDescription.ar),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Client Description ─────────────────────────────────────────────
        _accordion(
          key:   'clientDesc',
          title: 'Client Description',
          children: [
            SizedBox(height: 15.h),
            _readField('Description', data.clientDescription.description.en, height: 80),
            SizedBox(height: 10.h),
            _readFieldRtl('الوصف', data.clientDescription.description.ar, height: 80),
            SizedBox(height: 16.h),
            ...data.clientDescription.reasons.asMap().entries.map((e) =>
                _reasonReadItem(e.value, e.key)),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Owner Description ──────────────────────────────────────────────
        _accordion(
          key:   'ownerDesc',
          title: 'Owner Description',
          children: [
            SizedBox(height: 15.h),
            _readField('Description', data.ownerDescription.description.en, height: 80),
            SizedBox(height: 10.h),
            _readFieldRtl('الوصف', data.ownerDescription.description.ar, height: 80),
            SizedBox(height: 16.h),
            ...data.ownerDescription.reasons.asMap().entries.map((e) =>
                _reasonReadItem(e.value, e.key)),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Social Media Links ─────────────────────────────────────────────
        _accordion(
          key:   'socialLinks',
          title: 'Social Media Links',
          children: [
            SizedBox(height: 15.h),
            if (data.socialIcons.isEmpty)
              Text('No social links added',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText))
            else
              _socialLinksGrid(data.socialIcons),
          ],
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  // ── Reason read-only item ──────────────────────────────────────────────────
// ── Reason read-only item — isRequired removed ─────────────────────────────
  Widget _reasonReadItem(ContactReasonItem reason, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reason',
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(child: _readField('', reason.label.en)),
              SizedBox(width: 16.w),
              Expanded(child: _readFieldRtl('السبب', reason.label.ar)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _requiredIndicator(bool isRequired) {
    return Container(
      width: 36.w, height: 20.h,
      decoration: BoxDecoration(
        color: isRequired ? ColorPick.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Align(
        alignment: isRequired ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16.w, height: 16.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // ── Social Links Grid (2 per row) ──────────────────────────────────────────
  Widget _socialLinksGrid(List<ContactSocialIcon> icons) {
    final rows = (icons.length / 2).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final left  = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _socialLinkReadItem(icons[left])),
              SizedBox(width: 16.w),
              right < icons.length
                  ? Expanded(child: _socialLinkReadItem(icons[right]))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _socialLinkReadItem(ContactSocialIcon icon) {
    return _readField('',
        icon.link.isEmpty ? 'Insert Links' : icon.link);
  }

  // ── SVG Label ──────────────────────────────────────────────────────────────
  Widget _svgLabel(String text) => Text(text,
      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text));

  // ── Image Circle ───────────────────────────────────────────────────────────
  Widget _imgCircle(String url, {bool isSvg = false}) {
    if (url.isNotEmpty) {
      final viewId = 'svg-contact-main-${url.hashCode}';

      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
        return img;
      });

      return Container(
        width: 60.w,
        height: 60.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: SizedBox(
            width: 60.w,
            height: 60.h,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      );
    }
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isSvg ? Icons.description_outlined : Icons.image_outlined,
          color: Colors.grey,
          size: 20.sp,
        ),
      ),
    );
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
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
                color: ColorPick.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }

  // ── Read Field ─────────────────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(label,
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
          if (label.isNotEmpty)
            SizedBox(height: 4.h),
          Container(
            width: double.infinity, height: height.h,
            padding: EdgeInsets.symmetric(
                horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r)),
            alignment: height > 36 ? Alignment.topLeft : Alignment.centerLeft,
            child: Text(
              value.isEmpty ? 'Text Here' : value,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
              maxLines: height > 36 ? 4 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _readFieldRtl(String label, String value, {double height = 36}) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty)
              Text(label,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text)),
            if (label.isNotEmpty)
              SizedBox(height: 4.h),
            Container(
              width: double.infinity, height: height.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(4.r)),
              alignment:
              height > 36 ? Alignment.topRight : Alignment.centerRight,
              child: Text(
                value.isEmpty ? 'أكتب هنا' : value,
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                textDirection: TextDirection.rtl,
                maxLines: height > 36 ? 4 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
