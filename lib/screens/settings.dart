import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<_SettingItem> _settings = [];
  final _formKey = GlobalKey<FormState>();

  void _buildSettings() {
    _settings = [
      _SettingItem<ThemeMode>(
        key: const Key("theme"),
        icon: Icons.color_lens,
        title: AppLocalizations.of(context)!.theme,
        options: ThemeMode.values,
        value: context.watch<SystemModel>().currentThemeMode,
      ),
      _SettingItem<Language>(
        key: const Key("language"),
        icon: Icons.language,
        title: AppLocalizations.of(context)!.language,
        options: Language.values,
        value: context.watch<SystemModel>().currentLanguage,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    _buildSettings();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          stretch: true,
          pinned: true,
          floating: true,
          expandedHeight: 100.0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.all(normalPadding),
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ),
        Form(
          key: _formKey,
          child: SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                _SettingItem<Enum> item = _settings[index];
                return ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  trailing: item.options != null
                      ? Consumer<SystemModel>(
                          builder: (context, system, child) {
                            return DropdownMenu(
                              initialSelection: item.value,
                              onSelected: (Enum? value) {
                                if (value != null) {
                                  if (item.value is Language) {
                                    system.setLanguage(value as Language);
                                  } else if (item.value is ThemeMode) {
                                    system.setThemeMode(value as ThemeMode);
                                  }
                                }
                              },
                              dropdownMenuEntries:
                                  item.options!.map<DropdownMenuEntry<Enum>>(
                                (e) {
                                  return DropdownMenuEntry(
                                    value: e,
                                    label: AppLocalizations.of(context)!
                                        .systemValue(
                                      e.name,
                                    ),
                                  );
                                },
                              ).toList(),
                            );
                          },
                        )
                      : null,
                );
              },
              childCount: _settings.length,
            ),
            itemExtent: 80,
          ),
        ),
      ],
    );
  }
}

class _SettingItem<T extends Enum> {
  const _SettingItem({
    Key? key,
    required this.icon,
    required this.title,
    this.options,
    this.value,
  });

  final IconData icon;
  final String title;
  final Iterable<T>? options;
  final T? value;
}
