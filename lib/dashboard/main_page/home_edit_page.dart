/// ******************* FILE INFO *******************
/// File Name: home_edit_page.dart
/// Page 2 — "Editing Main Details"
/// UPDATED: Footer column title is now a dropdown populated from nav items.
///          Selecting a nav item auto-fills EN + AR title and sets the route.
///          Each label row now has a destination dropdown (fixed list) plus
///          free-text EN / AR fields.
///          Label map type changed from Map<String,TextEditingController>
///          to Map<String,dynamic> to hold the extra 'route' String? field.
/// FIXED:   _save() now syncs navButtons ORDER to cubit before updating
///          name/status — uses reorderNavButtons() so drag reorder persists.
/// UPDATED: _kLabelDestinations now use /about?tab=... query-param routes
///          so footer links deep-link directly into the correct About Us tab.
/// UPDATED: Removed _isSaving + full-screen overlay. CircularProgressIndicator
///          now shows only inside the publish confirm dialog while saving.
/// UPDATED: "App Link" section replaces "Download the App" — now has
///          Navigation Label (EN/AR), two icon pickers (iOS/Android),
///          and two link fields matching Figma design.
/// UPDATED: Publish now validates all required fields first — sets _submitted
///          to true so CustomValidatedTextFieldMaster shows inline errors.
/// UPDATED: Publish button is disabled until:
///          1. All validation passes
///          2. There are actual changes to save (no unnecessary saves)
/// FIXED:   Removed setState() from build method - added _validateSilent()

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:beauty_admin/core/widget/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:go_router/go_router.dart';

import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/circle_progress.dart';
import 'package:beauty_admin/core/widget/custom_dropdwon.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/appcolors.dart';
import 'package:beauty_admin/theme/app_wight.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';

import '../../../core/custom_dialog.dart';
import '../../controller/home/home_cubit.dart';
import '../../controller/home/home_state.dart';
import '../../model/home/home_model.dart';
import '../../widgets/app_admin_navbar.dart';
import 'home_main_page.dart';
import 'home_preview_page.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
}

// ── Route dropdown used only for nav-section route picker ──────────────────
const List<Map<String, String>> _kRoutes = [
  {'key': '',            'value': 'None'},
  {'key': '/',           'value': 'Home (/)'},
  {'key': '/services',   'value': 'Overview (/services)'},
  {'key': '/about',      'value': 'Our Products (/about)'},
  {'key': '/contact',    'value': 'About Us (/contact)'},
  {'key': '/terms',      'value': 'Terms of Service (/terms)'},
  {'key': '/contactus',  'value': 'Contact Us (/contactus)'},
];

const List<Map<String, String>> _kLabelDestinations = [
  {'key': '',                                    'value': 'None'},
  // ── Main Pages ──────────────────────────────
  {'key': '/',                                   'value': 'Home'},
  {'key': '/services',                           'value': 'Overview'},
  {'key': '/about',                              'value': 'Our Products'},
  {'key': '/contact',                            'value': 'Contact Us'},
  {'key': '/terms',                              'value': 'Terms of Service'},
  // ── Our Products page tabs ──────────────────
  {'key': '/about?tab=client-service',           'value': 'Client Service'},
  {'key': '/about?tab=owner-service',            'value': 'Owner Service'},
  // ── About Us page tabs ──────────────────────
  {'key': '/about?tab=our-strategy',             'value': 'Our Strategy'},
  {'key': '/about?tab=terms-and-conditions',     'value': 'Terms & Conditions'},
  {'key': '/about?tab=privacy-policy',           'value': 'Privacy Policy'},
  {'key': '/about?tab=vision',                   'value': 'Vision'},
  {'key': '/about?tab=mission',                  'value': 'Mission'},
  {'key': '/about?tab=values',                   'value': 'Values'},
  // ── Careers page tabs ───────────────────────
  {'key': '/careers?tab=why-join-our-team',      'value': 'Why Join Our Team'},
  {'key': '/careers?tab=interns',                'value': 'Our Interns'},
  {'key': '/careers?tab=our-team',               'value': 'Our Team'},
];

const List<Map<String, String>> _kFonts = [
  {'key': 'Cairo',     'value': 'Cairo'},
  {'key': 'Roboto',    'value': 'Roboto'},
  {'key': 'Poppins',   'value': 'Poppins'},
  {'key': 'Tajawal',   'value': 'Tajawal'},
  {'key': 'Almarai',   'value': 'Almarai'},
  {'key': 'Noto Sans', 'value': 'Noto Sans'},
];

class _HeaderItem {
  final TextEditingController en;
  final TextEditingController ar;
  bool status;
  final String id;

  _HeaderItem({required this.id})
      : en     = TextEditingController(),
        ar     = TextEditingController(),
        status = true;

  void dispose() {
    en.dispose();
    ar.dispose();
  }
}

class _PickedImage {
  final Uint8List? bytes;
  final String?   url;
  const _PickedImage({this.bytes, this.url});
  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

class _LinkItem {
  final TextEditingController text;
  _PickedImage icon;
  bool visibility;

  _LinkItem()
      : text       = TextEditingController(),
        icon       = const _PickedImage(),
        visibility = true;

  void dispose() { text.dispose(); }
}

// ── Color Picker Field ────────────────────────────────────────────────────────
class _ColorPickerField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final VoidCallback? onColorChanged;

  const _ColorPickerField({
    required this.controller,
    this.label,
    this.hintText = '#008037',
    this.onColorChanged,
  });

