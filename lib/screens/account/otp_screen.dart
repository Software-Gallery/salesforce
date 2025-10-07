import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/banner_blur.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final String imagePath = "assets/images/welcome_image.png";
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool cb_privacypolicy = false;
  bool isLoading = false;
  bool isCooldown = false; 
  int cooldownTime = 30; 
  Timer? timer; 
  bool isSendCode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AuthService().sendEmailVerification();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startCooldown() {
    setState(() {
      isCooldown = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (cooldownTime > 0) {
        setState(() {
          cooldownTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          isCooldown = false;
          cooldownTime = 30;
        });
      }
    });
  }

  Future<void> sendEmailVerification() async {
    setState(() {
      isLoading = true;
    });
    await AuthService().sendEmailVerification();
    setState(() {
      isLoading = false;
    });
    startCooldown();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Banner
          IgnorePointer(
            child: BannerBlur(
              showLogo: false,
              heightSize: MediaQuery.of(context).size.height / 3,
            ),
          ),
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 5, // Space below the banner
                left: 25,
                right: 25,
                bottom: MediaQuery.of(context).size.height / 1,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your 6-digit code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Your OTP code has been sent to your email. Please check your inbox.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.grey),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _codeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: "Code",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey, // Label tetap abu-abu
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12, // Garis bawah hitam saat tidak fokus
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12, // Garis bawah hitam saat fokus
                          ),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Code tidak boleh kosong"; // Pesan validasi
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0, // Ukuran teks lebih besar
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6, // Batas input 6 digit
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppConfig.appSize(context, .015),
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: isCooldown ? null : () async {
                      print('Resend Code');
                      await sendEmailVerification();
                    },
                    child: 
                    isLoading
                    ? TweenAnimationBuilder<Color?>(
                      tween: ColorTween(begin: Colors.grey, end: Colors.black),
                      duration: const Duration(seconds: 1),
                      builder: (context, color, child) {
                        return Text(
                          'Sending',
                          style: TextStyle(color: color),
                        );
                      },
                      onEnd: () {
                        setState(() {});
                      },
                    )
                    : Text(
                      isCooldown ? 'Wait $cooldownTime seconds' : 'Resend Code',
                      style: TextStyle(
                        color: isCooldown ? Colors.grey : AppColors.secondaryColor,
                        fontSize: AppConfig.appSize(context, .013),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          isSendCode = true;
                        });
                        await AuthService().verifyEmail(_codeController.text).then((value) {
                            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                            builder: (BuildContext context) {
                              return DashboardScreen();
                            },
                          ));
                        });
                        setState(() {
                          isSendCode = false;
                        }); 
                      } catch (e) {
                        Utils.showActionSnackBar(context: context,showLoad: true,text: e.toString());
                      }
                    },
                    color: AppColors.secondaryColor,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(AppConfig.appSize(context, .015)),
                    child: 
                    isSendCode
                    ? Container(
                      width: AppConfig.appSize(context, .02),
                      height: AppConfig.appSize(context, .02),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )
                    )
                    : 
                    FaIcon(
                      FontAwesomeIcons.arrowRight,
                      color: Colors.white,
                      size: AppConfig.appSize(context, .02),  
                    ),
                    // Icon(
                    //   Icons.keyboard_arrow_right_rounded,
                    //   color: Colors.white,
                    //   size: AppConfig.appSize(context, .02),
                    // ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned(
          //   top: AppConfig.appSize(context, .03),
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       SizedBox(width: AppConfig.appSize(context, .016),),
          //       GestureDetector(
          //         onTap: () {
          //           Navigator.of(context).pop();
          //         },
          //         child: Icon(Icons.keyboard_arrow_left_rounded,
          //         size: AppConfig.appSize(context, .034),),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget icon() {
    String iconPath = "assets/icons/app_icon.svg";
    return SvgPicture.asset(
      iconPath,
      width: 48,
      height: 56,
    );
  }

  Widget welcomeTextWidget() {
    return Column(
      children: [
        AppText(
          text: "Welcome",
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        AppText(
          text: "to our store",
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget sloganText() {
    return AppText(
      text: "Get your grecories as fast as in hour",
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xffFCFCFC).withOpacity(0.7),
    );
  }

  Widget okButton(BuildContext context) {
    return AppButton(
      label: "Sign Up",
      fontWeight: FontWeight.w600,
      padding: EdgeInsets.symmetric(vertical: 25),
      onPressed: () {
        //onGetStartedClicked(context);
      },
    );
  }

  void onGetStartedClicked(BuildContext context) {
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
      builder: (BuildContext context) {
        return DashboardScreen();
      },
    ));
  }

  Widget alreadyText() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Menjaga teks sejajar di tengah
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Aksi ketika "Sign In" ditekan
            // Misalnya, navigasi ke halaman sign in
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => SignInPage()),
            // );
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.green, // Warna hijau
            ),
          ),
        ),
      ],
    );
  }

  Widget byContinuingText() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'By continuing you agree to our ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.green, // Warna hijau
            ),
            recognizer: TapGestureRecognizer() // Membuat teks ini dapat ditekan
              ..onTap = () {
                // Aksi saat "Terms of Service" ditekan
                // Misalnya, tampilkan dialog atau navigasi ke halaman tertentu
                print('Terms of Service tapped');
              },
          ),
          const TextSpan(
            text: ' and ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.green, // Warna hijau
            ),
            recognizer: TapGestureRecognizer() // Membuat teks ini dapat ditekan
              ..onTap = () {
                // Aksi saat "Privacy Policy" ditekan
                print('Privacy Policy tapped');
              },
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}
