/// ******************* FILE INFO *******************
/// File Name: overview_preview_page.dart
/// Description: Preview page for Master CMS (Overview-style).
///              Renders: Overview text, Top Services row,
///              Gallery grid, Client Comments cards,
///              Download section with store badges.
///              Desktop / Tablet / Mobile frames, EN / AR toggle.
///              Back + Publish buttons at bottom.
/// Updated: 19/04/2026
///   - Accepts previewModel param so edits are visible before saving
///   - Accepts onPublish callback so publish runs the full edit-page save logic
/// Fixed: 19/04/2026
///   - Model is now stored in _effectiveModel during initState so BlocBuilder
///     rebuilds (triggered by cubit emitting OverviewCmsLoaded) can NEVER
///     override the draft passed from the edit page. Previously the BlocBuilder
///     re-evaluated the model on every state change and ignored previewModel
///     whenever cubit had loaded data.
///   - Image rendering updated: data-URLs (base64) are rendered with
///     Image.network instead of SvgPicture.network so locally-picked images
///     that were encoded as data-URLs in _buildDraftModel are displayed.
/// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/theme/new_theme.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/overview/overview_cubit.dart';
import '../../controller/overview/overview_state.dart';
import '../../core/custom_segmant_tab.dart';
import '../../model/overview/overview_model.dart';
import '../../widgets/admin_sub_navbar.dart';
import '../../widgets/app_admin_navbar.dart';
import '../main_page/home_main_page.dart';

class _C {
  static const Color primary     = Color(0xFFD16F9A);
  static const Color back        = Color(0xFFF1F2ED);
  static const Color labelText   = Color(0xFF333333);
  static const Color hintText    = Color(0xFFAAAAAA);
  static const Color border      = Color(0xFFE0E0E0);
  static const Color commentCard = Color(0xFFF8F8F8);
}

class OverviewPreviewPage extends StatefulWidget {
  /// The draft model built from the edit-page form (unsaved data).
  /// When null the page falls back to cubit.current (saved data).
  final OverviewPageModel? previewModel;

  /// Called when the user confirms Publish from this preview page.
  /// Should be the edit-page's _save() so the full write-to-cubit
  /// + upload logic runs before persisting.
  final Future<void> Function()? onPublish;

  const OverviewPreviewPage({
    super.key,
    this.previewModel,
    this.onPublish,
  });

  @override
  State<OverviewPreviewPage> createState() => _OverviewPreviewPageState();
}

class _OverviewPreviewPageState extends State<OverviewPreviewPage> {
  int  _deviceTab          = 0;
  bool _isEnglish          = true;
  bool _homeViewOpen       = true;
  int  _galleryActiveIndex = 0;
  bool _isPublishing       = false;

  // ✅ KEY FIX: Store the effective model once in initState.
  // This means BlocBuilder rebuilds triggered by cubit state changes
  // (e.g. OverviewCmsLoaded firing again) can NEVER replace the draft
  // model that was passed from the edit page.
  late OverviewPageModel _effectiveModel;

  final List<String> _deviceLabels = ['Desktop', 'Tablet', 'Mobile'];
  final List<String> _languageTabs = ['EN', 'AR'];

  @override
  void initState() {
    super.initState();
    // If a draft was passed, use it. Otherwise fall back to cubit's current.
    // We resolve cubit.current here via the context — safe in initState.
    _effectiveModel = widget.previewModel ??
        context.read<OverviewCmsCubit>().current;
  }

