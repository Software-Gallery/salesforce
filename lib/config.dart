
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConfig {
  //One instance, needs factory
  static AppConfig? _instance;
  factory AppConfig() => _instance ??= AppConfig._();

  AppConfig._();

  static const api_ip = 'https://dspapps.my.id';
  // static const api_ip = 'https://apihappyshop.vys-organizer.com';
  // static const api_ip = 'http://192.168.8.224';
  static const api_port = '';
  static String formatNumber(double number) {
    String formattedNumber = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
    return formattedNumber;
  }

  static double appSize(BuildContext context, double sizeOfScreen) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return (_width * sizeOfScreen) + (_height * sizeOfScreen);
  }
}
