import 'package:flutter/cupertino.dart';
import '../../utils/constants.dart';

class IOSTheme {
  // Светлая тема iOS
  static CupertinoThemeData lightTheme(double interfaceFontSize) {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: _buildTextTheme(interfaceFontSize, Brightness.light),
    );
  }

  // Тёмная тема iOS
  static CupertinoThemeData darkTheme(double interfaceFontSize) {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
      barBackgroundColor: CupertinoColors.black,
      textTheme: _buildTextTheme(interfaceFontSize, Brightness.dark),
    );
  }

  // Построение TextTheme для iOS
  static CupertinoTextThemeData _buildTextTheme(
    double baseFontSize,
    Brightness brightness,
  ) {
    final color = brightness == Brightness.light ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoTextThemeData(
      primaryColor: color,
      textStyle: TextStyle(
        fontSize: baseFontSize,
        color: color,
      ),
      actionTextStyle: TextStyle(
        fontSize: baseFontSize,
        color: AppConstants.primaryColor,
      ),
      tabLabelTextStyle: TextStyle(
        fontSize: baseFontSize - 1,
        color: color,
      ),
      navTitleTextStyle: TextStyle(
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontSize: baseFontSize + 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      navActionTextStyle: TextStyle(
        fontSize: baseFontSize,
        color: AppConstants.primaryColor,
      ),
      pickerTextStyle: TextStyle(
        fontSize: baseFontSize + 2,
        color: color,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontSize: baseFontSize + 2,
        color: color,
      ),
    );
  }
}

