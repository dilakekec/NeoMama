import 'package:flutter/material.dart';

import '../../models/baby_profile.dart';
import 'baby_form.dart';

class EditBabyScreen extends StatelessWidget {
  final BabyProfile baby;

  const EditBabyScreen({
    super.key,
    required this.baby,
  });

  @override
  Widget build(BuildContext context) {
    return BabyFormScreen(baby: baby);
  }
}
