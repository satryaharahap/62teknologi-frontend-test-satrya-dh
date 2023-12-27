import 'package:enamduatekno/main.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme base) {
    const String fontName = 'WorkSans';
    return base.copyWith(
      headline1: base.headline1?.copyWith(fontFamily: fontName),
      headline2: base.headline2?.copyWith(fontFamily: fontName),
      headline3: base.headline3?.copyWith(fontFamily: fontName),
      headline4: base.headline4?.copyWith(fontFamily: fontName),
      headline5: base.headline5?.copyWith(fontFamily: fontName),
      headline6: base.headline6?.copyWith(fontFamily: fontName),
      button: base.button?.copyWith(fontFamily: fontName),
      caption: base.caption?.copyWith(fontFamily: fontName),
      bodyText1: base.bodyText1?.copyWith(fontFamily: fontName),
      bodyText2: base.bodyText2?.copyWith(fontFamily: fontName),
      subtitle1: base.subtitle1?.copyWith(fontFamily: fontName),
      subtitle2: base.subtitle2?.copyWith(fontFamily: fontName),
      overline: base.overline?.copyWith(fontFamily: fontName),
    );
  }

  static ThemeData buildLightTheme() {
    final Color primaryColor = HexColor('#54D3C2');
    final Color secondaryColor = HexColor('#54D3C2');
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      indicatorColor: Colors.white,
      splashColor: Colors.white24,
      splashFactory: InkRipple.splashFactory,
      canvasColor: Colors.white,
      backgroundColor: const Color(0xFFFFFFFF),
      scaffoldBackgroundColor: const Color(0xFFF6F6F6),
      errorColor: const Color(0xFFB00020),
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      platform: TargetPlatform.iOS,
    );
  }

  static const Color mainColor = const Color(0xffbd291e);
  static const Color secondColor = const Color(0xfffec926);
  static const Color notWhite = Color(0xFFEDF0F2);

  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Roboto';

  static const Color blue = Color(0xFF03a9f4);
  static const Color indigo = Color(0xFF25476);
  static const Color purple = Color(0xFFab47bc);
  static const Color pink = Color(0xFFf06292);
  static const Color red = Color(0xFFdf5645);
  static const Color orange = Color(0xFFfa9f1b);
  static const Color yellow = Color(0xFFffe405);
  static const Color green = Color(0xFFFCC2E);
  static const Color teal = Color(0xFF26a69a);
  static const Color cyan = Color(0xFF0dcaf0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFcbd0d8);
  static const Color darkGray = Color(0xFF9ea2a8);
  static const Color gray100 = Color(0xFFf9fafc);
  static const Color gray200 = Color(0xFFedf1f6);
  static const Color gray300 = Color(0xFFe7ecf3);
  static const Color gray400 = Color(0xFFe7ecf3);
  static const Color gray500 = Color(0xFFe1e7f0);
  static const Color gray600 = Color(0xFFcbd0d8);
  static const Color gray700 = Color(0xFFb4b9c0);
  static const Color grey = Color(0xFF9ea2a8);
  static const Color gray800 = Color(0xFF9ea2a8);
  static const Color gray900 = Color(0xFF878b90);
  static const Color primary = Color(0xFF25476a);
  static const Color secondary = Color(0xFF26a69a);
  static const Color success = Color(0xFF9FCC2E);
  static const Color info = Color(0xFF03a9f4);
  static const Color warning = Color(0xFFfa9f1b);
  static const Color danger = Color(0xFFdf5645);
  static const Color light = Color(0xFFe1e7f0);
  static const Color dark = Color(0xFF373c43);


  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );



}
