import 'package:flutter/material.dart';
import 'package:salesforce/screens/account/account_screen.dart';
import 'package:salesforce/screens/histori_screen.dart';
import 'package:salesforce/screens/home/home_screen.dart';



class NavigatorItem {
  final String label;
  final String iconPath;
  final int index;
  final Widget screen;

    NavigatorItem(this.label, this.iconPath, this.index, this.screen);
}

List<NavigatorItem> navigatorItems = [
  NavigatorItem("Beranda", "assets/icons/shop_icon.svg", 0, HomeScreen()),
  NavigatorItem("Histori", "assets/icons/refresh.svg", 1, HistoriScreen()),
  NavigatorItem("Akun", "assets/icons/account_icon.svg", 2, AccountScreen()),
  // NavigatorItem("Promo", "assets/icons/promo_icon.svg", 1, PromoScreen()),
  // NavigatorItem("Belanja", "assets/icons/bag_icon.svg", 2, BelanjaScreen()),
  // NavigatorItem("Aktvitas", "assets/icons/file_icon.svg", 3, AktifitasScreen()),
];
