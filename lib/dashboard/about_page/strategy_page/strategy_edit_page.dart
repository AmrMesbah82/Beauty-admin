// ******************* FILE INFO *******************
// File Name: strategy_edit_page.dart
// Screen 2 of 3 — Our Strategy CMS: Edit page
// UPDATED: Added Strategic House - ENG and Strategic House - ARB accordions
// UPDATED: Added device preview tabs (Large Screen / Tablet / Mobile)

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:beauty_admin/controller/about_us/about_us_cubit.dart';
import 'package:beauty_admin/controller/about_us/about_us_state.dart';
import 'package:beauty_admin/core/custom_svg.dart';
import 'package:beauty_admin/core/widget/button.dart';
import 'package:beauty_admin/core/widget/textfield.dart';
import 'package:beauty_admin/theme/new_theme.dart';
import 'package:beauty_admin/widgets/admin_sub_navbar.dart';
import 'package:beauty_admin/widgets/app_navbar.dart';

import '../../../model/about_us/about_us.dart';
import 'strategy_preview_page.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kBg         = Color(0xFFF2F2F2);

// ── Device preview tab enum ─────────────────────────────────────────────────
enum DeviceTab { largeScreen, tablet, mobile }

// ═══════════════════════════════════════════════════════════════════════════════

class StrategyEditPage extends StatefulWidget {
  const StrategyEditPage({super.key});

  @override
  State<StrategyEditPage> createState() => _StrategyEditPageState();
}

class _StrategyEditPageState extends State<StrategyEditPage> {
  // ── Navigation Label ──
  final _navTitleEnCtrl = TextEditingController();
  final _navTitleArCtrl = TextEditingController();
  Uint8List? _navIconBytes;
  String _navIconUrl = '';

  // ── Strategic House — ENG ──
  Uint8List? _strategicHouseEnBytes;
  String _strategicHouseEnUrl = '';

  // ── Strategic House — ARB ──
  Uint8List? _strategicHouseArBytes;
  String _strategicHouseArUrl = '';

  bool _navLabelOpen        = true;
  bool _strategicHouseEnOpen = true;
  bool _strategicHouseArOpen = true;

  bool _submitted = false;
  bool _seeded    = false;
  bool _isSaving  = false;

  // ── Device preview tabs ──
  DeviceTab _strategicHouseEnTab = DeviceTab.largeScreen;
  DeviceTab _strategicHouseArTab = DeviceTab.largeScreen;

  @override
  void initState() {
    super.initState();
    context.read<StrategyCubit>().load();
  }

  @override
  void dispose() {
    _navTitleEnCtrl.dispose();
    _navTitleArCtrl.dispose();
    super.dispose();
  }

  // ── File pickers ──────────────────────────────────────────────────────────
  Future<Uint8List?> _pickImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }

      final file = files.first;
      final reader = html.FileReader();

      // Read as array buffer
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) {
          bytes = r.asUint8List();
        } else if (r is Uint8List) {
          bytes = r;
        }

        if (bytes != null) {
          // Log for debugging
          print('File loaded: ${file.name}, size: ${bytes.length} bytes');

          // Check if it's SVG by file extension or content
          final isSvgByExtension = file.name.toLowerCase().endsWith('.svg');
          final isSvgByType = file.type == 'image/svg+xml';

          if (isSvgByExtension || isSvgByType) {
            print('Detected SVG file');
          } else {
            // For non-SVG, we could validate header here
            print('Detected raster image');
          }

          c.complete(bytes);
        } else {
          c.complete(null);
        }
      });
      reader.onError.listen((e) {
        print('Error reading file: $e');
        c.complete(null);
      });
    });
    input.click();
    return c.future;
  }

  // ── Seed ─────────────────────────────────────────────────────────────────
  void _seed(OurStrategyModel m) {
    if (_seeded) return;
    _seeded = true;

    print('🔵 Seeding strategy data:');
    print('  - Nav icon URL: ${m.navigationLabel.iconUrl}');
    print('  - Strategic House EN URL: ${m.strategicHouseEnUrl}');
    print('  - Strategic House AR URL: ${m.strategicHouseArUrl}');
    print('  - Nav title EN: ${m.navigationLabel.title.en}');
    print('  - Nav title AR: ${m.navigationLabel.title.ar}');

    _navTitleEnCtrl.text = m.navigationLabel.title.en;
    _navTitleArCtrl.text = m.navigationLabel.title.ar;
    _navIconUrl = m.navigationLabel.iconUrl;
    _strategicHouseEnUrl = m.strategicHouseEnUrl;
    _strategicHouseArUrl = m.strategicHouseArUrl;
  }

