import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/system.dart';
import 'package:exif_helper/screens/select.dart';
import 'package:exif_helper/widgets/my_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
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
              trailing: item.options != null
                  ? DropdownButtonHideUnderline(
                      child: Consumer<SystemModel>(
                        builder: (context, systemModel, child) =>
                            DropdownButton<Enum>(
                          focusColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: normalPadding,
                          ),
                          enableFeedback: false,
                          value: item.value,
                          items: item.options!.map((o) {
                            return DropdownMenuItem(
                              value: o,
                              child: Text(AppLocalizations.of(context)!
                                  .systemValue(o.name)),
                            );
                          }).toList(),
                          onChanged: (Enum? value) {
                            if (value != null) {
                              systemModel.setSystemValue(value);
                            }
                          },
                        ),
                      ),
                    )
                  : Icon(
                      size: largeFontSize,
                      item.url != null
                          ? Icons.launch_outlined
                          : Icons.chevron_right_outlined,
                    ),
              onTap: item.options != null
                  ? null
                  : () {
                      _onTab(context, item);
                    },
            );
          },
          itemCount: _settings.length,
        ),
      ],
    );
  }

  void _onTab(BuildContext context, _SettingItem item) async {
    if (item.url != null) {
      if (await canLaunchUrl(item.url!)) {
        await launchUrl(item.url!);
      }
      return;
    }
    if (item.key == const Key("about")) {
      showAboutDialog(
        context: context,
        applicationIcon: const FlutterLogo(),
        applicationName: AppLocalizations.of(context)!.appTitle,
        applicationVersion: appVersion,
        applicationLegalese: "Copyright © 2023",
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
