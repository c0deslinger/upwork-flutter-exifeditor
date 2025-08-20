import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  // Private Constructor
  AppTheme._();

  static const textColorLightMode = Color(0xFF4B4F4E);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 8, 40, 43),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
            !Platform.isIOS ? Brightness.dark : Brightness.dark,
        statusBarIconBrightness:
            !Platform.isIOS ? Brightness.light : Brightness.dark,
      ),
      titleTextStyle: GoogleFonts.mPlusRounded1c(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      // color: const Color.fromARGB(255, 42, 178, 115),
      shadowColor: Colors.transparent,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreenDark1),
    scaffoldBackgroundColor: const Color(0xFFFCF9F2),
    canvasColor: Colors.white,
    primaryColor: AppColors.titleBlack,
    colorScheme: const ColorScheme.light(
      // surface: Color(0xFFFFCDD9),
      primary: textColorLightMode,
      onSurface: AppColors.titleBlack, // <-- SEE HERE
    ),
    iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(iconColor: WidgetStatePropertyAll(Colors.white))),
    hintColor: AppColors.greyBase3,
    checkboxTheme: const CheckboxThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.titleBlack)),
    textTheme: TextTheme(
        labelMedium: GoogleFonts.mPlusRounded1c(color: textColorLightMode),
        labelSmall: GoogleFonts.mPlusRounded1c(color: textColorLightMode),
        bodySmall: GoogleFonts.mPlusRounded1c(
          color: textColorLightMode,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.mPlusRounded1c(
          color: textColorLightMode,
          fontSize: 16,
        ),
        displayMedium: GoogleFonts.mPlusRounded1c(
          color: textColorLightMode,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.mPlusRounded1c(
            color: textColorLightMode,
            fontSize: 16,
            fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.mPlusRounded1c(
            color: textColorLightMode,
            fontSize: 12,
            fontWeight: FontWeight.w500)),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.titleGrey),
    ),
    indicatorColor: textColorLightMode,
    dividerColor: textColorLightMode,
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: GoogleFonts.mPlusRounded1c(
          color: textColorLightMode, fontSize: 12, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    cardTheme: const CardThemeData(color: Colors.white),
    popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        textStyle: GoogleFonts.mPlusRounded1c(
            color: textColorLightMode, fontSize: 14)),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 45, 55, 59),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
            Platform.isIOS ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            Platform.isIOS ? Brightness.dark : Brightness.light,
      ),
      titleTextStyle: GoogleFonts.mPlusRounded1c(
          fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      // color: const Color(0xFF1E1E1E), // Dark AppBar background
      shadowColor: Colors.transparent,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreenDark1),
    scaffoldBackgroundColor:
        const Color.fromARGB(255, 45, 45, 45), // Dark background
    canvasColor: const Color(0xFF1E1E1E),
    primaryColor: Colors.white, // Primary text color in dark mode
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF2C2C2C),
      primary: AppColors.tabColor,
      onSurface: Colors.white,
    ),
    iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(iconColor: WidgetStatePropertyAll(Colors.white))),
    hintColor: AppColors.greyBase3,
    checkboxTheme: const CheckboxThemeData(
      fillColor: WidgetStatePropertyAll(Colors.white),
      checkColor: WidgetStatePropertyAll(Colors.black),
    ),
    textTheme: TextTheme(
        labelMedium: GoogleFonts.mPlusRounded1c(color: Colors.white),
        labelSmall: GoogleFonts.mPlusRounded1c(color: Colors.white),
        bodySmall: GoogleFonts.mPlusRounded1c(
          color: Colors.white,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.mPlusRounded1c(
          color: Colors.white,
          fontSize: 16,
        ),
        displayMedium: GoogleFonts.mPlusRounded1c(
          color: Colors.white,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.mPlusRounded1c(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.mPlusRounded1c(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white),
    ),
    indicatorColor: Colors.white,
    dividerColor: const Color(0xFF2C2C2C), // Divider color for dark mode
    cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: GoogleFonts.mPlusRounded1c(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    popupMenuTheme: PopupMenuThemeData(
        color: const Color.fromARGB(255, 73, 73, 73),
        textStyle:
            GoogleFonts.mPlusRounded1c(color: Colors.white, fontSize: 14)),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1E1E)),
  );
}
