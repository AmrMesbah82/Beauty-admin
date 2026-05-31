// ******************* FILE INFO *******************
// File Name: preview_content.dart
// Description: Preview content widget for Master preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › master › presentation › ui › widget › master_preview

part of '../../pages/master_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double          fakeWidth;
  final double          fakeHeight;
  final MasterPageModel? model;
  final bool?           isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.homeViewOpen,
    required this.onToggleHome,
    this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final bool resolvedIsEnglish =
        isEnglish ?? Localizations.localeOf(context).languageCode == 'en';
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(fakeWidth, fakeHeight),
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: SizedBox(
        width: fakeWidth,
        height: fakeHeight,
        child: ColoredBox(
          color: ColorPick.white,
          child: model == null
              ? Center(
            child: Text(
              'No data available',
              style: TextStyle(
                  fontSize: 14, color: AppColors.secondaryText),
            ),
          )
              : SingleChildScrollView(
            child: _HomeViewAccordion(
              model:        model!,
              isEnglish:    resolvedIsEnglish,
              homeViewOpen: homeViewOpen,
              onToggleHome: onToggleHome,
              frameWidth:   fakeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home View accordion — pulled out so _PreviewContent stays lean
// ─────────────────────────────────────────────────────────────────────────────