import 'dart:ui';

import 'package:exif_helper/models/system.dart';
import 'package:exif_helper/screens/settings.dart';
import 'package:exif_helper/theme/theme.dart';
import 'package:exif_helper/widgets/my_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../mock/system_test.mocks.dart';

void main() {
  group("test settings screen build correctly", () {
    late Widget settingsPage;
    late MockSharedPreferences mockPrefs;
    setUp(() {
      mockPrefs = MockSharedPreferences();
      when(mockPrefs.getString('language')).thenReturn('system');
      when(mockPrefs.getString('themeMode')).thenReturn('system');
      when(mockPrefs.containsKey('language')).thenReturn(true);
      when(mockPrefs.containsKey('themeMode')).thenReturn(true);
      settingsPage = ChangeNotifierProvider(
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
              home: const Scaffold(
                body: SettingsPage(),
              ),
            );
          },
        ),
      );
    });
    testWidgets("Testing if views shows up", (WidgetTester tester) async {
      await tester.pumpWidget(settingsPage);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(MySliverAppBar), findsOneWidget);
      expect(find.byType(SliverList), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(5));
    });

    testWidgets('Testing should change theme', (WidgetTester tester) async {
      await tester.pumpWidget(settingsPage);
      await tester.pumpAndSettle();
      BuildContext context = tester.element(find.byType(SettingsPage));
      changeThemeMode(ThemeMode mode, int index) async {
        await tester.tap(find.byKey(const ValueKey("theme")));
        await tester.pumpAndSettle();
        expect(find.byType(SimpleDialog), findsNWidgets(1));
        when(mockPrefs.setString("themeMode", mode.name))
            .thenAnswer((realInvocation) async => true);
        await tester.tap(find.byType(RadioListTile<Enum>).at(index));
        await tester.pumpAndSettle();
        verify(mockPrefs.setString("themeMode", mode.name));
        expect(
            Provider.of<SystemModel>(context, listen: false).currentThemeMode,
            equals(mode));
      }

      await changeThemeMode(ThemeMode.light, 1);
      await changeThemeMode(ThemeMode.dark, 2);
      await changeThemeMode(ThemeMode.system, 0);
    });

    testWidgets("Testing should change language", (WidgetTester tester) async {
      await tester.pumpWidget(settingsPage);
      await tester.pumpAndSettle();
      BuildContext context = tester.element(find.byType(SettingsPage));
      changeLanguage(Language language, int index) async {
        await tester.tap(find.byKey(const ValueKey("language")));
        await tester.pumpAndSettle();
        expect(find.byType(SimpleDialog), findsNWidgets(1));
        when(mockPrefs.setString("language", language.name))
            .thenAnswer((realInvocation) async => true);
        await tester.tap(find.byType(RadioListTile<Enum>).at(index));
        await tester.pumpAndSettle();
        verify(mockPrefs.setString("language", language.name));
        expect(Provider.of<SystemModel>(context, listen: false).currentLanguage,
            equals(language));
      }

      await changeLanguage(Language.en, 1);
      await changeLanguage(Language.zh, 2);
      await changeLanguage(Language.system, 0);
    });

    testWidgets("Testing should can open privacy page",
        (WidgetTester tester) async {
      await tester.pumpWidget(settingsPage);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey("privacy")));
      await tester.pumpAndSettle();
    });

    testWidgets("Testing should can open privacy page",
        (WidgetTester tester) async {
      await tester.pumpWidget(settingsPage);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey("terms")));
      await tester.pumpAndSettle();
    });

    testWidgets("Testing should show about page", (WidgetTester tester) async {
      await tester.pumpWidget(settingsPage);
      await tester.pumpAndSettle();
      BuildContext context = tester.element(find.byType(SettingsPage));
      await tester.tap(find.byKey(const ValueKey("about")));
      await tester.pumpAndSettle();
      expect(find.byType(AboutDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(
          TextButton, MaterialLocalizations.of(context).closeButtonLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AboutDialog), findsNothing);
    });
  });
}
