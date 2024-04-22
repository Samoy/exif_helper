import 'package:exif_helper/models/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/image_exif.dart';
import '../models/image_path.dart';

enum Menu { clear, reset }

typedef OnSearch = void Function(String text);

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchModel>(builder: (context, searchModel, child) {
      return SliverAppBar(
        title: Text(AppLocalizations.of(context)!.exif),
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
                suffixIcon:
                    searchModel.searchText.isNotEmpty && searchModel.showSearch
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
          PopupMenuButton<Menu>(
            icon: const Icon(Icons.more_vert),
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.reset,
                child: ListTile(
                  leading: const Icon(Icons.refresh_outlined),
                  title: Text(AppLocalizations.of(context)!.resetExif),
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.clear,
                child: ListTile(
                  leading: const Icon(Icons.clear_all_outlined),
                  title: Text(AppLocalizations.of(context)!.clearImage),
                ),
              ),
            ],
          ),
        ],
        pinned: true,
      );
    });
  }

  void _onMenuSelected(Menu item) {
    if (item == Menu.reset) {
      Provider.of<ImageExifModel>(context, listen: false).resetExif();
    }
    if (item == Menu.clear) {
      Provider.of<ImagePathModel>(context, listen: false).clearImage();
    }
  }
}