  @override
  State<_ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<_ColorPickerField> {
  OverlayEntry? _overlay;
  final LayerLink _layerLink = LayerLink();

  Color get _currentColor {
    try {
      final hex = widget.controller.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  static String _colorToHex(Color c) =>
      '#${c.red.toRadixString(16).padLeft(2, '0')}'
          '${c.green.toRadixString(16).padLeft(2, '0')}'
          '${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  void _openPicker() {
    _closePicker();
    _overlay = OverlayEntry(
      builder: (_) => _ColorWheelOverlay(
        layerLink:    _layerLink,
        initialColor: _currentColor,
        onApply: (color) {
          widget.controller.text = _colorToHex(color);
          // ignore: invalid_use_of_protected_member
          widget.controller.notifyListeners();
          _closePicker();
          if (mounted) setState(() {});
          widget.onColorChanged?.call();
        },
        onClose: _closePicker,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _closePicker() { _overlay?.remove(); _overlay = null; }

  @override
  void dispose() { _closePicker(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!,
              style: StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          SizedBox(height: 5.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: SizedBox(
            height: 36.h,
            child: TextFormField(
              controller: widget.controller,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onChanged: (_) { setState(() {}); widget.onColorChanged?.call(); },
              onTap: _openPicker,
              decoration: InputDecoration(
                hintText:  widget.hintText,
                hintStyle: StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
                filled: true, fillColor: AppColors.card,
                isDense: true, counterText: '',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Container(
                    width: 16.w, height: 16.h,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                enabledBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: BorderSide(color: Color(0xFFD16F9A), width: 1)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: Colors.transparent)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Color Wheel Overlay ───────────────────────────────────────────────────────
class _ColorWheelOverlay extends StatefulWidget {
  final LayerLink layerLink;
  final Color initialColor;
  final ValueChanged<Color> onApply;
  final VoidCallback onClose;

  const _ColorWheelOverlay({
    required this.layerLink,
    required this.initialColor,
    required this.onApply,
    required this.onClose,
  });

  @override
  State<_ColorWheelOverlay> createState() => _ColorWheelOverlayState();
}

class _ColorWheelOverlayState extends State<_ColorWheelOverlay> {
  late Color _picked;

  @override
  void initState() { super.initState(); _picked = widget.initialColor; }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: widget.onClose,
          behavior: HitTestBehavior.translucent,
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ),
      Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: 400.w,
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select Color',
                        style: StyleText.fontSize16Weight600
                            .copyWith(color: _C.labelText)),
                    SizedBox(height: 16.h),
                    LayoutBuilder(builder: (context, constraints) {
                      final double pickerW =
                      (constraints.maxWidth).clamp(200.0, 320.0);
                      return SizedBox(
                        width: pickerW,
                        child: ColorPicker(
                          pickerColor: _picked,
                          onColorChanged: (c) => setState(() => _picked = c),
                          colorPickerWidth: pickerW,
                          pickerAreaHeightPercent: 0.65,
                          enableAlpha: false,
                          displayThumbColor: true,
                          portraitOnly: true,
                          pickerAreaBorderRadius: BorderRadius.circular(8.r),
                          hexInputBar: true,
                          labelTypes: const [],
                        ),
                      );
                    }),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text('Cancel',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: _C.labelText)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => widget.onApply(_picked),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(
                                color: _C.primary,
                                borderRadius: BorderRadius.circular(6.r)),
                            child: Text('Apply',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeEditPage
// ─────────────────────────────────────────────────────────────────────────────
class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});

  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  bool _submitted = false;
  bool _hasChanges = false;

  // ── Headings ──────────────────────────────────────────────────────────────
  final _titleEn     = TextEditingController();
  final _titleAr     = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _shortDescAr = TextEditingController();

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _navBtns = List.of(
    List.generate(3, (_) => {
      'nameEn': TextEditingController(),
      'nameAr': TextEditingController(),
    }),
  );
  final List<String?> _navRoutes = List.of([null, null, null]);
  final List<bool>    _navStatus = List.of([true,  true,  true]);

  // ── Sections 1–4 ──────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _sections =
  List.generate(4, (_) => {
    'textBox':       TextEditingController(text: '#008037'),
    'description':   TextEditingController(),
    'descriptionAr': TextEditingController(),
  });

  final List<Map<String, _PickedImage>> _sectionImages = List.generate(
    4,
        (_) => {'image': const _PickedImage(), 'icon': const _PickedImage()},
  );

  // ── Header titles ─────────────────────────────────────────────────────────
  late final List<_HeaderItem> _headerItems;

  // ── Footer columns ────────────────────────────────────────────────────────
  late final List<Map<String, dynamic>> _footerColumns;

  // ── Social links ──────────────────────────────────────────────────────────
  late final List<_LinkItem> _links;

  // ── Logo ──────────────────────────────────────────────────────────────────
  _PickedImage _logoPicked = const _PickedImage();

  // ── Branding ──────────────────────────────────────────────────────────────
  final _primaryColor      = TextEditingController(text: '#008037');
  final _secondaryColor    = TextEditingController(text: '#D9D9D9');
  final _bgColor           = TextEditingController(text: '#D9D9D9');
  final _headerFooterColor = TextEditingController(text: '#D9D9D9');
  String? _engFont = 'Cairo';
  String? _arFont  = 'Cairo';

  // ── App Link ✅ ───────────────────────────────────────────────────────────
  final _iosUrlCtrl       = TextEditingController();
  final _androidUrlCtrl   = TextEditingController();
  final _appLabelEnCtrl   = TextEditingController();
  final _appLabelArCtrl   = TextEditingController();
  bool  _downloadAppVisibility = true;
  _PickedImage _iosIconPicked     = const _PickedImage();
  _PickedImage _androidIconPicked = const _PickedImage();

  // ── Accordion open/close ──────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'theme': true, 'header': true, 'footer': true, 'links': true,
    'headings': true, 'navBtn': true, 'downloadApp': true,
    's1': true, 's2': true, 's3': true, 's4': true,
  };

  // ── Seed-hash guard ───────────────────────────────────────────────────────
  int? _seededModelHash;

  Color get _resolvedPrimaryColor {
    try {
      final hex = _primaryColor.text.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return _C.primary;
  }

  // ── Helpers: build a nav-items dropdown list from current local state ──────
  List<Map<String, String>> _buildNavDropdownItems() {
    final items = <Map<String, String>>[
      {'key': '', 'value': 'None'},
    ];
    for (var i = 0; i < _navBtns.length; i++) {
      final en    = _navBtns[i]['nameEn']!.text.trim();
      final route = _navRoutes[i] ?? '';
      if (route.isEmpty) continue;
      items.add({'key': route, 'value': en.isNotEmpty ? en : route});
    }
    return items;
  }

  // ─────────────────────────────────────────────────────────────────────────
  late final List<_PickedImage> _navIcons;

  @override
  void initState() {
    super.initState();
    _navIcons = List.generate(3, (_) => const _PickedImage());
    print('[HomeEditPage] ✅ initState');
    _seededModelHash = null;
    _headerItems   = List.generate(5, (i) => _HeaderItem(id: 'hi_$i'));
    _footerColumns = List.generate(3, (_) => _newFooterColumn());
    _links         = List.generate(4, (_) => _LinkItem());

    _setupChangeListeners();
  }

  void _setupChangeListeners() {
    _titleEn.addListener(() => setState(() => _hasChanges = true));
    _titleAr.addListener(() => setState(() => _hasChanges = true));
    _shortDescEn.addListener(() => setState(() => _hasChanges = true));
    _shortDescAr.addListener(() => setState(() => _hasChanges = true));

    for (final btn in _navBtns) {
      btn['nameEn']!.addListener(() => setState(() => _hasChanges = true));
      btn['nameAr']!.addListener(() => setState(() => _hasChanges = true));
    }

    _appLabelEnCtrl.addListener(() => setState(() => _hasChanges = true));
    _appLabelArCtrl.addListener(() => setState(() => _hasChanges = true));
    _iosUrlCtrl.addListener(() => setState(() => _hasChanges = true));
    _androidUrlCtrl.addListener(() => setState(() => _hasChanges = true));

    _primaryColor.addListener(() => setState(() => _hasChanges = true));
    _secondaryColor.addListener(() => setState(() => _hasChanges = true));
    _bgColor.addListener(() => setState(() => _hasChanges = true));
    _headerFooterColor.addListener(() => setState(() => _hasChanges = true));

    for (final item in _headerItems) {
      item.en.addListener(() => setState(() => _hasChanges = true));
      item.ar.addListener(() => setState(() => _hasChanges = true));
    }

    for (final col in _footerColumns) {
      (col['titleEn'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
      (col['titleAr'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        (label['en'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
        (label['ar'] as TextEditingController).addListener(() => setState(() => _hasChanges = true));
      }
    }

    for (final link in _links) {
      link.text.addListener(() => setState(() => _hasChanges = true));
    }
  }

  Future<_PickedImage?> _pickImage() async {
    print('[HomeEditPage] _pickImage: opening file picker');
    final completer = Completer<_PickedImage?>();
    bool completed  = false;

    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        print('[HomeEditPage] _pickImage: no file selected');
        if (!completed) { completed = true; completer.complete(null); }
        return;
      }
      final file = files.first;
      print('[HomeEditPage] _pickImage: file="${file.name}" type="${file.type}"');

      if (!file.name.toLowerCase().endsWith('.svg') &&
          file.type != 'image/svg+xml') {
        print('[HomeEditPage] _pickImage: ❌ rejected — not SVG');
        if (!completed) {
          completed = true;
          completer.complete(null);
          if (mounted) {

          }
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!completed) {
          completed = true;
          if (result is List<int>) {
            print('[HomeEditPage] _pickImage: ✅ read ${result.length} bytes');
            completer.complete(
                _PickedImage(bytes: Uint8List.fromList(result)));
          } else {
            print('[HomeEditPage] _pickImage: ❌ unexpected result type');
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) {
        print('[HomeEditPage] _pickImage: ❌ FileReader error');
        if (!completed) { completed = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(file);
    });

    input.click();

    Future.delayed(const Duration(minutes: 5), () {
      if (!completed) {
        print('[HomeEditPage] _pickImage: ⏰ TIMEOUT');
        completed = true;
        completer.complete(null);
      }
    });

    return completer.future;
  }

  void _seedFromModel(HomePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl),
      ...d.socialLinks.map((s) => s.iconUrl),
      d.branding.logoUrl,
      d.appDownloadLinks.iosUrl,
      d.appDownloadLinks.androidUrl,
      d.appDownloadLinks.labelEn,
      d.appDownloadLinks.labelAr,
      d.appDownloadLinks.iosIconUrl,
      d.appDownloadLinks.androidIconUrl,
    ]);

    print('[HomeEditPage] _seedFromModel: '
        'newHash=$modelHash cachedHash=$_seededModelHash');

    if (_seededModelHash == modelHash) {
      print('[HomeEditPage] _seedFromModel: hash UNCHANGED — skip');
      return;
    }
    _seededModelHash = modelHash;
    print('[HomeEditPage] _seedFromModel: ▶ seeding from model '
        '(navButtons=${d.navButtons.length})');

    _titleEn.text     = d.title.en;
    _titleAr.text     = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    print('[HomeEditPage] _seedFromModel: syncing navBtns '
        'local=${_navBtns.length} server=${d.navButtons.length}');

    while (_navBtns.length > d.navButtons.length) {
      final removed = _navBtns.removeLast();
      removed['nameEn']!.dispose();
      removed['nameAr']!.dispose();
      _navRoutes.removeLast();
      _navStatus.removeLast();
    }
    while (_navBtns.length < d.navButtons.length) {
      _navBtns.add({
        'nameEn': TextEditingController(),
        'nameAr': TextEditingController(),
      });
      _navRoutes.add(null);
      _navStatus.add(true);
    }

    for (var i = 0; i < d.navButtons.length; i++) {
      _navBtns[i]['nameEn']!.text = d.navButtons[i].name.en;
      _navBtns[i]['nameAr']!.text = d.navButtons[i].name.ar;
      _navRoutes[i] =
      d.navButtons[i].route.isEmpty ? null : d.navButtons[i].route;
      _navStatus[i] = d.navButtons[i].status;
    }

    while (_navIcons.length > d.navButtons.length) _navIcons.removeLast();
    while (_navIcons.length < d.navButtons.length) _navIcons.add(const _PickedImage());

    for (var i = 0; i < d.navButtons.length; i++) {
      _navIcons[i] = d.navButtons[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.navButtons[i].iconUrl)
          : const _PickedImage();
    }

    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i]['textBox']!.text       = d.sections[i].textBoxColor;
      _sections[i]['description']!.text   = d.sections[i].description.en;
      _sections[i]['descriptionAr']!.text = d.sections[i].description.ar;
      _sectionImages[i]['image'] = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl)
          : const _PickedImage();
      _sectionImages[i]['icon'] = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl)
          : const _PickedImage();
    }

    for (var i = 0;
    i < _headerItems.length && i < d.headerItems.length;
    i++) {
      _headerItems[i].en.text = d.headerItems[i].title.en;
      _headerItems[i].ar.text = d.headerItems[i].title.ar;
      _headerItems[i].status  = d.headerItems[i].status;
    }

    while (_footerColumns.length > d.footerColumns.length) {
      final removed = _footerColumns.removeLast();
      _disposeColumn(removed);
    }
    while (_footerColumns.length < d.footerColumns.length) {
      _footerColumns.add(_newFooterColumn());
    }
    for (var i = 0; i < d.footerColumns.length; i++) {
      (_footerColumns[i]['titleEn'] as TextEditingController).text =
          d.footerColumns[i].title.en;
      (_footerColumns[i]['titleAr'] as TextEditingController).text =
          d.footerColumns[i].title.ar;
      _footerColumns[i]['route'] =
      d.footerColumns[i].route.isEmpty ? null : d.footerColumns[i].route;

      final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
      while (labels.length > d.footerColumns[i].labels.length) {
        _disposeLabel(labels.removeLast());
      }
      while (labels.length < d.footerColumns[i].labels.length) {
        labels.add(_newLabelRow());
      }
      for (var li = 0; li < d.footerColumns[i].labels.length; li++) {
        (labels[li]['en'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.en;
        (labels[li]['ar'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.ar;
        labels[li]['route'] = d.footerColumns[i].labels[li].route.isEmpty
            ? null
            : d.footerColumns[i].labels[li].route;
      }
    }

    while (_links.length > d.socialLinks.length) _links.removeLast().dispose();
    while (_links.length < d.socialLinks.length) _links.add(_LinkItem());
    for (var i = 0; i < d.socialLinks.length; i++) {
      _links[i].text.text = d.socialLinks[i].url;
      _links[i].icon = d.socialLinks[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.socialLinks[i].iconUrl)
          : const _PickedImage();
      _links[i].visibility = d.socialLinks[i].visibility;
    }

    _primaryColor.text = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _bgColor.text = d.branding.backgroundColor.isNotEmpty
        ? d.branding.backgroundColor
        : '#D9D9D9';
    _headerFooterColor.text = d.branding.headerFooterColor.isNotEmpty
        ? d.branding.headerFooterColor
        : '#D9D9D9';
    _engFont =
    d.branding.englishFont.isEmpty ? 'Cairo' : d.branding.englishFont;
    _arFont =
    d.branding.arabicFont.isEmpty ? 'Cairo' : d.branding.arabicFont;
    _logoPicked = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl)
        : const _PickedImage();

    _iosUrlCtrl.text          = d.appDownloadLinks.iosUrl;
    _androidUrlCtrl.text      = d.appDownloadLinks.androidUrl;
    _appLabelEnCtrl.text      = d.appDownloadLinks.labelEn;
    _appLabelArCtrl.text      = d.appDownloadLinks.labelAr;
    _downloadAppVisibility    = d.appDownloadLinks.visibility;
    _iosIconPicked = d.appDownloadLinks.iosIconUrl.isNotEmpty
        ? _PickedImage(url: d.appDownloadLinks.iosIconUrl)
        : const _PickedImage();
    _androidIconPicked = d.appDownloadLinks.androidIconUrl.isNotEmpty
        ? _PickedImage(url: d.appDownloadLinks.androidIconUrl)
        : const _PickedImage();

    _hasChanges = false;

    print('[HomeEditPage] _seedFromModel: ✅ DONE');
  }

  Map<String, dynamic> _newFooterColumn() => {
    'titleEn': TextEditingController(),
    'titleAr': TextEditingController(),
    'route':   null as String?,
    'labels':  <Map<String, dynamic>>[_newLabelRow()],
  };

  Map<String, dynamic> _newLabelRow() => {
    'en':    TextEditingController(),
    'ar':    TextEditingController(),
    'route': null as String?,
  };

  void _disposeColumn(Map<String, dynamic> col) {
    (col['titleEn'] as TextEditingController).dispose();
    (col['titleAr'] as TextEditingController).dispose();
    for (final l in col['labels'] as List<Map<String, dynamic>>) {
      _disposeLabel(l);
    }
  }

  void _disposeLabel(Map<String, dynamic> label) {
    (label['en'] as TextEditingController).dispose();
    (label['ar'] as TextEditingController).dispose();
  }

  @override
  void dispose() {
    print('[HomeEditPage] 🔴 dispose');
    _titleEn.dispose();
    _titleAr.dispose();
    _shortDescEn.dispose();
    _shortDescAr.dispose();
    for (final m in _navBtns) {
      for (final c in m.values) c.dispose();
    }
    for (final m in _sections) {
      for (final c in m.values) c.dispose();
    }
    for (final item in _headerItems) item.dispose();
    for (final col in _footerColumns) _disposeColumn(col);
    for (final link in _links) link.dispose();
    _primaryColor.dispose();
    _secondaryColor.dispose();
    _bgColor.dispose();
    _headerFooterColor.dispose();
    _iosUrlCtrl.dispose();
    _androidUrlCtrl.dispose();
    _appLabelEnCtrl.dispose();
    _appLabelArCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() => _submitted = true);

    for (var i = 0; i < _navBtns.length; i++) {
      if (_navBtns[i]['nameEn']!.text.trim().isEmpty) return false;
      if (_navBtns[i]['nameAr']!.text.trim().isEmpty) return false;
    }

    for (final col in _footerColumns) {
      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        if ((label['en'] as TextEditingController).text.trim().isEmpty) return false;
        if ((label['ar'] as TextEditingController).text.trim().isEmpty) return false;
      }
    }

    for (final link in _links) {
      if (link.text.text.trim().isEmpty) return false;
    }

    if (_appLabelEnCtrl.text.trim().isEmpty) return false;
    if (_appLabelArCtrl.text.trim().isEmpty) return false;
    if (_iosUrlCtrl.text.trim().isEmpty) return false;
    if (_androidUrlCtrl.text.trim().isEmpty) return false;

    return true;
  }

  // ← NEW: Silent validation without setState for build method
  bool _validateSilent() {
    for (var i = 0; i < _navBtns.length; i++) {
      if (_navBtns[i]['nameEn']!.text.trim().isEmpty) return false;
      if (_navBtns[i]['nameAr']!.text.trim().isEmpty) return false;
    }

    for (final col in _footerColumns) {
      final labels = col['labels'] as List<Map<String, dynamic>>;
      for (final label in labels) {
        if ((label['en'] as TextEditingController).text.trim().isEmpty) return false;
        if ((label['ar'] as TextEditingController).text.trim().isEmpty) return false;
      }
    }

    for (final link in _links) {
      if (link.text.text.trim().isEmpty) return false;
    }

    if (_appLabelEnCtrl.text.trim().isEmpty) return false;
    if (_appLabelArCtrl.text.trim().isEmpty) return false;
    if (_iosUrlCtrl.text.trim().isEmpty) return false;
    if (_androidUrlCtrl.text.trim().isEmpty) return false;

    return true;
  }

  Future<void> _save(HomeCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    setState(() => _submitted = true);

    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(en: _shortDescEn.text, ar: _shortDescAr.text);

      final snapshot = List<NavButtonModel>.from(cubit.current.navButtons);
      final routeToId = { for (final b in snapshot) b.route: b.id };

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        if (localRoute.isEmpty) continue;

        final currentIndex = cubit.current.navButtons
            .indexWhere((b) => b.route == localRoute);
        if (currentIndex != -1 && currentIndex != i) {
          cubit.reorderNavButtonsSilent(currentIndex, i);
        }
      }

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute  = _navRoutes[i] ?? '';
        final id          = routeToId[localRoute];
        if (id == null) continue;

        cubit.updateNavButtonName(id,
            en: _navBtns[i]['nameEn']!.text,
            ar: _navBtns[i]['nameAr']!.text);
        cubit.updateNavButtonRoute(id, localRoute);

        if (_navIcons[i].bytes != null) {
          await cubit.uploadNavButtonIcon(id, _navIcons[i].bytes!);
        }

        final modelStatus = cubit.current.navButtons
            .firstWhere((b) => b.id == id,
            orElse: () => NavButtonModel(id: id))
            .status;
        if (modelStatus != _navStatus[i]) {
          cubit.toggleNavButtonStatus(id);
        }
      }
      //
      // for (var i = 0; i < _sections.length; i++) {
      //   cubit.updateSectionTextBoxColor(i, _sections[i]['textBox']!.text);
      //   cubit.updateSectionDescription(i,
      //       en: _sections[i]['description']!.text,
      //       ar: _sections[i]['descriptionAr']!.text);
      //   final img  = _sectionImages[i]['image']!;
      //   final icon = _sectionImages[i]['icon']!;
      //   if (img.bytes  != null) await cubit.uploadSectionImage(i, img.bytes!);
      //   if (icon.bytes != null) await cubit.uploadSectionIcon(i, icon.bytes!);
      // }

      // final currentModel = cubit.current;
      // for (var i = 0; i < _headerItems.length; i++) {
      //   if (i < currentModel.headerItems.length) {
      //     final id = currentModel.headerItems[i].id;
      //     cubit.updateHeaderItemTitle(id,
      //         en: _headerItems[i].en.text,
      //         ar: _headerItems[i].ar.text);
      //     if (currentModel.headerItems[i].status != _headerItems[i].status) {
      //       cubit.toggleHeaderItemStatus(id);
      //     }
      //   }
      // }

      while (cubit.current.footerColumns.length < _footerColumns.length) {
        cubit.addFooterColumn();
      }
      while (cubit.current.footerColumns.length > _footerColumns.length) {
        cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
      }
      for (var i = 0; i < _footerColumns.length; i++) {
        final colId = cubit.current.footerColumns[i].id;
        cubit.updateFooterColumnTitle(colId,
            en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
            ar: (_footerColumns[i]['titleAr'] as TextEditingController).text);
        cubit.updateFooterColumnRoute(
            colId, _footerColumns[i]['route'] as String? ?? '');

        final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
        while (cubit.current.footerColumns[i].labels.length < labels.length) {
          cubit.addFooterLabel(colId);
        }
        while (cubit.current.footerColumns[i].labels.length > labels.length) {
          cubit.removeFooterLabel(
              colId, cubit.current.footerColumns[i].labels.last.id);
        }
        for (var li = 0; li < labels.length; li++) {
          final lblId    = cubit.current.footerColumns[i].labels[li].id;
          final lblRoute = (labels[li]['route'] as String?) ?? '';
          cubit.updateFooterLabel(colId, lblId,
              en: (labels[li]['en'] as TextEditingController).text,
              ar: (labels[li]['ar'] as TextEditingController).text);
          cubit.updateFooterLabelRoute(colId, lblId, lblRoute);
        }
      }

      while (cubit.current.socialLinks.length < _links.length) {
        cubit.addSocialLink();
      }
      while (cubit.current.socialLinks.length > _links.length) {
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      }
      for (var i = 0; i < _links.length; i++) {
        final id = cubit.current.socialLinks[i].id;
        cubit.updateSocialLink(id,
            url:        _links[i].text.text,
            visibility: _links[i].visibility);
        if (_links[i].icon.bytes != null) {
          await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
        }
      }

      if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateBackgroundColor(_bgColor.text);
      cubit.updateHeaderFooterColor(_headerFooterColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont  ?? 'Cairo');

      cubit.updateAppDownloadLinks(
        iosUrl:         _iosUrlCtrl.text,
        androidUrl:     _androidUrlCtrl.text,
        labelEn:        _appLabelEnCtrl.text,
        labelAr:        _appLabelArCtrl.text,
        visibility:     _downloadAppVisibility,
      );
      if (_iosIconPicked.bytes != null) {
        await cubit.uploadAppLinkIcon('ios', _iosIconPicked.bytes!);
      }
      if (_androidIconPicked.bytes != null) {
        await cubit.uploadAppLinkIcon('android', _androidIconPicked.bytes!);
      }

      await cubit.save(publishStatus: publishStatus);

      _hasChanges = false;

      Get.forceAppUpdate();
      html.window.location.reload();
    } catch (e, st) {
      print('[HomeEditPage] _save: ❌ ERROR: $e\n$st');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        print('[HomeEditPage] 👂 listener: ${state.runtimeType}');

        if (state is HomeCmsSaved) {
          print('[HomeEditPage] listener: HomeCmsSaved — '
              '✅ NOT re-seeding (preserves local toggle state)');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Home page saved!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
        }

        if (state is HomeCmsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        print('[HomeEditPage] 🔨 builder: ${state.runtimeType}');

        if (state is HomeCmsLoaded) {
          _seedFromModel(state.data);
        }

        final cubit = context.read<HomeCmsCubit>();

        if (state is HomeCmsInitial || state is HomeCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.sectionBg,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        // ← FIXED: Use _validateSilent() instead of _validate() to avoid setState during build
        final bool isFormValid = _validateSilent();
        final bool canPublish = isFormValid && _hasChanges;

        return Scaffold(
          backgroundColor: _C.back,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: Container(
                      width: 1000.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppAdminNavbar(
                            activeLabel: 'Web Page',
                            homePage: HomeMainPage(),
                            webPage: HomeMainPage(),
                            jobListingPage: HomeMainPage(),
                          ),
                          SizedBox(width: 20.w),
                          AdminSubNavBar(activeIndex: 0),
                          SizedBox(
                            width: 1050.w,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                   vertical: 20.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Editing Main Details',
                                    style: StyleText.fontSize45Weight600.copyWith(
                                      color: _C.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),

                                  _accordion(
                                      key: 'theme',
                                      title: 'Theme and Logo',
                                      children: [_logoAndBrandingSection()]),
                                  _gap(),

                                  _navSection(),
                                  _gap(),

                                  _footerSection(cubit),
                                  _gap(),

                                  _appLinkSection(),
                                  _gap(),

                                  _linksSection(),
                                  _gap(),

                                  _bottomActions(cubit, canPublish),
                                  _gap(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            height: 44.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF797979),
                                              borderRadius: BorderRadius.circular(6.r),
                                            ),
                                            child: Center(
                                              child: Text('Discard',
                                                  style: StyleText.fontSize14Weight600
                                                      .copyWith(color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15.sp),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomActions(HomeCmsCubit cubit, bool canPublish) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final cubit = context.read<HomeCmsCubit>();

            // ── Branding ──────────────────────────────────────────────
            if (_logoPicked.bytes != null) await cubit.uploadLogo(_logoPicked.bytes!);
            cubit.updatePrimaryColor(_primaryColor.text);
            cubit.updateSecondaryColor(_secondaryColor.text);
            cubit.updateBackgroundColor(_bgColor.text);
            cubit.updateHeaderFooterColor(_headerFooterColor.text);
            cubit.updateEnglishFont(_engFont ?? 'Cairo');
            cubit.updateArabicFont(_arFont ?? 'Cairo');

            // ── Nav Buttons ───────────────────────────────────────────
            final snapshot = List<NavButtonModel>.from(cubit.current.navButtons);
            final routeToId = {for (final b in snapshot) b.route: b.id};
            for (var i = 0; i < _navBtns.length; i++) {
              final localRoute = _navRoutes[i] ?? '';
              if (localRoute.isEmpty) continue;
              final id = routeToId[localRoute];
              if (id == null) continue;
              cubit.updateNavButtonName(id,
                  en: _navBtns[i]['nameEn']!.text,
                  ar: _navBtns[i]['nameAr']!.text);
              cubit.updateNavButtonRoute(id, localRoute);
              if (_navIcons[i].bytes != null) {
                await cubit.uploadNavButtonIcon(id, _navIcons[i].bytes!);
              }
              final modelStatus = cubit.current.navButtons
                  .firstWhere((b) => b.id == id, orElse: () => NavButtonModel(id: id))
                  .status;
              if (modelStatus != _navStatus[i]) cubit.toggleNavButtonStatus(id);
            }

            // ── Footer Columns ────────────────────────────────────────
            while (cubit.current.footerColumns.length < _footerColumns.length) {
              cubit.addFooterColumn();
            }
            while (cubit.current.footerColumns.length > _footerColumns.length) {
              cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
            }
            for (var i = 0; i < _footerColumns.length; i++) {
              final colId = cubit.current.footerColumns[i].id;
              cubit.updateFooterColumnTitle(colId,
                  en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
                  ar: (_footerColumns[i]['titleAr'] as TextEditingController).text);
              cubit.updateFooterColumnRoute(
                  colId, _footerColumns[i]['route'] as String? ?? '');
              final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
              while (cubit.current.footerColumns[i].labels.length < labels.length) {
                cubit.addFooterLabel(colId);
              }
              while (cubit.current.footerColumns[i].labels.length > labels.length) {
                cubit.removeFooterLabel(
                    colId, cubit.current.footerColumns[i].labels.last.id);
              }
              for (var li = 0; li < labels.length; li++) {
                final lblId = cubit.current.footerColumns[i].labels[li].id;
                cubit.updateFooterLabel(colId, lblId,
                    en: (labels[li]['en'] as TextEditingController).text,
                    ar: (labels[li]['ar'] as TextEditingController).text);
                cubit.updateFooterLabelRoute(
                    colId, lblId, (labels[li]['route'] as String?) ?? '');
              }
            }

            // ── Social Links ──────────────────────────────────────────
            while (cubit.current.socialLinks.length < _links.length) {
              cubit.addSocialLink();
            }
            while (cubit.current.socialLinks.length > _links.length) {
              cubit.removeSocialLink(cubit.current.socialLinks.last.id);
            }
            for (var i = 0; i < _links.length; i++) {
              final id = cubit.current.socialLinks[i].id;
              cubit.updateSocialLink(id,
                  url: _links[i].text.text,
                  visibility: _links[i].visibility);
              if (_links[i].icon.bytes != null) {
                await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
              }
            }

            // ── App Link ──────────────────────────────────────────────
            if (_iosIconPicked.bytes != null) {
              await cubit.uploadAppLinkIcon('ios', _iosIconPicked.bytes!);
            }
            if (_androidIconPicked.bytes != null) {
              await cubit.uploadAppLinkIcon('android', _androidIconPicked.bytes!);
            }
            cubit.updateAppDownloadLinks(
              iosUrl:     _iosUrlCtrl.text,
              androidUrl: _androidUrlCtrl.text,
              labelEn:    _appLabelEnCtrl.text,
              labelAr:    _appLabelArCtrl.text,
              visibility: _downloadAppVisibility,
            );

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePreviewPage()),
            );
          },
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text('Preview',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
      SizedBox(width: 16.w),
      Expanded(
        child: GestureDetector(
          onTap: canPublish
              ? () {
            if (!_validate()) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please fill in all required fields before publishing.',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: Colors.white)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ));
              return;
            }
            showPublishConfirmDialog(
              context: context,
              onConfirm: () => _save(cubit, publishStatus: 'published'),
            );
          }
              : null,
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: canPublish ? _C.primary : _C.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                'Publish',
                style: StyleText.fontSize14Weight600
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _gap() => SizedBox(height: 10.h);

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(8.r)
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomSvg(
                    assetPath: 'assets/arrowdown.svg',
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.scaleDown,
                    color: Colors.white,
                  ),
                ),
              ]),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  Widget _logoAndBrandingSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      _sectionLabel('Logo'),
      SizedBox(height: 6.h),
      _imgBox(
        picked: _logoPicked,
        placeholderAsset: 'assets/home_control/image.svg',
        pickIconAsset: 'assets/control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _logoPicked = p);
        },
      ),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _primaryColor,
            label: 'Primary Color',
            hintText: '#008037',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _secondaryColor,
            label: 'Secondary',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _bgColor,
            label: 'Background',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _headerFooterColor,
            label: 'Header and Footer',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'English Font',
          primaryColor: _resolvedPrimaryColor,
          hint: Text('Select font',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText)),
          selectedValue: _engFont,
          dropdownColor: Colors.white,
          borderRadius: 4.r,
          items: _kFonts,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _engFont = val),
        )),
        SizedBox(width: 16.w),
        Expanded(child: CustomDropdownFormFieldInvMaster(
          label: 'Arabic Font',
          primaryColor: _resolvedPrimaryColor,
          hint: Text('Select font',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: _C.hintText)),
          selectedValue: _arFont,
          dropdownColor: Colors.white,
          items: _kFonts,
          borderRadius: 4.r,
          widthIcon: 18, heightIcon: 18, height: 36,
          onChanged: (val) => setState(() => _arFont = val),
        )),
      ]),
    ],
  );

