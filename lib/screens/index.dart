import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/screens/recent.dart';
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

  void _buildDestinations() {
    _destinations = [
      _ScaffoldDestination(
        icon: Icons.history_outlined,
        label: AppLocalizations.of(context)!.recent,
        page: const RecentPage(),
        selectedIcon: Icons.history,
      ),
      _ScaffoldDestination(
        icon: Icons.settings_outlined,
        label: AppLocalizations.of(context)!.settings,
        page: const SettingsPage(),
        selectedIcon: Icons.settings,
      )
    ];
  }

  @override
  void didChangeDependencies() {
    _buildDestinations();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
              groupAlignment: -1,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: const SizedBox(
                height: appLogoSize,
                child: CircleAvatar(
                  child: FlutterLogo(),
                ),
              ),
              destinations: _destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: _buildIcon(item),
                      label: Text(item.label),
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
                  icon: _buildIcon(item),
                  label: item.label,
                ))
            .toList(),
      ),
      body: _destinations[_selectedIndex].page,
    );
  }

  Widget _buildIcon(_ScaffoldDestination destination) {
    bool selected = _selectedIndex == _destinations.indexOf(destination);
    const double selectedScale = 1.1;
    const double unselectedScale = 1.0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final scaleValue = Tween<double>(
          end: selected ? selectedScale : unselectedScale,
          begin: selected ? unselectedScale : selectedScale,
        ).animate(animation);
        return ScaleTransition(
          scale: scaleValue, // 使用这里的scaleValue替换原本的animation
          child: child,
        );
      },
      child: Icon(
        selected ? destination.selectedIcon : destination.icon,
        key: ValueKey<int>(_selectedIndex),
      ),
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
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}
