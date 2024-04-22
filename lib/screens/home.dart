import 'package:exif_helper/models/search.dart';
import 'package:exif_helper/widgets/home_app_bar.dart';
import 'package:exif_helper/widgets/home_image_container.dart';
import 'package:exif_helper/widgets/home_image_exif.dart';
import 'package:exif_helper/widgets/home_save_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            HomeAppBar(
              key: const ValueKey("home_app_bar"),
            ),
            const HomeImageContainer(
              key: ValueKey("home_select_image_container"),
            ),
            Consumer<SearchModel>(
              builder: (context, searchModel, child) {
                return HomeExifContainer(
                  key: const ValueKey("home_exif_container"),
                  query: searchModel.searchText,
                );
              },
            ),
          ],
        ),
        const HomeSaveButton(
          key: ValueKey("home_save_button"),
        ),
      ],
    );
  }
}
