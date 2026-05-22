part of '../../pages/master_preview.dart';

class _PreviewContent extends StatelessWidget {
  final double          fakeWidth;
  final double          fakeHeight;
  final MasterPageModel? model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;

  const _PreviewContent({
    required this.fakeWidth,
    required this.fakeHeight,
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
  });

  @override
  Widget build(BuildContext context) {
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
          color: _C.back,
          child: model == null
              ? Center(
            child: Text(
              'No data available',
              style: TextStyle(
                  fontSize: 14, color: _C.hintText),
            ),
          )
              : SingleChildScrollView(
            child: _HomeViewAccordion(
              model:        model!,
              isEnglish:    isEnglish,
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
