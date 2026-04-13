import 'package:flutter/material.dart';

import '../../app_ui.dart';

class UIAlert extends StatelessWidget {
	final String label;
	final Color color;
	final Color contentColor;

	const UIAlert.success({
		super.key,
		required this.label
	}) : color = UIColorToken.pos400,
			 contentColor = UIColorToken.white;

	const UIAlert.info({
		super.key,
		required this.label
	}) : color = UIColorToken.white,
			 contentColor = UIColorToken.bismark;

	const UIAlert.error({
		super.key,
		required this.label
	}) : color = UIColorToken.neg400,
			 contentColor = UIColorToken.white;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: color,
				borderRadius: BorderRadius.circular(12)
			),
			child: Text(
				label,
        style: UITextStyleToken.interMedium.copyWith(
          color: contentColor
        ),
			),
		);
	}
}
