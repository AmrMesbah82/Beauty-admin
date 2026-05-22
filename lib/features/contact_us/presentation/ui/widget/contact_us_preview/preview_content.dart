part of '../../pages/contact_us_preview.dart';

class _PreviewContent extends StatefulWidget {
  final double           fakeWidth;
  final double           fakeHeight;
  final ContactUsCmsModel data;
  final bool             isEnglish;
  final bool             isMobile;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.data,
    required this.isEnglish,
    this.isMobile = false,
  });

  @override
  State<_PreviewContent> createState() => _PreviewContentState();
}

class _PreviewContentState extends State<_PreviewContent> {
  // ── Accordion open/close ──
  bool _headerOpen = true;
  bool _clientOpen = true;
  bool _ownerOpen  = true;

  // ── Form controllers ──
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _salonNameCtrl   = TextEditingController();
  final _salonNameArCtrl = TextEditingController();
  final _subjectCtrl     = TextEditingController();
  final _messageCtrl     = TextEditingController();

  String  _phoneCode         = '+20';
  String  _preferredLanguage = 'ar';
  String? _selectedTargetAudience;
  String? _selectedSalonCountry;
  String? _selectedNoBranches;
  String? _selectedServices;
  String? _selectedClientReason;
  String? _selectedOwnerReason;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _salonNameCtrl.dispose();
    _salonNameArCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  double get _hPad => widget.isMobile ? 16.0 : 30.0;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size:        Size(widget.fakeWidth, widget.fakeHeight),
        padding:     EdgeInsets.zero,
        viewInsets:  EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color: ColorPick.white,
          width: widget.fakeWidth,
          height: widget.fakeHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _headerSection(),
                const SizedBox(height: 16),
                _clientSection(),
                const SizedBox(height: 16),
                _ownerSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _accordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 12),
            decoration: BoxDecoration(
              color: _kPink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 15,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white, size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isOpen) child,
      ],
    );
  }

  // ── Header Section ─────────────────────────────────────────────────────────

  Widget _headerSection() {
    final data     = widget.data;
    final isEn     = widget.isEnglish;
    final title    = isEn
        ? (data.headings.title.en.isNotEmpty ? data.headings.title.en : 'Contact Us')
        : (data.headings.title.ar.isNotEmpty ? data.headings.title.ar : 'تواصل معنا');
    final subtitle = isEn
        ? (data.headings.shortDescription.en.isNotEmpty
        ? data.headings.shortDescription.en
        : 'Your Feedback Shapes Our Success!')
        : (data.headings.shortDescription.ar.isNotEmpty
        ? data.headings.shortDescription.ar
        : 'ملاحظاتك تشكل نجاحنا!');

    return _accordion(
      title:    'Header',
      isOpen:   _headerOpen,
      onToggle: () => setState(() => _headerOpen = !_headerOpen),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: 24),
        decoration: const BoxDecoration(

          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: widget.isMobile ? 80 : 160,
              child: data.headings.svgUrl.isNotEmpty
                  ? SvgPicture.network(data.headings.svgUrl,
                  width: widget.isMobile ? 80 : 160,
                  height: widget.isMobile ? 70 : 140,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) =>
                      Icon(Icons.image_outlined, size: 60, color: _kPink))
                  : SvgPicture.asset('assets/spa_core.svg',
                  width: widget.isMobile ? 80 : 160,
                  height: widget.isMobile ? 70 : 140,
                  fit: BoxFit.contain),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: widget.isMobile ? 18 : 24,
                          fontWeight: FontWeight.w900,
                          color: _kPink)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: widget.isMobile ? 11 : 13,
                          color: Colors.black87,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Client Section ─────────────────────────────────────────────────────────

  Widget _clientSection() {
    final data      = widget.data;
    final isEn      = widget.isEnglish;
    final desc      = isEn
        ? data.clientDescription.description.en
        : data.clientDescription.description.ar;
    final reasons   = data.clientDescription.reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map((r) => {'key': r.id, 'value': isEn ? r.label.en : r.label.ar})
        .toList();

    return _accordion(
      title:    'Client',
      isOpen:   _clientOpen,
      onToggle: () => setState(() => _clientOpen = !_clientOpen),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric( vertical: 24),
        decoration: const BoxDecoration(

          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: widget.isMobile
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(desc,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black87, height: 1.7)),
              ),
            _clientFormCard(reasons),
          ],
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                desc.isNotEmpty ? desc :
                'At Beauty, we firmly believe that feedback is the lifeblood of our success.',
                style: const TextStyle(
                    fontSize: 12, color: Colors.black87, height: 1.7),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: _clientFormCard(reasons)),
          ],
        ),
      ),
    );
  }

  Widget _clientFormCard(List<Map<String, String>> reasons) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: widget.isEnglish ? 'Preferred Language' : 'اللغة المفضلة'),
          const SizedBox(height: 6),
          _langRadioRow(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _previewField('First Name *', _firstNameCtrl, iconPath: 'assets/contact/name.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('Last Name *',  _lastNameCtrl,  iconPath: 'assets/contact/name.svg')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewField('Enter Your Email *', _emailCtrl, iconPath: 'assets/contact/sms.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewPhoneField()),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewDropdown('Gender',
                  _PreviewConst.targetAudienceEn.map((t) => {'key': t, 'value': t}).toList(),
                  null, (_) {}, iconPath: 'assets/contact/Target audience of salon .svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewDropdown('Country',
                  _PreviewConst.countriesEn.map((c) => {'key': c, 'value': c}).toList(),
                  null, (_) {}, iconPath: 'assets/contact/Country of salon.svg')),
            ],
          ),
          _previewField('Subject *', _subjectCtrl, iconPath: 'assets/contact/Subject .svg'),
          if (reasons.isNotEmpty)
            _previewDropdown('Reason', reasons, _selectedClientReason,
                    (v) => setState(() => _selectedClientReason = v),
                iconPath: 'assets/contact/Reason.svg'),
          _previewField('Message *', _messageCtrl,
              iconPath: 'assets/contact/Message.svg', maxLines: 3, fieldHeight: 72),
          const SizedBox(height: 8),
          _sendButton(),
        ],
      ),
    );
  }

  // ── Owner Section ──────────────────────────────────────────────────────────

  Widget _ownerSection() {
    final data    = widget.data;
    final isEn    = widget.isEnglish;
    final desc    = isEn
        ? data.ownerDescription.description.en
        : data.ownerDescription.description.ar;
    final reasons = data.ownerDescription.reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map((r) => {'key': r.id, 'value': isEn ? r.label.en : r.label.ar})
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _hPad),
      child: _accordion(
        title:    'Owner',
        isOpen:   _ownerOpen,
        onToggle: () => setState(() => _ownerOpen = !_ownerOpen),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric( vertical: 24),
          decoration: const BoxDecoration(

            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: widget.isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (desc.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(desc,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87, height: 1.7)),
                ),
              _ownerFormCard(reasons),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  desc.isNotEmpty ? desc :
                  'At Beauty, we firmly believe that feedback is the lifeblood of our success.',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black87, height: 1.7),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _ownerFormCard(reasons)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ownerFormCard(List<Map<String, String>> reasons) {
    final targetItems  = _PreviewConst.targetAudienceEn.map((t) => {'key': t, 'value': t}).toList();
    final countryItems = _PreviewConst.countriesEn.map((c) => {'key': c, 'value': c}).toList();
    final branchItems  = _PreviewConst.noBranchesEn.map((b) => {'key': b, 'value': b}).toList();
    final serviceItems = _PreviewConst.servicesEn.map((s) => {'key': s, 'value': s}).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Personal Info'),
          const SizedBox(height: 6),
          const _FormLabel('Preferred Language'),
          const SizedBox(height: 6),
          _langRadioRow(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _previewField('First Name *', _firstNameCtrl, iconPath: 'assets/contact/name.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('Last Name *',  _lastNameCtrl,  iconPath: 'assets/contact/name.svg')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewField('Enter Your Email *', _emailCtrl, iconPath: 'assets/contact/sms.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewPhoneField()),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'Salon Info'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _previewField('Salon Name *',    _salonNameCtrl,   iconPath: 'assets/contact/salon_name.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('اسم الصالون *',   _salonNameArCtrl, iconPath: 'assets/contact/salon_name.svg',
                  textDirection: TextDirection.rtl, textAlign: TextAlign.right)),
            ],
          ),
          _previewDropdown('Target audience of salon *', targetItems,
              _selectedTargetAudience, (v) => setState(() => _selectedTargetAudience = v),
              iconPath: 'assets/contact/Target audience of salon .svg'),
          Row(
            children: [
              Expanded(child: _previewDropdown('Country of salon', countryItems,
                  _selectedSalonCountry, (v) => setState(() => _selectedSalonCountry = v),
                  iconPath: 'assets/contact/Country of salon.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewField('City of salon', TextEditingController(),
                  iconPath: 'assets/contact/City of salon.svg')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _previewDropdown('No.Branches', branchItems,
                  _selectedNoBranches, (v) => setState(() => _selectedNoBranches = v),
                  iconPath: 'assets/contact/No.Branches.svg')),
              const SizedBox(width: 12),
              Expanded(child: _previewDropdown('Services', serviceItems,
                  _selectedServices, (v) => setState(() => _selectedServices = v),
                  iconPath: 'assets/contact/Services.svg')),
            ],
          ),
          _previewField('Subject *', _subjectCtrl, iconPath: 'assets/contact/Subject .svg'),
          if (reasons.isNotEmpty)
            _previewDropdown('Reason', reasons, _selectedOwnerReason,
                    (v) => setState(() => _selectedOwnerReason = v),
                iconPath: 'assets/contact/Reason.svg'),
          _previewField('Message *', _messageCtrl,
              iconPath: 'assets/contact/Message.svg', maxLines: 3, fieldHeight: 72),
          const SizedBox(height: 8),
          _sendButton(),
        ],
      ),
    );
  }

  // ── Shared widgets ─────────────────────────────────────────────────────────

  Widget _langRadioRow() {
    return Row(
      children: _PreviewConst.preferredLanguages.map((lang) {
        final bool selected = _preferredLanguage == lang;
        final lbl = _PreviewConst.preferredLanguageLabelsEn[lang] ?? lang;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 20),
          child: GestureDetector(
            onTap: () => setState(() => _preferredLanguage = lang),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _kPink : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _kPink),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 5),
                Text(lbl,
                    style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.black87 : Colors.black54)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _previewField(String label, TextEditingController controller, {
    String? iconPath,
    TextDirection textDirection = TextDirection.ltr,
    TextAlign textAlign         = TextAlign.start,
    int maxLines                = 1,
    double fieldHeight          = 32,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w500, color: Color(0xFF333333))),
        const SizedBox(height: 3),
        Container(
          height: fieldHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (iconPath != null)
                Padding(
                  padding: EdgeInsets.only(left: 8, top: maxLines > 1 ? 8 : 0),
                  child: SvgPicture.asset(iconPath,
                      width: 14, height: 14,
                      colorFilter: ColorFilter.mode(
                          Colors.grey.shade400, BlendMode.srcIn),
                      placeholderBuilder: (_) =>
                          Icon(Icons.edit_outlined, size: 14, color: Colors.grey.shade400)),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines:   maxLines,
                  textDirection: textDirection,
                  textAlign:  textAlign,
                  cursorColor: _kPink,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Text Here',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 6, vertical: maxLines > 1 ? 8 : 0),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _previewDropdown(String label, List<Map<String, String>> items,
      String? value, ValueChanged<String?> onChanged, {String? iconPath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 3),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items:         items,
          onChanged:     onChanged,
          width:         double.infinity,
          height:        32,
          borderRadius:  4,
          widthIcon:     14,
          heightIcon:    14,
          iconPath:      iconPath,
          primaryColor:  _kPink,
          hint: Text('Select',
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  color: Colors.grey.shade400)),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _previewPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone Number *',
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w500, color: Color(0xFF333333))),
        const SizedBox(height: 3),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    end: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: CustomDropdownFormFieldInvMaster(
                  selectedValue: _phoneCode,
                  items:         _phoneCodes,
                  onChanged:     (v) => setState(() => _phoneCode = v ?? _phoneCode),
                  widthIcon:     14,
                  heightIcon:    14,
                  width:         100,
                  height:        32,
                  borderRadius:  0,
                  primaryColor:  _kPink,
                  hint: Text('Code',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ),
              ),
              Expanded(
                child: TextField(
                  controller:      _phoneCtrl,
                  keyboardType:    TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor:     _kPink,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  decoration: InputDecoration(
                    hintText:  'Phone Number',
                    hintStyle: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _sendButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: _kPink,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        child: const Text('SEND',
            style: TextStyle(
                color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