  Widget _navSection() {
    final isOpen = _open['navBtn'] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['navBtn'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Header',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CustomSvg(
                  assetPath: 'assets/arrowdown.svg',
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.scaleDown,
                  color: Colors.white,
                ),
              ),
            ]),
          ),
        ),
        if (isOpen)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _navBtns.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final btn    = _navBtns.removeAt(oldIndex);
                final route  = _navRoutes.removeAt(oldIndex);
                final status = _navStatus.removeAt(oldIndex);
                final icon   = _navIcons.removeAt(oldIndex);
                _navBtns.insert(newIndex, btn);
                _navRoutes.insert(newIndex, route);
                _navStatus.insert(newIndex, status);
                _navIcons.insert(newIndex, icon);
                _hasChanges = true;
              });
            },
            itemBuilder: (context, i) =>
                _buildNavItemRow(key: ValueKey('nav_$i'), index: i),
          ),
      ]),
    );
  }

  Widget _buildNavItemRow({required Key key, required int index}) {
    final nameEnCtrl = _navBtns[index]['nameEn']!;
    final nameArCtrl = _navBtns[index]['nameAr']!;

    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: index == 0 ? 15.h : 0.h),
          _sectionLabel('Icon'),
          SizedBox(height: 6.h),
          _imgBox(
            picked: _navIcons[index],
            placeholderAsset: 'assets/control/edit_icon_pick.svg',
            pickIconAsset: 'assets/control/camera.svg',
            onPick: () async {
              final p = await _pickImage();
              if (p != null) {
                setState(() => _navIcons[index] = p);
                _hasChanges = true;
              }
            },
          ),
          SizedBox(height: 10.h),

          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h, right: 0.w),
                      child: Icon(Icons.menu_rounded,
                          size: 20.sp, color: _C.hintText),
                    ),
                  ),
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      label: 'Title',
                      fillColor: Colors.white,
                      labelTrailing: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Status ',
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: _C.labelText)),
                          FlutterSwitch(
                            width: 38.sp,
                            height: 22.sp,
                            padding: 3.sp,
                            borderRadius: 20.sp,
                            toggleSize: 16.sp,
                            activeColor: _C.primary,
                            inactiveColor: Colors.grey.withOpacity(.16),
                            value: _navStatus[index],
                            onToggle: (val) {
                              setState(() => _navStatus[index] = val);
                              _hasChanges = true;
                            },
                          ),
                        ],
                      ),
                      hint: 'Home',
                      controller: nameEnCtrl,
                      height: 36,
                      submitted: _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      primaryColor: _resolvedPrimaryColor,
                      onChanged: (value) => _hasChanges = true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomValidatedTextFieldMaster(
                        label: 'العنوان',
                        fillColor: Colors.white,
                        hint: 'الرئيسية',
                        controller: nameArCtrl,
                        height: 36,
                        submitted: _submitted,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        primaryColor: _resolvedPrimaryColor,
                        onChanged: (value) => _hasChanges = true,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _headerSection() {
    final isOpen = _open['header'] ?? true;
    return Container(
      decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['header'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: isOpen
                  ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r))
                  : BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Header Titles',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20.sp),
            ]),
          ),
        ),
        if (isOpen)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _headerItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _headerItems.removeAt(oldIndex);
                  _headerItems.insert(newIndex, item);
                  _hasChanges = true;
                });
              },
              itemBuilder: (context, i) => _buildHeaderRow(
                  key: ValueKey(_headerItems[i]),
                  index: i,
                  item: _headerItems[i]),
            ),
          ),
      ]),
    );
  }

  Widget _buildHeaderRow({
    required Key key,
    required int index,
    required _HeaderItem item,
  }) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Status: ',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: _C.labelText)),
              FlutterSwitch(
                width: 38.sp,
                height: 22.sp,
                padding: 3.sp,
                borderRadius: 20.sp,
                toggleSize: 16.sp,
                activeColor: _C.primary,
                inactiveColor: Colors.grey.withOpacity(.16),
                value: item.status,
                onToggle: (val) {
                  setState(() => item.status = val);
                  _hasChanges = true;
                },
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 20.sp, color: _C.hintText),
                ),
              ),
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Title',
                  hint: 'None',
                  fillColor: Colors.white,
                  controller: item.en,
                  height: 36,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  primaryColor: _resolvedPrimaryColor,
                  onChanged: (value) => _hasChanges = true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'العنوان',
                    fillColor: Colors.white,
                    hint: 'اكتب هنا',
                    controller: item.ar,
                    height: 36,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    primaryColor: _resolvedPrimaryColor,
                    onChanged: (value) => _hasChanges = true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerSection(HomeCmsCubit cubit) => _accordion(
    key: 'footer',
    title: 'Footer',
    children: [
      ...List.generate(_footerColumns.length, (i) => _buildFooterColumn(i)),
      SizedBox(height: 4.h),
      if (_footerColumns.length < 6)
        GestureDetector(
          onTap: () {
            print('🟢 [Footer] addColumn tapped: '
                'currentColumns=${_footerColumns.length}  max=6');
            setState(() {
              _footerColumns.add(_newFooterColumn());
              _hasChanges = true;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
                color: const Color(0xFF797979),
                borderRadius: BorderRadius.circular(4.r)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 14.sp, color: Colors.white),
              SizedBox(width: 4.w),
              Text('Column',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: Colors.white)),
            ]),
          ),
        )
      else
        Builder(builder: (_) {
          print('🔴 [Footer] addColumn HIDDEN: '
              'columns=${_footerColumns.length} >= 6');
          return const SizedBox();
        }),
    ],
  );

  Widget _buildFooterColumn(int colIndex) {
    final col    = _footerColumns[colIndex];
    final labels = col['labels'] as List<Map<String, dynamic>>;
    final navDropdownItems = _buildNavDropdownItems();

    // 🟡 DEBUG
    print('🟡 [Footer] buildFooterColumn: colIndex=$colIndex  '
        'totalColumns=${_footerColumns.length}  '
        'labelsCount=${labels.length}');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 15.h),
      if (colIndex > 0) ...[
        Divider(color: _C.divider, height: 1),
        SizedBox(height: 12.h),
      ],

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${colIndex + 1}${_ord(colIndex + 1)} Column',
              style: StyleText.fontSize15Weight600
                  .copyWith(color: _C.labelText)),
          _removeBtn(
              label: 'Remove',
              onTap: () => setState(() {
                final removed = _footerColumns.removeAt(colIndex);
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _disposeColumn(removed));
                _hasChanges = true;
              })),
        ],
      ),
      SizedBox(height: 8.h),

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: CustomDropdownFormFieldInvMaster(
              label: 'Group Title',
              primaryColor: _resolvedPrimaryColor,
              hint: Text('Select navigation item',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.hintText)),
              selectedValue: col['route'] as String?,
              items: navDropdownItems,
              widthIcon: 18,
              heightIcon: 18,
              dropdownColor: Colors.white,
              height: 36,
              onChanged: (val) {
                setState(() {
                  col['route'] = val;
                  if (val != null && val.isNotEmpty) {
                    final idx = _navRoutes.indexOf(val);
                    if (idx != -1) {
                      (col['titleEn'] as TextEditingController).text =
                          _navBtns[idx]['nameEn']!.text;
                      (col['titleAr'] as TextEditingController).text =
                          _navBtns[idx]['nameAr']!.text;
                    }
                  } else {
                    (col['titleEn'] as TextEditingController).clear();
                    (col['titleAr'] as TextEditingController).clear();
                  }
                  _hasChanges = true;
                });
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 1,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("عنوان المجموعة",
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 36.h,
                    child: TextFormField(
                      controller: col['titleAr'] as TextEditingController,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: _C.labelText),
                      decoration: InputDecoration(
                        hintText: 'الاسم بالعربي',
                        hintStyle: StyleText.fontSize12Weight400
                            .copyWith(color: _C.hintText),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                            const BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                            BorderSide(color: AppColors.primary, width: 1)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                            const BorderSide(color: Colors.transparent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),

      ...List.generate(labels.length, (li) => _buildLabelRow(colIndex, li)),
      SizedBox(height: 4.h),

      if (labels.length < 4)
        _addLabelBtn(onTap: () {
          print('🟢 [Footer] addLabel tapped: colIndex=$colIndex  '
              'currentLabels=${labels.length}  max=4');
          setState(() {
            labels.add(_newLabelRow());
            _hasChanges = true;
          });
        })
      else
        Builder(builder: (_) {
          print('🔴 [Footer] addLabel HIDDEN: colIndex=$colIndex  '
              'labelsCount=${labels.length} >= 4');
          return const SizedBox();
        }),

      SizedBox(height: 12.h),
    ]);
  }

  Widget _buildLabelRow(int colIndex, int labelIndex) {
    final labels =
    _footerColumns[colIndex]['labels'] as List<Map<String, dynamic>>;
    final label = labels[labelIndex];

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDropdownFormFieldInvMaster(
                        label: 'Navigate To',
                        primaryColor: _resolvedPrimaryColor,
                        hint: Text('Select destination',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: _C.hintText)),
                        selectedValue: label['route'] as String?,
                        items: _kLabelDestinations,
                        dropdownColor: Colors.white,
                        widthIcon: 18,
                        labelTrailing: GestureDetector(
                          onTap: () => setState(() {
                            final removed = labels.removeAt(labelIndex);
                            WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _disposeLabel(removed));
                            _hasChanges = true;
                          }),
                          child: Container(
                            width: 16.w,
                            height: 16.h,
                            decoration: const BoxDecoration(
                                color: _C.remove, shape: BoxShape.circle),
                            child: Icon(Icons.remove,
                                color: Colors.white, size: 16.sp),
                          ),
                        ),
                        heightIcon: 18,
                        borderRadius: 4.r,
                        height: 36,
                        onChanged: (val) {
                          setState(() => label['route'] = val);
                          _hasChanges = true;
                        },
                      ),
                    ),

                    SizedBox(width: 4.w),
                  ],
                ),
              ),
              SizedBox(width: 0.sp),
              Expanded(child: Container()),
            ],
          ),
          SizedBox(height: 8.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  label: 'Label',
                  hint: 'Text Here',
                  controller: label['en'] as TextEditingController,
                  height: 36,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  fillColor: Colors.white,
                  primaryColor: _resolvedPrimaryColor,
                  onChanged: (value) => _hasChanges = true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomValidatedTextFieldMaster(
                    label: 'التسمية',
                    fillColor: Colors.white,
                    hint: 'أدخل النص هنا',
                    controller: label['ar'] as TextEditingController,
                    height: 36,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    primaryColor: _resolvedPrimaryColor,
                    onChanged: (value) => _hasChanges = true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appLinkSection() => _accordion(
    key: 'downloadApp',
    title: 'App Link',
    children: [
      Padding(
        padding: EdgeInsets.symmetric( vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: 'Navigation Label',
                    fillColor: Colors.white,
                    hint: 'Text Here',
                    controller: _appLabelEnCtrl,
                    height: 36,
                    submitted: _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    primaryColor: _resolvedPrimaryColor,
                    onChanged: (value) => _hasChanges = true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomValidatedTextFieldMaster(
                      label: 'تسمية التنقل',
                      fillColor: Colors.white,
                      hint: 'أدخل النص هنا',
                      controller: _appLabelArCtrl,
                      height: 36,
                      submitted: _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      primaryColor: _resolvedPrimaryColor,
                      onChanged: (value) => _hasChanges = true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Icon'),
                      SizedBox(height: 6.h),
                      _imgBox(
                        picked: _iosIconPicked,
                        placeholderAsset: 'assets/control/edit_icon_pick.svg',
                        pickIconAsset: 'assets/control/camera.svg',
                        onPick: () async {
                          final p = await _pickImage();
                          if (p != null) {
                            setState(() => _iosIconPicked = p);
                            _hasChanges = true;
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      CustomValidatedTextFieldMaster(
                        label: 'Insert Apple Link',
                        fillColor: Colors.white,
                        hint: 'Insert Apple Link',
                        controller: _iosUrlCtrl,
                        submitted: _submitted,
                        height: 36,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        primaryColor: _resolvedPrimaryColor,
                        onChanged: (value) => _hasChanges = true,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Icon'),
                      SizedBox(height: 6.h),
                      _imgBox(
                        picked: _androidIconPicked,
                        placeholderAsset: 'assets/control/edit_icon_pick.svg',
                        pickIconAsset: 'assets/control/camera.svg',
                        onPick: () async {
                          final p = await _pickImage();
                          if (p != null) {
                            setState(() => _androidIconPicked = p);
                            _hasChanges = true;
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      CustomValidatedTextFieldMaster(
                        label: 'Insert Android Link',
                        fillColor: Colors.white,
                        hint: 'Insert Android Link',
                        controller: _androidUrlCtrl,
                        height: 36,
                        submitted: _submitted,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        primaryColor: _resolvedPrimaryColor,
                        onChanged: (value) => _hasChanges = true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _linksSection() => _accordion(
    key: 'links',
    title: 'Links',
    children: [
      ...List.generate((_links.length / 2).ceil(), (rowIndex) {
        final left  = rowIndex * 2;
        final right = left + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _linkItem(left)),
              SizedBox(width: 16.w),
              right < _links.length
                  ? Expanded(child: _linkItem(right))
                  : const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
      SizedBox(height: 4.h),
      GestureDetector(
        onTap: () => setState(() {
          _links.add(_LinkItem());
          _hasChanges = true;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text('Link',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: Colors.white)),
          ]),
        ),
      ),
    ],
  );

  Widget _linkItem(int i) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel('Icon'),
          GestureDetector(
            onTap: () => setState(() {
              final removed = _links.removeAt(i);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => removed.dispose());
              _hasChanges = true;
            }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: _C.remove,
                  borderRadius: BorderRadius.circular(4.r)),
              child: Text('Remove',
                  style: StyleText.fontSize11Weight400
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      SizedBox(height: 5.h),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _imgBox(
            picked: _links[i].icon,
            placeholderAsset: 'assets/control/edit_icon_pick.svg',
            pickIconAsset: 'assets/control/edit_icon_pick.svg',
            onPick: () async {
              final p = await _pickImage();
              if (p != null) {
                setState(() => _links[i].icon = p);
                _hasChanges = true;
              }
            },
          ),
        ],
      ),
      SizedBox(height: 8.h),
      CustomValidatedTextFieldMaster(
        label: 'Insert Link',
        fillColor: Colors.white,
        hint: 'Insert Links',
        controller: _links[i].text,
        height: 36,
        submitted: _submitted,
        primaryColor: _resolvedPrimaryColor,
        onChanged: (value) => _hasChanges = true,
        labelTrailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Visibility',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: _C.labelText)),
            SizedBox(width: 6.w),
            FlutterSwitch(
              width: 38.sp,
              height: 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: _resolvedPrimaryColor,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: _links[i].visibility,
              onToggle: (val) {
                setState(() => _links[i].visibility = val);
                _hasChanges = true;
              },
            ),
          ],
        ),
      ),
    ],
  );

  Widget _removeBtn(
      {required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
              color: _C.remove, borderRadius: BorderRadius.circular(4.r)),
          child: Text(label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: Colors.white)),
        ),
      );

  Widget _addLabelBtn({required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
          color: const Color(0xFF797979),
          borderRadius: BorderRadius.circular(4.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text('Label',
            style: StyleText.fontSize12Weight500
                .copyWith(color: Colors.white)),
      ]),
    ),
  );

  Widget _sectionLabel(String text) => Text(text,
      style: StyleText.fontSize14Weight500.copyWith(color: _C.labelText));

  Widget _imgBox({
    required _PickedImage picked,
    String placeholderAsset = 'assets/home_control/image.svg',
    String pickIconAsset    = 'assets/control/camera.svg',
    VoidCallback? onPick,
  }) {
    Widget content;

    if (picked.bytes != null) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.memory(
                picked.bytes!,
                width: 30.w, height: 30.h,
                fit: BoxFit.scaleDown,
                placeholderBuilder: (_) =>
                    _placeholderCircle(placeholderAsset),
              ),
            ),
          ),
        ),
      );
    }
    else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 70.w, height: 70.h,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.network(
                picked.url!,
                width: 20.w, height: 20.h,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const CircleProgressMaster(),
              ),
            ),
          ),
        ),
      );
    }


    else {
      content = _placeholderCircle(placeholderAsset);
    }

    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(onTap: onPick, child: content),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 24.w, height: 24.h,
            decoration: BoxDecoration(
              color: _C.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvg(
                assetPath: pickIconAsset,
                width: 12.w, height: 12.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _placeholderCircle(String assetPath) => Container(
    width: 70.w, height: 70.h,
    decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), shape: BoxShape.circle),
    child: Center(
        child: CustomSvg(
            assetPath: assetPath,
            width: 20.w, height: 20.h, fit: BoxFit.fill)),
  );

  String _ord(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}