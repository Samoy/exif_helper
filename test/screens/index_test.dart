import 'dart:ui';

import 'package:exif_helper/models/system.dart';
import 'package:exif_helper/screens/home.dart';
import 'package:exif_helper/screens/index.dart';
import 'package:exif_helper/screens/settings.dart';
import 'package:exif_helper/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../mock/system_test.mocks.dart';

void main() {
  group("test index screen build correctly", () {
    late Widget indexPage;
    late MockSharedPreferences mockPrefs;
    const homeKey = ValueKey("navigation_0");
    const settingKey = ValueKey("navigation_1");
    setUp(() {
      mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('language')).thenReturn('system');
      when(mockPrefs.getString('themeMode')).thenReturn('system');
      when(mockPrefs.containsKey('language')).thenReturn(true);
      when(mockPrefs.containsKey('themeMode')).thenReturn(true);
      indexPage = ChangeNotifierProvider(
        create: (context) => SystemModel(prefs: mockPrefs),
        child: Consumer<SystemModel>(
          builder: (context, SystemModel system, child) {
            Language language = system.currentLanguage;
            return MaterialApp(
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: system.currentThemeMode,
                locale: language == Language.system
                    ? PlatformDispatcher.instance.locale
                    : language.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const IndexPage());
          },
        ),
      );
    });

    testWidgets("Testing if Scaffold shows up", (WidgetTester tester) async {
      await tester.pumpWidget(indexPage);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets("Testing landscape show and operate correctly",
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(indexPage);
      await tester.pumpAndSettle();
      // Test show
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byKey(homeKey), findsOneWidget);
      expect(find.byKey(settingKey), findsOneWidget);
      // Test operate
      await tester.tap(find.byKey(settingKey));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.tap(find.byKey(homeKey));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('Testing portrait show and operate correctly',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 750));
      await tester.pumpWidget(indexPage);
      await tester.pumpAndSettle();
      // Test show
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(2));
      expect(find.byType(HomePage), findsOneWidget);
      // Test operate
      await tester.tap(find.byType(NavigationDestination).last);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.tap(find.byType(NavigationDestination).first);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
