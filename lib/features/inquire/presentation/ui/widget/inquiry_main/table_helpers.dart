part of '../../pages/inquiry_main.dart';

const List<String> _kHeaders = [
  'No', 'Submission Date', 'Preferred Language', 'First Name', 'Last Name',
  'Email', 'Country Code', 'Phone Number', 'Gender', 'Country',
  'Subject', 'Reason', 'Message', 'Inquiry Priority', 'Inquiry Relevance',
  'Required Action', 'Notes', 'Status',
];

extension _InquiryMainTable on _InquiryMainPageState {
  Map<int, TableColumnWidth> get _columnWidths => {
    0:  FixedColumnWidth(45.sp),  1:  FixedColumnWidth(110.sp), 2:  FixedColumnWidth(120.sp),
    3:  FixedColumnWidth(110.sp), 4:  FixedColumnWidth(110.sp), 5:  FixedColumnWidth(170.sp),
    6:  FixedColumnWidth(90.sp),  7:  FixedColumnWidth(110.sp), 8:  FixedColumnWidth(80.sp),
    9:  FixedColumnWidth(100.sp), 10: FixedColumnWidth(140.sp), 11: FixedColumnWidth(120.sp),
    12: FixedColumnWidth(160.sp), 13: FixedColumnWidth(110.sp), 14: FixedColumnWidth(150.sp),
    15: FixedColumnWidth(160.sp), 16: FixedColumnWidth(140.sp), 17: FixedColumnWidth(90.sp),
  };

  TextStyle get _cellStyle => TextStyle(fontSize: 11.sp, color: AppColors.text);

  Widget _cell(Widget child) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
    child: DefaultTextStyle.merge(style: _cellStyle, child: child),
  );

  Widget _tc(String text, {int ml = 2}) =>
      _cell(Text(text.isEmpty ? '-' : text, maxLines: ml, overflow: TextOverflow.ellipsis));

  Widget _priorityChip(InquiryPriority? p) {
    if (p == null) return Text('-', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8.sp, height: 8.sp, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
      SizedBox(width: 4.w),
      Flexible(child: Text(p.label, style: TextStyle(fontSize: 11.sp, color: AppColors.text), overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _buildTable(List<InquiryModel> inquiries, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: _columnWidths,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: ColorPick.primary),
              children: _kHeaders.map((h) => Padding(
                padding: EdgeInsets.all(8.sp),
                child: Text(h, maxLines: 1,
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              )).toList(),
            ),
            ...List.generate(inquiries.length, (idx) {
              final i        = inquiries[idx];
              final rowColor = idx.isEven ? const Color(0xFFF7F8FA) : Colors.white;
              final dateStr  = i.submissionDate != null
                  ? '${i.submissionDate!.day}/${i.submissionDate!.month}/${i.submissionDate!.year}'
                  : '-';
              final cells = [
                _tc('${idx + 1}', ml: 1),
                _tc(dateStr, ml: 1),
                _tc(i.preferredLanguage, ml: 1),
                _tc(i.firstName),
                _tc(i.lastName),
                _tc(i.email),
                _tc(i.countryCode, ml: 1),
                _tc(i.phone),
                _tc(i.gender, ml: 1),
                _tc(i.country),
                _tc(i.subject),
                _tc(i.reason),
                _tc(i.message, ml: 1),
                _cell(_priorityChip(i.inquiryPriority)),
                _tc(i.inquiryRelevance?.label ?? '-'),
                _tc(i.requiredAction?.label ?? '-'),
                _tc(i.note),
                _cell(Text(i.status.label,
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: i.status.color))),
              ];
              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: cells.map((cell) => InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<InquiryCubit>(),
                        child: InquiryDetailPage(inquiryId: i.id),
                      ),
                    ),
                  ),
                  child: cell,
                )).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(int total, int newC, int replied, int closed) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = (constraints.maxWidth - 30.w) / 4;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: w, child: _summaryCard('Total Submission', total, Colors.grey)),
        SizedBox(width: 10.w),
        SizedBox(width: w, child: _summaryCard('New',     newC,    ColorPick.primary)),
        SizedBox(width: 10.w),
        SizedBox(width: w, child: _summaryCard('Replied', replied, const Color(0xFFFF9800))),
        SizedBox(width: 10.w),
        SizedBox(width: w, child: _summaryCard('Closed',  closed,  const Color(0xFFE53935))),
      ]);
    });
  }

  Widget _summaryCard(String title, int count, Color topColor) {
    return Container(
      decoration: BoxDecoration(color: ColorPick.white, borderRadius: BorderRadius.circular(8.r)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(title,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.text))),
            Text('$count', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFiltersRow({
    required InquiryCubit cubit,
    required String?      activeStatus,
    required String?      activeGender,
    required String?      activeCountry,
    required int?         activeMonth,
    required List<InquiryModel> inquiries,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Wrap(spacing: 8.w, runSpacing: 6.h, children: [
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeStatus,
              items: _kAllStatuses.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white, primaryColor: ColorPick.primary,
              hint: Text('Status', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: cubit.setStatusFilter,
            ),
          ),
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeGender,
              items: _kAllGenders.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white, primaryColor: ColorPick.primary,
              hint: Text('Gender', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: cubit.setGenderFilter,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeCountry,
              items: _kAllCountries.map((s) => {'key': s, 'value': s}).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white, primaryColor: ColorPick.primary,
              hint: Text('Country', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: cubit.setCountryFilter,
            ),
          ),
          SizedBox(
            width: 120.w,
            child: CustomDropdownFormFieldInvMaster(
              selectedValue: activeMonth?.toString(),
              items: _kAllMonths.map((m) => {
                'key':   m.toString(),
                'value': _kMonthNames[m - 1],
              }).toList(),
              widthIcon: 14, heightIcon: 14, height: 32,
              dropdownColor: ColorPick.white, primaryColor: ColorPick.primary,
              hint: Text('Calendar', style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText)),
              onChanged: (v) => cubit.setMonthFilter(v != null ? int.tryParse(v) : null),
            ),
          ),
        ]),
        const Spacer(),
        customButtonWithImage(
          title: 'Export',
          function: () => _showExportDialog(inquiries),
          textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
          height: 32.h, space: 4.w, radius: 6, color: ColorPick.primary,
          image: 'assets/images/export.svg',
          widthImage: 14.sp, heightImage: 14.sp,
          colorBorder: ColorPick.primary, svgColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
      ],
    );
  }

  Widget _chartRow({required Widget left, required Widget right}) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final half = (constraints.maxWidth - 16.w) / 2;
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: half, child: left),
          SizedBox(width: 16.w),
          SizedBox(width: half, child: right),
        ],
      );
    });
  }

  Widget _chartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(color: ColorPick.white, borderRadius: BorderRadius.circular(8.r)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ColorPick.primary)),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(subtitle, style: TextStyle(fontSize: 11.sp, color: AppColors.text)),
        ],
        SizedBox(height: 12.h),
        chart,
      ]),
    );
  }
}
