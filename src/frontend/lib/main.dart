import 'package:flutter/material.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/localization/app_translations.dart';
import 'core/services/Otplocalization.dart' show OtpService;
import 'core/services/language_controller.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();
  await OtpService.initializeNotifications();
  await LanguageController.instance.init();
  await ThemeController.instance.init();

  runApp(const MediKioskApp());
}
class MediKioskApp extends StatelessWidget {
  const MediKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LanguageController.instance,
        ThemeController.instance,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: tr('app_title'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRouter.routes,
        );
      },
    );
  }
}
