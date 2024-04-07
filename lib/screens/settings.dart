import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/system.dart';
import 'package:exif_helper/widgets/my_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
        const Key("theme"),
        icon: Icons.color_lens,
        title: AppLocalizations.of(context)!.theme,
        options: ThemeMode.values,
        value: context.watch<SystemModel>().currentThemeMode,
      ),
      _SettingItem<Language>(
        const Key("language"),
        icon: Icons.language,
        title: AppLocalizations.of(context)!.language,
        options: Language.values,
        value: context.watch<SystemModel>().currentLanguage,
      ),
      _SettingItem<Language>(const Key("privacy"),
          icon: Icons.gpp_good_outlined,
          title: AppLocalizations.of(context)!.privacy,
          url: Uri.parse("https://www.google.com")),
      _SettingItem<Language>(
        const Key("terms"),
        icon: Icons.insert_drive_file_outlined,
        title: AppLocalizations.of(context)!.terms,
        url: Uri.parse("https://www.baidu.com"),
      ),
      _SettingItem<Language>(
        const Key("about"),
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
        MySliverAppBar(
          title: AppLocalizations.of(context)!.settings,
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
              subtitle: item.value != null
                  ? Text(AppLocalizations.of(context)!
                      .systemValue(item.value!.name))
                  : null,
              onTap: () {
                _onTap(context, item);
              },
            );
          },
          itemCount: _settings.length,
        ),
      ],
    );
  }

  void _onTap(BuildContext context, _SettingItem item) async {
    if (item.options != null) {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(item.title),
            children: item.options!.map((e) {
              return SimpleDialogOption(
                child: Row(
                  children: [
                    Radio(
                      value: e.name,
                      groupValue: item.value?.name,
                      onChanged: (value) {},
                    ),
                    Text(AppLocalizations.of(context)!.systemValue(e.name)),
                  ],
                ),
                onPressed: () {
                  context.read<SystemModel>().setSystemValue(e);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          );
        },
      );
    }
    if (item.url != null) {
      if (await canLaunchUrl(item.url!)) {
        await launchUrl(item.url!);
      }
      return;
    }
    if (item.key == const Key("about")) {
      showAboutDialog(
        context: context,
        applicationIcon: Image.asset(
          "assets/images/logo.png",
          width: dialogLogoSize,
        ),
        applicationName: AppLocalizations.of(context)!.appTitle,
        applicationVersion: appVersion,
        applicationLegalese: "Copyright © ${DateTime.now().year}",
      );
    }
  }
}

class _SettingItem<T extends Enum> {
  const _SettingItem(
    this.key, {
    required this.icon,
    required this.title,
    this.options,
    this.value,
    this.url,
  });

  final Key key;
  final IconData icon;
  final String title;
  final Iterable<T>? options;
  final T? value;
  final Uri? url;
}
