part of '../../pages/about_us_edit.dart';

extension _AboutEditValidation on _AboutEditPageMasterState {
  List<String> _getMissingFields() {
    final missing = <String>[];

    void checkEn(String text, String label) {
      if (text.trim().isEmpty) {
        missing.add('$label — required');
      } else if (RegExp(r'[؀-ۿ]').hasMatch(text)) {
        missing.add('$label — English characters only');
      }
    }

    void checkAr(String text, String label) {
      if (text.trim().isEmpty) {
        missing.add('$label — required');
      } else if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
        missing.add('$label — Arabic characters only');
      }
    }

    checkEn(_titleEnCtrl.text, 'Heading Title (EN)');
    checkAr(_titleArCtrl.text, 'Heading Title (AR)');
    checkEn(_navLabelTitleEnCtrl.text, 'Navigation Label Title (EN)');
    checkAr(_navLabelTitleArCtrl.text, 'Navigation Label Title (AR)');
    checkEn(_visionSubEnCtrl.text, 'Vision Sub Description (EN)');
    checkAr(_visionSubArCtrl.text, 'Vision Sub Description (AR)');
    checkEn(_visionDescEnCtrl.text, 'Vision Description (EN)');
    checkAr(_visionDescArCtrl.text, 'Vision Description (AR)');
    checkEn(_missionSubEnCtrl.text, 'Mission Sub Description (EN)');
    checkAr(_missionSubArCtrl.text, 'Mission Sub Description (AR)');
    checkEn(_missionDescEnCtrl.text, 'Mission Description (EN)');
    checkAr(_missionDescArCtrl.text, 'Mission Description (AR)');

    for (var i = 0; i < _valueItems.length; i++) {
      final v = _valueItems[i];
      checkEn(v.titleEnCtrl.text, 'Value ${i + 1} Title (EN)');
      checkAr(v.titleArCtrl.text, 'Value ${i + 1} Title (AR)');
      checkEn(v.shortDescEnCtrl.text, 'Value ${i + 1} Short Description (EN)');
      checkAr(v.shortDescArCtrl.text, 'Value ${i + 1} Short Description (AR)');
    }

    return missing;
  }

  void _showValidationError() {
    final missing = _getMissingFields();
    if (missing.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: _kRed, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Validation Error',
              style: StyleText.fontSize14Weight600.copyWith(color: Colors.black87),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please fill all required fields:',
              style: StyleText.fontSize12Weight400.copyWith(color: Colors.black54),
            ),
            SizedBox(height: 12.h),
            ...missing.map(
              (field) => Padding(
                padding: EdgeInsets.only(left: 8.w, top: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: _kRed)),
                    Expanded(
                      child: Text(
                        field,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: StyleText.fontSize13Weight500.copyWith(color: _kGreenSolid),
            ),
          ),
        ],
      ),
    );
  }
}
