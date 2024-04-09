import 'package:flutter/material.dart';

import '../widgets/my_sliver_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        MySliverAppBar(
          title: AppLocalizations.of(context)!.historyRecord,
        ),
      ],
    );
  }
}
