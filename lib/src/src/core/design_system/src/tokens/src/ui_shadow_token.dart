part of '../../../app_ui.dart';

abstract class UIShadowToken {

	static final dropShadow = [
		BoxShadow(
			color: UIColorToken.black.withOpacity(0.1),
			blurRadius: 4,
      spreadRadius: -2,
      offset: Offset(0, 2)
		)
	];

	static final buttonBlueShadow = [
		BoxShadow(
			color: UIColorToken.blue.withOpacity(0.8),
			blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1)
		)
	];
}
