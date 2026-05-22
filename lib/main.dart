
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'features/about_us/data/repo_imp/about_us_repo_imp.dart';
import 'features/about_us/presentation/controller/about_us_cubit.dart';
import 'features/client_services/data/repo_imp/client_services_repo_imp.dart';
import 'features/client_services/presentation/controller/client_services_cubit.dart';
import 'features/contact_us/presentation/controller/contact_us_location_cubit.dart';
import 'features/contact_us/presentation/controller/contact_us_cubit.dart';
import 'features/demos/domain/repo/demo_repo.dart';
import 'features/demos/presentation/controller/demo_cubit.dart';
import 'features/home/data/repo_imp/home_repo_impl.dart';
import 'features/home/presentation/controller/home_cubit.dart';
import 'features/home/presentation/controller/lang_state.dart';
import 'features/home/presentation/ui/pages/home_main.dart';
import 'features/inquire/data/repo_imp/inquiry_repo_imp.dart';
import 'features/inquire/presentation/controller/inquiry_cubit.dart';
import 'features/master/data/repo_imp/master_repo_imp.dart';
import 'features/master/presentation/controller/master_cubit.dart';
import 'features/overview/data/repo_imp/overview_repo_imp.dart';
import 'features/overview/presentation/controller/overview_cubit.dart';
import 'features/owner_services/data/repo_imp/owner_services_repo_imp.dart';
import 'features/owner_services/presentation/controller/owner_services_cubit.dart';
import 'features/request/data/repo_imp/request_repo_imp.dart';
import 'features/request/presentation/controller/request_cubit.dart';
import 'firebase_options.dart';

Size _getDesignSize({
  required double screenWidth,
  required double screenHeight,
}) {
  final isLandscape = screenWidth > screenHeight;
  if (screenWidth >= 1920) return const Size(1920, 1080);
  if (screenWidth >= 1366) return const Size(1366, 768);
  if (screenWidth >= 768) {
    return isLandscape ? const Size(1024, 768) : const Size(768, 1024);
  }
  return isLandscape ? const Size(812, 375) : const Size(375, 812);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: true,
      webExperimentalForceLongPolling: true,
      webExperimentalAutoDetectLongPolling: false,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen =
        View.of(context).physicalSize / View.of(context).devicePixelRatio;
    final designSize = _getDesignSize(
      screenWidth: screen.width,
      screenHeight: screen.height,
    );

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      builder: (ctx, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<LanguageCubit>(
              create: (_) => LanguageCubit(),
            ),
            BlocProvider<HomeCmsCubit>(
              create: (_) => HomeCmsCubit(
                repository: HomeRepositoryImpl(),
              )..load(),
            ),
            BlocProvider<MasterCmsCubit>(
              create: (_) => MasterCmsCubit(
                MasterRepoImp(),
              ),
            ),
            BlocProvider<OverviewCmsCubit>(
              create: (_) => OverviewCmsCubit(
                OverviewRepoImp(),
              ),
            ),
            BlocProvider<ClientServicesCmsCubit>(
              create: (_) => ClientServicesCmsCubit(
                ClientServicesRepoImp(),
              ),
            ),
            BlocProvider<OwnerServicesCmsCubit>(
              create: (_) => OwnerServicesCmsCubit(
                OwnerServicesRepoImp(),
              ),
            ),
            // About Us Cubits
            BlocProvider<AboutCubit>(
              create: (_) => AboutCubit(
                repo: AboutRepoImpl(),
              ),
            ),
            BlocProvider<StrategyCubit>(
              create: (_) => StrategyCubit(
                repo: AboutRepoImpl(),
              ),
            ),
            BlocProvider<TermsCubit>(
              create: (_) => TermsCubit(
                repo: AboutRepoImpl(),
              ),
            ),
            // Contact Us Cubits
            BlocProvider<ContactCubit>(
              create: (_) => ContactCubit(),
            ),
            BlocProvider<ContactUsCmsCubit>(
              create: (_) => ContactUsCmsCubit()..load(),
            ),
            // Inquiries Cubit
            BlocProvider<InquiryCubit>(
              create: (_) => InquiryCubit(
                repo: InquiryRepoImp(),
              ),
            ),
            // Request Demo Cubit (FIXED: corrected import path and repo)
            BlocProvider<RequestDemoCubit>(
              create: (_) => RequestDemoCubit(
                repo: RequestDemoRepo(),
              ),
            ),
            // Request Demo CMS Cubit (separate from above)
            BlocProvider<RequestDemoCmsCubit>(
              create: (_) => RequestDemoCmsCubit(
                RequestDemoRepoImp(),
              ),
            ),
          ],
          child: MaterialApp(
            title: 'Beauty Admin',
            debugShowCheckedModeBanner: false,
            // ── Fade animation for all route transitions app-wide ──────────
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadePageTransitionsBuilder(),
                  TargetPlatform.iOS:     FadePageTransitionsBuilder(),
                  TargetPlatform.windows: FadePageTransitionsBuilder(),
                  TargetPlatform.macOS:   FadePageTransitionsBuilder(),
                  TargetPlatform.linux:   FadePageTransitionsBuilder(),
                  TargetPlatform.fuchsia: FadePageTransitionsBuilder(),
                },
              ),
            ),
            home: const HomeMainPage(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FadePageTransitionsBuilder — 300ms easeInOut fade for all MaterialPageRoutes
// ─────────────────────────────────────────────────────────────────────────────

class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }
}