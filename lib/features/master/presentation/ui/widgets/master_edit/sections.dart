// ******************* FILE INFO *******************
// File Name: sections.dart
// Description: Form section widgets for Master edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_edit

part of '../../pages/master_edit.dart';

extension _MasterEditSections on _MasterEditPageState {
  Widget _headerSectionBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Image'),
              Row(children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: ColorPick.primary,
                  inactiveColor: Colors.grey.withValues(alpha: .16),
                  value: _headerVisibility,
                  onToggle: (val) => setState(() => _headerVisibility = val),
                ),
              ]),
            ],
          ),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _headerImage,
            onPick: () async {
              final p = await _pickImage();
              if (p != null && mounted) setState(() => _headerImage = p);
            },
          ),
          if (_submitted && _headerImage.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Header SVG image is required',
                style: StyleText.fontSize12Weight400.copyWith(color: ColorPick.red),
              ),
            ),
          SizedBox(height: 14.h),
          _biRow('Title *', 'العنوان *', _headerTitleEn, _headerTitleAr,
              useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Short Description *',
            hint: 'Text Here',
            controller: _headerShortEn,
            height: 36,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            primaryColor: _resolvedPrimaryColor,
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'وصف مختصر *',
              hint: 'أدخل النص هنا',
              controller: _headerShortAr,
              height: 36,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutUsSectionBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _biRow('Title *', 'العنوان *', _aboutTitleEn, _aboutTitleAr,
              useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Description *',
            hint: 'Text Here',
            controller: _aboutDescEn,
            maxLines: 5,
            maxLength: 10000,
            height: 120,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            primaryColor: _resolvedPrimaryColor,
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف *',
              hint: 'أدخل النص هنا',
              controller: _aboutDescAr,
              maxLines: 5,
              height: 120,
              maxLength: 10000,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerSectionBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Image *'),
              Row(children: [
                Text('Visibility',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                SizedBox(width: 6.w),
                FlutterSwitch(
                  width: 38.sp,
                  height: 22.sp,
                  padding: 3.sp,
                  borderRadius: 20.sp,
                  toggleSize: 16.sp,
                  activeColor: ColorPick.primary,
                  inactiveColor: Colors.grey.withValues(alpha: .16),
                  value: _footerVisibility,
                  onToggle: (val) => setState(() => _footerVisibility = val),
                ),
              ]),
            ],
          ),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _footerImage,
            onPick: () async {
              final p = await _pickImage();
              if (p != null) setState(() => _footerImage = p);
            },
          ),
          if (_submitted && _footerImage.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Footer SVG image is required',
                style: StyleText.fontSize12Weight400.copyWith(color: ColorPick.red),
              ),
            ),
          SizedBox(height: 14.h),
          _biRow('Title *', 'العنوان *', _footerTitleEn, _footerTitleAr,
              useRow: true),
          SizedBox(height: 10.h),
          CustomValidatedTextFieldMaster(
            label: 'Description *',
            hint: 'Text Here',
            controller: _footerDescEn,
            maxLines: 5,
            height: 120,
            submitted: _submitted,
            fillColor: Colors.white,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            primaryColor: _resolvedPrimaryColor,
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomValidatedTextFieldMaster(
              label: 'الوصف *',
              hint: 'أدخل النص هنا',
              controller: _footerDescAr,
              maxLines: 5,
              height: 120,
              submitted: _submitted,
              fillColor: Colors.white,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              primaryColor: _resolvedPrimaryColor,
            ),
          ),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'App Store Link *',
                hint: 'Insert Apple Link',
                controller: _appStoreLink,
                height: 36,
                submitted: _submitted,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Google Play Link *',
                hint: 'Insert Android Link',
                controller: _googlePlayLink,
                height: 36,
                submitted: _submitted,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _publishScheduleBody() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Publish Date (Optional)'),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 36.h,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _publishDate != null
                                    ? DateFormat('dd MMM yyyy').format(_publishDate!)
                                    : 'Select date',
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: _publishDate != null ? AppColors.text : AppColors.secondaryText,
                                ),
                              ),
                            ),
                            CustomSvg(assetPath: "assets/calendar.svg", width: 20.w, height: 20.h, fit: BoxFit.scaleDown),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: Column()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(MasterCmsCubit cubit) {
    final bool canPublish = _isFormValid;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              final draft = _buildDraftModel(cubit);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: MasterPreviewPage(previewModel: draft),
                  ),
                ),
              );
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Color(0xFF8A5C70),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Preview',
                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: AbsorbPointer(
            absorbing: !canPublish,
            child: Opacity(
              opacity: canPublish ? 1.0 : 0.6,
              child: GestureDetector(
                onTap: () {
                  if (!canPublish) {
                    setState(() => _submitted = true);
                    _showValidationError();
                    return;
                  }
                  final bool isScheduled = _publishDate != null &&
                      _publishDate!.isAfter(DateTime.now());

                  showPublishConfirmDialog(
                    title: isScheduled
                        ? 'SCHEDULE HOMEPAGE'
                        : 'EDITING HOMEPAGE DETAILS',
                    subtitle: isScheduled
                        ? 'Your changes will be scheduled for '
                          '${DateFormat('dd/MM/yyyy').format(_publishDate!)}. '
                          'The published version will remain live until then.'
                        : 'Do you want to save the changes made to this HOMEPAGE?',
                    context: context,
                    onConfirm: () => _save(cubit, publishStatus: 'published'),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: canPublish ? ColorPick.primary : ColorPick.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text('Publish',
                        style: StyleText.fontSize14Weight600.copyWith(
                          color: Colors.white.withValues(alpha: canPublish ? 1.0 : 0.55),
                        )),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _secondaryButtons(MasterCmsCubit cubit) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isEditingDraft) {
                showPublishConfirmDialog(
                  title: 'DISCARD DRAFT',
                  subtitle:
                      'Are you sure you want to discard this draft? '
                      'The published version will remain unchanged.',
                  context: context,
                  onConfirm: () => cubit.discardDraft(),
                );
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MasterMainPage()),
                  );
                }
              }
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF797979),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Discard',
                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: Expanded(child: Container()),
        ),
      ],
    );
  }
}
