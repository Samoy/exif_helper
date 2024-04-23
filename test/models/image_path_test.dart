import 'package:exif_helper/models/image_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImagePathModel', () {
    late ImagePathModel imagePathModel;
    const String path = "test/test_image.jpg";

    setUp(() {
      imagePathModel = ImagePathModel();
    });

    test('initial imagePath is empty', () {
      expect(imagePathModel.imagePath, '');
    });

    test('setting imagePath updates the value', () {
      imagePathModel.imagePath = path;
      expect(imagePathModel.imagePath, path);
    });

    test('clearImage sets imagePath to empty', () {
      imagePathModel.imagePath = path;
      imagePathModel.clearImage();
      expect(imagePathModel.imagePath, '');
    });
  });
}
