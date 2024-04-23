import 'package:flutter/material.dart';

class ImagePathModel extends ChangeNotifier {
  String _imagePath = "";

  String get imagePath => _imagePath;

  set imagePath(String value) {
    _imagePath = value;
    notifyListeners();
  }

  void clearImage() {
    _imagePath = "";
    notifyListeners();
  }
}
