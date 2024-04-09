import 'dart:async';

import 'package:exif_helper/extensions/platform_extension.dart';
import 'package:exif_helper/models/search.dart';
import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:exif_helper/widgets/desktop_image_panel.dart';
import 'package:exif_helper/widgets/image_panel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../common/constant.dart';
import '../models/exif.dart';

enum _Menu { clear, reset }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _allowedExtensions = ["jpg", "tif", "jpeg", "tiff"];
  final double fileIconSize = 64.0;
  bool _isDragging = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ExifModel>(
      builder: (context, exifModel, child) {
        return Consumer<SearchModel>(builder: (ctx, searchModel, child) {
          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    title: Text(AppLocalizations.of(context)!.exifInfo),
                    actions: [
                      AnimatedContainer(
                        width: searchModel.showSearch ? 200 : 0,
                        height: 40,
                        duration: const Duration(milliseconds: 100),
                        child: TextField(
                          focusNode: searchModel.searchFocusNode,
                          controller: searchModel.searchController,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            hintText: AppLocalizations.of(context)!.searchExif,
                            suffixIcon: searchModel.searchText.isNotEmpty &&
                                    searchModel.showSearch
                                ? IconButton(
                                    onPressed: () {
                                      searchModel.searchController.clear();
                                      searchModel.clearSearchText();
                                    },
                                    icon: const Icon(Icons.clear_outlined),
                                  )
                                : null,
                          ),
                          onEditingComplete: searchModel.searchExif,
                          onChanged: (text) {
                            searchModel.setSearchText(text);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: searchModel.searchExif,
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
                              title:
                                  Text(AppLocalizations.of(context)!.resetExif),
                            ),
                          ),
                          PopupMenuItem<_Menu>(
                            value: _Menu.clear,
                            child: ListTile(
                              leading: const Icon(Icons.clear_all_outlined),
                              title: Text(
                                  AppLocalizations.of(context)!.clearImage),
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
                              ? DesktopImagePanel(
                                  imagePath: exifModel.path,
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
                                  onDragDone: (path) {
                                    setState(() {
                                      _isDragging = false;
                                    });
                                    if (path != null) {
                                      _setImagePath(path);
                                    }
                                  },
                                )
                              : ImagePanel(imagePath: exifModel.path),
                        ),
                      ),
                    ),
                  ),
                  exifModel.path.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .supportImageFormatBelow),
                              const SizedBox(
                                height: smallMargin,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var extension in _allowedExtensions)
                                    Padding(
                                      padding: const EdgeInsets.all(
                                          normalPadding / 2),
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
                          future: exifModel.image,
                          builder: (context, snapshot) {
                            return snapshot.connectionState ==
                                    ConnectionState.done
                                ? (() {
                                    image.Image? img = snapshot.data;
                                    exifModel.setImageData(img);
                                    exifModel.setExifItems(img);
                                    return img == null
                                        ? SliverFillRemaining(
                                            hasScrollBody: false,
                                            child: Center(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .noExifData),
                                            ),
                                          )
                                        : _buildExifData(
                                            exifModel.exifItems.toList());
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
              if (exifModel.path.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(
                      normalPadding,
                    ),
                    width: normalButtonWidth,
                    child: FilledButton(
                      child: Text(AppLocalizations.of(context)!.save),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title:
                                  Text(AppLocalizations.of(context)!.saveImage),
                              content: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: normalButtonWidth,
                                ),
                                child: Text(AppLocalizations.of(context)!
                                    .saveImageInfo),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                      AppLocalizations.of(context)!.cancel),
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
            ],
          );
        });
      },
    );
  }

  Widget _buildExifData(List<ExifItem> exifModels) {
    return Form(
      key: _formKey,
      child: SliverList.separated(
        itemBuilder: (BuildContext context, int index) {
          ExifItem exifModel = exifModels[index];
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
      Map<String, image.IfdValue?> info, ExifItem exifItem) {
    String query = context.watch<SearchModel>().searchText;
    return info.keys
        .where(
            (element) => element.contains(RegExp(query, caseSensitive: false)))
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
                        Provider.of<ExifModel>(context, listen: false)
                            .changeExifValue(info, exifItem.tag, key, value);
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

  void _resetExif() {
    _formKey.currentState?.reset();
  }

  void _clearImage() {
    Provider.of<ExifModel>(context, listen: false).clearImage();
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

  void _setImagePath(String path) {
    Provider.of<ExifModel>(context, listen: false).setImagePath(path);
  }

  void _saveExifData() async {
    final imagePath = Provider.of<ExifModel>(context, listen: false).path;
    String extension = path.extension(imagePath).substring(1);
    String fileName = AppLocalizations.of(context)!
        .fileCopy(path.basenameWithoutExtension(imagePath), extension);
    if (PlatformExtension.isMobile) {
      _saveFileToMobile(fileName, extension);
    } else {
      _saveFile(fileName, extension);
    }
  }

  void _saveFile(String fileName, String extension) {
    final appContext = AppLocalizations.of(context)!;
    FilePicker.platform.saveFile(
      dialogTitle: appContext.saveImage,
      type: FileType.custom,
      fileName: fileName,
      allowedExtensions: [extension],
    ).then((path) async {
      if (path != null) {
        String lowerCaseExtension = extension.toLowerCase();
        Future<bool>? future;
        if (lowerCaseExtension == "jpg" || lowerCaseExtension == "jpeg") {
          future = image.encodeJpgFile(
              path, Provider.of<ExifModel>(context, listen: false).imageData!);
        } else if (lowerCaseExtension == "tif" ||
            lowerCaseExtension == "tiff") {
          future = image.encodeTiffFile(
              path, Provider.of<ExifModel>(context, listen: false).imageData!);
        }
        future?.then((success) {
          _showTips(success ? appContext.saveSuccess : appContext.saveFailed);
        });
      }
    });
  }

  void _saveFileToMobile(String fileName, String extension) async {
    final appContext = AppLocalizations.of(context)!;
    String lowerCaseExtension = extension.toLowerCase();
    Uint8List? bytes;
    if (lowerCaseExtension == "jpg" || lowerCaseExtension == "jpeg") {
      bytes = image
          .encodeJpg(Provider.of<ExifModel>(context, listen: false).imageData!);
    } else if (lowerCaseExtension == "tif" || lowerCaseExtension == "tiff") {
      bytes = image.encodeTiff(
          Provider.of<ExifModel>(context, listen: false).imageData!);
    } else {
      _showTips(appContext.invalidImageType);
    }
    if (bytes != null) {
      FilePicker.platform
          .saveFile(
        dialogTitle: appContext.saveImage,
        type: FileType.custom,
        fileName: fileName,
        allowedExtensions: [extension],
        bytes: bytes,
      )
          .then((path) async {
        _showTips(
            path != null ? appContext.saveSuccess : appContext.saveFailed);
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
