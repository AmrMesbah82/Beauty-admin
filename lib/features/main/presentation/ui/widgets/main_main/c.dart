// ******************* FILE INFO *******************
// File Name: c.dart
// Description: Private constants/enums for Main main
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › main › presentation › ui › widget › main_main

part of '../../pages/main_main.dart';
/// Strip leading slash for display
String _displayRoute(String route) {
  if (route.isEmpty) return 'None';
  return route.startsWith('/') ? route.substring(1) : route;
}
