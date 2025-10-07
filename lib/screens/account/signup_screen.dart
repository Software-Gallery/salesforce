import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/app.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/banner_blur.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/screens/account/otp_screen.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  final Function() onClickedSignIn;
  const SignUpScreen({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final String imagePath = "assets/images/welcome_image.png";
  final _formKey = GlobalKey<FormState>();
    final _usernameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool cb_privacypolicy = false;
    bool _isObscured = true;
    bool isLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // Banner
                BannerBlur(showLogo: true,heightSize: MediaQuery.of(context).size.height / 3.6,),
                Form(
                  key: _formKey,
                  child: Padding(padding: EdgeInsets.symmetric(horizontal: 25), child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.signup_header,
                        style: TextStyle(fontSize: AppConfig.appSize(context, .025), fontWeight: FontWeight.w600,),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        AppLocalizations.of(context)!.signup_subheader,
                        style: TextStyle(fontSize: AppConfig.appSize(context, .015), fontWeight: FontWeight.w500,color: Colors.grey),
                        textAlign: TextAlign.start,
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12), 
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) =>
                            value != null && value.isEmpty ? "Username tidak boleh kosong" : null,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 20.0, 
                        ),
                      ),
                      SizedBox(height: 18,),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email tidak boleh kosong";
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Masukkan email yang valid";
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(height: 18,),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password tidak boleh kosong";
                          } else if (value.length < 8) {
                            return "Password minimal 8 karakter";
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(height: 20,),
                      okButton(context),
                      SizedBox(height: 15,),
                      alreadyText()
                    ],
                  ),)
                ),
              ],
            ),
            Positioned(
              top: AppConfig.appSize(context, .028),
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LanguageSelector()
                ],
              )
            ),
          ],
        ),
      )
    );
  }

  Widget okButton(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: AppConfig.appSize(context, .05),
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (!isValid) return ;
          setState(() {
            isLoad = true;
          });
          await onGetStartedClicked(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          // padding: EdgeInsets.symmetric(vertical: AppConfig.appSize(context, .01)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.appSize(context, .02)), // <-- Radius
          ),
        ), 
        child: 
        isLoad
        ? Container(
          width: AppConfig.appSize(context, .02),
          height: AppConfig.appSize(context, .02),
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
        : Text(
          AppLocalizations.of(context)!.signup_button_label,
          style: TextStyle(
            fontSize: AppConfig.appSize(context, .016),
            color: Colors.white,
            fontWeight: FontWeight.w600
          ),
        )
      ),
    );
  }  

  Future<void> onGetStartedClicked(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';
      await AuthService().signUp(
        email: _emailController.text, 
        pass: _passwordController.text, 
        username: _usernameController.text);
      setState(() {
        isLoad=false;
      });
      Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return OTPScreen();
        },
      ));
    } catch (e) {
      Utils.showActionSnackBar(context: context,showLoad: true,text: e.toString()); 
      setState(() {
        isLoad=false;
      });
    }
  }  
  
  Widget alreadyText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Menjaga teks sejajar di tengah
      children: [
        Text(
          AppLocalizations.of(context)!.already_have_account,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.onClickedSignIn();
          },
          child: Text(
            ' ' + AppLocalizations.of(context)!.already_have_account_link,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryColor, // Warna hijau
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

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _selectedLanguage = 'en'; // Bahasa default

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);

    Locale newLocale = Locale(languageCode);
    MyApp.setLocale(context, newLocale);
  }

  void _showLanguageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'English',
                  style: _selectedLanguage == 'en'
                      ? TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        )
                      : TextStyle(
                          color: Colors.black,
                        ),
                ),
                onTap: () {
                  _changeLanguage('en');
                  Navigator.pop(context); // Close the modal after selection
                },
                selected: _selectedLanguage == 'en',
              ),
              ListTile(
                title: Text(
                  'Indonesia',
                  style: _selectedLanguage == 'id'
                      ? TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        )
                      : TextStyle(
                          color: Colors.black,
                        ),
                ),
                onTap: () {
                  _changeLanguage('id');
                  Navigator.pop(context); // Close the modal after selection
                },
                selected: _selectedLanguage == 'id',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: _showLanguageOptions,
      color: Colors.white, // Set button background color
      child: Icon(
        Icons.language,
        color: AppColors.primaryColor, // Set your preferred color for the globe icon
      ),
      padding: EdgeInsets.all(8.0), // Adjust the padding as needed
      shape: CircleBorder(), // Optional: make it circular like IconButton
    );
  }
}
