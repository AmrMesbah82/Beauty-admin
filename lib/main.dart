import 'package:beauty_admin/repo/home_repo/home_repository_impl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'controller/home/home_cubit.dart';
import 'controller/home/lang_state.dart';
import 'dashboard/main_page/home_main_page.dart';
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
          ],
          child: MaterialApp(
            title: 'Beauty User',
            debugShowCheckedModeBanner: false,
            home: HomeMainPage(),
          ),
        );
      },
    );
  }
}