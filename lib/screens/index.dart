import 'package:exif_helper/screens/home.dart';
import 'package:exif_helper/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../extensions/platform_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with WindowListener {
  int _selectedIndex = 0;

  List<_ScaffoldDestination> _destinations = <_ScaffoldDestination>[];

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  void _init() {
    if (PlatformExtension.isDesktop) {
      (() async {
        await windowManager.setPreventClose(true);
      })();
    }
  }

  void _initDestinations() {
    _destinations = [
      _ScaffoldDestination(
        icon: const Icon(Icons.history_outlined),
        label: AppLocalizations.of(context)!.recent,
        page: const HomePage(),
        selectedIcon: const Icon(Icons.history),
      ),
      _ScaffoldDestination(
        icon: const Icon(Icons.settings_outlined),
        label: AppLocalizations.of(context)!.settings,
        page: const SettingsPage(),
        selectedIcon: const Icon(Icons.settings),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_destinations.isEmpty) {
      _initDestinations();
    }
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      if (orientation == Orientation.landscape) {
        return _buildLandscape();
      }
      return _buildPortrait();
    });
  }

  // 构建横屏
  Scaffold _buildLandscape() {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: 0,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              minWidth: 100,
              labelType: NavigationRailLabelType.all,
              destinations: _destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.icon,
                      label: Text(item.label),
                      selectedIcon: item.selectedIcon,
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _destinations[_selectedIndex].page,
            ),
          ],
        ),
      ),
    );
  }

  // 构建竖屏
  Scaffold _buildPortrait() {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: _destinations
            .map((item) => NavigationDestination(
                  icon: item.icon,
                  label: item.label,
                  selectedIcon: item.selectedIcon,
                ))
            .toList(),
      ),
      body: _destinations[_selectedIndex].page,
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (!mounted) return;
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.exifConfirm),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

class _ScaffoldDestination {
  const _ScaffoldDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final Icon icon;
  final Icon selectedIcon;
  final Widget page;
}
