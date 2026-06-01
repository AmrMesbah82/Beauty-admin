// ******************* FILE INFO *******************
// File Name: preview_content.dart
// Description: Preview content widget for Strategy preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › about_us › presentation › ui › widget › strategy_preview

part of '../../pages/strategy_page/strategy_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double fakeWidth;
  final double fakeHeight;
  final OurStrategyModel model;
  final Uint8List? enBytes;
  final String enUrl;
  final Uint8List? arBytes;
  final String arUrl;
  final bool hasEnImage;
  final bool hasArImage;
  final bool isMobile;
  final bool isTablet;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.enBytes,
    required this.enUrl,
    required this.arBytes,
    required this.arUrl,
    required this.hasEnImage,
    required this.hasArImage,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTabletOrMobile = isMobile || isTablet;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final verticalPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          width: fakeWidth,
          height: fakeHeight,
          color: ColorPick.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strategic House Section
                  _buildStrategicHouseSection(isEnglish),
                  SizedBox(height: isMobile ? 24.h : 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Strategic House Section ────────────────────────────────────────────────
  Widget _buildStrategicHouseSection(bool isEnglish) {
    final dir = isEnglish ? ui.TextDirection.ltr : ui.TextDirection.rtl;
    final title = isEnglish ? 'Strategic House' : 'البيت الاستراتيجي';
    final hasImage = isEnglish ? hasEnImage : hasArImage;
    final bytes = isEnglish ? enBytes : arBytes;
    final url = isEnglish ? enUrl : arUrl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.w : 20.w,
              vertical: isMobile ? 12.h : 16.h,
            ),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(8.r)
              ),
            child: Text(
              title,
              textDirection: dir,
              style: TextStyle(
                fontSize: isMobile ? 16.sp : 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Image
          Padding(
            padding: EdgeInsets.all(isMobile ? 12.r : 20.r),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _buildImage(
                  bytes: bytes,
                  url: url,
                  hasImage: hasImage,
                  height: isMobile ? 180 : (isTablet ? 240 : 300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Widget ────────────────────────────────────────────────────────────
  Widget _buildImage({
    required Uint8List? bytes,
    required String url,
    required bool hasImage,
    required double height,
  }) {
    if (!hasImage) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorPick.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: ColorPick.white),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined,
                  color: Colors.grey[400], size: isMobile ? 40.sp : 48.sp),
              SizedBox(height: 8.h),
              Text(
                'No image uploaded',
                style: TextStyle(
                  fontSize: isMobile ? 11.sp : 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle uploaded bytes (new upload)
    if (bytes != null && bytes.isNotEmpty) {
      final isSvg = _isSvgBytes(bytes);
      if (isSvg) {
        return SvgPicture.memory(
          bytes,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Center(
            child: CircularProgressIndicator(
              color: ColorPick.primary,
              strokeWidth: 2,
            ),
          ),
        );
      } else {
        return Image.memory(
          bytes,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            height: height,
            color: ColorPick.white,
            child: Icon(Icons.broken_image,
                color: Colors.grey[400], size: 48),
          ),
        );
      }
    }

    // Handle existing URL (from database)
    if (url.isNotEmpty) {
      final isSvg = _isSvgUrl(url);
      if (isSvg) {
        return FutureBuilder<Uint8List>(
          future: _loadSvgBytes(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: height,
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorPick.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              return SvgPicture.memory(
                snapshot.data!,
                width: double.infinity,
                height: height,
                fit: BoxFit.contain,
              );
            }
            return Container(
              height: height,
              color: ColorPick.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        color: Colors.grey[400], size: 48),
                    SizedBox(height: 8.h),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return Image.network(
          url,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: height,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: ColorPick.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: height,
            color: ColorPick.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image,
                      color: Colors.grey[400], size: 48),
                  SizedBox(height: 8.h),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  bool _isSvgBytes(Uint8List? bytes) {
    if (bytes == null || bytes.length < 5) return false;
    final header = bytes.sublist(0, bytes.length > 5 ? 5 : bytes.length);
    final headerStr = String.fromCharCodes(header);
    return headerStr.contains('<svg') || headerStr.contains('<?xml');
  }

  bool _isSvgUrl(String url) {
    final decoded = Uri.decodeFull(url).toLowerCase();
    return decoded.contains('.svg') ||
        decoded.contains('/svg?') ||
        decoded.contains('/svg/') ||
        decoded.endsWith('/svg');
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (response.status != 200) {
        throw Exception('Failed to load SVG: ${response.status}');
      }
      return (response.response as ByteBuffer).asUint8List();
    } catch (e) {
      rethrow;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BROWSER CHROME BAR
// ═════════════════════════════════════════════════════════════════════════════
