// ******************* FILE INFO *******************
// File Name: preview_view.dart
// Description: Preview view widget for Contact Us preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › contact_us › presentation › ui › widget › contact_us_preview

part of '../../pages/contact_us_preview.dart';

class _PreviewView extends StatelessWidget {
  const _PreviewView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPick.background,
      body: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
        builder: (context, state) {
          if (state is ContactUsCmsLoading || state is ContactUsCmsInitial) {
            return const Center(child: CircularProgressIndicator(color: ColorPick.primary));
          }
          if (state is ContactUsCmsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ContactUsCmsCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is ContactUsCmsLoaded) {
            return _PreviewBody(data: state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREVIEW BODY
// ═══════════════════════════════════════════════════════════════════════════════
