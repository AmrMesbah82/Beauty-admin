// ******************* FILE INFO *******************
// File Name: charts.dart
// Description: Chart widgets for Inquiry main
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › widget › inquiry_main

part of '../../pages/inquiry_main.dart';

extension _InquiryMainCharts on _InquiryMainPageState {
  Widget _buildBarChart(Map<int, int> monthly) {
    final maxVal  = monthly.values.fold(1, (a, b) => a > b ? a : b);
    const maxBarH = 130.0;
    const labelH  = 16.0;
    return SizedBox(
      height: 175.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final val  = monthly[i + 1] ?? 0;
          final barH = maxVal > 0 ? (val / maxVal) * maxBarH : 0.0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: labelH.h,
                  child: val > 0
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Text('$val', style: TextStyle(fontSize: 7.sp, color: AppColors.text, fontWeight: FontWeight.w600)),
                        )
                      : const SizedBox(),
                ),
                Container(
                  height: barH.h,
                  decoration: BoxDecoration(
                    color: val > 0 ? ColorPick.primary : Colors.transparent,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(3.r), topRight: Radius.circular(3.r)),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(_kMonthNames[i], style: TextStyle(fontSize: 8.sp, color: AppColors.secondaryText)),
              ]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPieSection(Map<String, int> counts, List<Color> colors) {
    if (counts.isEmpty) return const SizedBox(height: 120);
    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) {
            final pct = total > 0 ? (entries[i].value / total * 100).round() : 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(children: [
                Container(width: 10.sp, height: 10.sp,
                    decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 6.w),
                Expanded(child: Text(entries[i].key, style: TextStyle(fontSize: 10.sp, color: AppColors.text), overflow: TextOverflow.ellipsis)),
                Text('$pct%', style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
              ]),
            );
          }),
        ),
      ),
      SizedBox(width: 16.w),
      SizedBox(
        width: 110.w, height: 110.w,
        child: CustomPaint(painter: _PiePainter(
          values: entries.map((e) => e.value.toDouble()).toList(),
          colors: colors,
        )),
      ),
    ]);
  }

  Widget _buildLocationChart(Map<String, int> counts) {
    if (counts.isEmpty) return const SizedBox(height: 160);
    final total = counts.values.fold(0, (a, b) => a + b);
    const barH  = 120.0;
    return SizedBox(
      height: 160.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: counts.entries.map((e) {
          final pct    = total > 0 ? (e.value / total * 100).round() : 0;
          final fillH  = (pct / 100) * barH;
          final emptyH = barH - fillH;
          return Expanded(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(height: emptyH.h, color: ColorPick.primary.withOpacity(0.3)),
                  Container(height: fillH.h,  color: ColorPick.primary),
                ]),
              ),
              SizedBox(height: 5.h),
              Text('$pct%', style: TextStyle(fontSize: 8.sp, color: AppColors.text, fontWeight: FontWeight.w600)),
              SizedBox(height: 2.h),
              Text(e.key, style: TextStyle(fontSize: 7.sp, color: AppColors.secondaryText),
                  overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ]),
          ));
        }).toList(),
      ),
    );
  }

  Widget _buildDonutSection(Map<String, int> counts, List<Color> colors) {
    if (counts.isEmpty) return const SizedBox(height: 120);
    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(children: [
              Container(width: 8.sp, height: 8.sp,
                  decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
              SizedBox(width: 5.w),
              Expanded(child: Text(entries[i].key, style: TextStyle(fontSize: 9.sp, color: AppColors.text), overflow: TextOverflow.ellipsis)),
            ]),
          )),
        ),
      ),
      SizedBox(width: 12.w),
      SizedBox(
        width: 110.w, height: 110.w,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
            painter: _DonutPainter(
              values: entries.map((e) => e.value.toDouble()).toList(),
              colors: colors,
            ),
            size: Size(110.w, 110.w),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Total', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
            Text('$total', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
          ]),
        ]),
      ),
    ]);
  }

  List<Color> _pieColors(int n) {
    const palette = [
      Color(0xFFD16F9A), Color(0xFFE8A0BE), Color(0xFFF2C8DA),
      Color(0xFFA0522D), Color(0xFFF4A460), Color(0xFFDEB887),
    ];
    return List.generate(n, (i) => palette[i % palette.length]);
  }

  List<Color> _priorityColors() => [
    InquiryPriority.critical.color,
    InquiryPriority.high.color,
    InquiryPriority.medium.color,
    InquiryPriority.low.color,
    InquiryPriority.informationalOnly.color,
  ];

  List<Color> _relevanceColors() => const [
    Color(0xFFD16F9A), Color(0xFFE8A0BE), Color(0xFFF2C8DA),
    Color(0xFFB0BEC5), Color(0xFF90A4AE), Color(0xFF607D8B),
  ];

  List<Color> _actionColors() => const [
    Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A),
    Color(0xFF9CCC65), Color(0xFFD4E157), Color(0xFFFFF176),
    Color(0xFFFFCC02), Color(0xFFF4511E),
  ];
}
