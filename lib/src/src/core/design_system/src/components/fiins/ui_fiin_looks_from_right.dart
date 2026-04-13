import 'package:fiin/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class UIFiinLooksFromRight extends StatelessWidget {
  const UIFiinLooksFromRight({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.images.fiinLookRight.path,
      height: 64,
    );
  }
}


