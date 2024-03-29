import 'dart:ui';

import 'package:exif_helper/screens/index.dart';
import 'package:exif_helper/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:routerino/routerino.dart';
import 'package:exif_helper/models/system.dart';

void main() async {
  await initWindowOptions();
  runApp(const MyApp());
}

Future<void> initWindowOptions() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SystemModel(),
      child: Consumer<SystemModel>(
        builder: (context, SystemModel system, child) {
          Language language = system.currentLanguage; // 当前语言设置
          // 构建MaterialApp
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) {
              String title = AppLocalizations.of(context)!.appTitle;
              (() async {
                await windowManager.setTitle(title);
              })();
              return title;
            },
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: system.currentThemeMode,
            locale: language == Language.system
                ? PlatformDispatcher.instance.locale
                : language.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: Routerino.navigatorKey,
            home: RouterinoHome(
              builder: () => const IndexPage(),
            ),
          );
        },
      ),
    );
  }
}
