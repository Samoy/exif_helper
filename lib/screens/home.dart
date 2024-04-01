import 'package:exif_helper/screens/detail.dart';
import 'package:exif_helper/widgets/dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

import '../common/constant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(normalPadding),
        child: InkWell(
          child: DashedContainer(
            height: 300,
            width: double.infinity,
            child: Column(
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
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
