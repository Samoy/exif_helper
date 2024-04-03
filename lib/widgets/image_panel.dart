import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/constant.dart';
import '../extensions/platform_extension.dart';

class ImagePanel extends StatefulWidget {
  final String imagePath;

  const ImagePanel({super.key, required this.imagePath});

  @override
  State<ImagePanel> createState() => _ImagePanelState();
}

class _ImagePanelState extends State<ImagePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.imagePath.isEmpty
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
            File(widget.imagePath),
            fit: BoxFit.contain,
          );
  }
}
