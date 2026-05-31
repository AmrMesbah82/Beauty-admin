// ******************* FILE INFO *******************
// File Name: space.dart
// Description: Spacing/gap widgets
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › widget

// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024
// Objectives: This file is responsible for providing helper widgets for spacing.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Vertical spacing
SizedBox verticalSpace(double height) {
  return SizedBox(
    height: height.h,
  );
}

// Horizontal spacing
SizedBox horizontalSpace(double width) {
  return SizedBox(
    width: width.w,
  );
}
