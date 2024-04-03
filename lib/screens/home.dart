import 'dart:io';
import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:exif_helper/extensions/platform_extension.dart';
import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;

import '../common/constant.dart';
import '../models/exif.dart';

enum _Menu { clear, reset }

typedef FetchImageFunc = Future<image.Image?> Function(String);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _allowedExtensions = ["jpg", "jpeg", "tif", "tiff"];
  final double fileIconSize = 64.0;

  String _imagePath = "";
  image.Image? _image;
  bool _isDragging = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  Future<image.Image?>? _imageData;

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
            SliverAppBar(
              title: Text(AppLocalizations.of(context)!.home),
              actions: [
                AnimatedContainer(
                  width: _showSearch ? 200 : 0,
                  height: 40,
                  duration: const Duration(milliseconds: 100),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onEditingComplete: _searchExif,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      hintText: AppLocalizations.of(context)!.searchExif,
                      suffixIcon:
                          _searchController.text.isNotEmpty && _showSearch
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  icon: const Icon(Icons.clear_outlined),
                                )
                              : null,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _searchExif,
                  icon: const Icon(Icons.search_outlined),
                ),
                PopupMenuButton<_Menu>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: _menuSelected,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<_Menu>>[
                    PopupMenuItem<_Menu>(
                      value: _Menu.reset,
                      child: ListTile(
                        leading: const Icon(Icons.refresh_outlined),
                        title: Text(AppLocalizations.of(context)!.resetExif),
                      ),
                    ),
                    PopupMenuItem<_Menu>(
                      value: _Menu.clear,
                      child: ListTile(
                        leading: const Icon(Icons.clear_all_outlined),
                        title: Text(AppLocalizations.of(context)!.clearImage),
                      ),
                    ),
                  ],
                ),
              ],
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(normalPadding),
                child: InkWell(
                  onTap: _selectImage,
                  child: DashedContainer(
                    width: double.infinity,
                    height: 300,
                    color: _isDragging
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    child: PlatformExtension.isDesktop
                        ? DropTarget(
                            onDragDone: (detail) {
                              _onDragDone(context, detail);
                            },
                            onDragEntered: (detail) {
                              setState(() {
                                _isDragging = true;
                              });
                            },
                            onDragExited: (detail) {
                              setState(() {
                                _isDragging = false;
                              });
                            },
                            child: _buildImagePanel(),
                          )
                        : _buildImagePanel(),
                  ),
                ),
              ),
            ),
            _imagePath.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!
                            .supportImageFormatBelow),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var extension in _allowedExtensions)
                              Padding(
                                padding:
                                    const EdgeInsets.all(normalPadding / 2),
                                child: SvgPicture.asset(
                                  "assets/images/$extension.svg",
                                  width: fileIconSize,
                                  height: fileIconSize,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : FutureBuilder(
                    future: _imageData,
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.done
                          ? (() {
                              image.Image? img = snapshot.data;
                              _image = img;
                              return img == null
                                  ? SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .noExifData),
                                      ),
                                    )
                                  : _buildExifData(img.exif);
                            }())
                          : const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                    },
                  ),
          ],
        ),
        if (_imagePath.isNotEmpty)
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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.saveImage),
                          content:
                              Text(AppLocalizations.of(context)!.saveImageInfo),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FilledButton(
                              child: Text(AppLocalizations.of(context)!.ok),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _saveExifData();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePanel() {
    return _imagePath.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                width: 64.0,
                "assets/images/upload.svg",
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.secondary, BlendMode.srcIn),
              ),
              const SizedBox(
                height: normalMargin,
              ),
              Text(
                  "${AppLocalizations.of(context)!.selectImage}${PlatformExtension.isDesktop ? AppLocalizations.of(context)!.dragImage : ""}")
            ],
          )
        : Image.file(
            File(_imagePath),
            fit: BoxFit.contain,
          );
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
          return Container(
            margin: index == exifModels.length - 1
                ? const EdgeInsets.only(bottom: 80)
                : EdgeInsets.zero,
            child: Card(
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
        .where((element) => element
            .contains(RegExp(_searchController.text, caseSensitive: false)))
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

  void _menuSelected(_Menu item) {
    switch (item) {
      case _Menu.reset:
        _resetExif();
        break;
      case _Menu.clear:
        _clearImage();
        break;
    }
  }

  Future<image.Image?> _fetchExifData(String path) {
    return compute((path) {
      return path.isEmpty
          ? null
          : image.decodeImageFile(path).then((value) => value);
    }, path);
  }

  void _searchExif() {
    setState(() {
      if (!_showSearch) {
        _showSearch = true;
      } else if (_searchController.text.isEmpty) {
        _showSearch = false;
      }
      _showSearch
          ? _searchFocusNode.requestFocus()
          : _searchFocusNode.unfocus();
    });
  }

  void _resetExif() {
    _formKey.currentState?.reset();
  }

  void _clearImage() {
    _image = null;
    setState(() {
      _imagePath = "";
    });
  }

  void _selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
    );
    if (result != null) {
      _setImagePath(result.files.single.path!);
    }
  }

  void _onDragDone(BuildContext context, DropDoneDetails detail) {
    setState(() {
      _isDragging = false;
    });
    if (detail.files.isNotEmpty) {
      String filePath = detail.files.first.path;
      String extension = path.extension(filePath).substring(1).toLowerCase();
      if (_allowedExtensions.contains(extension)) {
        _setImagePath(detail.files.first.path);
      } else {
        _showTips(AppLocalizations.of(context)!.invalidImageType);
      }
    }
  }

  void _setImagePath(String path) {
    setState(() {
      _imagePath = path;
    });
    _imageData = _fetchExifData(_imagePath);
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
        debugPrint(e.message);
      }
    }
  }

  _setIfdValue(image.IfdValue ifdValue, String key, String value) {
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

  void _setSinglesValue({
    required image.IfdValue ifdValue,
    required String value,
    index = 0,
  }) {
    Type type = ifdValue.runtimeType;
    switch (type) {
      case const (image.IfdByteValue):
      case const (image.IfdValueShort):
      case const (image.IfdValueLong):
      case const (image.IfdValueSByte):
      case const (image.IfdValueSShort):
      case const (image.IfdValueSLong):
        ifdValue.setInt(int.parse(value), index);
        break;
      case const (image.IfdValueSingle):
      case const (image.IfdValueDouble):
        ifdValue.setDouble(double.parse(value), index);
        break;
      case const (image.IfdValueRational):
      case const (image.IfdValueSRational):
        int numerator = int.parse(value.split("/")[0]);
        int denominator = int.parse(value.split("/")[1]);
        ifdValue.setRational(numerator, denominator, index);
        break;
      case const (image.IfdValueAscii):
        ifdValue.setString(value);
        break;
      default:
        break;
    }
  }

  void _saveExifData() async {
    String extension = path.extension(_imagePath).substring(1);
    String fileName =
        "${path.basenameWithoutExtension(_imagePath)}-副本.$extension";
    if (PlatformExtension.isMobile) {
      _saveFileToMobile(fileName, extension);
    } else {
      _saveFile(fileName, extension);
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

  void _showTips(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(message),
      ),
    );
  }
}
