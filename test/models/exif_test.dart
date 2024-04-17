import 'package:exif_helper/models/exif.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("test ExifModel", () {
    final exifModel = ExifModel();
    const imagePath = "test/test_image.jpg";

    test('ExifModel should set image path correctly', () {
      exifModel.setImagePath(imagePath);
      expect(exifModel.path, imagePath);
    });

    test('ExifModel should fetch image data correctly', () async {
      exifModel.setImagePath(imagePath);
      final image = await exifModel.image;
      expect(image, isNotNull);
    });

    test("ExifModel should set items correctly", () async {
      exifModel.setImagePath(imagePath);
      final image = await exifModel.image;
      exifModel.setExifItems(image);
      expect(exifModel.exifItems, isNotEmpty);
    });

    test('ExifModel should set image data correctly', () async {
      exifModel.setImagePath(imagePath);
      final image = await exifModel.image;
      exifModel.setImageData(image);
      expect(exifModel.imageData, isNotNull);
    });

    test('ExifModel should change exif value correctly', () async {
      exifModel.setImagePath(imagePath);
      final image = await exifModel.image;
      exifModel.setImageData(image);
      final value = exifModel.imageData!.clone();
      ExifItem exifItem = exifModel.exifItems.first;
      final info = exifItem.info.first;
      exifModel.changeExifValue(info, exifItem.tag, info.keys.first, "Test456");
      expect(exifModel.imageData!.exif, isNot(equals(value.exif)));
    });

    test('ExifModel should clear image correctly', () {
      exifModel.setImagePath(imagePath);
      exifModel.clearImage();
      expect(exifModel.path, '');
      expect(exifModel.image, isNull);
      expect(exifModel.exifItems.isEmpty, isTrue);
    });
  });
}
