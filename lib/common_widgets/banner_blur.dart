import 'dart:ui';

import 'package:flutter/material.dart';

class BannerBlur extends StatelessWidget {
  final bool showLogo;
  final double heightSize;

  const BannerBlur({
    Key? key, 
    required bool this.showLogo,
    required double this.heightSize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/banner_login.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 32),
            child: Container(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          showLogo ? 
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width / 6,
            ),
            )
          ) : Container(),
          
        ],
      ),
    );
  }
}