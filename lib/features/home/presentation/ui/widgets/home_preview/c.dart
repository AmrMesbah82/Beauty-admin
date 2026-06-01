// ******************* FILE INFO *******************
// File Name: c.dart
// Description: Private constants/enums for Home preview
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › home › presentation › ui › widget › home_preview

part of '../../pages/home_preview.dart';
enum _PreviewDevice { desktop, tablet, mobile }

// ── Viewport constants ────────────────────────────────────────────────────────
const double _kDesktopW = 1366.0;
const double _kDesktopH =  768.0;

const double _kTabletW  =  768.0;
const double _kTabletH  = 1024.0;

const double _kMobileW  =  375.0;
const double _kMobileH  =  812.0;

double _safeScale(double v) =>
    (v.isFinite && !v.isNaN && v > 0) ? v : 1.0;
