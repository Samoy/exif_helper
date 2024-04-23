import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/extensions/platform_extension.dart';
import 'package:exif_helper/models/image_path.dart';
import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:exif_helper/widgets/desktop_image_panel.dart';
import 'package:exif_helper/widgets/image_panel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                      key: const ValueKey("home_image_panel"),
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
                  : ImagePanel(
                      imagePath: imagePathModel.imagePath,
                      key: const ValueKey("home_image_panel"),
                    ),
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
