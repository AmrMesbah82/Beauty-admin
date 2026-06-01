// ******************* FILE INFO *******************
// File Name: logic_helpers.dart
// Description: Business-logic helpers for Inquiry main
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › widget › inquiry_main

part of '../../pages/inquiry_main.dart';

extension _InquiryMainLogic on _InquiryMainPageState {
  String _esc(String v) {
    if (v.isEmpty) return '';
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${_kMonthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  int _userTypeToIndex(String? activeUserType) {
    if (activeUserType == 'Client') return 0;
    if (activeUserType == 'Owner')  return 1;
    return -1;
  }

  void _showExportDialog(List<InquiryModel> inquiries) {
    final fileNameCtrl = TextEditingController();
    bool isExporting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Container(
            width: 400.w,
            padding: EdgeInsets.all(20.sp),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 30.sp, height: 30.sp,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: ColorPick.primary),
                  child: Icon(Icons.file_download_outlined, size: 16.sp, color: Colors.white),
                ),
                SizedBox(width: 8.sp),
                Text('Export', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.text)),
              ]),
              SizedBox(height: 20.sp),
              CustomValidatedTextFieldMaster(
                label: 'File Name', hint: 'Enter file name',
                controller: fileNameCtrl, height: 36, submitted: false,
                primaryColor: ColorPick.primary, fillColor: ColorPick.background,
              ),
              SizedBox(height: 20.sp),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: isExporting ? null : () => Navigator.of(ctx).pop(),
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8.r)),
                    child: Center(child: Text('Discard', style: TextStyle(fontSize: 14.sp, color: AppColors.text))),
                  ),
                )),
                SizedBox(width: 15.sp),
                Expanded(child: GestureDetector(
                  onTap: isExporting ? null : () {
                    final fn = fileNameCtrl.text.trim();
                    if (fn.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a file name')));
                      return;
                    }
                    setDlg(() => isExporting = true);
                    _performExport(inquiries, fn);
                    Navigator.of(ctx).pop();
                    _showExportSuccessDialog(fn);
                  },
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: isExporting ? Colors.grey : ColorPick.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(child: isExporting
                        ? SizedBox(width: 16.sp, height: 16.sp,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Download', style: TextStyle(fontSize: 14.sp, color: Colors.white))),
                  ),
                )),
              ]),
            ]),
          ),
        );
      }),
    );
  }

  void _performExport(List<InquiryModel> inquiries, String fileName) {
    try {
      final buf = StringBuffer();
      final headers = [
        'No','Submission Date','Preferred Language','First Name','Last Name',
        'Email','Country Code','Phone Number','Gender','Country','Subject',
        'Reason','Message','Inquiry Priority','Inquiry Relevance',
        'Required Action','Notes','Status',
      ];
      buf.writeln(headers.map(_esc).join(','));
      for (int i = 0; i < inquiries.length; i++) {
        final inq = inquiries[i];
        buf.writeln([
          '${i + 1}', _fmtDate(inq.submissionDate), inq.preferredLanguage,
          inq.firstName, inq.lastName, inq.email, inq.countryCode, inq.phone,
          inq.gender, inq.country, inq.subject, inq.reason, inq.message,
          inq.inquiryPriority?.label ?? '', inq.inquiryRelevance?.label ?? '',
          inq.requiredAction?.label ?? '', inq.note, inq.status.label,
        ].map(_esc).join(','));
      }
      final blob = html.Blob([utf8.encode(buf.toString())], 'text/csv;charset=utf-8');
      final url  = html.Url.createObjectUrlFromBlob(blob);
      final fn   = fileName.toLowerCase().endsWith('.csv') ? fileName : '$fileName.csv';
      html.AnchorElement(href: url)..setAttribute('download', fn)..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showExportSuccessDialog(String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64.sp, height: 64.sp,
              decoration: BoxDecoration(color: ColorPick.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: ColorPick.primary, size: 40.sp),
            ),
            SizedBox(height: 16.h),
            Text('Export Successful', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
            SizedBox(height: 8.h),
            Text('$fileName\ndownloaded successfully', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText, height: 1.4)),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('OK', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
