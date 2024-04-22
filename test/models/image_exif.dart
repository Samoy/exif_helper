import 'package:exif_helper/models/image_exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group("test ImageExifModel", () {
    const imagePath = "test/test_image.jpg";
    late ImageExifModel imageExifModel;

    setUp(() async {
      imageExifModel = ImageExifModel(path: imagePath);
      await imageExifModel.fetchImageExifInfo();
    });

    test('ImageExifModel should set image path correctly', () {
      expect(imageExifModel.path, imagePath);
    });

    test('ImageExifModel should fetch image data correctly', () async {
      expect(imageExifModel.image, isNotNull);
    });

    test("ImageExifModel should set items correctly", () async {
      expect(imageExifModel.exifItems, isNotEmpty);
    });

    test('ImageExifModel should set image data correctly', () async {
      expect(imageExifModel.imageData, isNotNull);
    });

    testWidgets('ImageExifModel should change and reset exif value correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider(
            create: (context) => imageExifModel,
            child: Consumer<ImageExifModel>(
              builder: (context, model, child) {
                return Form(
                  key: model.formKey,
                  child: TextFormField(),
                );
              },
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final value = imageExifModel.imageData!.clone();
      ExifItem exifItem = imageExifModel.exifItems.first;
      final info = exifItem.info.first;
      imageExifModel.changeExifValue(
          info, exifItem, info.keys.first, "Test456");
      expect(imageExifModel.imageData!.exif, isNot(equals(value.exif)));
      imageExifModel.resetExif();
      final expected = imageExifModel.imageData!.exif.toString();
      final actual = value.exif.toString();
      expect(expected, equals(actual));
    });
  });
}
