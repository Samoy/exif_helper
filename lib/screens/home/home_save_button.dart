import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/common/utils.dart';
import 'package:exif_helper/extensions/platform_extension.dart';
import 'package:exif_helper/models/image_exif.dart';
import 'package:exif_helper/models/image_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as image;
import 'dart:typed_data';

class HomeSaveButton extends StatefulWidget {
  const HomeSaveButton({super.key});

  @override
  State<HomeSaveButton> createState() => _HomeSaveButtonState();
}

class _HomeSaveButtonState extends State<HomeSaveButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageExifModel>(builder: (context, exifModel, child) {
      if (exifModel.imageData != null) {
        return Align(
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
                      title: Text(AppLocalizations.of(context)!.saveImage),
                      content: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: normalButtonWidth,
                        ),
                        child:
                            Text(AppLocalizations.of(context)!.saveImageInfo),
                      ),
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
        );
      }
      return Container();
    });
  }

  void _saveExifData() async {
    final imagePath =
        Provider.of<ImagePathModel>(context, listen: false).imagePath;
    String extension = path.extension(imagePath).substring(1);
    String fileName = AppLocalizations.of(context)!
        .fileCopy(path.basenameWithoutExtension(imagePath), extension);
    image.Image imageData =
        Provider.of<ImageExifModel>(context, listen: false).imageData!;
    if (PlatformExtension.isMobile) {
      _saveFileToMobile(fileName, imageData, extension);
    } else {
      _saveFile(fileName, imageData, extension);
    }
  }

  void _saveFile(String fileName, image.Image imageData, String extension) {
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
          future = image.encodeJpgFile(path, imageData);
        } else if (lowerCaseExtension == "tif" ||
            lowerCaseExtension == "tiff") {
          future = image.encodeTiffFile(path, imageData);
        }
        future?.then((success) {
          SnackBarUtils.showSnackBar(context,
              success ? appContext.saveSuccess : appContext.saveFailed);
        });
      }
    });
  }

  void _saveFileToMobile(
      String fileName, image.Image imageData, String extension) async {
    final appContext = AppLocalizations.of(context)!;
    String lowerCaseExtension = extension.toLowerCase();
    Uint8List? bytes;
    if (lowerCaseExtension == "jpg" || lowerCaseExtension == "jpeg") {
      bytes = image.encodeJpg(imageData);
    } else if (lowerCaseExtension == "tif" || lowerCaseExtension == "tiff") {
      bytes = image.encodeTiff(imageData);
    } else {
      SnackBarUtils.showSnackBar(context, appContext.invalidImageType);
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
        SnackBarUtils.showSnackBar(context,
            path != null ? appContext.saveSuccess : appContext.saveFailed);
      });
    }
  }
}
