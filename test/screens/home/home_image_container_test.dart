import 'package:desktop_drop/desktop_drop.dart';
import 'package:exif_helper/models/image_path.dart';
import 'package:exif_helper/screens/home/home_image_container.dart';
import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:exif_helper/widgets/desktop_image_panel.dart';
import 'package:exif_helper/widgets/image_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group("test HomeImageContainer build correctly", () {
    const imagePath = "test/test_image.jpg";
    late Widget homeImageContainerScreen;
    late ImagePathModel imagePathModel;

    setUp(() {
      homeImageContainerScreen = ChangeNotifierProvider(
        create: (context) {
          imagePathModel = ImagePathModel();
          return imagePathModel;
        },
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                HomeImageContainer(),
              ],
            ),
          ),
        ),
      );
    });

    testWidgets("Test if views shows up", (WidgetTester tester) async {
      await tester.pumpWidget(homeImageContainerScreen);
      await tester.pumpAndSettle();
      expect(find.byType(SliverToBoxAdapter), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(DashedContainer), findsOneWidget);
      expect(find.byType(ImagePanel), findsOneWidget);
    });
    testWidgets("Test if select image works", (WidgetTester tester) async {
      await tester.pumpWidget(homeImageContainerScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      // 这里需要模拟选择图片
      imagePathModel.imagePath = imagePath;
      await tester.pumpAndSettle();
      expect(imagePathModel.imagePath, imagePath);
      final finder = find.byKey(const ValueKey("home_image_panel"));
      expect(finder, findsOneWidget);
      Widget widget = tester.widget(finder);
      if (widget is DesktopImagePanel) {
        final dropEventDetails = DropEventDetails(
          localPosition: const Offset(10, 10),
          globalPosition: const Offset(10, 10),
        );
        widget.onDragEntered?.call(dropEventDetails);
        widget.onDragUpdated?.call(dropEventDetails);
        widget.onDragDone?.call(imagePath);
        widget.onDragExited?.call(dropEventDetails);
      }
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
