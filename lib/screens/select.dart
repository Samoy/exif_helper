import 'package:exif_helper/common/constant.dart';
import 'package:exif_helper/models/system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SelectPage<T extends Enum> extends StatefulWidget {
  const SelectPage({
    super.key,
    this.title,
    required this.options,
  });

  final String? title;
  final Iterable<Enum> options;

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title != null
          ? AppBar(
              title: Text(widget.title!),
            )
          : null,
      body: ListView.separated(
          itemBuilder: (context, index) {
            Enum option = widget.options.elementAt(index);
            return Consumer<SystemModel>(builder: (context, system, child) {
              return ListTile(
                minVerticalPadding: normalPadding,
                selected:
                    option == system.currentSystemValue[option.runtimeType],
                selectedTileColor:
                    Theme.of(context).colorScheme.primaryContainer,
                title: Text(
                    AppLocalizations.of(context)!.systemValue(option.name)),
                onTap: () {
                  system.setSystemValue(option);
                },
              );
            });
          },
          separatorBuilder: (context, index) => const Divider(
                thickness: 1,
                height: 1,
              ),
          itemCount: widget.options.length),
    );
  }
}
