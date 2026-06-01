// ******************* FILE INFO *******************
// File Name: sections.dart
// Description: Section widgets for Demo main page
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › demos › presentation › ui › widget › demo_main_page

part of '../../pages/demo_main_page.dart';

extension _RequestDemoMainSections on _RequestDemoMainPageState {
  Widget _chartRow({required Widget left, required Widget right}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          SizedBox(width: 16.w),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _summaryRow(int total, int newC, int replied, int closed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: _summaryCard('Total Submission', total, Colors.grey)),
        SizedBox(width: 10.w),
        Expanded(child: _summaryCard('New', newC, ColorPick.primary)),
        SizedBox(width: 10.w),
        Expanded(
            child: _summaryCard('Replied', replied, const Color(0xFFFF9800))),
        SizedBox(width: 10.w),
        Expanded(
            child: _summaryCard('Closed', closed, const Color(0xFFE53935))),
      ],
    );
  }

  Widget _buildFiltersRow({
    required RequestDemoCubit cubit,
    required List<String> uniqueStatuses,
    required List<String> uniqueEntityTypes,
    required List<String> uniqueCountries,
    required List<int> uniqueMonths,
    required String? activeStatus,
    required String? activeEntityType,
    required String? activeCountry,
    required int? activeMonth,
    required bool hasFilters,
    required List<RequestDemoModel> demos,
    required List<DemoQuestionModel> dynamicQuestions,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Wrap(spacing: 8.w, runSpacing: 6.h, children: [
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeStatus,
              items: _kAllStatuses
                  .map((s) => {'key': s, 'value': s})
                  .toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white,
              primaryColor: ColorPick.primary,
              hint: Text('Status',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: cubit.setStatusFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeEntityType,
              items: _kAllEntityTypes
                  .map((s) => {'key': s, 'value': s})
                  .toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white,
              primaryColor: ColorPick.primary,
              hint: Text('Entity Type',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: cubit.setEntityTypeFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeCountry,
              items: _kAllCountries
                  .map((s) => {'key': s, 'value': s})
                  .toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white,
              primaryColor: ColorPick.primary,
              hint: Text('Location',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: cubit.setCountryFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeMonth?.toString(),
              items: _kAllMonths
                  .map((m) => {
                        'key':   m.toString(),
                        'value': _kMonthNames[m - 1],
                      })
                  .toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white,
              primaryColor: ColorPick.primary,
              hint: Text('Calendar',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: (v) =>
                  cubit.setMonthFilter(v != null ? int.tryParse(v) : null),
            ),
          ),
        ]),
        const Spacer(),
        customButtonWithImage(
          title: 'Export',
          function: () => _showExportDialog(demos, dynamicQuestions),
          textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
          height: 32.h, space: 4.w, radius: 6, color: ColorPick.primary,
          image: 'assets/images/export.svg',
          widthImage: 14.sp, heightImage: 14.sp,
          colorBorder: ColorPick.primary,
          svgColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, int count, Color topColor) {
    return Container(
      decoration: BoxDecoration(
          color: ColorPick.white, borderRadius: BorderRadius.circular(8.r)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text))),
                Text('$count',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text)),
              ]),
        ),
      ]),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(int dynamicCount) {
    final Map<int, TableColumnWidth> widths = {
      0: FixedColumnWidth(110.sp),
      1: FixedColumnWidth(120.sp),
      2: FixedColumnWidth(100.sp),
      3: FixedColumnWidth(90.sp),
      4: FixedColumnWidth(90.sp),
      5: FixedColumnWidth(90.sp),
      6: FixedColumnWidth(100.sp),
      7: FixedColumnWidth(100.sp),
      8: FixedColumnWidth(110.sp),
      9: FixedColumnWidth(160.sp),
    };
    final staticLeftCount = _kStaticHeadersLeft.length;
    for (int i = 0; i < dynamicCount; i++) {
      widths[staticLeftCount + i] = FixedColumnWidth(140.sp);
    }
    final rightStart = staticLeftCount + dynamicCount;
    widths[rightStart + 0] = FixedColumnWidth(110.sp);
    widths[rightStart + 1] = FixedColumnWidth(150.sp);
    widths[rightStart + 2] = FixedColumnWidth(160.sp);
    widths[rightStart + 3] = FixedColumnWidth(140.sp);
    widths[rightStart + 4] = FixedColumnWidth(80.sp);
    return widths;
  }

  TextStyle get _cellStyle =>
      TextStyle(fontSize: 11.sp, color: AppColors.text);

  Widget _cell(Widget child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
        child: DefaultTextStyle.merge(style: _cellStyle, child: child),
      );

  Widget _tc(String text, {int ml = 2}) =>
      _cell(Text(text.isEmpty ? '-' : text,
          maxLines: ml, overflow: TextOverflow.ellipsis));

  Widget _buildTable(
    List<RequestDemoModel> demos,
    List<DemoQuestionModel> dynamicQuestions,
    BuildContext context,
  ) {
    final headers      = _buildHeaders(dynamicQuestions);
    final columnWidths = _buildColumnWidths(dynamicQuestions.length);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: ColorPick.primary),
              children: headers
                  .map((h) => Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: Text(h,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ))
                  .toList(),
            ),
            ...List.generate(demos.length, (idx) {
              final d        = demos[idx];
              final rowColor =
                  idx.isEven ? const Color(0xFFF7F8FA) : Colors.white;
              final dateStr = d.submissionDate != null
                  ? '${d.submissionDate!.day}/${d.submissionDate!.month}/${d.submissionDate!.year}'
                  : '-';
              final cells = <Widget>[
                _tc(dateStr, ml: 1),
                _tc(d.salonName),
                _tc(d.country),
                _tc(d.city),
                _tc(d.noBranches, ml: 1),
                _tc(d.noEmployees, ml: 1),
                _tc(d.firstName),
                _tc(d.lastName),
                _tc('${d.countryCode} ${d.phone}'.trim()),
                _tc(d.email),
                ...dynamicQuestions.map((q) => _tc(_getAnswer(d, q.id))),
                _cell(_priorityChip(d.inquiryPriority)),
                _tc(d.inquiryRelevance?.label ?? '-'),
                _tc(d.requiredAction?.label ?? '-'),
                _tc(d.note),
                _cell(Text(d.status.label,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: d.status.color))),
              ];
              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: cells
                    .map((cell) => InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<RequestDemoCubit>(),
                                child: RequestDemoDetailPage(demoId: d.id),
                              ),
                            ),
                          ),
                          child: cell,
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(DemoPriority? p) {
    if (p == null) {
      return Text('-',
          style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8.sp, height: 8.sp,
          decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
      SizedBox(width: 4.w),
      Flexible(
          child: Text(p.label,
              style: TextStyle(fontSize: 11.sp, color: AppColors.text),
              overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _chartCard(String title, String subtitle, Widget chart) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
          color: ColorPick.white, borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorPick.primary)),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(subtitle,
                style: TextStyle(fontSize: 11.sp, color: AppColors.text)),
          ],
          SizedBox(height: 12.h),
          chart,
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> monthly) {
    final maxVal  = monthly.values.fold(0, (a, b) => a > b ? a : b);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: labelH.h,
                    child: val > 0
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Text('$val',
                                style: TextStyle(
                                    fontSize: 7.sp,
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w600)),
                          )
                        : const SizedBox(),
                  ),
                  Container(
                    height: val > 0 ? barH.h : 4.h,
                    decoration: BoxDecoration(
                      color:
                          val > 0 ? ColorPick.primary : ColorPick.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3.r),
                          topRight: Radius.circular(3.r)),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(_kMonthNames[i],
                      style: TextStyle(
                          fontSize: 8.sp, color: AppColors.secondaryText)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSegmentedBarChart({
    required Map<String, int> counts,
    required List<Color> colors,
  }) {
    if (counts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              height: 28.h, color: ColorPick.white,
              child: Center(
                  child: Text('No data',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.secondaryText))),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      );
    }

    final total     = counts.values.fold(0, (a, b) => a + b);
    final entries   = counts.entries.toList();
    final isAllZero = total == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(entries.length, (i) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Text(entries[i].key,
                  style: TextStyle(
                      fontSize: 9.sp, color: AppColors.secondaryText)),
              SizedBox(height: 3.h),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8.sp, height: 8.sp,
                  decoration: BoxDecoration(
                      color: isAllZero
                          ? ColorPick.white
                          : colors[i % colors.length],
                      shape: BoxShape.circle),
                ),
                SizedBox(width: 3.w),
                Text('${entries[i].value}',
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text)),
              ]),
            ]);
          }),
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: isAllZero
              ? Row(
                  children: List.generate(
                      entries.length,
                      (i) => Expanded(
                          child: Container(
                              height: 28.h, color: ColorPick.white))))
              : Row(
                  children: List.generate(entries.length, (i) {
                    final pct = entries[i].value / total;
                    return Flexible(
                      flex: (pct * 100).round().clamp(1, 100),
                      child: Container(
                          height: 28.h,
                          color: colors[i % colors.length]),
                    );
                  }),
                ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildTwoColumnHorizontalBarChart(Map<String, int> counts) {
    if (counts.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
            child: Text('No data',
                style: TextStyle(
                    fontSize: 11.sp, color: AppColors.secondaryText))),
      );
    }

    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();
    final half    = (entries.length / 2).ceil();
    final left    = entries.sublist(0, half);
    final right   = entries.length > half
        ? entries.sublist(half)
        : <MapEntry<String, int>>[];

    Widget buildEntry(MapEntry<String, int> e) {
      final pct  = total > 0 ? (e.value / total * 100).round() : 0;
      final fill = total > 0 ? e.value / total : 0.0;
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key,
                  style: TextStyle(fontSize: 9.sp, color: AppColors.text),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 3.h),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: Stack(children: [
                      Container(height: 12.h, color: ColorPick.white),
                      if (fill > 0)
                        FractionallySizedBox(
                          widthFactor: fill.clamp(0.0, 1.0),
                          child: Container(
                              height: 12.h, color: ColorPick.primary),
                        ),
                    ]),
                  ),
                ),
                SizedBox(width: 5.w),
                SizedBox(
                  width: 26.w,
                  child: Text('$pct%',
                      style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                ),
              ]),
            ]),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: left.map(buildEntry).toList())),
        SizedBox(width: 12.w),
        Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: right.map(buildEntry).toList())),
      ],
    );
  }

  Widget _buildDonutSection({
    required Map<String, int> counts,
    required int centerTotal,
    required List<Color> colors,
    bool usePriorityColors = false,
  }) {
    if (counts.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Text('No data',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.secondaryText))),
          SizedBox(width: 16.w),
          SizedBox(
            width: 110.w, height: 110.w,
            child: CustomPaint(
              painter: _DonutPainter(
                values: const [1],
                colors: const [Color(0xFFE0E0E0)],
                centerLabel: 'Total',
                centerValue: '0',
              ),
            ),
          ),
        ],
      );
    }

    final total   = counts.values.fold(0, (a, b) => a + b);
    final entries = counts.entries.toList();

    final dotColors = List.generate(entries.length, (i) {
      if (usePriorityColors) return _priorityColorForLabel(entries[i].key);
      if (colors.isEmpty) return ColorPick.white;
      return colors[i % colors.length];
    });

    final paintValues = total == 0
        ? List<double>.filled(entries.length, 1.0)
        : entries.map((e) => e.value.toDouble()).toList();
    final paintColors = total == 0
        ? List<Color>.filled(entries.length, ColorPick.white)
        : dotColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final pct =
                  total > 0 ? (entries[i].value / total * 100).round() : 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(children: [
                  Container(
                      width: 10.sp, height: 10.sp,
                      decoration: BoxDecoration(
                          color: dotColors[i], shape: BoxShape.circle)),
                  SizedBox(width: 6.w),
                  Expanded(
                      child: Text(entries[i].key,
                          style:
                              TextStyle(fontSize: 10.sp, color: AppColors.text),
                          overflow: TextOverflow.ellipsis)),
                  Text('$pct%',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600)),
                ]),
              );
            }),
          ),
        ),
        SizedBox(width: 16.w),
        SizedBox(
          width: 110.w, height: 110.w,
          child: CustomPaint(
            painter: _DonutPainter(
              values: paintValues,
              colors: paintColors,
              centerLabel: 'Total',
              centerValue: '$centerTotal',
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _pieColors(int n) {
    if (n == 0) return [];
    return List.generate(n, (i) {
      final opacity = 1.0 - (i * 0.15).clamp(0.0, 0.6);
      return ColorPick.primary.withValues(alpha: opacity);
    });
  }

  List<Color> _priorityColors(List<String> labels) =>
      labels.map(_priorityColorForLabel).toList();

  Color _priorityColorForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('critical'))      return const Color(0xFFE53935);
    if (l.contains('high'))          return const Color(0xFFEF6C00);
    if (l.contains('medium'))        return const Color(0xFFFFB300);
    if (l.contains('low'))           return const Color(0xFF5B9BD5);
    if (l.contains('informational')) return const Color(0xFFBDBDBD);
    return const Color(0xFFBDBDBD);
  }
}
