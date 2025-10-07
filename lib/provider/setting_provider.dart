import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider with ChangeNotifier {
  String versi = '';
  String server = '';

  Future<void> setUserData(String versi, String server) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.versi = versi;
    this.server = server;
    prefs.setString('CURRENTSETTING', server);
    notifyListeners();
  }

  Future<void> setServer(String server) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.server = server;
    prefs.setString('CURRENTSETTING', server);
    notifyListeners();
  }
}
