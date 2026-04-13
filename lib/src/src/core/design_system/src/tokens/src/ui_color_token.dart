part of '../../../app_ui.dart';


class UIColorToken {
	// DYNAMIC
	final Color bgColor;
	final Color fgColor;
	final Color contentColor;
	final Color secondContentColor;
	final Color disabledContentColor;

	const UIColorToken({
		required this.bgColor,
		required this.fgColor,
		required this.contentColor,
		required this.secondContentColor,
		required this.disabledContentColor,
	});
	
	factory UIColorToken.light() => UIColorToken(
		bgColor: cararra,
		fgColor: white,
		contentColor: bismark,
		secondContentColor: casper,
		disabledContentColor: Color(0xffE5E7EB),
	);

	factory UIColorToken.dark() => const UIColorToken(
		bgColor: Color(0xff120F1B),
		fgColor: Color(0xff15121F),
		contentColor: bismark,
		secondContentColor: casper,
		disabledContentColor: Color(0xffE5E7EB),
	);

	// GENERAL
	static const Color white = Color(0xffFFFFFF);
  static const Color athensGray = Color(0xffF3F4F6);
  static const Color bismark = Color(0xff456285);
  static const Color buttercup = Color(0xffF59E0B);
  static const Color cararra = Color(0xffFAFAF8);
  static const Color casper = Color(0xffAEC2D4);
  static const Color chelseaCucumber = Color(0xff97AF50);
  static const Color violet = Color(0xff8B5CF6);
  static const Color blue = Color(0xff3B82F6);
  static const Color linkWater = Color(0xffD1E3F4);
  static const Color mountainMeadow = Color(0xff65AF83);
	static const Color grey = Color(0xffA1A1A1);
	static const Color black = Color(0xff000000);
	static Color overlay = bismark.withValues(alpha: 0.5);

	// NEUTRAL
  static const Color neu700 = Color(0xff101010);
	static const Color neu600 = Color(0xff2F2F2F);
	static const Color neu500 = Color(0xff848383);
	static const Color neu400 = Color(0xffB3B3B3);
	static const Color neu300 = Color(0xffE6E6E6);
	static const Color neu200 = Color(0xffF4F4F4);
	static const Color neu100 = Color(0xffFAFAFA);
	static const Color neu50 = Color(0xffFFFFFF);

	// NEGATIVE 
	static const Color neg600 = Color(0xff640B17);
	static const Color neg500 = Color(0xffC03649);
	static const Color neg400 = Color(0xffFF697D);
  static const Color neg300 = Color(0xffE58D99);
	static const Color neg200 = Color(0xffFDEDEF);
	static const Color neg100 = Color(0xffFCF2F3);


	// Positive
	static const Color pos500 = Color(0xff68822C);
	static const Color pos400 = Color(0xff97AF50);
	static const Color pos300 = Color(0xffBED377);
	static const Color pos200 = Color(0xffECF9BE);
	static const Color pos100 = Color(0xffF7FFDB);
}
