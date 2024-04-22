import 'package:exif_helper/models/image_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/constant.dart';
import '../extensions/platform_extension.dart';
import 'dashed_container.dart';
import 'desktop_image_panel.dart';
import 'image_panel.dart';

typedef OnSelectImage = void Function(String path);

class HomeImageContainer extends StatefulWidget {
  const HomeImageContainer({super.key});

  @override
  State<StatefulWidget> createState() => _HomeImageContainerState();
}

class _HomeImageContainerState extends State<HomeImageContainer> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePathModel>(builder: (context, imagePathModel, child) {
      return SliverToBoxAdapter(
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
                      imagePath: imagePathModel.imagePath,
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
                          imagePathModel.imagePath = path;
                        }
                      },
                    )
                  : ImagePanel(imagePath: imagePathModel.imagePath),
            ),
          ),
        ),
      );
    });
  }

  void _selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    if (result != null) {
      if (mounted) {
        Provider.of<ImagePathModel>(context, listen: false).imagePath =
            result.files.single.path!;
      }
    }
  }
}
