import 'package:flutter/material.dart';

import '../widgets/my_sliver_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        MySliverAppBar(
          title: AppLocalizations.of(context)!.recent,
        ),
      ],
    );
  }
}
