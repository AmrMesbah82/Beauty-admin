part of '../../custom_dialog.dart';

// ******************* FILE INFO *******************
// File Name: upload_dialog.dart
// Description: File upload dialog widget
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › main_widgets › dialogs

Future<void> showUploadDialog({
  required BuildContext context,
  String dialogTitle = 'Adding Attachment',
  String titleFieldLabel = 'Title Name',
  String titleFieldHint = 'Text here',
  String submitLabel = 'Submit',
  String discardLabel = 'Discard',
  TextDirection textDirection = TextDirection.ltr,
  /// SVG asset for the attachment icon in the header
  String? headerIconAsset,
  /// Allowed file extensions e.g. ['pdf','png','jpg']
  List<String>? allowedExtensions,
  void Function(PlatformFile file, String titleName)? onSubmit,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _UploadDialog(
      dialogTitle: dialogTitle,
      titleFieldLabel: titleFieldLabel,
      titleFieldHint: titleFieldHint,
      submitLabel: submitLabel,
      discardLabel: discardLabel,
      textDirection: textDirection,
      headerIconAsset: headerIconAsset,
      allowedExtensions: allowedExtensions,
      onSubmit: onSubmit,
    ),
  );
}

class _UploadDialog extends StatefulWidget {
  final String dialogTitle;
  final String titleFieldLabel;
  final String titleFieldHint;
  final String submitLabel;
  final String discardLabel;
  final TextDirection textDirection;
  final String? headerIconAsset;
  final List<String>? allowedExtensions;
  final void Function(PlatformFile, String)? onSubmit;

  const _UploadDialog({
    required this.dialogTitle,
    required this.titleFieldLabel,
    required this.titleFieldHint,
    required this.submitLabel,
    required this.discardLabel,
    required this.textDirection,
    this.headerIconAsset,
    this.allowedExtensions,
    this.onSubmit,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  PlatformFile? _pickedFile;
  final TextEditingController _titleCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null
          ? FileType.custom
          : FileType.any,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_pickedFile == null) return;
    if (_titleCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit?.call(_pickedFile!, _titleCtrl.text.trim());
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return _DialogShell(
      width: 910.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              _TitleIcon(
                assetPath: widget.headerIconAsset,
                fallback: Icon(Icons.attach_file,
                    size: 18.r, color: AppColors.primary),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.dialogTitle,
                style:
                StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Drop zone OR file card ──
          _pickedFile == null ? _buildDropZone(lightMode) : _buildFileCard(),

          SizedBox(height: 16.h),

          // ── Title field ──
          Text(
            widget.titleFieldLabel,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 6.h),
          CustomValidatedTextFieldMaster(
            hint: widget.titleFieldHint,
            controller: _titleCtrl,
            height: 36,
            submitted: _submitted,
            textDirection: widget.textDirection,
            onChanged: (_) => setState(() {}),
          ),

          SizedBox(height: 20.h),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: _secondaryBtn(
                  label: widget.discardLabel,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _primaryBtn(
                  label: widget.submitLabel,
                  onTap: _handleSubmit,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildDropZone(bool lightMode) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          color: lightMode ? const Color(0xFFF1F2ED) : AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined,
                size: 48.r, color: Colors.grey.shade500),
            SizedBox(height: 8.h),
            Text(
              'Drag & Drop files here',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 4.h),
            Text(
              'Or',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard() {
    final file = _pickedFile!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFFFDE59), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.image_outlined, size: 28.r, color: Colors.orange.shade400),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatBytes(file.size),
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _pickedFile = null),
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
