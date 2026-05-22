part of '../../pages/strategy_page/strategy_edit.dart';

class _StrategicHouseDisplayWidget extends StatelessWidget {
  final DisplayDeviceTab displayTab;
  final Uint8List? desktopBytes;
  final String desktopUrl;
  final bool desktopIsSvg;
  final Uint8List? tabletBytes;
  final String tabletUrl;
  final bool tabletIsSvg;
  final Uint8List? mobileBytes;
  final String mobileUrl;
  final bool mobileIsSvg;
  final Future<Uint8List> Function(String) loadSvgBytes;

  const _StrategicHouseDisplayWidget({
    required this.displayTab,
    required this.desktopBytes,
    required this.desktopUrl,
    required this.desktopIsSvg,
    required this.tabletBytes,
    required this.tabletUrl,
    required this.tabletIsSvg,
    required this.mobileBytes,
    required this.mobileUrl,
    required this.mobileIsSvg,
    required this.loadSvgBytes,
  });

  double _getPreviewWidth() {
    switch (displayTab) {
      case DisplayDeviceTab.largeScreen:
        return double.infinity;
      case DisplayDeviceTab.tablet:
        return 600;
      case DisplayDeviceTab.mobile:
        return 320;
    }
  }

  Uint8List? _getCurrentBytes() {
    switch (displayTab) {
      case DisplayDeviceTab.largeScreen:
        return desktopBytes;
      case DisplayDeviceTab.tablet:
        return tabletBytes;
      case DisplayDeviceTab.mobile:
        return mobileBytes;
    }
  }

  String _getCurrentUrl() {
    switch (displayTab) {
      case DisplayDeviceTab.largeScreen:
        return desktopUrl;
      case DisplayDeviceTab.tablet:
        return tabletUrl;
      case DisplayDeviceTab.mobile:
        return mobileUrl;
    }
  }

  bool _getCurrentIsSvg() {
    switch (displayTab) {
      case DisplayDeviceTab.largeScreen:
        return desktopIsSvg;
      case DisplayDeviceTab.tablet:
        return tabletIsSvg;
      case DisplayDeviceTab.mobile:
        return mobileIsSvg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _getCurrentBytes();
    final url = _getCurrentUrl();
    final isSvg = _getCurrentIsSvg();
    final hasImage = bytes != null || url.isNotEmpty;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _getPreviewWidth(),
        height: 220.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.grey[100],
        ),
        child: hasImage
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Builder(
            builder: (context) {
              if (bytes != null && isSvg) {
                return SvgPicture.memory(
                  bytes,
                  width: _getPreviewWidth(),
                  height: 220.h,
                  fit: BoxFit.contain,
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
                        width: _getPreviewWidth(),
                        height: 220.h,
                        fit: BoxFit.contain,
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 48.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Failed to load SVG',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvg(
              assetPath: "assets/images/upload-image.svg",
              width: 100.w,
              height: 100.h,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 8.h),
            Text(
              'No image uploaded for ${displayTab == DisplayDeviceTab.largeScreen ? "Desktop" : displayTab == DisplayDeviceTab.tablet ? "Tablet" : "Mobile"}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for device upload row
