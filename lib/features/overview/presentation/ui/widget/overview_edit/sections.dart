part of '../../pages/overview_edit.dart';

extension _OverviewEditSections on _OverviewEditPageState {
  Widget _headingsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _headTitleEn, _headTitleAr, useRow: true),
      SizedBox(height: 10.h),
      CustomValidatedTextFieldMaster(
        label: 'Description', hint: 'Text Here', controller: _headDescEn,
        maxLines: 4, height: 100, maxLength: 10000, submitted: _submitted,
        fillColor: Colors.white, primaryColor: _resolvedPrimary,
      ),
      SizedBox(height: 10.h),
      Directionality(
        textDirection: ui.TextDirection.rtl,
        child: CustomValidatedTextFieldMaster(
          label: 'الوصف *', hint: 'أدخل النص هنا', controller: _headDescAr,
          maxLines: 4, height: 100, maxLength: 10000, submitted: _submitted,
          fillColor: Colors.white, textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.right, primaryColor: _resolvedPrimary,
        ),
      ),
    ]),
  );

  Widget _servicesBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _svcTitleEn, _svcTitleAr, useRow: true),
      SizedBox(height: 10.h),
      ...List.generate(_services.length, (i) => _serviceItemRow(i)),
      if (_submitted && _services.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text('At least one service item is required',
              style: StyleText.fontSize12Weight400.copyWith(color: ColorPick.red)),
        ),
      SizedBox(height: 8.h),
      _addButton('Service', () {
        setState(() => _services.add(_ServiceLocal(id: 'svc_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _serviceItemRow(int i) {
    final svc = _services[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Service ${i + 1}'),
            GestureDetector(
              onTap: () => setState(() { final r = _services.removeAt(i); r.dispose(); }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: ColorPick.red, borderRadius: BorderRadius.circular(4.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Remove', style: StyleText.fontSize10Weight400.copyWith(color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _sectionLabel('Image'),
        SizedBox(height: 6.h),
        _imgBox(
          picked: svc.image,
          onPick: () async { final p = await _pickImage(); if (p != null) setState(() => svc.image = p); },
        ),
        SizedBox(height: 10.h),
        _biRow('Service Name *', 'اسم الخدمة *', svc.nameEn, svc.nameAr, useRow: true),
      ]),
    );
  }

  Widget _galleryBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
        spacing: 10.w, runSpacing: 10.h,
        children: List.generate(_galleryItems.length, (i) => _gallerySlot(i)),
      ),
      SizedBox(height: 8.h),
      _addButton('Image', () {
        setState(() => _galleryItems.add(_GalleryLocal(id: 'gal_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _gallerySlot(int i) {
    final gal = _galleryItems[i];
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        _sectionLabel('Image ${i + 1}'),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => setState(() => _galleryItems.removeAt(i)),
          child: Container(
            width: 14.w, height: 14.h,
            decoration: const BoxDecoration(color: ColorPick.red, shape: BoxShape.circle),
            child: Icon(Icons.close, color: Colors.white, size: 10.sp),
          ),
        ),
      ]),
      SizedBox(height: 4.h),
      _imgBox(
        picked: gal.image,
        onPick: () async { final p = await _pickImage(); if (p != null) setState(() => gal.image = p); },
      ),
    ]);
  }

  Widget _commentsBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _cmtTitleEn, _cmtTitleAr, useRow: true),
      SizedBox(height: 10.h),
      ...List.generate(_comments.length, (i) => _commentItemRow(i)),
      if (_submitted && _comments.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text('At least one client feedback is required',
              style: StyleText.fontSize12Weight400.copyWith(color: ColorPick.red)),
        ),
      SizedBox(height: 8.h),
      _addButton('Feedback', () {
        setState(() => _comments.add(_CommentLocal(id: 'cmt_${DateTime.now().millisecondsSinceEpoch}')));
      }),
    ]),
  );

  Widget _commentItemRow(int i) {
    final cmt = _comments[i];
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Feedback ${i + 1}'),
            GestureDetector(
              onTap: () => setState(() { final r = _comments.removeAt(i); r.dispose(); }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: ColorPick.red, borderRadius: BorderRadius.circular(4.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text('Remove', style: StyleText.fontSize10Weight400.copyWith(color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _imgBox(
          picked: cmt.image,
          onPick: () async { final p = await _pickImage(); if (p != null) setState(() => cmt.image = p); },
        ),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(child: CustomValidatedTextFieldMaster(
            label: 'First Name *', hint: 'Text Here', controller: cmt.firstNameEn,
            height: 36, submitted: _submitted, fillColor: Colors.white, primaryColor: _resolvedPrimary,
          )),
          SizedBox(width: 16.w),
          Expanded(child: CustomValidatedTextFieldMaster(
            label: 'Last Name *', hint: 'Text Here', controller: cmt.lastNameEn,
            height: 36, submitted: _submitted, fillColor: Colors.white, primaryColor: _resolvedPrimary,
          )),
        ]),
        SizedBox(height: 8.h),
        Row(children: [
          Expanded(child: Directionality(textDirection: ui.TextDirection.rtl, child: CustomValidatedTextFieldMaster(
            label: 'اسم العائلة *', hint: 'أدخل النص هنا', controller: cmt.lastNameAr,
            height: 36, submitted: _submitted, fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right, primaryColor: _resolvedPrimary,
          ))),
          SizedBox(width: 16.w),
          Expanded(child: Directionality(textDirection: ui.TextDirection.rtl, child: CustomValidatedTextFieldMaster(
            label: 'الاسم الأول *', hint: 'أدخل النص هنا', controller: cmt.firstNameAr,
            height: 36, submitted: _submitted, fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right, primaryColor: _resolvedPrimary,
          ))),
        ]),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          label: 'Feedback *', hint: 'Text Here', controller: cmt.feedbackEn,
          maxLines: 3, height: 80, submitted: _submitted, fillColor: Colors.white, primaryColor: _resolvedPrimary,
        ),
        SizedBox(height: 8.h),
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'ملاحظات *', hint: 'أدخل النص هنا', controller: cmt.feedbackAr,
            maxLines: 3, height: 80, submitted: _submitted, fillColor: Colors.white,
            textDirection: ui.TextDirection.rtl, textAlign: TextAlign.right, primaryColor: _resolvedPrimary,
          ),
        ),
      ]),
    );
  }

  Widget _downloadBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _biRow('Title *', 'العنوان *', _dlTitleEn, _dlTitleAr, useRow: true),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: CustomValidatedTextFieldMaster(
          label: 'Apple Store Link', hint: 'Insert Links', controller: _appStoreLink,
          height: 36, submitted: _submitted, fillColor: Colors.white, primaryColor: _resolvedPrimary,
        )),
        SizedBox(width: 16.w),
        Expanded(child: CustomValidatedTextFieldMaster(
          label: 'Android Link', hint: 'Insert Links', controller: _googlePlay,
          height: 36, submitted: _submitted, fillColor: Colors.white, primaryColor: _resolvedPrimary,
        )),
      ]),
    ]),
  );

  Widget _scheduleBody() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(height: 15.h),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Publish Date *'),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4.r),
              border: _publishDate == null && _submitted ? Border.all(color: ColorPick.red, width: 1) : null,
            ),
            child: Row(children: [
              Expanded(child: Text(
                _publishDate != null ? DateFormat('dd MMM yyyy').format(_publishDate!) : 'Select Date',
                style: StyleText.fontSize12Weight400.copyWith(
                    color: _publishDate != null ? AppColors.text : AppColors.secondaryText),
              )),
              CustomSvg(assetPath: "assets/calendar.svg", width: 20.w, height: 20.h),
            ]),
          ),
        ),
        if (_publishDate == null && _submitted)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text('Publish date is required',
                style: TextStyle(color: ColorPick.red, fontSize: 10.sp)),
          ),
      ])),
      SizedBox(width: 16.w),
      Expanded(child: Column()),
    ]),
  ]);

  Widget _actionRow(OverviewCmsCubit cubit, bool canPublish) => Row(children: [
    Expanded(
      child: GestureDetector(
        onTap: () {
          final draft = _buildDraftModel(cubit);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: OverviewPreviewPage(
                previewModel: draft,
                onPublish: () => _save(cubit, publishStatus: 'published'),
              ),
            ),
          ));
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(color: Color(0xFF8A5C70), borderRadius: BorderRadius.circular(6.r)),
          child: Center(child: Text('Preview', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
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
              if (!canPublish) { setState(() => _submitted = true); _showValidationError(); return; }
              final bool isScheduled = _publishDate != null && _publishDate!.isAfter(DateTime.now());
              showPublishConfirmDialog(
                title: isScheduled ? 'SCHEDULE OVERVIEW' : 'PUBLISHING OVERVIEW',
                subtitle: isScheduled
                    ? 'Your changes will be scheduled for ${DateFormat('dd/MM/yyyy').format(_publishDate!)}. The published version will remain live until then.'
                    : 'Do you want to publish this OVERVIEW?',
                context: context,
                onConfirm: () async => _save(cubit, publishStatus: 'published'),
              );
            },
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                  color: canPublish ? ColorPick.primary : ColorPick.primary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(6.r)),
              child: Center(child: Text('Publish', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
            ),
          ),
        ),
      ),
    ),
  ]);

  Widget _secondaryRow(OverviewCmsCubit cubit) => Row(children: [
    Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isEditingDraft) {
            showPublishConfirmDialog(
              title: 'DISCARD DRAFT',
              subtitle: 'Are you sure you want to discard this draft? The published version will remain unchanged.',
              context: context,
              onConfirm: () => cubit.discardDraft(),
            );
          } else {
            if (Navigator.canPop(context)) { Navigator.pop(context); }
            else { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OverviewMainPage())); }
          }
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(color: ColorPick.discard, borderRadius: BorderRadius.circular(6.r)),
          child: Center(child: Text('Discard', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
        ),
      ),
    ),
    SizedBox(width: 300.w),
    Expanded(
      child: GestureDetector(
        onTap: () {
          showPublishConfirmDialog(
            title: 'SAVE AS DRAFT',
            subtitle: 'Your changes will be saved as a draft. The published version will remain live and unchanged.',
            context: context,
            onConfirm: () => _save(cubit, publishStatus: 'draft'),
          );
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(color: Color(0xFF525252), borderRadius: BorderRadius.circular(6.r)),
          child: Center(child: Text('Save For Later', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
        ),
      ),
    ),
  ]);
}
