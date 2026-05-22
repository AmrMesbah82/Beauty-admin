part of '../../pages/contact_us_edit.dart';

class _SocialLinkDropdown extends StatelessWidget {
  final List<SocialLinkModel> footerLinks;
  final int?                  selectedIndex;
  final ValueChanged<int?>    onChanged;
  final bool                  submitted;

  const _SocialLinkDropdown({
    super.key,
    required this.footerLinks,
    required this.selectedIndex,
    required this.onChanged,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    if (footerLinks.isEmpty) {
      return Container(
        height:  38.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color:        const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width:  14.w,
              height: 14.w,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: _kPink),
            ),
            SizedBox(width: 10.w),
            Text('Loading social links...',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   12.sp,
                    color:      Colors.grey.shade500)),
          ],
        ),
      );
    }

    final items = footerLinks.asMap().entries.map((entry) {
      final index  = entry.key;
      final link   = entry.value;
      final hasUrl = link.url.isNotEmpty;
      return DropdownMenuItem<int>(
        value:   index,
        enabled: hasUrl,
        child: Row(
          children: [
            if (link.iconUrl.isNotEmpty)
              _buildIcon(link.iconUrl, hasUrl ? _kPink : Colors.grey.shade400)
            else
              Icon(Icons.link,
                  size:  16.sp,
                  color: hasUrl ? _kPink : Colors.grey.shade400),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hasUrl
                    ? _truncateUrl(link.url)
                    : 'Social ${index + 1} — no URL',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   12.sp,
                  color:      hasUrl ? Colors.black87 : Colors.grey.shade400,
                  fontStyle:
                  hasUrl ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();

    final selectedLink =
    selectedIndex != null && selectedIndex! < footerLinks.length
        ? footerLinks[selectedIndex!]
        : null;

    Widget selectedDisplay() {
      if (selectedLink == null) {
        return Row(children: [
          Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400),
          SizedBox(width: 8.w),
          Text('Insert Links',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   12.sp,
                  color:      Colors.grey.shade400)),
        ]);
      }
      return Row(children: [
        if (selectedLink.iconUrl.isNotEmpty)
          _buildIcon(selectedLink.iconUrl, _kPink)
        else
          Icon(Icons.link, size: 16.sp, color: _kPink),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            selectedLink.url.isNotEmpty
                ? _truncateUrl(selectedLink.url)
                : 'Insert Links',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   12.sp,
                color:      Colors.black87),
          ),
        ),
      ]);
    }

    final selectedItemWidgets =
    List.generate(footerLinks.length, (_) => selectedDisplay());

    return Container(
      height:  38.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value:      selectedIndex,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 20.sp, color: Colors.grey.shade600),
          hint: Row(children: [
            Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400),
            SizedBox(width: 8.w),
            Text('Insert Links',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   12.sp,
                    color:      Colors.grey.shade400)),
          ]),
          selectedItemBuilder: (_) => selectedItemWidgets,
          items:     items,
          onChanged: (idx) {
            if (idx == null) return;
            if (footerLinks[idx].url.isEmpty) return;
            onChanged(idx);
          },
        ),
      ),
    );
  }

  /// Renders icon correctly for both PNG and SVG URLs
  Widget _buildIcon(String url, Color color) {
    final isPng = !url.toLowerCase().contains('.svg') &&
        !url.toLowerCase().contains('svg%2B');

    if (isPng) {
      return Image.network(
        url,
        width:          18.w,
        height:         18.w,
        fit:            BoxFit.contain,
        color:          color,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder:   (_, __, ___) =>
            Icon(Icons.link, size: 16.sp, color: color),
      );
    }

    return SvgPicture.network(
      url,
      width:              18.w,
      height:             18.w,
      fit:                BoxFit.contain,
      colorFilter:        ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) =>
          Icon(Icons.link, size: 16.sp, color: color),
    );
  }

  String _truncateUrl(String url) {
    final clean = url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    return clean.length > 38 ? '${clean.substring(0, 38)}…' : clean;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════════════
