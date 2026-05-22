// ******************* FILE INFO *******************
// File Name: contact_us_preview.dart
// Updated: Rewritten to match OverviewPreviewPage pattern
//   - Desktop / Tablet / Mobile device frames with Transform.scale
//   - CustomSegmentedTabs for EN / AR toggle
//   - Back + Publish buttons
//   - _BrowserChrome bar
//   - All preview content moved into _PreviewContent widget

// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_admin/core/custom_dialog.dart';
import 'package:beauty_admin/core/custom_segmant_tab.dart';
import 'package:beauty_admin/core/widget/custom_dropdwon.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../data/model/contact_us_model_location.dart';
import '../../controller/contact_us_location_cubit.dart';
import '../../controller/contact_us_location_state.dart';

part '../widget/contact_us_preview/c.dart';
part '../widget/contact_us_preview/preview_const.dart';
part '../widget/contact_us_preview/preview_view.dart';
part '../widget/contact_us_preview/preview_body.dart';
part '../widget/contact_us_preview/desktop_frame.dart';
part '../widget/contact_us_preview/tablet_frame.dart';
part '../widget/contact_us_preview/mobile_frame.dart';
part '../widget/contact_us_preview/preview_content.dart';
part '../widget/contact_us_preview/section_header.dart';
part '../widget/contact_us_preview/form_label.dart';
part '../widget/contact_us_preview/browser_chrome.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

const Color _kPink = Color(0xFFD16F9A);

class ContactUsCmsPreviewPage extends StatelessWidget {
  const ContactUsCmsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactUsCmsCubit()..load(),
      child: const _PreviewView(),
    );
  }
}
