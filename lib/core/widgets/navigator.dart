// ******************* FILE INFO *******************
// File Name: navigator.dart
// Description: Navigation helper extensions
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: core › widget

import 'package:flutter/material.dart';

void navigateTo(context, widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

//=======================================================================================================================================================

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
    context, MaterialPageRoute(builder: (context) => widget), (route) => false);

//=======================================================================================================================================================