  // ── Helper: renders an image URL which may be a remote URL or a
  //    base64 data-URL produced by _bytesToDataUrl in the edit page.
  Widget _buildImage({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final ph = placeholder ??
        Container(
          width: width,
          height: height,
          color: _C.primary.withOpacity(0.12),
          child: Icon(Icons.image_outlined,
              color: _C.primary.withOpacity(0.4), size: 36.sp),
        );

    if (url.isEmpty) return ph;

    // data-URLs (base64 encoded locally-picked images)
    if (url.startsWith('data:')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => ph,
      );
    }

    // Remote SVG URLs
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => ph,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ BlocBuilder is kept only to react to publish/loading state changes
    //    (e.g. show spinner while publishing). The MODEL itself is never
    //    re-read from the bloc — _effectiveModel is always used instead.
    return BlocBuilder<OverviewCmsCubit, OverviewCmsState>(
      builder: (context, state) {
        final cubit = context.read<OverviewCmsCubit>();

        if (state is OverviewCmsInitial || state is OverviewCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final double previewWidth = switch (_deviceTab) {
          1 => 700.w,
          2 => 380.w,
          _ => 1000.w,
        };

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppAdminNavbar(
                    activeLabel: 'Web Pages',
                    homePage: HomeMainPage(),
                    webPage: HomeMainPage(),
                    jobListingPage: HomeMainPage(),
                  ),
                  SizedBox(width: 20.w),
                  AdminSubNavBar(activeIndex: 2),

                  SizedBox(
                    width: 1000.w,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preview Overview Details',
                              style: StyleText.fontSize45Weight600.copyWith(
                                  color: _C.primary,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 12.h),

                          // ── Device tabs + lang toggle ──────────────────────
                          Row(children: [
                            ...List.generate(3, (i) {
                              final isActive = _deviceTab == i;
                              return GestureDetector(
                                onTap: () => setState(() => _deviceTab = i),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16.w),
                                  child: Text(_deviceLabels[i],
                                      style: StyleText.fontSize14Weight600
                                          .copyWith(
                                        color: isActive
                                            ? _C.primary
                                            : _C.hintText,
                                        decoration: isActive
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        decorationColor: _C.primary,
                                      )),
                                ),
                              );
                            }),
                            const Spacer(),
                            SizedBox(
                              width: 85.w,
                              height: 36.h,
                              child: CustomSegmentedTabs(
                                tabs: _languageTabs,
                                selectedIndex: _isEnglish ? 0 : 1,
                                onTabSelected: (index) =>
                                    setState(() => _isEnglish = index == 0),
                                selectedColor: _C.primary,
                                unselectedColor: Colors.white,
                                selectedTextColor: Colors.white,
                                unselectedTextColor: _C.labelText,
                                equalWidth: false,
                                containerPadding: EdgeInsets.symmetric(
                                    horizontal: 8.sp, vertical: 4.sp),
                              ),
                            ),
                          ]),
                          SizedBox(height: 16.h),

                          // ── Preview content ────────────────────────────────
                          // ✅ Always passes _effectiveModel (never re-reads bloc)
                          _previewAccordion(_effectiveModel, previewWidth),
                          SizedBox(height: 24.h),

                          // ── Bottom buttons ─────────────────────────────────
                          Row(children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                      color: _C.primary.withOpacity(0.5),
                                      borderRadius:
                                      BorderRadius.circular(6.r)),
                                  child: Center(
                                      child: Text('Back',
                                          style: StyleText.fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white))),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: _isPublishing
                                    ? null
                                    : () {
                                  showPublishConfirmDialog(
                                    title: 'PUBLISHING OVERVIEW',
                                    subtitle:
                                    'Do you want to publish this OVERVIEW?',
                                    context: context,
                                    onConfirm: () async {
                                      setState(
                                              () => _isPublishing = true);
                                      try {
                                        if (widget.onPublish != null) {
                                          await widget.onPublish!();
                                        } else {
                                          await cubit.save(
                                              publishStatus:
                                              'published');
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() =>
                                          _isPublishing = false);
                                        }
                                      }
                                    },
                                  );
                                },
                                child: Opacity(
                                  opacity: _isPublishing ? 0.6 : 1.0,
                                  child: Container(
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                        color: _C.primary,
                                        borderRadius:
                                        BorderRadius.circular(6.r)),
                                    child: Center(
                                      child: _isPublishing
                                          ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child:
                                        const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                          : Text('Publish',
                                          style: StyleText
                                              .fontSize14Weight600
                                              .copyWith(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
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

  Widget _previewAccordion(OverviewPageModel model, double width) {
    return Center(
      child: SizedBox(
        width: width,
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => _homeViewOpen = !_homeViewOpen),
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: _homeViewOpen
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text('Home View',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: Colors.white))),
                Icon(
                    _homeViewOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp),
              ]),
            ),
          ),
          if (_homeViewOpen)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(6.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _previewOverview(model),
                    SizedBox(height: 50.h),
                    _previewServices(model),
                    SizedBox(height: 50.h),
                    _previewGallery(model),
                    SizedBox(height: 50.h),
                    _previewComments(model),
                    SizedBox(height: 50.h),
                    _previewDownload(model),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _previewOverview(OverviewPageModel m) {
    final title =
    _isEnglish ? m.headings.title.en : m.headings.title.ar;
    final desc = _isEnglish
        ? m.headings.description.en
        : m.headings.description.ar;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isNotEmpty ? title : 'Overview',
            style: StyleText.fontSize22Weight700
                .copyWith(color: _C.primary, fontSize: 22.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            desc.isNotEmpty
                ? desc
                : 'Welcome to Beauty App, where beauty meets tranquility.',
            textDirection:
            _isEnglish ? TextDirection.ltr : TextDirection.rtl,
            style: StyleText.fontSize14Weight400.copyWith(
                height: 1.7, color: _C.labelText, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                child:
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                      _isEnglish ? 'Read More' : 'اقرأ المزيد',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: _C.primary)),
                  SizedBox(width: 6.w),
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.primary.withOpacity(0.15)),
                    child: Icon(
                        _isEnglish
                            ? Icons.arrow_forward
                            : Icons.arrow_back,
                        size: 14.sp,
                        color: _C.primary),
                  ),
                ]),
              ),
            ),
          ),
        ]);
  }

  Widget _previewServices(OverviewPageModel m) {
    if (m.services.items.isEmpty) return const SizedBox.shrink();
    final svcTitle =
    _isEnglish ? m.services.title.en : m.services.title.ar;

    return Column(
      crossAxisAlignment: _isEnglish
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          svcTitle.isNotEmpty ? svcTitle : 'Top Services',
          textDirection:
          _isEnglish ? TextDirection.ltr : TextDirection.rtl,
          style: StyleText.fontSize22Weight700
              .copyWith(color: _C.primary, fontSize: 22.sp),
        ),
        SizedBox(height: 24.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: m.services.items.map((item) {
              final name =
              _isEnglish ? item.name.en : item.name.ar;
              return Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _C.primary.withOpacity(0.2),
                          width: 2.w),
                    ),
                    child: ClipOval(
                      child: Center(
                        child: item.imageUrl.isNotEmpty
                            ? _buildImage(
                          url: item.imageUrl,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.scaleDown,
                          placeholder: const CircleProgressMaster(),
                        )
                            : Icon(Icons.spa_outlined,
                            color: _C.primary.withOpacity(0.4),
                            size: 28.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                      name.isNotEmpty ? name : 'Service',
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: _C.labelText)),
                ]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _previewGallery(OverviewPageModel m) {
    if (m.gallery.images.isEmpty) return const SizedBox.shrink();
    final visibleImages = m.gallery.images
        .where((img) => img.imageUrl.isNotEmpty)
        .toList();
    if (visibleImages.isEmpty) return const SizedBox.shrink();

    if (_galleryActiveIndex >= visibleImages.length) {
      _galleryActiveIndex = visibleImages.length - 1;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double inactiveSize = isMobile ? 110.w : 200.w;
    final double activeSize   = isMobile ? 160.w : 284.w;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEnglish ? 'Gallery' : 'المعرض',
              style: StyleText.fontSize22Weight700
                  .copyWith(color: _C.primary, fontSize: 22.sp)),
          SizedBox(height: 24.h),
          SizedBox(
            height: activeSize + 16.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                List.generate(visibleImages.length, (i) {
                  final bool isActive = _galleryActiveIndex == i;
                  final double size =
                  isActive ? activeSize : inactiveSize;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w),
                    child: GestureDetector(
                      onTap: () => setState(
                              () => _galleryActiveIndex = i),
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(24.r)),
                        duration:
                        const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        width: size,
                        height: size,
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(24.r),
                          child: _buildImage(
                            url: visibleImages[i].imageUrl,
                            width: size,
                            height: size,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            List.generate(visibleImages.length, (i) {
              final bool active = _galleryActiveIndex == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _galleryActiveIndex = i),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 250),
                  width: active ? 24.w : 8.w,
                  height: 8.w,
                  margin:
                  EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(4.r),
                    color: active
                        ? _C.primary
                        : _C.primary.withOpacity(0.3),
                  ),
                ),
              );
            }),
          ),
        ]);
  }

  Widget _previewComments(OverviewPageModel m) {
    if (m.clientComments.comments.isEmpty)
      return const SizedBox.shrink();
    final cmtTitle = _isEnglish
        ? m.clientComments.title.en
        : m.clientComments.title.ar;
    final highlightWord =
    _isEnglish ? 'Clients' : 'عملائنا';
    final titleText = cmtTitle.isNotEmpty
        ? cmtTitle
        : (_isEnglish
        ? 'What Our Clients Say About Us'
        : 'ماذا يقول عملاؤنا عنّا');

    return Column(
      crossAxisAlignment: _isEnglish
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        _buildHighlightedTitle(titleText, highlightWord),
        SizedBox(height: 24.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: m.clientComments.comments.map((cmt) {
              final firstName = _isEnglish
                  ? cmt.firstName.en
                  : cmt.firstName.ar;
              final lastName = _isEnglish
                  ? cmt.lastName.en
                  : cmt.lastName.ar;
              final feedback = _isEnglish
                  ? cmt.feedback.en
                  : cmt.feedback.ar;
              final fullName =
              '$firstName $lastName'.trim();

              return Container(
                width: 280.w,
                margin: EdgeInsets.only(right: 16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: _C.commentCard,
                  borderRadius:
                  BorderRadius.circular(12.r),
                  border:
                  Border.all(color: _C.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black
                            .withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      ClipOval(
                        child: cmt.imageUrl.isNotEmpty
                            ? _buildImage(
                          url: cmt.imageUrl,
                          width: 48.r,
                          height: 48.r,
                          fit: BoxFit.cover,
                          placeholder: CircleAvatar(
                            radius: 24.r,
                            backgroundColor: _C
                                .primary
                                .withOpacity(0.15),
                            child: Icon(
                                Icons.person_outline,
                                color: _C.primary,
                                size: 22.sp),
                          ),
                        )
                            : CircleAvatar(
                          radius: 24.r,
                          backgroundColor: _C
                              .primary
                              .withOpacity(0.15),
                          child: Icon(
                              Icons.person_outline,
                              color: _C.primary,
                              size: 22.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          fullName.isNotEmpty
                              ? fullName
                              : 'Client Name',
                          style: StyleText
                              .fontSize14Weight600
                              .copyWith(
                              color: _C.labelText,
                              fontWeight:
                              FontWeight.w600),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    SizedBox(height: 14.h),
                    Text(
                      feedback.isNotEmpty
                          ? feedback
                          : 'Great service! Highly recommended.',
                      textDirection: _isEnglish
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: StyleText.fontSize12Weight400
                          .copyWith(
                          height: 1.6,
                          color: _C.labelText
                              .withOpacity(0.75)),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedTitle(
      String title, String highlightWord) {
    final idx = title
        .toLowerCase()
        .indexOf(highlightWord.toLowerCase());
    if (idx == -1) {
      return Text(title,
          style: StyleText.fontSize22Weight700.copyWith(
              color: _C.labelText,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              height: 1.4));
    }
    final before =
    title.substring(0, idx);
    final keyword =
    title.substring(idx, idx + highlightWord.length);
    final after =
    title.substring(idx + highlightWord.length);

    return Text.rich(TextSpan(
      style: StyleText.fontSize22Weight700.copyWith(
          color: _C.labelText,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 1.4),
      children: [
        if (before.isNotEmpty) TextSpan(text: before),
        TextSpan(
            text: keyword,
            style: TextStyle(color: _C.primary)),
        if (after.isNotEmpty) TextSpan(text: after),
      ],
    ));
  }

  Widget _previewDownload(OverviewPageModel m) {
    final title =
    _isEnglish ? m.download.title.en : m.download.title.ar;
    final titleText = title.isNotEmpty
        ? title
        : (_isEnglish
        ? 'Download our app for the best experience'
        : 'قم بتنزيل تطبيقنا للحصول على أفضل تجربة');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: 40.w, vertical: 30.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r)),
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        if (isWide) {
          return Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(titleText,
                    style: StyleText.fontSize20Weight600
                        .copyWith(
                        color: _C.primary,
                        fontSize: 22.sp)),
              ),
              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _storeBadge(
                        label: _isEnglish
                            ? 'Google Play'
                            : 'جوجل بلاي',
                        icon: Icons.play_arrow_rounded),
                    SizedBox(width: 12.w),
                    _storeBadge(
                        label: _isEnglish
                            ? 'App Store'
                            : 'آب ستور',
                        icon: Icons.apple),
                  ]),
            ],
          );
        }
        return Column(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              Text(titleText,
                  style: StyleText.fontSize20Weight600
                      .copyWith(
                      color: _C.primary,
                      fontSize: 22.sp),
                  textAlign: TextAlign.center),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: [
                  _storeBadge(
                      label: _isEnglish
                          ? 'Google Play'
                          : 'جوجل بلاي',
                      icon: Icons.play_arrow_rounded),
                  _storeBadge(
                      label: _isEnglish
                          ? 'App Store'
                          : 'آب ستور',
                      icon: Icons.apple),
                ],
              ),
            ]);
      }),
    );
  }

  Widget _storeBadge(
      {required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 18.sp),
        SizedBox(width: 6.w),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  _isEnglish ? 'GET IT ON' : 'تحميل من',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w400)),
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600)),
            ]),
      ]),
    );
  }
}