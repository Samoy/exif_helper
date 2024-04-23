import 'dart:ui';

import 'package:exif_helper/models/system.dart';
import 'package:exif_helper/theme/theme.dart';
import 'package:exif_helper/widgets/image_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../mock/system_test.mocks.dart';

void main() {
  const String imagePath = "test/test_image.jpg";
  MockSharedPreferences mockPrefs = MockSharedPreferences();
  when(mockPrefs.getString('language')).thenReturn('system');
  when(mockPrefs.getString('themeMode')).thenReturn('system');
  when(mockPrefs.containsKey('language')).thenReturn(true);
  when(mockPrefs.containsKey('themeMode')).thenReturn(true);
  Widget createImagePanelScreen(ImagePanel imagePanel) {
    return ChangeNotifierProvider(
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
              home: imagePanel);
        },
      ),
    );
  }

  group('test ImagePanel build correctly', () {
    testWidgets('should display upload SVG when imagePath is empty',
        (WidgetTester tester) async {
      const widget = ImagePanel(imagePath: '');
      await tester.pumpWidget(createImagePanelScreen(widget));
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(
          find.textContaining(
              AppLocalizations.of(tester.element(find.byType(ImagePanel)))!
                  .selectImage),
          findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should display image file when imagePath is not empty',
        (WidgetTester tester) async {
      const widget = ImagePanel(imagePath: imagePath);
      await tester.pumpWidget(createImagePanelScreen(widget));
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.byType(Column), findsNothing);
      expect(
          find.textContaining(
              AppLocalizations.of(tester.element(find.byType(ImagePanel)))!
                  .selectImage),
          findsNothing);
    });
  });
}
