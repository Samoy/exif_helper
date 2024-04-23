import 'package:exif_helper/models/image_exif.dart';
import 'package:exif_helper/models/image_path.dart';
import 'package:exif_helper/models/search.dart';
import 'package:exif_helper/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group("test home screen build correctly", () {
    late Widget homePage;
    late ImageExifModel exifModel;
    const imagePath = "test/test_image.jpg";
    setUp(() {
      homePage = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SearchModel()),
          ChangeNotifierProvider(create: (context) => ImagePathModel()),
        ],
        child: ChangeNotifierProxyProvider<ImagePathModel, ImageExifModel>(
          create: (context) => ImageExifModel(),
          update: (context, imagePathModel, previous) {
            exifModel = ImageExifModel(path: imagePathModel.imagePath);
            return exifModel;
          },
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: HomePage(),
            ),
          ),
        ),
      );
    });
    testWidgets("Testing if views shows up", (WidgetTester tester) async {
      await tester.pumpWidget(homePage);
      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byKey(const ValueKey("home_app_bar")), findsOneWidget);
      expect(find.byKey(const ValueKey("home_select_image_container")),
          findsOneWidget);
      expect(find.byKey(const ValueKey("home_exif_container")), findsOneWidget);
    });

    testWidgets("Testing if image and exif data shows up",
        (WidgetTester tester) async {
      await tester.pumpWidget(homePage);
      await tester.pumpAndSettle();
      BuildContext context = tester.element(find.byType(HomePage));
      Provider.of<ImagePathModel>(context, listen: false).imagePath = imagePath;
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      await tester.runAsync(() => exifModel.fetchImageExifInfo());
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey("home_save_button")), findsOneWidget);
    });
  });
}
