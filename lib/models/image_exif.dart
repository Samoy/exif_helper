import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageExifModel extends ChangeNotifier {
  ImageExifModel({this.path = ""});

  final String path;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  img.Image? _imageData;
  bool _loading = false;
  img.Image? _image;
  List<ExifItem> _exifItems = [];

  bool get loading => _loading;

  img.Image? get image => _image;

  img.Image? get imageData => _imageData;

  GlobalKey<FormState> get formKey => _formKey;

  UnmodifiableListView<ExifItem> get exifItems =>
      UnmodifiableListView(_exifItems);

  fetchImageExifInfo() async {
    if (path.isEmpty) return;
    _loading = true;
    _image = await compute((message) => img.decodeImageFile(message), path);
    _setImageData(_image?.clone());
    _setExifItems(_imageData);
    _loading = false;
    notifyListeners();
  }

  void _setImageData(img.Image? image) {
    if (image == null) return;
    _imageData = image;
    notifyListeners();
  }

  void _setExifItems(img.Image? image) {
    if (image == null) {
      return;
    }
    final List<ExifItem> items = [];
    final directories = image.exif;
    final getTagName = directories.getTagName;
    for (final name in directories.keys) {
      List<Map<String, img.IfdValue?>> info = [];
      final directory = directories[name];
      for (final tag in directory.keys) {
        final value = directory[tag];
        final tagName = getTagName(tag);
        if (tagName != "<unknown>" &&
            value?.type != img.IfdValueType.undefined) {
          info.add({tagName: value});
        }
      }
      items.add(ExifItem(name, info));
      for (final subName in directory.sub.keys) {
        List<Map<String, img.IfdValue?>> subInfo = [];
        final subDirectory = directory.sub[subName];
        for (final tag in subDirectory.keys) {
          final value = subDirectory[tag];
          final subTagName = _getSubTagName(subName, tag);
          if (subTagName != "<unknown>" &&
              value?.type != img.IfdValueType.undefined) {
            subInfo.add({subTagName: value});
          }
        }
        items.add(ExifItem(subName, subInfo));
      }
    }
    _exifItems = items;
    notifyListeners();
  }

  void changeExifValue(Map<String, img.IfdValue?> info, ExifItem exifItem,
      String key, String value) {
    img.IfdValue? ifdValue = info[key]?.clone();
    String tag = exifItem.tag;
    if (ifdValue != null && value.isNotEmpty) {
      try {
        _setIfdValue(ifdValue, key, value);
        switch (tag) {
          case "ifd0":
            _imageData?.exif.imageIfd[key] = ifdValue;
          case "ifd1":
            _imageData?.exif.thumbnailIfd[key] = ifdValue;
          case "exif":
            _imageData?.exif.exifIfd[key] = ifdValue;
          case "gps":
            _imageData?.exif.gpsIfd[key] = ifdValue;
          case "interop":
            _imageData?.exif.interopIfd[key] = ifdValue;
        }
        notifyListeners();
      } on FormatException catch (e) {
        debugPrint(e.message);
      }
    }
  }

  void resetExif() {
    _formKey.currentState?.reset();
    _setImageData(_image?.clone());
    _setExifItems(_imageData);
    notifyListeners();
  }

  void _setIfdValue(img.IfdValue ifdValue, String key, String value) {
    if (value.startsWith("[") && value.endsWith("]")) {
      List<String> valueArray = value.substring(1, value.length - 1).split(",");
      for (int i = 0; i < valueArray.length; i++) {
        final item = valueArray[i].trim();
        if (item.isNotEmpty) {
          _setSinglesValue(
            ifdValue: ifdValue,
            value: item,
            index: i,
          );
        }
      }
    } else {
      _setSinglesValue(
        ifdValue: ifdValue,
        value: value,
      );
    }
  }

  void _setSinglesValue(
      {required img.IfdValue ifdValue, required String value, index = 0}) {
    Type type = ifdValue.runtimeType;
    switch (type) {
      case const (img.IfdByteValue):
      case const (img.IfdValueShort):
      case const (img.IfdValueLong):
      case const (img.IfdValueSByte):
      case const (img.IfdValueSShort):
      case const (img.IfdValueSLong):
        {
          int? result = int.tryParse(value);
          if (result != null) {
            ifdValue.setInt(result, index);
          }
        }
        break;
      case const (img.IfdValueSingle):
      case const (img.IfdValueDouble):
        {
          double? result = double.tryParse(value);
          if (result != null) {
            ifdValue.setDouble(result, index);
          }
        }
        break;
      case const (img.IfdValueRational):
      case const (img.IfdValueSRational):
        {
          final array = value.split("/");
          if (array.length != 2) {
            break;
          }
          if (array[0].isEmpty || array[1].isEmpty) {
            break;
          }
          int? numerator = int.tryParse(array[0]);
          int? denominator = int.tryParse(array[1]);
          if (numerator != null || denominator != null) {
            ifdValue.setRational(numerator!, denominator!, index);
          }
        }
        break;
      case const (img.IfdValueAscii):
        ifdValue.setString(value);
        break;
      default:
        break;
    }
  }

  String _getSubTagName(String subName, int tag) {
    switch (subName) {
      case "gps":
        {
          if (!img.exifGpsTags.containsKey(tag)) {
            return "<unknown>";
          }
          return img.exifGpsTags[tag]!.name;
        }
      case "interop":
        {
          if (!img.exifInteropTags.containsKey(tag)) {
            return "<unknown>";
          }
          return img.exifInteropTags[tag]!.name;
        }
      default:
        {
          if (!img.exifImageTags.containsKey(tag)) {
            return "<unknown>";
          }
          return img.exifImageTags[tag]!.name;
        }
    }
  }
}

class ExifItem {
  ExifItem(this.tag, this.info);

  String tag;
  List<Map<String, img.IfdValue?>> info;
}
