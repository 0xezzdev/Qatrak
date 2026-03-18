import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/feature/splash_screen/widget/splash_screen.dart';
import 'package:qatrak/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(MyApp());
  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 850),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // ignore: deprecated_member_use
          useInheritedMediaQuery: true,
          //locale: DevicePreview.locale(context),
          //builder: DevicePreview.appBuilder,
          home: SplashScreen(),
        );
      },
    );
  }
}
