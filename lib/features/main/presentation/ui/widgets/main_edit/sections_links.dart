// ******************* FILE INFO *******************
// File Name: sections_links.dart
// Description: Link section widgets for Main edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › main › presentation › ui › widget › main_edit

part of '../../pages/main_edit.dart';

extension _HomeEditSectionsLinks on _HomeEditPageState {
  Widget _appLinkSection() => _accordion(
    key: 'downloadApp',
    title: 'App Link',
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: 'Navigation Label', fillColor: Colors.white,
                    hint: 'Text Here', controller: _appLabelEnCtrl,
                    height: 36, submitted: _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    primaryColor: _resolvedPrimaryColor,
                    onChanged: (value) => _hasChanges = true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomValidatedTextFieldMaster(
                      label: 'تسمية التنقل', fillColor: Colors.white,
                      hint: 'أدخل النص هنا', controller: _appLabelArCtrl,
                      height: 36, submitted: _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      primaryColor: _resolvedPrimaryColor,
                      onChanged: (value) => _hasChanges = true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Icon'),
                      SizedBox(height: 6.h),
                      _imgBox(
                        picked: _iosIconPicked,
                        placeholderAsset: 'assets/control/edit_icon_pick.svg',
                        pickIconAsset: 'assets/control/camera.svg',
                        onPick: () async {
                          final p = await _pickImage();
                          if (p != null) {
                            setState(() => _iosIconPicked = p);
                            _hasChanges = true;
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      CustomValidatedTextFieldMaster(
                        label: 'Insert Apple Link', fillColor: Colors.white,
                        hint: 'Insert Apple Link', controller: _iosUrlCtrl,
                        submitted: _submitted, height: 36,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        primaryColor: _resolvedPrimaryColor,
                        onChanged: (value) => _hasChanges = true,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Icon'),
                      SizedBox(height: 6.h),
                      _imgBox(
                        picked: _androidIconPicked,
                        placeholderAsset: 'assets/control/edit_icon_pick.svg',
                        pickIconAsset: 'assets/control/camera.svg',
                        onPick: () async {
                          final p = await _pickImage();
                          if (p != null) {
                            setState(() => _androidIconPicked = p);
                            _hasChanges = true;
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      CustomValidatedTextFieldMaster(
                        label: 'Insert Android Link', fillColor: Colors.white,
                        hint: 'Insert Android Link', controller: _androidUrlCtrl,
                        height: 36, submitted: _submitted,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        primaryColor: _resolvedPrimaryColor,
                        onChanged: (value) => _hasChanges = true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _linksSection() => _accordion(
    key: 'links',
    title: 'Links',
    children: [
      ...List.generate((_links.length / 2).ceil(), (rowIndex) {
        final left  = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _linkItem(left)),
              SizedBox(width: 16.w),
              right < _links.length
                  ? Expanded(child: _linkItem(right))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
      SizedBox(height: 4.h),
      GestureDetector(
        onTap: () => setState(() {
          _links.add(_LinkItem());
          _hasChanges = true;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text('Link',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: Colors.white)),
          ]),
        ),
      ),
    ],
  );

  Widget _linkItem(int i) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel('Icon'),
          GestureDetector(
            onTap: () => setState(() {
              final removed = _links.removeAt(i);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => removed.dispose());
              _hasChanges = true;
            }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: ColorPick.red,
                  borderRadius: BorderRadius.circular(4.r)),
              child: Text('Remove',
                  style: StyleText.fontSize11Weight400
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      SizedBox(height: 5.h),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _imgBox(
            picked: _links[i].icon,
            placeholderAsset: 'assets/control/edit_icon_pick.svg',
            pickIconAsset: 'assets/control/edit_icon_pick.svg',
            onPick: () async {
              final p = await _pickImage();
              if (p != null) {
                setState(() => _links[i].icon = p);
                _hasChanges = true;
              }
            },
          ),
        ],
      ),
      SizedBox(height: 8.h),
      CustomValidatedTextFieldMaster(
        label: 'Insert Link', fillColor: Colors.white,
        hint: 'Insert Links', controller: _links[i].text,
        height: 36, submitted: _submitted,
        primaryColor: _resolvedPrimaryColor,
        onChanged: (value) => _hasChanges = true,
        labelTrailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Visibility',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
            SizedBox(width: 6.w),
            FlutterSwitch(
              width: 38.sp, height: 22.sp,
              padding: 3.sp, borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: ColorPick.primary,
              inactiveColor: Colors.grey.withValues(alpha: .16),
              value: _links[i].visibility,
              onToggle: (val) {
                setState(() => _links[i].visibility = val);
                _hasChanges = true;
              },
            ),
          ],
        ),
      ),
    ],
  );

  Widget _bottomActions(HomeCmsCubit cubit, bool canPublish) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final cubit = context.read<HomeCmsCubit>();
            if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
            cubit.updatePrimaryColor(_primaryColor.text);
            cubit.updateMalePrimaryColor(_malePrimaryColor.text);
            cubit.updateSecondaryColor(_secondaryColor.text);
            cubit.updateBackgroundColor(_bgColor.text);
            cubit.updateHeaderFooterColor(_headerFooterColor.text);
            cubit.updateMainWidgetColor(_mainWidgetColor.text);
            cubit.updateEnglishFont(_engFont ?? 'Cairo');
            cubit.updateArabicFont(_arFont ?? 'Cairo');

            final snapshot  = List<NavButtonModel>.from(cubit.current.navButtons);
            final routeToId = {for (final b in snapshot) b.route: b.id};
            for (var i = 0; i < _navBtns.length; i++) {
              final localRoute = _navRoutes[i] ?? '';
              if (localRoute.isEmpty) continue;
              final id = routeToId[localRoute];
              if (id == null) continue;
              cubit.updateNavButtonName(id,
                  en: _navBtns[i]['nameEn']!.text,
                  ar: _navBtns[i]['nameAr']!.text);
              cubit.updateNavButtonRoute(id, localRoute);
              if (_navIcons[i].bytes != null) {
                await cubit.uploadNavButtonIcon(id, _navIcons[i].bytes!);
              }
              final modelStatus = cubit.current.navButtons
                  .firstWhere((b) => b.id == id,
                      orElse: () => NavButtonModel(id: id))
                  .status;
              if (modelStatus != _navStatus[i]) cubit.toggleNavButtonStatus(id);
            }

            while (cubit.current.footerColumns.length < _footerColumns.length) {
              cubit.addFooterColumn();
            }
            while (cubit.current.footerColumns.length > _footerColumns.length) {
              cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
            }
            for (var i = 0; i < _footerColumns.length; i++) {
              final colId = cubit.current.footerColumns[i].id;
              cubit.updateFooterColumnTitle(colId,
                  en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
                  ar: (_footerColumns[i]['titleAr'] as TextEditingController).text);
              cubit.updateFooterColumnRoute(
                  colId, _footerColumns[i]['route'] as String? ?? '');
              final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
              while (cubit.current.footerColumns[i].labels.length < labels.length) {
                cubit.addFooterLabel(colId);
              }
              while (cubit.current.footerColumns[i].labels.length > labels.length) {
                cubit.removeFooterLabel(
                    colId, cubit.current.footerColumns[i].labels.last.id);
              }
              for (var li = 0; li < labels.length; li++) {
                final lblId = cubit.current.footerColumns[i].labels[li].id;
                cubit.updateFooterLabel(colId, lblId,
                    en: (labels[li]['en'] as TextEditingController).text,
                    ar: (labels[li]['ar'] as TextEditingController).text);
                cubit.updateFooterLabelRoute(
                    colId, lblId, (labels[li]['route'] as String?) ?? '');
              }
            }

            while (cubit.current.socialLinks.length < _links.length) {
              cubit.addSocialLink();
            }
            while (cubit.current.socialLinks.length > _links.length) {
              cubit.removeSocialLink(cubit.current.socialLinks.last.id);
            }
            for (var i = 0; i < _links.length; i++) {
              final id = cubit.current.socialLinks[i].id;
              cubit.updateSocialLink(id,
                  url: _links[i].text.text, visibility: _links[i].visibility);
              if (_links[i].icon.bytes != null) {
                await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
              }
            }

            if (_iosIconPicked.bytes != null) {
              await cubit.uploadAppLinkIcon('ios', _iosIconPicked.bytes!);
            }
            if (_androidIconPicked.bytes != null) {
              await cubit.uploadAppLinkIcon('android', _androidIconPicked.bytes!);
            }
            cubit.updateAppDownloadLinks(
              iosUrl:     _iosUrlCtrl.text,
              androidUrl: _androidUrlCtrl.text,
              labelEn:    _appLabelEnCtrl.text,
              labelAr:    _appLabelArCtrl.text,
              visibility: _downloadAppVisibility,
            );

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePreviewPage()),
            );
          },
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: ColorPick.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text('Preview',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: GestureDetector(
          onTap: canPublish
              ? () {
                  if (!_validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Please fill in all required fields before publishing.',
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: Colors.white)),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ));
                    return;
                  }
                  showPublishConfirmDialog(
                    context: context,
                    onConfirm: () =>
                        _save(cubit, publishStatus: 'published'),
                  );
                }
              : null,
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: canPublish
                  ? ColorPick.primary
                  : ColorPick.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text('Publish',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
    ],
  );
}
