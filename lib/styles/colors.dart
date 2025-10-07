import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  //One instance, needs factory
  static AppColors? _instance;
  factory AppColors() => _instance ??= AppColors._();

  AppColors._();

  static const primaryColor = Color(0xffff6600);
  static const secondaryColor = Color(0xff90d24e);
  static const darkSecondaryColor = Color.fromARGB(255, 60, 141, 64);
  static const accentColor = Color(0xff604bc4);
  static const bgColor = Color(0xfff5f5f5);
  static const darkGrey = Color(0xff7C7C7C);
  static const grey = Color(0xfff4f4f4);
}
