import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  runApp(
    const IryaxSpaceApp(),
  );
}

class IryaxSpaceApp extends StatelessWidget {
  const IryaxSpaceApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IRYAX Space',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          behavior: HitTestBehavior.translucent,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          ),
        );
      },

      // Always start with Splash.
      // Splash will decide:
      // Logged in            -> Dashboard/Home
      // Registration pending -> Registration
      // Otherwise            -> Login
      initialRoute: AppRoutes.splash,

      getPages: AppPages.pages,
    );
  }
}