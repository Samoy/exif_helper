import 'package:exif_helper/screens/home/home_save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:exif_helper/models/image_exif.dart';
import 'package:exif_helper/models/image_path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('HomeSaveButton', () {
    const imagePath = "test/test_image.jpg";
    late Widget homeSaveButtonScreen;
    late ImageExifModel imageExifModel;
    setUp(() {
      homeSaveButtonScreen = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            ImagePathModel imagePathModel = ImagePathModel();
            imagePathModel.imagePath = imagePath;
            return imagePathModel;
          }),
          ChangeNotifierProvider(create: (context) {
            imageExifModel = ImageExifModel(path: imagePath);
            return imageExifModel;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: HomeSaveButton(),
          ),
        ),
      );
    });

    testWidgets('Renders Save Button when imageData is null', (tester) async {
      await tester.pumpWidget(homeSaveButtonScreen);
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('Does not render Save Button when imageData is not null',
        (tester) async {
      await tester.pumpWidget(homeSaveButtonScreen);
      await tester.runAsync(() => imageExifModel.fetchImageExifInfo());
      await tester.pumpAndSettle();
      final saveButtonFinder = find.byType(FilledButton);
      expect(saveButtonFinder, findsOneWidget);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(
          TextButton,
          AppLocalizations.of(tester.element(find.byType(AlertDialog)))!
              .cancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton,
          AppLocalizations.of(tester.element(find.byType(AlertDialog)))!.ok));
      await tester.pumpAndSettle();
    });
  });
}
