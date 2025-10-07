import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salesforce/app.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/banner_blur.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/screens/home/home_screen.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final Function() onClickedSignUp;
  const LoginScreen({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    
    String _selectedLanguage = 'en';   

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

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // BannerBlur(showLogo: true,heightSize: MediaQuery.of(context).size.height / 3.6,),
                Image.asset("assets/images/login_header.jpg"),
                // SizedBox(
                //   width: double.infinity,
                //   height: AppConfig.appSize(context, .16), // Atur tinggi sesuai kebutuhan
                //   child: SvgPicture.asset(
                //     "assets/images/login_header.svg",
                //     fit: BoxFit.cover, // Sesuaikan dengan layout yang kamu inginkan
                //   ),
                // ),
                SizedBox(height: AppConfig.appSize(context, .04),),
                LogoApp(),                
                SizedBox(height: AppConfig.appSize(context, .04),),
                Form(
                  key: _formKey,
                  child: Padding(padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)), child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.login_header,
                        style: TextStyle(fontSize: AppConfig.appSize(context, .025) , fontWeight: FontWeight.w600,),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        AppLocalizations.of(context)!.login_subheader,
                        style: TextStyle(fontSize: AppConfig.appSize(context, .015), fontWeight: FontWeight.w500,color: Colors.grey),
                        textAlign: TextAlign.start,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey, // Label tetap abu-abu, baik saat fokus maupun tidak
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12), // Garis bawah hitam saat tidak fokus
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12), // Garis bawah hitam saat fokus
                          ),
                          //suffixIcon: Icon(Icons.check)
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email tidak boleh kosong";
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Masukkan email yang valid";
                          }
                          return null; // Tidak ada error
                        },
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, // Teks input bold
                          fontSize: 20.0, // Ukuran teks sedikit lebih besar
                        ),
                      ),
                      SizedBox(height: 18,),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured, // Password disembunyikan atau ditampilkan
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey, // Label tetap abu-abu, baik saat fokus maupun tidak
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12), // Garis bawah hitam saat tidak fokus
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12), // Garis bawah hitam saat fokus
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility : Icons.visibility_off, // Ikon mata
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured; // Mengubah visibilitas password
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
                          return null; // Tidak ada error
                        },
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, // Teks input bold
                          fontSize: 20.0, // Ukuran teks sedikit lebih besar
                        ),
                      ),
                      SizedBox(height: 20,),
                      okButton(context),
                      // SizedBox(height: 15,),
                      // alreadyText()
                    ],
                  ),)
                ),
              ],
            ),
            // Positioned(
            //   top: AppConfig.appSize(context, .028),
            //   left: 0,
            //   right: 0,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       LanguageSelector()
            //     ],
            //   )
            // ),
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
          // final isValid = _formKey.currentState!.validate();
          // if (!isValid) return ;
          setState(() {
            isLoad = true;
          });
          // await onGetStartedClicked(context);
          // 23/09/2025 Ini diakali, harus dihapus waktu sudah bisa auth nya
          setState(() {
            isLoad = false;
          });
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) {
              return DashboardScreen();
              // return HomeScreen();
            },
          ));
          // final prefs = await SharedPreferences.getInstance();
          // print(prefs.getString('message'));
          // print(prefs.getString('username'));
          // print(prefs.getInt('iduser'));
          // prefs.setString('email', _emailController.text);
          // prefs.setString('iduser', _emailController.text);
          // Navigator.of(context).push(new MaterialPageRoute(
          //   builder: (BuildContext context) {
          //     // return OTPScreen();
          //     return DashboardScreen();
          //   },
          // ));
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
          AppLocalizations.of(context)!.login_button_label,
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
      await AuthService().auth(_emailController.text, _passwordController.text);
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) {
          return DashboardScreen();
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
          AppLocalizations.of(context)!.dont_have_acocunt,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.onClickedSignUp();
          },
          child: Text(
            ' ' + AppLocalizations.of(context)!.dont_have_acocunt_link,
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

class LogoApp extends StatelessWidget {
  const LogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kotak dengan huruf A dan titik
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Tulisan SALES FORCE
        const Text(
          'ALES FORCE',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}