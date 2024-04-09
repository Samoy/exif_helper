import 'package:desktop_drop/desktop_drop.dart';
import 'package:exif_helper/widgets/image_panel.dart';
import 'package:flutter/material.dart';

typedef OnDragDoneCallback = void Function(String? path);

class DesktopImagePanel extends StatefulWidget {
  final String imagePath;

  final OnDragCallback<DropEventDetails>? onDragEntered;

  final OnDragCallback<DropEventDetails>? onDragExited;

  final OnDragCallback<DropEventDetails>? onDragUpdated;

  final OnDragDoneCallback? onDragDone;

  const DesktopImagePanel({
    super.key,
    required this.imagePath,
    this.onDragEntered,
    this.onDragUpdated,
    this.onDragDone,
    this.onDragExited,
  });

  @override
  State<DesktopImagePanel> createState() => _DesktopImagePanelState();
}

class _DesktopImagePanelState extends State<DesktopImagePanel> {
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (DropDoneDetails details) {
        widget.onDragDone?.call(details.files[0].path);
      },
      onDragEntered: widget.onDragEntered,
      onDragExited: widget.onDragExited,
      onDragUpdated: widget.onDragUpdated,
      child: ImagePanel(imagePath: widget.imagePath),
    );
  }
}
