import 'package:flutter/material.dart';
import 'package:salesforce/screens/account/account_screen.dart';
import 'package:salesforce/screens/histori_screen.dart';
import 'package:salesforce/screens/home/home_screen.dart';
import 'package:salesforce/screens/summary_screen.dart';



class NavigatorItem {
  final String label;
  final String iconPath;
  final int index;
  final Widget screen;

    NavigatorItem(this.label, this.iconPath, this.index, this.screen);
}

List<NavigatorItem> navigatorItems = [
  NavigatorItem("Beranda", "assets/icons/home-bold.svg", 0, HomeScreen()),
  // NavigatorItem("Histori", "assets/icons/note-bold.svg", 1, HistoriScreen()),
  NavigatorItem("Histori", "assets/icons/note-bold.svg", 1, SummaryScreen()),
  NavigatorItem("Akun", "assets/icons/user-bold.svg", 2, AccountScreen()),
  // NavigatorItem("Promo", "assets/icons/promo_icon.svg", 1, PromoScreen()),
  // NavigatorItem("Belanja", "assets/icons/bag_icon.svg", 2, BelanjaScreen()),
  // NavigatorItem("Aktvitas", "assets/icons/file_icon.svg", 3, AktifitasScreen()),
];
