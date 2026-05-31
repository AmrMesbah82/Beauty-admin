// ******************* FILE INFO *******************
// File Name: helpers.dart
// Description: Helper widgets for Inquiry details
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › widget › inquiry_details

part of '../../pages/inquiry_details.dart';

extension _InquiryDetailHelpers on _InquiryDetailPageState {
  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  void _showSimpleDialog({
    required Color cmsPrimary,
    required String title,
    required String body,
    required VoidCallback onBack,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          width: 344.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Text(
                FormatHelper.capitalize(title),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              SizedBox(height: 8.h),
              Text(
                FormatHelper.capitalize(body),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText, height: 1.5),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onBack,
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: ColorPick.white,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(FormatHelper.capitalize('Back'),
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.text)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: cmsPrimary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(FormatHelper.capitalize('Confirm'),
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readField(String label, String value, {bool multiLine = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(FormatHelper.capitalize(label),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.text)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: multiLine ? 80.h : 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: multiLine ? 8.h : 0),
          decoration: BoxDecoration(color: ColorPick.white, borderRadius: BorderRadius.circular(4.r)),
          alignment: multiLine ? Alignment.topLeft : Alignment.centerLeft,
          child: Text(
            FormatHelper.capitalize(value.isEmpty ? 'Text Here' : value),
            style: StyleText.fontSize12Weight400.copyWith(
                color: value.isEmpty ? AppColors.secondaryText : AppColors.text),
            maxLines: multiLine ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Color cmsPrimary,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(FormatHelper.capitalize(label),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.text)),
        SizedBox(height: 4.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items.map((s) => {'key': s, 'value': s}).toList(),
          widthIcon: 14, heightIcon: 14, height: 36,
          borderRadius: 4,
          dropdownColor: const Color(0xFFF1F1F1),
          primaryColor: cmsPrimary,
          hint: Text(FormatHelper.capitalize(hint),
              style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _priorityLegend(Color cmsPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: InquiryPriority.critical.color,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(FormatHelper.capitalize('Critical'),
                style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(height: 6.h),
        ...['High', 'Medium', 'Low', 'Informational Only'].map((label) => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text(FormatHelper.capitalize(label),
              style: TextStyle(fontSize: 10.sp, color: AppColors.text)),
        )),
      ],
    );
  }

  Widget _listLegend({
    required String title,
    required List<String> items,
    required Color baseColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6.r)),
          child: Center(
            child: Text(FormatHelper.capitalize(title),
                style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
        ),
        SizedBox(height: 6.h),
        ...items.skip(1).map((item) => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text(FormatHelper.capitalize(item),
              style: TextStyle(fontSize: 10.sp, color: AppColors.text)),
        )),
      ],
    );
  }
}
