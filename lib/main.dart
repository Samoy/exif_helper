import 'dart:ui';

import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/language.dart';
import 'package:exif_helper/screens/index.dart';
import 'package:exif_helper/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:routerino/routerino.dart';

void main() async {
  await initWindowOptions();
  runApp(const MyApp());
}

initWindowOptions() async {
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
      create: (context) {
        Language language = Language();
        language.initLanguage();
        return language;
      },
      child: Consumer<Language>(
        builder: (context, Language language, child) {
          LanguageItem languageItem = language.current;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appTitle,
            theme: lightTheme,
            darkTheme: darkTheme,
            locale: languageItem == LanguageItem.auto
                ? PlatformDispatcher.instance.locale
                : languageItem.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: Routerino.navigatorKey,
            // <-- add this
            home: RouterinoHome(
              builder: () => const IndexPage(),
            ),
          );
        },
      ),
    );
  }
}
