import 'package:flutter/material.dart';

class AppText {
  static TextStyle h1(BuildContext c) => Theme.of(c).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.w700,
      );

  static TextStyle h2(BuildContext c) => Theme.of(c).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w700,
      );

  static TextStyle body(BuildContext c) => Theme.of(c).textTheme.bodyMedium!.copyWith(
        height: 1.3,
      );

  static TextStyle caption(BuildContext c) => Theme.of(c).textTheme.bodySmall!.copyWith(
        color: Theme.of(c).hintColor,
      );
}