import 'dart:ui';

import 'package:exif_helper/screens/index.dart';
import 'package:exif_helper/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:routerino/routerino.dart';
import 'package:exif_helper/models/system.dart';

import 'extensions/platform_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformExtension.isDesktop) {
    await initDesktop();
  } else {
    initMobile();
  }
  runApp(const MyApp());
}

Future<void> initDesktop() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    titleBarStyle: TitleBarStyle.normal,
    minimumSize: Size(400, 700),
    size: Size(1000, 800),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

void initMobile() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? _preferences;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SystemModel(prefs: _preferences),
      child: Consumer<SystemModel>(
        builder: (context, SystemModel system, child) {
          Language language = system.currentLanguage; // 当前语言设置
          // 构建MaterialApp
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) {
              String title = AppLocalizations.of(context)!.appTitle;
              if (PlatformExtension.isDesktop) {
                (() async {
                  await windowManager.setTitle(title);
                })();
              }
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
            home: RouterinoHome<IndexPage>(
              builder: () => const IndexPage(),
            ),
          );
        },
      ),
    );
  }
}
