// ******************* FILE INFO *******************
// File Name: c.dart
// Description: Private constants/enums for Home main
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_main

part of '../../pages/home_main.dart';
/// Strip leading slash for display
String _displayRoute(String route) {
  if (route.isEmpty) return 'None';
  return route.startsWith('/') ? route.substring(1) : route;
}
