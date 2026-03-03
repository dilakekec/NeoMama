import 'package:flutter/material.dart';
import 'neo_background.dart';
import 'app_spacing.dart';

class NeoScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final bool scroll;
  final bool safeArea;

  const NeoScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.scroll = true,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: AppSpacing.screen,
      child: child,
    );

    if (scroll) content = SingleChildScrollView(child: content);
    if (safeArea) content = SafeArea(child: content);

    return NeoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: content,
      ),
    );
  }
}