import 'package:image/image.dart';

class ExifModel {
  ExifModel(this.tag, this.info);

  String tag;
  List<Map<String, IfdValue?>> info;
}
