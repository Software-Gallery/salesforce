import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/app.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/provider/setting_provider.dart';
import 'package:salesforce/screens/about_screen.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_item.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  String email = '';
  String username = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUserData();
  }

  Future<void> setUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('loginemail') ?? '';
      username = prefs.getString('loginname') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, settingProvider, child) {
        return SafeArea(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading:
                        SizedBox(width: 65, height: 65, child: getImageHeader()),
                    title: AppText(
                      text: username,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: AppText(
                      text: email,
                      color: Color(0xff7C7C7C),
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Column(
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       PageRouteBuilder(
                      //         pageBuilder: (context, animation, secondaryAnimation) => HelpScreen(),
                      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      //           // Mengatur animasi slide
                      //           var begin = Offset(1.0, 0.0); // Mulai dari sebelah kanan
                      //           var end = Offset.zero; // Tujuan ke posisi akhir (ke tengah)
                      //           var curve = Curves.easeInOut;

                      //           var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
                      //           var slideAnimation = animation.drive(tween);

                      //           return SlideTransition(
                      //             position: slideAnimation,
                      //             child: child,
                      //           );
                      //         },
                      //       ),
                      //     );
                      //   },
                      //   // child: getAccountItemWidget(accountItems[0]),
                      //   child: Container(
                      //     color: Colors.white,
                      //     margin: EdgeInsets.symmetric(vertical: 15),
                      //     padding: EdgeInsets.symmetric(horizontal: 25),
                      //     child: Row(
                      //       children: [
                      //         SizedBox(
                      //           width: 20,
                      //           height: 20,
                      //           child: SvgPicture.asset(
                      //             "assets/icons/account_icons/help_icon.svg",
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: AppConfig.appSize(context, .018),
                      //         ),
                      //         Text(
                      //           AppLocalizations.of(context)!.account_help_title,
                      //           style: TextStyle(fontSize: AppConfig.appSize(context, .016), fontWeight: FontWeight.bold),
                      //         ),
                      //         Spacer(),
                      //         Icon(Icons.arrow_forward_ios)
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => AboutScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                // Mengatur animasi slide
                                var begin = Offset(1.0, 0.0); // Mulai dari sebelah kanan
                                var end = Offset.zero; // Tujuan ke posisi akhir (ke tengah)
                                var curve = Curves.easeInOut;

                                var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var slideAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: slideAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 15),
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    "assets/icons/account_icons/about_icon.svg",
                                  ),
                                ),
                                SizedBox(
                                  width: AppConfig.appSize(context, .018),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.account_about_title,
                                  style: TextStyle(fontSize: AppConfig.appSize(context, .016), fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          ),
                      ),
                      padded(
                        Row(
                          children: [
                            SizedBox(
                              width: AppConfig.appSize(context, .018),
                              height: AppConfig.appSize(context, .018),
                              child: SvgPicture.asset(
                                settingProvider.isImageItem 
                                ? "assets/icons/gallery.svg"
                                : "assets/icons/gallery-slash.svg",
                              ),
                            ),
                            SizedBox(
                              width: AppConfig.appSize(context, .018),
                            ),
                            Text("Gambar Barang",  style: TextStyle(fontSize: AppConfig.appSize(context, .016), fontWeight: FontWeight.bold),),
                            Spacer(),
                            Switch(
                              value: settingProvider.isImageItem,
                              onChanged: (value) {
                                settingProvider.toggleisImageItem(value);
                              },
                              activeColor: Colors.orange, // Warna saat switch dalam keadaan ON (true)
                              inactiveTrackColor: Colors.purple, // Warna track saat switch dalam keadaan OFF (false)
                            )
                        
                          ],
                        ),
                      )
                    ]
                    // getChildrenWithSeperator(
                    //   widgets: accountItems.map((e) {
                    //     return getAccountItemWidget(e);
                    //   }).toList(),
                    //   seperator: Divider(
                    //     thickness: 1,
                    //   ),
                    // ),
                  ),
                
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .014)),
                  //   child: LanguageSelector()),
                  SizedBox(
                    height: 12,
                  ),
                  logoutButton(context),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );    
  }

  Widget logoutButton(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          elevation: 0,
          backgroundColor: Color(0xffF2F3F2),
          textStyle: TextStyle(
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 25),
          minimumSize: const Size.fromHeight(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: AppConfig.appSize(context, .02),
              height: AppConfig.appSize(context, .02),
              child: SvgPicture.asset(
                "assets/icons/account_icons/logout_icon.svg",
              ),
            ),
            Text(
              AppLocalizations.of(context)!.account_logout,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: AppConfig.appSize(context, .014),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),
            Container()
          ],
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('email', '');
          prefs.setString('username', '');
          prefs.setInt('loginid', -1);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthPage(),));
        },
      ),
    );
  }

  Widget getImageHeader() {
    String imagePath = "assets/images/user.png";
    return CircleAvatar(
      radius: 5.0,
      backgroundImage: AssetImage(imagePath),
      backgroundColor: AppColors.primaryColor.withOpacity(0.7),
    );
  }

  Widget getAccountItemWidget(AccountItem accountItem) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              accountItem.iconPath,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            accountItem.label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios)
        ],
      ),
    );
  }

  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
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

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.language, color: Colors.black,), // Ganti dengan ikon global yang Anda inginkan
          SizedBox(width: AppConfig.appSize(context, .018)), // Jarak antara ikon dan teks
          Text(
            AppLocalizations.of(context)!.account_about_language,
            style: TextStyle(
              color: Colors.black,
              fontSize: AppConfig.appSize(context, .016),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      children: [
        ListTile(
          title: Text(
            'English', 
            style: 
            _selectedLanguage == 'en'
            ? TextStyle(
              color: AppColors.accentColor,
              fontWeight: FontWeight.bold
            )
            : TextStyle(
              color: Colors.black,
            ),
          ),
          onTap: () => _changeLanguage('en'),
          selected: _selectedLanguage == 'en',
        ),
        ListTile(
          // title: Text('Bahasa Indonesia'),
          title: Text(
            'Indonesia', 
            style: 
            _selectedLanguage == 'id'
            ? TextStyle(
              color: AppColors.accentColor,
              fontWeight: FontWeight.bold
            )
            : TextStyle(
              color: Colors.black,
            ),
          ),
          onTap: () => _changeLanguage('id'),
          selected: _selectedLanguage == 'id',
        ),
      ],
      tilePadding: EdgeInsets.all(8.0),
      expandedAlignment: Alignment.centerLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      // backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        // side: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}