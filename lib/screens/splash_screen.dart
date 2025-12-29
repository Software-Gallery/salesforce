import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/screens/home/home_screen.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/colors.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    const delay = const Duration(seconds: 3);
    Future.delayed(delay, () => onTimerFinished());
  }

  void onTimerFinished() {
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
      builder: (BuildContext context) {
        // return AuthPage();
        return AuthService().handleAuthState();
        // return DashboardScreen();
        // return HomeScreen();
        // return AuthPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          welcomeTextWidget(),
          // splashScreenIcon(context),
        ],) 
      ),
    );
  }
}

Widget splashScreenIcon(BuildContext context) {
  String iconPath = "assets/images/logo.png";
  return Image.asset(
    iconPath,
    width: MediaQuery.of(context).size.width / 3,
  );
}
  Widget welcomeTextWidget() {
    return Column(
      children: [
        AppText(
          text: "Sales Force",
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        AppText(
          text: "Application",
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        
      ],
    );
  }
