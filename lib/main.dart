import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme_controller.dart';
import 'core/theme/mihrab_palette.dart';
import 'core/theme/mihrab_theme.dart';
import 'features/home/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await WakelockPlus.enable();
  }

  await InjectionContainer.restoreTheme();

  runApp(const MihrabApp());
}

class MihrabApp extends StatelessWidget {
  const MihrabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeId>(
      valueListenable: AppThemeController.instance,
      builder: (context, themeId, _) {
        return MaterialApp(
          title: 'MIHRAB | محراب',
          debugShowCheckedModeBanner: false,
          theme: MihrabTheme.of(themeId),
          // Arabic locale => RTL direction and Arabic Material strings.
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            // Respect the system font size but keep the layout from breaking.
            return MediaQuery.withClampedTextScaling(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.25,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const HomePage(),
        );
      },
    );
  }
}
