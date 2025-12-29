import 'package:flutter/material.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/provider/CurrentVisitProvider.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/provider/TrnSalesOrderDetailProvider.dart';
import 'package:salesforce/provider/TrnSalesOrderHeaderProvider.dart';
import 'package:salesforce/provider/setting_provider.dart';
import 'package:salesforce/screens/splash_screen.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/theme.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findRootAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BarangProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TrmSalesOrderDetailProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TrmSalesOrderHeaderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RuteProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Sales Force',
        theme: themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        home: SplashScreen(),
        // home: UpgradeAlert(
        //   barrierDismissible: false,
        //   showIgnore: true,
        //   showLater: true,
        //   dialogStyle: UpgradeDialogStyle.material,
        //   upgrader: Upgrader(
        //     messages: UpgraderMessages(code: 'Tesssss'),
        //     willDisplayUpgrade: ({required display, installedVersion, versionInfo}) => true,                        
        //     debugLogging: true,        
        //     minAppVersion: '9.9.9',
        //   ),
        //   // child: SplashScreen()
        //   child: AuthService().handleAuthState(),
        // ),
      ),
    );
  }
}
