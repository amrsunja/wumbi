part of '../../../app_ui.dart';

class UIIconToken {
	static final icons = Assets.icons;

	static Widget toIcon(
		/// icon - is the path to the asset icon
		String icon, {
		Color? color,
		double? size,
		Alignment? alignment,
		}) {
	  return SvgPicture.asset(
			icon,
			width: size,
			height: size,
			colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
			fit: BoxFit.contain,
			alignment: alignment ?? Alignment.center,
		);
	}
}
