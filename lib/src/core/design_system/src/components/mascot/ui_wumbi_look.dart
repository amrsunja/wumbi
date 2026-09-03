import 'package:wumbi/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class UIWumbiLook extends StatelessWidget {
  const UIWumbiLook({super.key, this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.images.wumbiLook.path, height: height);
  }
}
