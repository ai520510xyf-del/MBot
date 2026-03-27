import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MBot Mobile 阴影系统
class AppShadow {
  AppShadow._();

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x8030363D),
      spreadRadius: 0,
      blurRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x4D000000),
      spreadRadius: 0,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x66000000),
      spreadRadius: 0,
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x4D000000),
      spreadRadius: 0,
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x80000000),
      spreadRadius: 0,
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x4D000000),
      spreadRadius: 0,
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x99000000),
      spreadRadius: 0,
      blurRadius: 25,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x66000000),
      spreadRadius: 0,
      blurRadius: 10,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: AppColors.primaryGlow,
      spreadRadius: 0,
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];
}
