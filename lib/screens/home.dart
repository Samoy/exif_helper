import 'dart:io';

import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;

import '../common/constant.dart';
import '../models/exif.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  final ScrollController _scrollController = ScrollController();
  String _imagePath = "";
  image.Image? _image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(normalPadding),
                child: Text(
                  AppLocalizations.of(context)!.selectImage,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(normalPadding),
                child: InkWell(
                  onTap: _selectImage,
                  child: DashedContainer(
                    width: double.infinity,
                    height: 300,
                    child: _imagePath.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                width: 64.0,
                                "assets/images/upload.svg",
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.secondary,
                                    BlendMode.srcIn),
                              ),
                              const SizedBox(
                                height: normalMargin,
                              ),
                              Text("请选择一张照片或拖拽照片至此处")
                            ],
                          )
                        : Image.file(
                            File(_imagePath),
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(normalPadding),
                child: Text(
                  "Exif信息",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            _imagePath.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text("暂无数据"),
                    ),
                  )
                : FutureBuilder<image.Image?>(
                    future: _fetchExifData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.hasExif) {
                        _image = snapshot.data!.clone();
                        final exifData = snapshot.data?.exif;
                        return _buildExifData(exifData!);
                      }
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: snapshot.hasData
                              ? const Text("无Exif数据")
                              : const CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: extraLargePadding + normalButtonHeight,
              ),
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(normalPadding),
            child: SizedBox(
              width: normalButtonWidth,
              height: normalButtonHeight,
              child: FilledButton(
                child: Text(AppLocalizations.of(context)!.save),
                onPressed: () {
                  _saveExifData();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "tif", "tiff"],
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _imagePath = result.files.single.path!;
      });
    }
  }

  Future<image.Image?> _fetchExifData() {
    return compute((path) {
      return image.decodeImageFile(path);
    }, _imagePath);
  }

  Widget _buildExifData(image.ExifData directories) {
    final getTagName = directories.getTagName;
    final List<ExifModel> exifModels = [];
    for (final name in directories.keys) {
      List<Map<String, image.IfdValue?>> info = [];
      final directory = directories[name];
      for (final tag in directory.keys) {
        final value = directory[tag];
        final tagName = getTagName(tag);
        if (tagName != "<unknown>" &&
            value?.type != image.IfdValueType.undefined) {
          info.add({tagName: value});
        }
      }
      exifModels.add(ExifModel(name, info));
      for (final subName in directory.sub.keys) {
        List<Map<String, image.IfdValue?>> subInfo = [];
        final subDirectory = directory.sub[subName];
        for (final tag in subDirectory.keys) {
          final value = subDirectory[tag];
          final subTagName = _getSubTagName(subName, tag);
          if (subTagName != "<unknown>" &&
              value?.type != image.IfdValueType.undefined) {
            subInfo.add({subTagName: value});
          }
        }
        exifModels.add(ExifModel(subName, subInfo));
      }
    }
    return Form(
      key: _formKey,
      child: SliverList.separated(
        itemBuilder: (BuildContext context, int index) {
          ExifModel exifModel = exifModels[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: normalMargin,
            ),
            child: Padding(
              padding: const EdgeInsets.all(normalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exifModel.tag.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (final info in exifModel.info)
                    Column(
                      children: _buildExifInfo(info, exifModel),
                    )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: normalMargin,
          );
        },
        itemCount: exifModels.length,
      ),
    );
  }

  List<Widget> _buildExifInfo(
      Map<String, image.IfdValue?> info, ExifModel exifModel) {
    return info.keys
        .map((key) => Padding(
              padding: const EdgeInsets.symmetric(vertical: normalPadding),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(key),
                  ),
                  const SizedBox(
                    width: normalMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      initialValue: info[key]!.toString(),
                      onChanged: (value) {
                        _changeExifValue(info, exifModel.tag, key, value);
                      },
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  String _getSubTagName(String subName, int tag) {
    switch (subName) {
      case "gps":
        {
          if (!image.exifGpsTags.containsKey(tag)) {
            return "<unknown>";
          }
          return image.exifGpsTags[tag]!.name;
        }
      case "interop":
        {
          if (!image.exifInteropTags.containsKey(tag)) {
            return "<unknown>";
          }
          return image.exifInteropTags[tag]!.name;
        }
      default:
        {
          if (!image.exifImageTags.containsKey(tag)) {
            return "<unknown>";
          }
          return image.exifImageTags[tag]!.name;
        }
    }
  }

  void _changeExifValue(
      Map<String, image.IfdValue?> info, String tag, String key, String value) {
    image.IfdValue? ifdValue = info[key]?.clone();
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
      } on FormatException catch (e) {
        debugPrint("格式不正确$e");
      }
    }
  }

  _setIfdValue(image.IfdValue ifdValue, String key, String value) {
    Type type = ifdValue.runtimeType;
    if (value.startsWith("[") && value.endsWith("]")) {
      List<String> valueArray = value.substring(1, value.length - 1).split(",");
      for (int i = 0; i < valueArray.length; i++) {
        final item = valueArray[i].trim();
        if (item.isNotEmpty) {
          _setSinglesValue(type, ifdValue, item, index: i);
        }
      }
    } else {
      _setSinglesValue(type, ifdValue, value);
    }
  }

  void _setSinglesValue(Type type, image.IfdValue ifdValue, String value,
      {index = 0}) {
    switch (type) {
      case image.IfdByteValue _:
      case image.IfdValueShort _:
      case image.IfdValueLong _:
      case image.IfdValueSByte _:
      case image.IfdValueSShort _:
      case image.IfdValueSLong _:
        ifdValue.setInt(int.parse(value), index);
        break;
      case image.IfdValueSingle _:
      case image.IfdValueDouble _:
        ifdValue.setDouble(double.parse(value), index);
        break;
      case image.IfdValueRational _:
      case image.IfdValueSRational _:
        int numerator = int.parse(value.split("/")[0]);
        int denominator = int.parse(value.split("/")[1]);
        ifdValue.setRational(numerator, denominator, index);
        break;
      case image.IfdValueAscii _:
        ifdValue.setString(value);
        break;
      default:
        break;
    }
  }

  void _saveExifData() async {
    if (_image != null) {
      // 这里添加这行代码是为了取出exif数据，否则exif数据不会保存到文件中
      // 不要删除这行代码
      _image?.exif = _image!.exif.clone();
    } else {
      _showTips("无法保存，请重试");
    }

    String extension = path.extension(_imagePath).substring(1);
    String fileName =
        "${path.basenameWithoutExtension(_imagePath)}-副本.$extension";
    if (Platform.isAndroid || Platform.isIOS) {
      _saveFileToMobile(fileName, extension);
    } else {
      _saveFile(fileName, extension);
    }
  }

  void _saveFileToMobile(String fileName, String extension) async {
    String lowerCaseExtension = extension.toLowerCase();
    Uint8List? bytes;
    if (lowerCaseExtension == "jpg" || lowerCaseExtension == "jpeg") {
      bytes = image.encodeJpg(_image!);
    } else if (lowerCaseExtension == "tif" || lowerCaseExtension == "tiff") {
      bytes = image.encodeTiff(_image!);
    } else {
      _showTips("不支持的文件格式");
    }
    if (bytes != null) {
      FilePicker.platform
          .saveFile(
        dialogTitle: "保存图片",
        type: FileType.custom,
        fileName: fileName,
        allowedExtensions: [extension],
        bytes: bytes,
      )
          .then((path) async {
        _showTips(path != null ? "保存成功" : "保存失败");
      });
    }
  }

  void _saveFile(String fileName, String extension) {
    FilePicker.platform.saveFile(
      dialogTitle: "保存图片",
      type: FileType.custom,
      fileName: fileName,
      allowedExtensions: [extension],
    ).then((path) async {
      if (path != null) {
        image.encodeImageFile(path, _image!).then((success) {
          _showTips(success ? "保存成功" : "保存失败");
        });
      }
    });
  }

  void _showTips(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(message),
      ),
    );
  }
}
