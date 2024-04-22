import 'package:exif_helper/models/image_exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/constant.dart';

class HomeExifContainer extends StatefulWidget {
  const HomeExifContainer({super.key, this.query = ''});

  final String query;

  @override
  State<HomeExifContainer> createState() => _HomeExifContainerState();
}

class _HomeExifContainerState extends State<HomeExifContainer> {

  final double fileIconSize = 64.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageExifModel>(builder: (context, imageExifModel, child) {
      if (imageExifModel.loading) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (imageExifModel.image != null) {
        return _buildExifData(imageExifModel);
      }
      return SliverFillRemaining(
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
                for (var extension in allowedExtensions)
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
      );
    });
  }

  Widget _buildExifData(ImageExifModel imageExifModel) {
    final exifItems = imageExifModel.exifItems;
    return Form(
        key: imageExifModel.formKey,
        child: SliverList.separated(
          itemBuilder: (BuildContext context, int index) {
            ExifItem exif = exifItems[index];
            return Container(
              margin: index == exifItems.length - 1
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
                        exif.tag.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (final info in exif.info)
                        Column(
                          children: _buildExifInfo(info, exif),
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
          itemCount: exifItems.length,
        ));
  }

  List<Widget> _buildExifInfo(
      Map<String, image.IfdValue?> info, ExifItem exifItem) {
    return info.keys.map(
      (key) {
        final show = key.contains(RegExp(widget.query, caseSensitive: false));
        return SizedBox.fromSize(
          size: show ? null : Size.zero,
          child: Padding(
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
                      Provider.of<ImageExifModel>(context, listen: false)
                          .changeExifValue(info, exifItem, key, value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).toList();
  }
}
