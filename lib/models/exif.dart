import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

class ExifModel extends ChangeNotifier {
  Image? _image;

  Image? get image => _image;
  List<ExifItem> _exifItems = [];


  UnmodifiableListView<ExifItem> get exifItems =>
      UnmodifiableListView(_exifItems);

  void setImage(String path) async {
    _image = await decodeImageFile(path);
    genExifItems();
    notifyListeners();
  }

  void clearImage() {
    _image = null;
  }

  void genExifItems() {
    if (image == null) {
      return;
    }
    final directories = image!.exif;
    final getTagName = directories.getTagName;
    List<ExifItem> items = [];
    for (final name in directories.keys) {
      List<Map<String, IfdValue?>> info = [];
      final directory = directories[name];
      for (final tag in directory.keys) {
        final value = directory[tag];
        final tagName = getTagName(tag);
        if (tagName != "<unknown>" && value?.type != IfdValueType.undefined) {
          info.add({tagName: value});
        }
      }
      items.add(ExifItem(name, info));
      for (final subName in directory.sub.keys) {
        List<Map<String, IfdValue?>> subInfo = [];
        final subDirectory = directory.sub[subName];
        for (final tag in subDirectory.keys) {
          final value = subDirectory[tag];
          final subTagName = _getSubTagName(subName, tag);
          if (subTagName != "<unknown>" &&
              value?.type != IfdValueType.undefined) {
            subInfo.add({subTagName: value});
          }
        }
        items.add(ExifItem(subName, subInfo));
      }
    }
    _exifItems = items;
  }

  void changeExifValue(
      Map<String, IfdValue?> info, String tag, String key, String value) {
    IfdValue? ifdValue = info[key]?.clone();
    if (ifdValue != null && value.isNotEmpty) {
      try {
        _setIfdValue(ifdValue, key, value);
        switch (tag) {
          case "ifd0":
            _image?.exif.imageIfd[key] = ifdValue;
          case "ifd1":
            _image?.exif.thumbnailIfd[key] = ifdValue;
          case "exif":
            _image?.exif.exifIfd[key] = ifdValue;
          case "gps":
            _image?.exif.gpsIfd[key] = ifdValue;
          case "interop":
            _image?.exif.interopIfd[key] = ifdValue;
        }
        notifyListeners();
      } on FormatException catch (e) {
        debugPrint(e.message);
      }
    }
  }

  void _setIfdValue(IfdValue ifdValue, String key, String value) {
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
      {required IfdValue ifdValue, required String value, index = 0}) {
    Type type = ifdValue.runtimeType;
    switch (type) {
      case const (IfdByteValue):
      case const (IfdValueShort):
      case const (IfdValueLong):
      case const (IfdValueSByte):
      case const (IfdValueSShort):
      case const (IfdValueSLong):
        ifdValue.setInt(int.parse(value), index);
        break;
      case const (IfdValueSingle):
      case const (IfdValueDouble):
        ifdValue.setDouble(double.parse(value), index);
        break;
      case const (IfdValueRational):
      case const (IfdValueSRational):
        int numerator = int.parse(value.split("/")[0]);
        int denominator = int.parse(value.split("/")[1]);
        ifdValue.setRational(numerator, denominator, index);
        break;
      case const (IfdValueAscii):
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
          if (!exifGpsTags.containsKey(tag)) {
            return "<unknown>";
          }
          return exifGpsTags[tag]!.name;
        }
      case "interop":
        {
          if (!exifInteropTags.containsKey(tag)) {
            return "<unknown>";
          }
          return exifInteropTags[tag]!.name;
        }
      default:
        {
          if (!exifImageTags.containsKey(tag)) {
            return "<unknown>";
          }
          return exifImageTags[tag]!.name;
        }
    }
  }
}

class ExifItem {
  ExifItem(this.tag, this.info);

  String tag;
  List<Map<String, IfdValue?>> info;
}
