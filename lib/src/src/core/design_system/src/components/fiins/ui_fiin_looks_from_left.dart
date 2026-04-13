import 'package:fiin/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class UIFiinLooksFromLeft extends StatelessWidget {
  const UIFiinLooksFromLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.images.fiinLookLeft.path,
      height: 64,
    );
  }
}


