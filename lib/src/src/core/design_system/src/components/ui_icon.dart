import 'package:fiin/src/src/core/locale/l10n.dart';
import 'package:flutter/material.dart';

import '../../app_ui.dart';

class UIIcon extends StatelessWidget {
	final String assetIcon;
	final Color? color;
	final bool defaultColor;
	final double? size;
	final Alignment? alignment;
	final VoidCallback? onTap;

	const UIIcon(
		this.assetIcon, {
		super.key,
		this.color,
		this.defaultColor = false,
		this.size,
		this.alignment,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		final theme = AppTheme.of(context);
    final locale = Localizations.localeOf(context);

		return UITap(
			onTap: onTap,
			child: Transform.flip(
        flipX: locale.languageCode == L10n.ar.languageCode,
			  child: UIIconToken.toIcon(
			  	assetIcon,
			  	color: defaultColor ? null : color ?? theme.colors.contentColor,
			  	size: size,
			  	alignment: alignment
			  ),
			)
		);
	}
}
