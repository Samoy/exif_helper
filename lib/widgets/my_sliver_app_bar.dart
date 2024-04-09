import 'package:flutter/material.dart';

import '../common/constant.dart';

class MySliverAppBar extends StatefulWidget {
  const MySliverAppBar({super.key, this.title});

  final String? title;

  @override
  State<MySliverAppBar> createState() => _MySliverAppBarState();
}

class _MySliverAppBarState extends State<MySliverAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.all(normalPadding),
        title: widget.title != null
            ? Text(
                widget.title!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              )
            : null,
      ),
    );
  }
}
