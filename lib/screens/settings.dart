import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<_SettingItem> _settings = [];

  void _buildSettings() {
    _settings = [
      _SettingItem<ThemeMode>(
        key: const Key("theme"),
        icon: Icons.color_lens,
        title: AppLocalizations.of(context)!.theme,
      ),
      _SettingItem<Language>(
        key: const Key("language"),
        icon: Icons.language,
        title: AppLocalizations.of(context)!.language,
      ),
      _SettingItem<Language>(
        key: const Key("privacy"),
        icon: Icons.gpp_good_outlined,
        title: AppLocalizations.of(context)!.privacy,
      ),
      _SettingItem<Language>(
        key: const Key("terms"),
        icon: Icons.insert_drive_file_outlined,
        title: AppLocalizations.of(context)!.terms,
      ),
      _SettingItem<Language>(
        key: const Key("about"),
        icon: Icons.info_outline,
        title: AppLocalizations.of(context)!.about,
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
        SliverList.builder(
          itemBuilder: (context, index) {
            _SettingItem item = _settings[index];
            return ListTile(
              minVerticalPadding: normalPadding,
              leading: Icon(
                item.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right_outlined),
              onTap: () {},
            );
          },
          itemCount: _settings.length,
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
