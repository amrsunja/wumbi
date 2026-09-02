import 'package:fiin/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class UIFiinLook extends StatelessWidget {
  const UIFiinLook({super.key, this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.images.fiinLook.path, height: height);
  }
}
