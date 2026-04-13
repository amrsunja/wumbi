import 'package:flutter/material.dart';

class UiCircleColorBadge extends StatelessWidget {
  const UiCircleColorBadge({
    super.key,
    required this.color,
    this.size = 10
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: .circular(100),
        boxShadow: [
          BoxShadow(
            blurRadius: size,
            color: color
          )
        ]
      ),
    );
  }
}









