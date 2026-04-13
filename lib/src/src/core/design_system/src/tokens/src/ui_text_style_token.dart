part of '../../../app_ui.dart';

abstract class UITextStyleToken {
	static final TextStyle interExtra = GoogleFonts.inter(
		fontStyle: FontStyle.normal,
		fontWeight: FontWeight.w900,
	);
	static final TextStyle interBold = GoogleFonts.inter(
		fontStyle: FontStyle.normal,
		fontWeight: FontWeight.bold,
	);
	static final TextStyle interMedium = GoogleFonts.inter(
		fontStyle: FontStyle.normal,
		fontWeight: FontWeight.w500,
	);
	static final TextStyle interSemiBold = GoogleFonts.inter(
		fontStyle: FontStyle.normal,
		fontWeight: FontWeight.w600,
	);
	static final TextStyle interRegular = GoogleFonts.inter(
		fontStyle: FontStyle.normal,
		fontWeight: FontWeight.w300,
	);
}
