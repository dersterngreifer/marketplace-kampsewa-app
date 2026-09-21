import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/screens/splash_screen.dart';

void main() => runApp(const Main());

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Marketplace KampSewa Indonesia",
        theme: ThemeData(
          primaryColor: AppColors.mainColor,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.mainColor,
            selectionColor: AppColors.mainColor.withValues(alpha: 0.3),
            selectionHandleColor: AppColors.mainColor,
          ),
        ),
        home: const SplashScreen());
  }
}
