// ******************* FILE INFO *******************
// File Name: nav_icon_upload_widget.dart
// Description: Nav icon upload widget for Strategy edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › strategy_edit

part of '../../pages/strategy_page/strategy_edit.dart';

class _NavIconUploadWidget extends StatelessWidget {
  final Uint8List? bytes;
  final String url;
  final bool isSvg;
  final String? errorText;
  final Future<Uint8List> Function(String) loadSvgBytes;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _NavIconUploadWidget({
    super.key,
    required this.bytes,
    required this.url,
    required this.isSvg,
    this.errorText,
    required this.loadSvgBytes,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon',
            style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text
            )
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEEEEEE),
                      border: errorText != null
                          ? Border.all(color: _kRed, width: 2)
                          : null,
                    ),
                    child: hasImage
                        ? ClipOval(
                      child: Builder(
                        builder: (context) {
                          if (bytes != null && isSvg) {
                            return SvgPicture.memory(
                              bytes!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (url.isNotEmpty && isSvg) {
                            return FutureBuilder<Uint8List>(
                              key: ValueKey(url),
                              future: loadSvgBytes(url),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasData) {
                                  return SvgPicture.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[400],
                                  size: 28.sp,
                                );
                              },
                            );
                          }
                          return Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 28.sp,
                          );
                        },
                      ),
                    )
                        : Icon(Icons.add,
                        color: errorText != null ? _kRed : Colors.grey[600],
                        size: 28.sp),
                  ),
                  if (hasImage && onRemove != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kRed,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  if (!hasImage)
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kGreenSolid),
                        child: Icon(Icons.edit,
                            color: Colors.white, size: 13.sp),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: _kRed,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget for displaying the selected device preview
