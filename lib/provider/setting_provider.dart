import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider with ChangeNotifier {
  String versi = '';
  String server = '';

  bool isImageItem = false;

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

  Future<bool> toggleisImageItem(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isImageItem = newValue;
    notifyListeners();
    prefs.setBool('SETTINGISIMAGEITEM', newValue);

    return isImageItem;
  }  
}
