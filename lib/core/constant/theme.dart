import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pantau_app/core/constant/colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.backgroundColor,
  useMaterial3: true,
  primaryTextTheme: primaryTextTheme,
  textTheme: primaryTextTheme
);

final TextTheme primaryTextTheme = GoogleFonts.poppinsTextTheme().copyWith(
  titleLarge: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  ),
  titleMedium: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  ),
  titleSmall: GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  ),
  labelLarge: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  ),
  labelMedium: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  ),
  labelSmall: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  ),
  bodyLarge: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  ),
  bodyMedium: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  ),
  bodySmall: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  ),
);