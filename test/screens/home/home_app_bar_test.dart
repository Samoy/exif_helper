import 'package:exif_helper/models/image_exif.dart';
import 'package:exif_helper/models/image_path.dart';
import 'package:exif_helper/models/search.dart';
import 'package:exif_helper/screens/home/home_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group("test HomeAppBar build correctly", () {
    const imagePath = "test/test_image.jpg";
    late Widget homeAppBarScreen;
    late HomeAppBar appBar;
    late SearchModel searchModel;
    late ImagePathModel imagePathModel;
    late ImageExifModel exifModel;
    setUp(() {
      appBar = const HomeAppBar();
      homeAppBarScreen = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            searchModel = SearchModel();
            return searchModel;
          }),
          ChangeNotifierProvider(create: (context) {
            imagePathModel = ImagePathModel();
            return imagePathModel;
          }),
        ],
        child: ChangeNotifierProxyProvider<ImagePathModel, ImageExifModel>(
          create: (context) => ImageExifModel(),
          update: (context, imagePathModel, previous) {
            exifModel = ImageExifModel(path: imagePathModel.imagePath);
            return exifModel;
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  appBar,
                  SliverToBoxAdapter(
                    child: Consumer<ImageExifModel>(
                      builder: (context, exifModel, child) {
                        return Form(
                          key: exifModel.formKey,
                          child: Container(),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
    testWidgets("Testing if views shows up", (WidgetTester tester) async {
      await tester.pumpWidget(homeAppBarScreen);
      await tester.pumpAndSettle();
      expect(find.byWidget(appBar), findsOneWidget);
      BuildContext context = tester.element(find.byWidget(appBar));
      expect(find.text(AppLocalizations.of(context)!.exif), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
    testWidgets("Testing if search works", (WidgetTester tester) async {
      await tester.pumpWidget(homeAppBarScreen);
      await tester.pumpAndSettle();
      final searchButtonFinder = find.byIcon(Icons.search_outlined);
      final textFieldFinder = find.byType(TextField);
      const String text = "DateTime";
      await tester.tap(searchButtonFinder);
      await tester.pumpAndSettle();
      await tester.enterText(textFieldFinder, text);
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget);
      expect(searchModel.searchText, text);
      await tester.tap(searchButtonFinder);
      await tester.pumpAndSettle();
      expect(searchModel.searchFocusNode.hasFocus, isTrue);
      await tester.tap(find.byIcon(Icons.clear_outlined));
      await tester.pumpAndSettle();
      expect(find.text(text), findsNothing);
      await tester.tap(searchButtonFinder);
      await tester.pumpAndSettle();
      expect(searchModel.searchFocusNode.hasFocus, isFalse);
    });
    testWidgets("Testing if reset works", (WidgetTester tester) async {
      await tester.pumpWidget(homeAppBarScreen);
      await tester.pumpAndSettle();
      imagePathModel.imagePath = imagePath;
      await tester.pumpAndSettle();
      await tester.runAsync(() => exifModel.fetchImageExifInfo());
      final menuButtonFinder = find.byIcon(Icons.more_vert);
      await tester.tap(menuButtonFinder);
      await tester.pumpAndSettle();
      // Change Image Exif
      final value = exifModel.imageData!.clone();
      ExifItem exifItem = exifModel.exifItems.first;
      final info = exifItem.info.first;
      exifModel.changeExifValue(info, exifItem, info.keys.first, "Test456");
      await tester.pumpAndSettle();
      // Reset Exif
      final resetExifFinder = find.text(
          AppLocalizations.of(tester.element(menuButtonFinder))!.resetExif);
      await tester.tap(resetExifFinder);
      await tester.pumpAndSettle();
      expect(exifModel.imageData!.exif.toString(), value.exif.toString());
      await tester.tap(menuButtonFinder);
      await tester.pumpAndSettle();
      // Clear Image
      final clearImageFinder = find.text(
          AppLocalizations.of(tester.element(menuButtonFinder))!.clearImage);
      await tester.tap(clearImageFinder);
      await tester.pumpAndSettle();
      expect(imagePathModel.imagePath, "");
    });
  });
}