// Update _buildModel to include current URLs
  OurStrategyModel _buildModel(String status) => OurStrategyModel(
    publishStatus: status,
    navigationLabel: AboutNavigationLabel(
      iconUrl: _navIconUrl,  // Use the current URL
      title: AboutBilingualText(
        en: _navTitleEnCtrl.text.trim(),
        ar: _navTitleArCtrl.text.trim(),
      ),
    ),
    vision: const StrategySection(),
    strategicHouseEnUrl: _strategicHouseEnUrl,  // Use the current URL
    strategicHouseArUrl: _strategicHouseArUrl,  // Use the current URL
  );

  Map<String, Uint8List> _collectUploads() {
    final uploads = <String, Uint8List>{};
    if (_navIconBytes != null)
      uploads['strategy_cms/navLabel/icon'] = _navIconBytes!;
    if (_strategicHouseEnBytes != null)
      uploads['strategy_cms/strategicHouse/en'] = _strategicHouseEnBytes!;
    if (_strategicHouseArBytes != null)
      uploads['strategy_cms/strategicHouse/ar'] = _strategicHouseArBytes!;
    return uploads;
  }

  bool _validate() {
    return [
      _navTitleEnCtrl,
      _navTitleArCtrl,
    ].every((c) => c.text.trim().isNotEmpty);
  }

  // ── Preview ───────────────────────────────────────────────────────────────
  void _onPreview() {
    setState(() => _submitted = true);
    if (!_validate()) return;
    final cubit   = context.read<StrategyCubit>();
    final model   = _buildModel('draft');
    final uploads = _collectUploads();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StrategyPreviewPage(model: model, imageUploads: uploads),
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save(String status) async {
    setState(() => _submitted = true);
    if (!_validate()) return;
    setState(() => _isSaving = true);

    final model = _buildModel(status);
    final uploads = _collectUploads();

    print('🔵 Saving strategy:');
    print('  - Nav icon bytes: ${_navIconBytes != null}');
    print('  - Strategic House EN bytes: ${_strategicHouseEnBytes != null}');
    print('  - Strategic House AR bytes: ${_strategicHouseArBytes != null}');
    print('  - Current EN URL: $_strategicHouseEnUrl');
    print('  - Current AR URL: $_strategicHouseArUrl');

    await context.read<StrategyCubit>().save(
      model: model,
      imageUploads: uploads.isEmpty ? null : uploads,
    );
  }

  // ── Device preview width helper ───────────────────────────────────────────
  double _previewWidth(DeviceTab tab) {
    switch (tab) {
      case DeviceTab.largeScreen:
        return double.infinity;
      case DeviceTab.tablet:
        return 600.w;
      case DeviceTab.mobile:
        return 320.w;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyCubit, StrategyState>(
      listener: (context, state) {
        if (state is StrategyLoaded) {
          _seed(state.data);
        }
        if (state is StrategySaved) {
          setState(() => _isSaving = false);

          // Update local URLs with the saved ones
          setState(() {
            _navIconUrl = state.data.navigationLabel.iconUrl;
            _strategicHouseEnUrl = state.data.strategicHouseEnUrl;
            _strategicHouseArUrl = state.data.strategicHouseArUrl;

            print('🟢 URLs updated after save:');
            print('  - Nav Icon URL: $_navIconUrl');
            print('  - EN URL: $_strategicHouseEnUrl');
            print('  - AR URL: $_strategicHouseArUrl');

            // Clear bytes after successful upload
            _navIconBytes = null;
            _strategicHouseEnBytes = null;
            _strategicHouseArBytes = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Our Strategy saved!'),
              backgroundColor: _kGreenSolid,
            ),
          );

          // Navigate back after save
          Navigator.pop(context);
        }
        if (state is StrategyError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: _kRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is StrategyLoading || state is StrategyInitial;

        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 1000.w,
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            AdminSubNavBar(activeIndex: 3),
                            SizedBox(height: 20.h),
                            loading
                                ? const Center(
                                child: CircularProgressIndicator(
                                    color: _kGreenSolid))
                                : _buildForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSaving) _savingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Editing Our Strategy',
            style: StyleText.fontSize45Weight600.copyWith(
                color: _kGreen, fontWeight: FontWeight.w700)),
        SizedBox(height: 24.h),

        // ── Navigation Label ──────────────────────────────────────────────
        _accordion(
          title: 'Navigation Label',
          isOpen: _navLabelOpen,
          onToggle: () =>
              setState(() => _navLabelOpen = !_navLabelOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: _navIconBytes,
                url: _navIconUrl,
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) setState(() => _navIconBytes = b);
                },
              ),
              SizedBox(height: 16.h),
              _fieldLabel('Title'),
              SizedBox(height: 8.h),
              _bilingualRow(
                  enCtrl: _navTitleEnCtrl,
                  arCtrl: _navTitleArCtrl,
                  enHint: 'Text Here',
                  arHint: 'أدخل النص هنا'),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ENG ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ENG',
          isOpen: _strategicHouseEnOpen,
          onToggle: () =>
              setState(() => _strategicHouseEnOpen = !_strategicHouseEnOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width : 300.w,
                child: _deviceTabBar(
                  selected: _strategicHouseEnTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseEnTab = tab),
                ),
              ),
              SizedBox(height: 16.h),
              _imageUploadBox(
                label: 'Upload Image',
                bytes: _strategicHouseEnBytes,
                url: _strategicHouseEnUrl,
                previewWidth: _previewWidth(_strategicHouseEnTab),
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) setState(() => _strategicHouseEnBytes = b);
                },
                onRemove: (_strategicHouseEnBytes != null ||
                    _strategicHouseEnUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseEnBytes = null;
                  _strategicHouseEnUrl   = '';
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Strategic House — ARB ─────────────────────────────────────────
        _accordion(
          title: 'Strategic House - ARB',
          isOpen: _strategicHouseArOpen,
          onToggle: () =>
              setState(() => _strategicHouseArOpen = !_strategicHouseArOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width : 300.w,
                child: _deviceTabBar(
                  selected: _strategicHouseArTab,
                  onChanged: (tab) =>
                      setState(() => _strategicHouseArTab = tab),
                ),
              ),
              SizedBox(height: 16.h),
              _imageUploadBox(
                label: 'Upload Image',
                bytes: _strategicHouseArBytes,
                url: _strategicHouseArUrl,
                previewWidth: _previewWidth(_strategicHouseArTab),
                onTap: () async {
                  final b = await _pickImage();
                  if (b != null) setState(() => _strategicHouseArBytes = b);
                },
                onRemove: (_strategicHouseArBytes != null ||
                    _strategicHouseArUrl.isNotEmpty)
                    ? () => setState(() {
                  _strategicHouseArBytes = null;
                  _strategicHouseArUrl   = '';
                })
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        // ── Action buttons ────────────────────────────────────────────────
        Row(children: [
          Expanded(
              child: _btn(
                  label: 'Preview',
                  color: const Color(0xFF4CAF50),
                  onTap: _onPreview)),
          SizedBox(width: 16.w),
          Expanded(
              child: _btn(
                  label: 'Publish',
                  color: _kGreenSolid,
                  onTap: () => _save('published'))),
        ]),
        SizedBox(height: 12.h),
        _btn(
            label: 'Discard',
            color: const Color(0xFF9E9E9E),
            onTap: () => Navigator.pop(context)),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding:
          EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _kGreenSolid,
            borderRadius: isOpen
                ? BorderRadius.vertical(top: Radius.circular(12.r))
                : BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp),
            ],
          ),
        ),
      ),
      if (isOpen)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          padding: EdgeInsets.all(20.w),
          child: child,
        ),
    ]);
  }

  // ── Device Tab Bar ────────────────────────────────────────────────────────
  Widget _deviceTabBar({
    required DeviceTab selected,
    required ValueChanged<DeviceTab> onChanged,
  }) {
    Widget tab(String label, DeviceTab value) {
      final isActive = selected == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isActive ? _kGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          tab('Large Screen', DeviceTab.largeScreen),
          SizedBox(width: 4.w),
          tab('Tablet', DeviceTab.tablet),
          SizedBox(width: 4.w),
          tab('Mobile', DeviceTab.mobile),
        ],
      ),
    );
  }

  /// Large rectangular image upload area (for Strategic House sections)
  Widget _imageUploadBox({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    double previewWidth = double.infinity,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    // Helper function to check if bytes contain SVG
    bool _isSvgBytes(Uint8List? bytes) {
      if (bytes == null || bytes.length < 5) return false;
      final checkLen = bytes.length > 100 ? 100 : bytes.length;
      final header = bytes.sublist(0, checkLen);
      final headerStr = String.fromCharCodes(header);
      return headerStr.contains('<svg') || headerStr.contains('<?xml');
    }

    // Helper function to check if URL points to SVG
    bool _isSvgUrl(String url) {
      final decodedUrl = Uri.decodeFull(url).toLowerCase();
      return decodedUrl.contains('.svg') ||
          decodedUrl.contains('%2Esvg') ||
          decodedUrl.contains('image/svg+xml');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── image area ──
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: previewWidth,
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),

            ),
            child: hasImage
                ? Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Builder(
                    builder: (context) {
                      // Handle uploaded bytes (new upload)
                      if (bytes != null) {
                        final isSvg = _isSvgBytes(bytes);
                        if (isSvg) {
                          return SvgPicture.memory(
                            bytes,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Image.memory(
                            bytes,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 48.sp,
                            ),
                          );
                        }
                      }

                      // Handle existing URL (from database)
                      if (url.isNotEmpty) {
                        final isSvg = _isSvgUrl(url);
                        print('Displaying image from URL: $url, isSvg: $isSvg');

                        if (isSvg) {
                          // For SVG URLs, we need to fetch and display
                          return FutureBuilder<Uint8List>(
                            future: _loadSvgBytes(url),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData) {
                                return SvgPicture.memory(
                                  snapshot.data!,
                                  width: previewWidth,
                                  height: 220.h,
                                  fit: BoxFit.contain,
                                );
                              }
                              if (snapshot.hasError) {
                                print('Error loading SVG: ${snapshot.error}');
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
                                        'Failed to load image',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        } else {
                          // For raster images, use Image.network
                          return Image.network(
                            url,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 48.sp,
                            ),
                          );
                        }
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Remove button (top-right)
                if (onRemove != null)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _kRed,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Remove',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
                  'Drop your image here',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtonWithImage(
              title: label,
              function: onTap,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white
              ),
              height: 38.h,
              space: 8.sp,
              width: 250.w,
              radius: 8.r,
              color: _kGreenSolid,
              image: "",
              widthImage: 16.w,
              heightImage: 16.h,
              colorBorder: Colors.transparent,
            ),
          ],
        )
      ],
    );
  }

  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    // Auto-detect if content is SVG
    bool detectedSvg = false;
    if (bytes != null && bytes.length > 5) {
      final checkLen = bytes.length > 100 ? 100 : bytes.length;
      final headerStr = String.fromCharCodes(bytes.sublist(0, checkLen));
      detectedSvg = headerStr.contains('<svg') || headerStr.contains('<?xml');
    }
    if (!detectedSvg && url.isNotEmpty) {
      final decodedUrl = Uri.decodeFull(url).toLowerCase();
      detectedSvg = decodedUrl.contains('.svg') ||
          decodedUrl.contains('%2Esvg') ||
          decodedUrl.contains('image/svg+xml');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEEEEEE)),
                child: hasImage
                    ? ClipOval(child: _buildImgWidget(bytes, url, detectedSvg))
                    : Icon(Icons.add,
                    color: Colors.grey[600],
                    size: 28.sp),
              ),
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
    );
  }

  Widget _buildImgWidget(Uint8List? bytes, String url, bool isSvg) {
    // Check if bytes contain SVG data — check first 100 bytes instead of 5
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final checkLen = bytes.length > 100 ? 100 : bytes.length;
      final header = bytes.sublist(0, checkLen);
      final headerStr = String.fromCharCodes(header);
      isSvgData = headerStr.contains('<svg') || headerStr.contains('<?xml');
    }

    // Check if URL points to SVG
    bool isSvgUrl = false;
    if (url.isNotEmpty) {
      final decodedUrl = Uri.decodeFull(url).toLowerCase();
      isSvgUrl = decodedUrl.contains('.svg') ||
          decodedUrl.contains('%2Esvg') ||
          decodedUrl.contains('image/svg+xml');
    }

    print('_buildImgWidget - isSvg: $isSvg, isSvgData: $isSvgData, isSvgUrl: $isSvgUrl, url: $url');

    // Handle SVG files (from bytes, URL, or explicit flag)
    if (isSvg || isSvgData || isSvgUrl) {
      // Handle SVG from bytes (new upload)
      if (bytes != null) {
        return SvgPicture.memory(
          bytes,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Handle SVG from URL (existing image)
      if (url.isNotEmpty) {
        return FutureBuilder<Uint8List>(
          future: _loadSvgBytes(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return SvgPicture.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
            if (snapshot.hasError) {
              print('Error loading SVG from URL: ${snapshot.error}');
              return Icon(
                Icons.broken_image,
                color: Colors.grey[400],
                size: 28.sp,
              );
            }
            return const SizedBox.shrink();
          },
        );
      }
    }

    // Handle raster images
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.broken_image,
          color: Colors.red[300],
          size: 28.sp,
        ),
      );
    }

    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) => Icon(
          Icons.broken_image,
          color: Colors.red[300],
          size: 28.sp,
        ),
      );
    }

    return Icon(
      isSvg ? Icons.description : Icons.image,
      color: Colors.grey,
      size: 28.sp,
    );
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    try {
      print('Loading SVG from URL: $url');
      final res = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (res.status != 200) {
        throw Exception('Failed to load SVG: ${res.status}');
      }
      final bytes = (res.response as ByteBuffer).asUint8List();
      print('SVG loaded successfully, size: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      print('Error loading SVG: $e');
      rethrow;
    }
  }

  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: _submitted,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint,
            controller: arCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: _submitted,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w,
        height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _kGreenSolid),
            SizedBox(height: 12.h),
            Text('Saving...',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}