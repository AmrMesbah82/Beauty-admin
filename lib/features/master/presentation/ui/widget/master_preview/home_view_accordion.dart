part of '../../pages/master_preview.dart';

class _HomeViewAccordion extends StatelessWidget {
  final MasterPageModel model;
  final bool            isEnglish;
  final bool            homeViewOpen;
  final VoidCallback    onToggleHome;
  final double          frameWidth;

  const _HomeViewAccordion({
    required this.model,
    required this.isEnglish,
    required this.homeViewOpen,
    required this.onToggleHome,
    required this.frameWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric( vertical: 16),
      child: Column(
        children: [
          // ── Accordion header ──────────────────────────────────────────
          GestureDetector(
            onTap: onToggleHome,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Expanded(
                  child: Text('Home View',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                AnimatedRotation(
                  turns: homeViewOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomSvg(
                    assetPath: 'assets/arrowdown.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                    color: Colors.white,
                  ),
                ),
              ]),
            ),
          ),

          // ── Accordion body ────────────────────────────────────────────
          if (homeViewOpen)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewHeaderSection(model: model, isEnglish: isEnglish),
                  _PreviewAboutUsSection(model: model, isEnglish: isEnglish),
                  _PreviewFooterSection(model: model, isEnglish: isEnglish),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widgets (stateless, pass model + isEnglish)
// ─────────────────────────────────────────────────────────────────────────────
