// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 15/3/2026
// Objectives: This file is responsible for providing the app text styles that are used in the app.
// FIX: Removed _withFontFamily wrapper — it was overwriting GoogleFonts internal font key
//      with plain 'Cairo' string which Flutter cannot resolve, causing Arabic fallback font.
//      Cairo font natively supports both Arabic and English so no wrapper is needed.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


import 'app_wight.dart';
import 'appcolors.dart';

abstract class AppTextStyles {

  // --------------------- REGULAR Text Styles - w400 ---------------------

  static TextStyle get font10LightGreyRegularCairo => GoogleFonts.cairo(
    color: AppColors.lightGrey,
    fontSize: 10.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font26BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 26.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font20BlackCairoSemiBold => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get redFont12CairoRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.red,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font16SecondaryBlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font10RegularMonserrat => GoogleFonts.cairo(
    fontSize: 10.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font10BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font10FullBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font16FullBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font10BlackRegularInter => GoogleFonts.inter(
    color: AppColors.text,
    fontSize: 10.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12PrimaryColorRegularCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.primary,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12LightGreyRegularCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.lightGrey,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12SecondaryBlackMontserratRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12MediumGreyRegularCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.mediumGrey,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font15MediumInverseBaseRegularCairo => GoogleFonts.cairo(
    fontSize: 15.sp,
    color: AppColors.inverseBase,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12RedRegularCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.red,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12BlackCairoBold => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.bold,
  );

  static TextStyle get font12BlackCairoSemiBold => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font12FullBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font11FullBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 11.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12FullBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12SecondaryBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font10SecondaryBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12BlueCairoRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.blue,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14BlackRegularCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12darkWhiteShadowRegular => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.darkWhiteShadow,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font16inverseBaseRegularCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.inverseBase,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14FullBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14FullBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.fullBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font14SecondaryBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14SecondaryBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16LightGreyRegularCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.lightGrey,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font16PrimaryColorRegularCairo => GoogleFonts.cairo(
    color: AppColors.primary,
    fontSize: 16.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font16BlackRegularCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 16.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font16WhiteRegularCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: Colors.white,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font18SecondaryBlackRegularCairo => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font19WhiteRegularCairo => GoogleFonts.cairo(
    fontSize: 19.sp,
    color: Colors.white,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font19BlackRegularCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 19.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font19BlackMediumCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 19.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font19LightGreyRegularCairo => GoogleFonts.cairo(
    fontSize: 19.sp,
    color: AppColors.lightGrey,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font20BlackRegularCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 20.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font23BlackRegularCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 23.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font12SpanTextCairoRegular => GoogleFonts.cairo(
    color: AppColors.spanText,
    fontSize: 12.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font11SpanTextCairoRegular => GoogleFonts.cairo(
    color: AppColors.spanText,
    fontSize: 11.sp,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14SpanTextCairoMedium => GoogleFonts.cairo(
    color: AppColors.spanText,
    fontSize: 12.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font10SpanTextCairoRegular => GoogleFonts.cairo(
    color: AppColors.spanText,
    fontSize: 10.sp,
    fontWeight: AppFontWeights.regular,
  );

  // --------------------- MEDIUM Text Styles - w500 ---------------------

  static TextStyle get font8SecondaryBlackCairo => GoogleFonts.cairo(
    fontSize: 8.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font8SecondaryBlackRegularCairo => GoogleFonts.cairo(
    fontSize: 8.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font10BlueCairo => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: AppColors.blue,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12PrimaryColorMediumCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.primary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font10BlackCairoMediam => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: const Color(0xff797979),
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12InputColorCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.inputColor,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12BlackCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12LighterGreyMediumCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.lighterGrey,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font10LighterGreyMediumCairo => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: AppColors.lighterGrey,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12ButtonCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.textButton,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12SecondaryBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16TextMediumCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12secondaryPrimaryCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12WhiteCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.background,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font13SecondaryBlackCairo => GoogleFonts.cairo(
    fontSize: 13.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12SecondaryBlackMediumCairo => GoogleFonts.cairo(
    color: AppColors.secondaryBlack,
    fontSize: 12.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font14SecondaryBlackCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font14BlackCairoMedium => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16BlackCairoMedium => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font14BlueCairoMedium => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.lightBlue,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16whiteCairoMedium => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.white,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font14TextButtonCairoMedium => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.textButton,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16MediumMonserrat => GoogleFonts.cairo(
    fontSize: 16.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16BlackCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.inputColor,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16SecondaryPrimaryCairoMedium => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16SecondaryBlackCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16SecondaryYelloCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16ButtonMediumCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.textButton,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16MediumDarkGreyCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.darkGrey,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16MediumInverseBaseCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.inverseBase,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16MediumSecondaryTextCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.secondaryText,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font12RegularSecondaryTextCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.secondaryText,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font14MediumSecondaryTextCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.secondaryText,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font20MediumSecondaryTextCairo => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.secondaryText,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16LightGreyMediumCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.lightGrey,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16InputColorCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.inputColor,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16SecondaryBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font16PrimaryColorMediumCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.primary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18BlackMediumCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 18.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18ButtonMediumCairo => GoogleFonts.cairo(
    color: AppColors.textButton,
    fontSize: 18.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18SecondaryPrimaryCairoMedium => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18BlackCairoMedium => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18secondaryPrimaryMediumCairo => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18SecondaryBlackCairoMedium => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font18SecondaryBlackCairoRegular => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font19DarkGreyMediumCairo => GoogleFonts.cairo(
    color: AppColors.darkGrey,
    fontSize: 19.sp,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font20BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font20BlackCairoMedium => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font23MediumDarkGreyCairo => GoogleFonts.cairo(
    fontSize: 23.sp,
    color: AppColors.darkGrey,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font23LightGreyMediumCairo => GoogleFonts.cairo(
    fontSize: 23.sp,
    color: AppColors.lightGrey,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font23MediumBlackCairo => GoogleFonts.cairo(
    fontSize: 23.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font28BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 28.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font45BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 45.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font36BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 36.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font21BlackMediumCairo => GoogleFonts.cairo(
    fontSize: 21.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font36MediumBlackCairo => GoogleFonts.cairo(
    fontSize: 36.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font24MediumBlackCairo => GoogleFonts.cairo(
    fontSize: 24.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  // --------------------- SEMI-BOLD Text Styles - w600 -------------------

  static TextStyle get font10WhiteSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 10.sp,
    color: Colors.white,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font12GrayCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.grey,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font12DarkGrayCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.darkGrey,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font14DarkGrayCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.darkGrey,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font14BlackCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font18BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 18.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font20BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font20SecondaryBlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font26BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 26.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font28BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 28.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font14BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font16BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font16SecondaryPrimarySemiBoldCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font19SecondaryPrimarySemiBoldCairo => GoogleFonts.cairo(
    fontSize: 19.sp,
    color: AppColors.secondaryPrimary,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font14MontserratNumber => GoogleFonts.montserrat(
    fontSize: 14.sp,
    color: const Color(0xB31A1A1A),
    fontWeight: AppFontWeights.semiBold,
  );

  // --------------------- BOLD Text Styles - w700 -----------------------

  static TextStyle get font12LightGreyBoldCairo => GoogleFonts.cairo(
    fontSize: 12.sp,
    color: AppColors.lightGrey,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font16WhiteBoldCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: Colors.white,
    fontWeight: AppFontWeights.bold,
  );

  static TextStyle get font16PrimaryColorBoldCairo => GoogleFonts.cairo(
    fontSize: 16.sp,
    color: AppColors.primary,
    fontWeight: AppFontWeights.bold,
  );

  static TextStyle get font14PrimaryColorSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 14.sp,
    color: AppColors.primary,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font23PrimaryColorBoldCairo => GoogleFonts.cairo(
    fontSize: 23.sp,
    color: AppColors.primary,
    fontWeight: AppFontWeights.bold,
  );

  static TextStyle get font23WhiteBoldCairo => GoogleFonts.cairo(
    fontSize: 23.sp,
    color: Colors.white,
    fontWeight: AppFontWeights.bold,
  );

  static TextStyle get font20BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font15BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 15.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font25BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 25.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font26BlackCairoRegular => GoogleFonts.cairo(
    fontSize: 26.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.regular,
  );

  static TextStyle get font23BlackSemiBoldCairo => GoogleFonts.cairo(
    color: AppColors.text,
    fontSize: 23.sp,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font30BlackCairoMedium => GoogleFonts.cairo(
    fontSize: 30.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font30BlackCairoSemiBold => GoogleFonts.cairo(
    fontSize: 30.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font35BlackCairoSemiBold => GoogleFonts.cairo(
    fontSize: 35.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font22BlackCairoMedium => GoogleFonts.cairo(
    fontSize: 22.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font22BlackCairoSemiBold => GoogleFonts.cairo(
    fontSize: 22.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font20SecondaryBlackMediumCairo => GoogleFonts.cairo(
    fontSize: 20.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font30SecondaryBlackMediumCairo => GoogleFonts.cairo(
    fontSize: 30.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font25SecondaryBlackMediumCairo => GoogleFonts.cairo(
    fontSize: 25.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.medium,
  );

  static TextStyle get font25SecondaryBlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 25.sp,
    color: AppColors.secondaryBlack,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font30BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 30.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font25BlackSemiBoldCairo => GoogleFonts.cairo(
    fontSize: 25.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );

  static TextStyle get font26BlackCairo => GoogleFonts.cairo(
    fontSize: 26.sp,
    color: AppColors.text,
    fontWeight: AppFontWeights.semiBold,
  );
}