import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/image_exif.dart';
import 'package:exif_helper/screens/home/home_image_exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group("test HomeExifContainer build correctly", () {
    const imagePath = "test/test_image.jpg";
    late Widget homeExifContainerScreen;
    late ImageExifModel imageExifModel;

    setUp(() {
      homeExifContainerScreen = ChangeNotifierProvider(
        create: (context) {
          imageExifModel = ImageExifModel(path: imagePath);
          return imageExifModel;
        },
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                HomeExifContainer(),
              ],
            ),
          ),
        ),
      );
    });

    testWidgets("Test if views shows up", (WidgetTester tester) async {
      await tester.pumpWidget(homeExifContainerScreen);
      await tester.pumpAndSettle();
      expect(
          find.text(AppLocalizations.of(
                  tester.element(find.byType(HomeExifContainer)))!
              .supportImageFormatBelow),
          findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(allowedExtensions.length));
    });
    testWidgets("Test if fetch image exif info works",
        (WidgetTester tester) async {
      await tester.pumpWidget(homeExifContainerScreen);
      await tester.pumpAndSettle();
      await tester.runAsync(() => imageExifModel.fetchImageExifInfo());
      await tester.pumpAndSettle();
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(SliverList), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });
  });
}
